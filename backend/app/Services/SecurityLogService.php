<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Request;
use Illuminate\Support\Facades\Auth;

class SecurityLogService
{
    /**
     * Log authentication events
     */
    public static function logAuthEvent(string $event, array $data = []): void
    {
        $logData = [
            'event' => $event,
            'user_id' => Auth::id(),
            'ip_address' => Request::ip(),
            'user_agent' => Request::userAgent(),
            'timestamp' => now(),
            'data' => $data
        ];

        Log::channel('security')->info("AUTH_EVENT: {$event}", $logData);
    }

    /**
     * Log donation events
     */
    public static function logDonationEvent(string $event, array $data = []): void
    {
        $logData = [
            'event' => $event,
            'user_id' => Auth::id(),
            'ip_address' => Request::ip(),
            'timestamp' => now(),
            'data' => $data
        ];

        Log::channel('donation')->info("DONATION_EVENT: {$event}", $logData);
    }

    /**
     * Log security violations
     */
    public static function logSecurityViolation(string $violation, array $data = []): void
    {
        $logData = [
            'violation' => $violation,
            'user_id' => Auth::id(),
            'ip_address' => Request::ip(),
            'user_agent' => Request::userAgent(),
            'timestamp' => now(),
            'data' => $data
        ];

        Log::channel('security')->warning("SECURITY_VIOLATION: {$violation}", $logData);
    }

    /**
     * Log API access attempts
     */
    public static function logApiAccess(string $endpoint, string $method, array $data = []): void
    {
        $logData = [
            'endpoint' => $endpoint,
            'method' => $method,
            'user_id' => Auth::id(),
            'ip_address' => Request::ip(),
            'timestamp' => now(),
            'data' => $data
        ];

        Log::channel('api')->info("API_ACCESS: {$method} {$endpoint}", $logData);
    }

    /**
     * Log failed authorization attempts
     */
    public static function logUnauthorizedAccess(string $resource, string $action, array $data = []): void
    {
        $logData = [
            'resource' => $resource,
            'action' => $action,
            'user_id' => Auth::id(),
            'ip_address' => Request::ip(),
            'user_agent' => Request::userAgent(),
            'timestamp' => now(),
            'data' => $data
        ];

        Log::channel('security')->warning("UNAUTHORIZED_ACCESS: {$action} on {$resource}", $logData);
    }
}
