<?php

namespace App\Jobs;

use App\Models\Donation;
use App\Services\FirebaseService;
use App\Services\NotificationService;
use App\Enums\DonationStatus;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendDonationReminderJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $donation;

    public function __construct(Donation $donation)
    {
        $this->donation = $donation;
    }

    public function handle()
    {
        try {
            // Check if donation is still valid for reminder
            if (!$this->shouldSendReminder()) {
                return;
            }

            $title = 'Lembrete de Doação';
            $message = sprintf(
                'Olá! Você tem uma doação agendada para amanhã às %s no %s. Não se esqueça!',
                $this->donation->donation_time->format('H:i'),
                $this->donation->bloodcenter->name
            );

            $data = [
                'type' => 'donation_reminder',
                'donation_token' => $this->donation->donation_token,
                'bloodcenter_id' => $this->donation->bloodcenter_id,
                'donation_date' => $this->donation->donation_date->format('Y-m-d'),
                'donation_time' => $this->donation->donation_time->format('H:i'),
            ];

            // Send notification to user
            $firebaseService = app(FirebaseService::class);
            $firebaseService->sendNotificationToUser(
                $this->donation->user_id,
                $title,
                $message,
                $data
            );

            // Mark reminder as sent
            $this->donation->markReminderSent();

            Log::info("Donation reminder sent successfully", [
                'donation_id' => $this->donation->id,
                'user_id' => $this->donation->user_id,
                'donation_token' => $this->donation->donation_token
            ]);

        } catch (\Exception $e) {
            Log::error("Failed to send donation reminder", [
                'donation_id' => $this->donation->id,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    private function shouldSendReminder(): bool
    {
        // Refresh the donation from database
        $this->donation->refresh();

        // Don't send if already sent
        if ($this->donation->reminder_sent) {
            return false;
        }

        // Only send for scheduled donations
        if ($this->donation->status !== DonationStatus::SCHEDULED) {
            return false;
        }

        // Don't send if donation is in the past
        if ($this->donation->donation_date->isPast()) {
            return false;
        }

        // Only send if donation is tomorrow
        if (!$this->donation->donation_date->isToday() && !$this->donation->donation_date->isTomorrow()) {
            return false;
        }

        return true;
    }

    public function failed(\Exception $exception)
    {
        Log::error("Donation reminder job failed", [
            'donation_id' => $this->donation->id,
            'error' => $exception->getMessage()
        ]);
    }
}
