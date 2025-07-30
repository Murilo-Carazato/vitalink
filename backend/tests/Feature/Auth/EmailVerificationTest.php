<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Auth\Events\Verified;
use App\Notifications\VerifyEmailNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\URL;
use Tests\TestCase;

class EmailVerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_verification_notification_endpoint_exists(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => null,
        ]);

        $response = $this->post('/api/email/verification-notification', [
            'email' => $user->email,
        ]);

        $response->assertStatus(200);
    }

    public function test_email_can_be_verified(): void
    {
        Event::fake();

        $user = User::factory()->create([
            'email_verified_at' => null,
        ]);

        // Usar a URL na mesma forma que a classe VerifyEmailNotification gera
        $baseUrl = config('app.url');
        $emailHash = sha1($user->email);
        $id = $user->id;

        $signedUrl = URL::temporarySignedRoute(
            'verification.verify',
            now()->addMinutes(60),
            ['id' => $id, 'hash' => $emailHash],
            false
        );

        // Extrair parâmetros da URL assinada
        $parsedUrl = parse_url($signedUrl);
        $queryParams = [];
        if (isset($parsedUrl['query'])) {
            parse_str($parsedUrl['query'], $queryParams);
        }

        // Usar a mesma construção que a notificação usa
        $verificationUrl = "{$baseUrl}/api/email/verify/{$id}/{$emailHash}?expires={$queryParams['expires']}&signature={$queryParams['signature']}";

        $response = $this->get($verificationUrl);

        Event::assertDispatched(Verified::class);

        $this->assertTrue($user->fresh()->hasVerifiedEmail());
        $response->assertJson(['message' => 'Email verified successfully.']);
    }

    public function test_email_is_not_verified_with_invalid_hash(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => null,
        ]);

        $verificationUrl = URL::temporarySignedRoute(
            'verification.verify',
            now()->addMinutes(60),
            ['id' => $user->id, 'hash' => sha1('wrong-email')]
        );

        $this->get($verificationUrl);

        $this->assertFalse($user->fresh()->hasVerifiedEmail());
    }

    public function test_verification_notification_can_be_sent(): void
    {
        Notification::fake();
        
        $user = User::factory()->create([
            'email_verified_at' => null,
        ]);

        $response = $this->post('/api/email/verification-notification', [
            'email' => $user->email,
        ]);

        Notification::assertSentTo(
            [$user], VerifyEmailNotification::class
        );

        $response->assertJson(['message' => 'Verification link sent successfully.']);
    }
}
