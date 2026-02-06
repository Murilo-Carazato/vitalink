<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\SecurityLogService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Log; // Added for debugging
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    protected $firebaseAuth;

    public function __construct(FirebaseAuth $firebaseAuth)
    {
        $this->firebaseAuth = $firebaseAuth;
    }

    /**
     * Handle traditional login with email verification.
     */
    public function store(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        // Rate limiting
        $this->ensureIsNotRateLimited($request);

        $user = User::where('email', $request->email)
                   ->where('is_active', true)
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            RateLimiter::hit($this->throttleKey($request));
            throw ValidationException::withMessages([
                'email' => ['Credenciais inválidas.'],
            ]);
        }

        // Check email verification
        if (!$user->hasVerifiedEmail()) {
            throw ValidationException::withMessages([
                'email' => ['Por favor, verifique seu email antes de fazer login.'],
            ]);
        }

        // Update last login
        $user->updateLastLogin();

        // Clear rate limiting
        RateLimiter::clear($this->throttleKey($request));

        return response()->json([
            'message' => 'Login realizado com sucesso',
            'token' => $user->createToken($request->email)->plainTextToken,
            'user' => $user->getPublicProfile(),
        ], Response::HTTP_OK);
    }

    /**
     * Handle Google login with Firebase verification.
     */
    public function handleGoogleCallback(Request $request)
    {
        // Debug: initial request information
        Log::info('Google login attempt', [
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            // Do NOT log entire token for security; just first 15 chars
            'token_start' => substr($request->idToken ?? '', 0, 15)
        ]);


        $request->validate([
            'idToken' => 'required|string',
        ]);

        try {
            $verifiedIdToken = $this->firebaseAuth->verifyIdToken($request->idToken);
        } catch (\Exception $e) {
            Log::warning('Firebase token verification failed', ['exception' => $e->getMessage()]);
            SecurityLogService::logSecurityViolation('invalid_firebase_token', [
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'message' => 'Token do Firebase inválido'
            ], Response::HTTP_UNAUTHORIZED);
        }

        // Log token claims for debugging (no sensitive user info)
        Log::info('Firebase token verified', [
            'uid' => $verifiedIdToken->claims()->get('sub'),
            'email' => $verifiedIdToken->claims()->get('email'),
            'issuer' => $verifiedIdToken->claims()->get('iss'),
            'aud' => $verifiedIdToken->claims()->get('aud')
        ]);

        $uid = $verifiedIdToken->claims()->get('sub');
        $email = $verifiedIdToken->claims()->get('email');
        $emailVerified = $verifiedIdToken->claims()->get('email_verified');
        $issuer = $verifiedIdToken->claims()->get('iss');
        $audience = $verifiedIdToken->claims()->get('aud');
        
        // Additional security validations
        if (!$email || !$emailVerified) {
            SecurityLogService::logSecurityViolation('unverified_google_email', [
                'email' => $email,
                'email_verified' => $emailVerified
            ]);
            
            return response()->json([
                'message' => 'Email não verificado no Google'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
        
        // Validate issuer (Firebase returns https://securetoken.google.com/<project-id>)
        $expectedIssuer = 'https://securetoken.google.com/'.env('FIREBASE_PROJECT_ID');
        if ($issuer !== $expectedIssuer && !str_contains($issuer, 'accounts.google.com')) {
            SecurityLogService::logSecurityViolation('invalid_token_issuer', [
                'issuer' => $issuer
            ]);
            
            return response()->json([
                'message' => 'Token inválido'
            ], Response::HTTP_UNAUTHORIZED);
        }
        
        // Check token expiration (verifyIdToken already checks, but we log if close)
        $expClaim = $verifiedIdToken->claims()->get('exp');
        $expTs = $expClaim instanceof \DateTimeInterface ? $expClaim->getTimestamp() : $expClaim;
        if ($expTs && $expTs < time()) {
            SecurityLogService::logSecurityViolation('expired_google_token', [
                'exp' => $expTs,
                'current_time' => time()
            ]);
            
            return response()->json([
                'message' => 'Token expirado'
            ], Response::HTTP_UNAUTHORIZED);
        }

        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'password' => Hash::make(Str::random(24)),
                'isadmin' => 'user', // Default to regular user
                'email_verified_at' => now(), // Auto-verify Google users
                'is_active' => true,
            ]
        );

        // Update last login
        $user->updateLastLogin();
        
        // Log successful Google login
        SecurityLogService::logAuthEvent('google_login_success', [
            'user_id' => $user->id,
            'firebase_uid' => $uid
        ]);

        // Create token with expiration
        $token = $user->createToken(
            'google_auth_token',
            ['*'],
            now()->addHours(24)
        );

        return response()->json([
            'message' => 'Login com Google realizado com sucesso',
            'token' => $token->plainTextToken,
            'user' => $user->getPublicProfile(),
        ], Response::HTTP_OK);
    }

    /**
     * Check if user has a new token available and return it
     */
    public function checkTokenRefresh(Request $request)
    {
        $user = $request->user();
        $cacheKey = "new_token_{$user->id}";
        
        $newTokenData = Cache::get($cacheKey);
        
        if ($newTokenData) {
            // Clear the cache after retrieving
            Cache::forget($cacheKey);
            
            return response()->json([
                'token_refreshed' => true,
                'access_token' => $newTokenData['token'],
                'expires_at' => $newTokenData['expires_at'],
                'created_at' => $newTokenData['created_at']
            ]);
        }
        
        return response()->json(['token_refreshed' => false]);
    }

    /**
     * Logout user (revoke token)
     */
    public function logout(Request $request)
    {
        $user = $request->user();
        
        // Revoke current token
        $request->user()->currentAccessToken()->delete();
        
        // Clear any pending refresh tokens
        Cache::forget("new_token_{$user->id}");
        
        return response()->json(['message' => 'Token revogado com sucesso'], Response::HTTP_OK);
    }

    /**
     * Handle logout.
     */
    public function destroy(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout realizado com sucesso',
        ], Response::HTTP_OK);
    }

    /**
     * Send email verification.
     */
    public function sendVerificationEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Usuário não encontrado.'
            ], Response::HTTP_NOT_FOUND);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Email já verificado.'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $user->sendEmailVerificationNotification();

        return response()->json([
            'message' => 'Email de verificação enviado com sucesso.'
        ], Response::HTTP_OK);
    }

    /**
     * Verify email with token.
     */
    public function verifyEmail(Request $request, $id, $hash)
    {
        $user = User::findOrFail($id);

        if (!hash_equals(
            sha1($user->getEmailForVerification()),
            $hash
        )) {
            return response()->json([
                'message' => 'Link de verificação inválido.'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Email já verificado.'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $user->markEmailAsVerified();

        return response()->json([
            'message' => 'Email verificado com sucesso.'
        ], Response::HTTP_OK);
    }

    /**
     * Ensure the request is not rate limited.
     */
    protected function ensureIsNotRateLimited(Request $request): void
    {
        if (!RateLimiter::tooManyAttempts($this->throttleKey($request), 5)) {
            return;
        }

        $seconds = RateLimiter::availableIn($this->throttleKey($request));

        throw ValidationException::withMessages([
            'email' => trans('auth.throttle', [
                'seconds' => $seconds,
                'minutes' => ceil($seconds / 60),
            ]),
        ]);
    }

    /**
     * Get the rate limiting throttle key for the request.
     */
    protected function throttleKey(Request $request): string
    {
        return Str::transliterate(Str::lower($request->input('email')).'|'.$request->ip());
    }
}
