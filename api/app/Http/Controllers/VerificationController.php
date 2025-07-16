<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Auth\Events\Verified;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;
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
                'message' => 'User not found.'
            ], Response::HTTP_NOT_FOUND);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Email already verified.'
            ]);
        }

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
                'message' => 'User not found.',
                'email_verified' => false
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'email_verified' => $user->hasVerifiedEmail()
        ]);
    }

    /**
     * Mark the user's email as verified.
     */
    public function verify(Request $request, $id, $hash)
    {
        $user = User::findOrFail($id);

        // Check if URL is properly signed
        $currentUrl = $request->fullUrl();
        
        if (!$this->verifyUrl($currentUrl, $user)) {
            return response()->json([
                'message' => 'Invalid verification link.'
            ], Response::HTTP_BAD_REQUEST);
        }

        if ($user->hasVerifiedEmail()) {
            // Redireciona para o deep link do aplicativo mesmo se já estiver verificado
            return redirect()->away('vitalink://app/email-verified');
        }

        if ($user->markEmailAsVerified()) {
            event(new Verified($user));
        }

        // Redireciona para o deep link do aplicativo
        return redirect()->away('vitalink://app/email-verified');
    }

    /**
     * Verify the signature of the verification URL.
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

        $expires = $query['expires'];
        $signature = $query['signature'];

        // Check if URL has expired
        if (Carbon::now()->getTimestamp() > $expires) {
            return false;
        }

        $signableUrl = URL::temporarySignedRoute(
            'verification.verify',
            Carbon::createFromTimestamp($expires),
            ['id' => $user->getKey(), 'hash' => sha1($user->getEmailForVerification())],
            false
        );

        $parsedSignableUrl = parse_url($signableUrl);
        if (!isset($parsedSignableUrl['query'])) {
            return false;
        }

        parse_str($parsedSignableUrl['query'], $signableQuery);
        return $signature === $signableQuery['signature'];
    }
} 