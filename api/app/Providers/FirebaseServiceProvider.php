<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use GuzzleHttp\RequestOptions;
use Kreait\Firebase\Http\HttpClientOptions;
use Illuminate\Support\Facades\Log;

class FirebaseServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(Messaging::class, function () {
            $certPath = base_path('cacert.pem');

            $httpOptions = HttpClientOptions::default()->withGuzzleConfigOptions([
                RequestOptions::VERIFY => $certPath,
            ]);

            $factory = (new Factory())
                ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')))
                ->withHttpClientOptions($httpOptions);

            return $factory->createMessaging();
        });

        $this->app->singleton(FirebaseAuth::class, function () {
            $certPath = base_path('cacert.pem');
            Log::info('[FirebaseServiceProvider] Registering FirebaseAuth with cert: ' . $certPath);

            $httpOptions = HttpClientOptions::default()->withGuzzleConfigOptions([
                RequestOptions::VERIFY => $certPath,
            ]);

            $factory = (new Factory())
                ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')))
                ->withHttpClientOptions($httpOptions);

            Log::info('[FirebaseServiceProvider] FirebaseAuth singleton created with custom HTTP client options.');

            return $factory->createAuth();
        });
    }
}