<?php

namespace App\Console\Commands;

use App\Models\Donation;
use App\Jobs\SendDonationReminderJob;
use App\Enums\DonationStatus;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class SendDonationReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'donations:send-reminders';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Send reminder notifications for upcoming donations';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting to send donation reminders...');

        // Get donations that need reminders (tomorrow's donations)
        $donationsNeedingReminders = Donation::where('status', DonationStatus::SCHEDULED)
            ->where('reminder_sent', false)
            ->whereDate('donation_date', now()->addDay())
            ->with(['user', 'bloodcenter'])
            ->get();

        $this->info("Found {$donationsNeedingReminders->count()} donations needing reminders");

        $successCount = 0;
        $failCount = 0;

        foreach ($donationsNeedingReminders as $donation) {
            try {
                // Dispatch job to send reminder
                SendDonationReminderJob::dispatch($donation);
                $successCount++;
                
                $this->line("Reminder queued for donation {$donation->donation_token}");
                
            } catch (\Exception $e) {
                $failCount++;
                $this->error("Failed to queue reminder for donation {$donation->donation_token}: {$e->getMessage()}");
                
                Log::error("Failed to queue donation reminder", [
                    'donation_id' => $donation->id,
                    'error' => $e->getMessage()
                ]);
            }
        }

        $this->info("Reminder sending completed!");
        $this->info("Successfully queued: {$successCount}");
        $this->info("Failed: {$failCount}");

        Log::info("Donation reminders command completed", [
            'total_donations' => $donationsNeedingReminders->count(),
            'success_count' => $successCount,
            'fail_count' => $failCount
        ]);

        return 0;
    }
}
