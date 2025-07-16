<?php

namespace App\Jobs;

use App\Models\Donation;
use App\Services\DonationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendDonationReminder implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $donation;

    /**
     * Create a new job instance.
     */
    public function __construct(Donation $donation)
    {
        $this->donation = $donation;
    }

    /**
     * Execute the job.
     */
    public function handle(DonationService $donationService): void
    {
        try {
            if ($this->donation->needsReminder()) {
                $donationService->sendReminder($this->donation);
                
                Log::info('Reminder sent for donation', [
                    'donation_id' => $this->donation->id,
                    'donation_token' => $this->donation->donation_token,
                    'donation_date' => $this->donation->donation_date,
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Failed to send donation reminder', [
                'donation_id' => $this->donation->id,
                'error' => $e->getMessage(),
            ]);
            
            throw $e;
        }
    }
} 