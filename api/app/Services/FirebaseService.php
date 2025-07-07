<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Symfony\Component\HttpFoundation\Response;

class FirebaseService
{
    protected $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
        // Log the current CA certificate settings
        Log::info('CURL_CA_BUNDLE: ' . getenv('CURL_CA_BUNDLE'));
        Log::info('SSL_CERT_FILE: ' . getenv('SSL_CERT_FILE'));
    }
    
    public function sendNotification($title, $content, $bloodType, $type)
    {
        try {
            $message = CloudMessage::withTarget('topic', $bloodType)
                ->withNotification(Notification::create($title, $content))
                ->withData(['key' => $type]);
            $result = $this->messaging->send($message);
            Log::info('Firebase notification sent successfully', ['result' => $result]);
            return $result;
        } catch (\Exception $e) {
            Log::error('Firebase notification error: ' . $e->getMessage(), [
                'exception' => get_class($e),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);
            throw $e;
        }
    }
}