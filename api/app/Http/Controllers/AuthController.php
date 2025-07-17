<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\RateLimiter;
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
        $request->validate([
            'idToken' => 'required|string',
        ]);

        try {
            $verifiedIdToken = $this->firebaseAuth->verifyIdToken($request->idToken);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Token do Firebase inválido: ' . $e->getMessage()
            ], Response::HTTP_UNAUTHORIZED);
        }

        $uid = $verifiedIdToken->claims()->get('sub');
        $firebaseUser = $this->firebaseAuth->getUser($uid);

        // Check if email is verified in Firebase
        if (!$firebaseUser->emailVerified) {
            return response()->json([
                'message' => 'Por favor, verifique seu email no Google antes de continuar.'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $user = User::updateOrCreate(
            ['email' => $firebaseUser->email],
            [
                'password' => Hash::make(Str::random(24)),
                'isadmin' => 'user', // Default to regular user
                'email_verified_at' => now(), // Auto-verify Google users
                'is_active' => true,
            ]
        );

        // Update last login
        $user->updateLastLogin();

        return response()->json([
            'message' => 'Login com Google realizado com sucesso',
            'token' => $user->createToken($firebaseUser->email)->plainTextToken,
            'user' => $user->getPublicProfile(),
        ], Response::HTTP_OK);
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
