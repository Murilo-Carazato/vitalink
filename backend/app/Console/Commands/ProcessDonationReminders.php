<?php

namespace App\Console\Commands;

use App\Jobs\SendDonationReminder;
use App\Services\DonationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class ProcessDonationReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'donations:process-reminders';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Process donation reminders for tomorrow\'s donations';

    /**
     * Execute the console command.
     */
    public function handle(DonationService $donationService): int
    {
        $this->info('Processing donation reminders...');

        $donationsNeedingReminders = $donationService->getDonationsNeedingReminders();

        if ($donationsNeedingReminders->isEmpty()) {
            $this->info('No donations need reminders.');
            return 0;
        }

        $this->info("Found {$donationsNeedingReminders->count()} donations needing reminders.");

        $bar = $this->output->createProgressBar($donationsNeedingReminders->count());

        foreach ($donationsNeedingReminders as $donation) {
            try {
                SendDonationReminder::dispatch($donation);
                $bar->advance();
            } catch (\Exception $e) {
                Log::error('Failed to dispatch reminder job', [
                    'donation_id' => $donation->id,
                    'error' => $e->getMessage(),
                ]);
                $this->error("Failed to process reminder for donation {$donation->id}: {$e->getMessage()}");
            }
        }

        $bar->finish();
        $this->newLine();
        $this->info('Reminder processing completed.');

        return 0;
    }
} 