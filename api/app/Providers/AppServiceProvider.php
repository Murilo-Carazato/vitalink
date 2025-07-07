<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        ResetPassword::createUrlUsing(function (object $notifiable, string $token) {
            return config('app.frontend_url') . "/password-reset/$token?email={$notifiable->getEmailForPasswordReset()}";
        });

        $certPath = base_path('cacert.pem');
        if (file_exists($certPath)) {
            // Set multiple environment variables to ensure certificate is used
            putenv("CURL_CA_BUNDLE=$certPath");
            putenv("SSL_CERT_FILE=$certPath");

            // Also set PHP stream context defaults as a backup
            $context = stream_context_get_default([
                'ssl' => [
                    'cafile' => $certPath,
                    'verify_peer' => true,
                    'verify_peer_name' => true,
                ]
            ]);
        }
    }
}
