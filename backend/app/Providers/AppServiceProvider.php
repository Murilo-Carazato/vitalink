<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Log;
use Illuminate\Foundation\Vite;

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
        $this->app->booted(function () {
            if (app()->bound('filament')) {
                \Filament\Facades\Filament::serving(function () {
                    \Filament\Facades\Filament::registerTheme(
                        app(Vite::class)('resources/css/app.css'),
                    );
                });
            }
        });
        
        $certPath = base_path('cacert.pem');
        if (file_exists($certPath)) {
            Log::info('cacert.pem FOUND at: ' . $certPath);
            // Set multiple environment variables to ensure certificate is used
            putenv("CURL_CA_BUNDLE=$certPath");
            putenv("SSL_CERT_FILE=$certPath");

            // Also set PHP stream context defaults as a backup
            stream_context_set_default([
                'ssl' => [
                    'cafile' => $certPath,
                    'verify_peer' => true,
                    'verify_peer_name' => true,
                ]
            ]);
            Log::info('PHP stream SSL context configured successfully for cacert.pem.');
        } else {
            Log::warning('cacert.pem NOT FOUND at: ' . $certPath . ' - SSL verification may fail.');
        }
    }
}
