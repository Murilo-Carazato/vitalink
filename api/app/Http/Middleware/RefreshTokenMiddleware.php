<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Laravel\Sanctum\PersonalAccessToken;
use Symfony\Component\HttpFoundation\Response;

class RefreshTokenMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();
        
        if (!$user) {
            return $next($request);
        }

        $token = $user->currentAccessToken();
        
        if (!$token || !($token instanceof PersonalAccessToken)) {
            return $next($request);
        }

        // Check if token is close to expiration (within 6 hours)
        $expiresAt = $token->expires_at;
        $shouldRefresh = false;

        if ($expiresAt && $expiresAt->diffInHours(now()) <= 6) {
            $shouldRefresh = true;
        }

        // Also check if token is older than 12 hours (for security)
        if ($token->created_at->diffInHours(now()) >= 12) {
            $shouldRefresh = true;
        }

        if ($shouldRefresh) {
            $this->refreshUserToken($user, $token);
        }

        return $next($request);
    }

    /**
     * Refresh the user's access token
     */
    private function refreshUserToken($user, $currentToken): void
    {
        // Prevent multiple refresh attempts
        $refreshKey = "token_refresh_{$user->id}_{$currentToken->id}";
        
        if (Cache::has($refreshKey)) {
            return;
        }

        Cache::put($refreshKey, true, 300); // 5 minutes lock

        try {
            // Create new token with same abilities
            $newToken = $user->createToken(
                'refreshed_token',
                $currentToken->abilities,
                now()->addHours(24) // 24 hours expiration
            );

            // Store new token info in cache for client to retrieve
            Cache::put("new_token_{$user->id}", [
                'token' => $newToken->plainTextToken,
                'expires_at' => $newToken->accessToken->expires_at->toISOString(),
                'created_at' => now()->toISOString()
            ], 600); // 10 minutes to retrieve

            // Revoke old token after a grace period
            dispatch(function () use ($currentToken) {
                sleep(60); // 1 minute grace period
                $currentToken->delete();
            })->delay(now()->addMinutes(1));

        } catch (\Exception $e) {
            \Log::error('Token refresh failed', [
                'user_id' => $user->id,
                'token_id' => $currentToken->id,
                'error' => $e->getMessage()
            ]);
        }
    }
}
