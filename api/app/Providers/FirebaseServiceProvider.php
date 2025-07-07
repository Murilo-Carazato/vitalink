<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Http\HttpClientOptions;
use GuzzleHttp\RequestOptions;

class FirebaseServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(Messaging::class, function () {
            $certPath = base_path('cacert.pem');

            $options = HttpClientOptions::default()
                ->withGuzzleConfigOptions([
                    RequestOptions::VERIFY => $certPath,

                    'curl' => [
                        CURLOPT_CAINFO         => $certPath,
                        CURLOPT_SSL_VERIFYPEER => true,
                    ],
                ]);

            $factory = (new Factory())
                ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')))
                ->withHttpClientOptions($options);

            return $factory->createMessaging();
        });
    }
}