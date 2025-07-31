<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\URL;

class VerifyEmailNotification extends Notification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct()
    {
        // ensure queued after DB commit
        $this->afterCommit = true;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $verificationUrl = $this->verificationUrl($notifiable);
        
        return (new MailMessage)
                    ->subject('Verificação de Email - Vitalink')
                    ->line('Por favor, clique no botão abaixo para verificar seu endereço de email.')
                    ->action('Verificar Email', $verificationUrl)
                    ->line('Se você não criou uma conta, nenhuma ação é necessária.');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            //
        ];
    }

    /**
     * Get the verification URL for the given notifiable.
     */
    protected function verificationUrl($notifiable)
    {
        // Gera o hash do email do usuário
        $emailHash = sha1($notifiable->getEmailForVerification());
        
        // Força o uso do IP/porta local, mas mantém caminho e assinatura gerados pelo Laravel
        $baseUrl = "http://192.168.0.5:8000";

        $relativeSigned = URL::temporarySignedRoute(
            'api.verification.verify',
            Carbon::now()->addMinutes(Config::get('auth.verification.expire', 60)),
            [
                'id' => $notifiable->getKey(),
                'hash' => $emailHash,
            ],
            false // retorna URL relativa (sem domínio)
        );

        // Junta domínio forçado com caminho + query assinados
        return $baseUrl . $relativeSigned;
    }
} 