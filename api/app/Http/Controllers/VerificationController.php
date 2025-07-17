<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Auth\Events\Verified;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\RateLimiter;
use Symfony\Component\HttpFoundation\Response;

class VerificationController extends Controller
{
    /**
     * Display email verification notice.
     */
    public function notice()
    {
        return response()->json([
            'message' => 'Please verify your email address to continue.'
        ]);
    }

    /**
     * Send email verification notification.
     */
    public function send(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Nenhum usuário encontrado com este email.'
            ], Response::HTTP_NOT_FOUND);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Este email já foi verificado.'
            ]);
        }

        // Limita o número de tentativas para evitar spam
        if (RateLimiter::tooManyAttempts('verification:'.$user->id, 3)) {
            $seconds = RateLimiter::availableIn('verification:'.$user->id);
            return response()->json([
                'message' => 'Muitas tentativas. Por favor, tente novamente em ' . ceil($seconds / 60) . ' minutos.'
            ], Response::HTTP_TOO_MANY_REQUESTS);
        }

        // Incrementa o contador de tentativas
        RateLimiter::hit('verification:'.$user->id, 3600); // 1 hora de bloqueio após 3 tentativas

        // Envia a notificação de verificação
        $user->sendEmailVerificationNotification();

        return response()->json([
            'message' => 'Verification link sent successfully.'
        ]);
    }

    /**
     * Check email verification status.
     */
    public function checkStatus(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Nenhum usuário encontrado com este email.',
                'email_verified' => false
            ], Response::HTTP_NOT_FOUND);
        }

        // Verifica se o email está verificado
        $isVerified = $user->hasVerifiedEmail();
        
        // Se não estiver verificado, verifica se há um token de verificação pendente
        if (!$isVerified) {
            $hasPendingVerification = $user->verificationTokens()
                ->where('created_at', '>', now()->subDay())
                ->exists();
                
            return response()->json([
                'email_verified' => false,
                'has_pending_verification' => $hasPendingVerification,
                'can_resend' => !RateLimiter::tooManyAttempts('verification:'.$user->id, 3)
            ]);
        }

        return response()->json([
            'email_verified' => true
        ]);
    }

    /**
     * Mark the user's email as verified.
     */
    public function verify(Request $request, $id, $hash)
    {
        $user = User::findOrFail($id);

        // Verifica se o hash corresponde ao email do usuário
        if (!hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
            return response()->json([
                'message' => 'Link de verificação inválido.'
            ], Response::HTTP_BAD_REQUEST);
        }

        // Verifica se o link expirou (24 horas)
        $expires = $request->query('expires');
        if (now()->getTimestamp() > $expires) {
            return response()->json([
                'message' => 'Este link de verificação expirou. Por favor, solicite um novo.'
            ], Response::HTTP_BAD_REQUEST);
        }

        // Verifica a assinatura do URL
        

        // Se o email já está verificado, retorna sucesso sem fazer nada
        if ($user->hasVerifiedEmail()) {
            return $this->redirectWithToken($user);
        }

        // Marca o email como verificado
        if ($user->markEmailAsVerified()) {
            event(new Verified($user));
            
            // Invalida quaisquer tokens de verificação antigos
            $user->verificationTokens()->delete();
        }

        return $this->redirectWithToken($user);
    }
    
    /**
     * Redireciona para o app com um token de autenticação
     */
    protected function redirectWithToken($user)
    {
        // Cria um token de acesso temporário
        $token = $user->createToken('email-verification', ['*'], now()->addMinutes(5))->plainTextToken;
        
        // Redireciona para o app com o token
        $deepLink = 'vitalink://app/email-verified?token=' . urlencode($token);

        // Se o user-agent for navegador (sem suporte ao esquema), mostra HTML e faz refresh
        if (str_contains(request()->header('User-Agent') ?? '', 'Mozilla')) {
            return response()->view('verify-redirect', ['deepLink' => $deepLink]);
        }

        return redirect()->away($deepLink);
    }

    /**
     * Verifica a assinatura da URL de verificação.
     * Mantido para compatibilidade com versões antigas.
     */
    private function verifyUrl($url, $user)
    {
        $parsedUrl = parse_url($url);
        if (!isset($parsedUrl['query'])) {
            return false;
        }

        parse_str($parsedUrl['query'], $query);

        if (!isset($query['expires']) || !isset($query['signature'])) {
            return false;
        }

        // Verifica se a URL expirou
        if (Carbon::now()->getTimestamp() > $query['expires']) {
            return false;
        }

        // Usa o verificador de assinatura do Laravel
        $request = Request::create($url);
        return $request->hasValidSignature();
    }
} 