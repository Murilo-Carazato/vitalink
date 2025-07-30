<?php

return [
    'credentials' => [
        'file' => env('FIREBASE_CREDENTIALS'),
    ],

    'http_client_options' => [
        'verify' => base_path('cacert.pem'),
        // Add more specific Guzzle options 
        'curl' => [
            CURLOPT_CAINFO => base_path('cacert.pem'),
            CURLOPT_SSL_VERIFYPEER => true,
        ],
    ],
];
