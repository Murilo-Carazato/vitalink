<?php

namespace App\Jobs;

use App\Models\News;
use App\Models\User;
use App\Services\FirebaseService;
use App\Enums\BloodType;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendEmergencyNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $news;
    protected $targetBloodType;

    public function __construct(News $news, ?string $targetBloodType = null)
    {
        $this->news = $news;
        $this->targetBloodType = $targetBloodType;
    }

    public function handle()
    {
        try {
            $firebaseService = app(FirebaseService::class);
            
            // Get verified users who can receive notifications
            $usersQuery = User::where('is_active', true)
                ->whereNotNull('email_verified_at');

            // If targeting specific blood type, filter by emergency type
            if ($this->targetBloodType) {
                // This would require blood type to be stored locally or retrieved from another source
                // For now, send to all verified users
                Log::info("Emergency notification targeting blood type: {$this->targetBloodType}");
            }

            $users = $usersQuery->get();

            $title = 'Emergência - Doação Urgente';
            $message = $this->news->title;

            $data = [
                'type' => 'emergency_news',
                'news_id' => $this->news->id,
                'bloodcenter_id' => $this->news->bloodcenter_id,
                'target_blood_type' => $this->targetBloodType,
                'priority' => 'high',
            ];

            $successCount = 0;
            $failCount = 0;

            foreach ($users as $user) {
                try {
                    $firebaseService->sendNotificationToUser(
                        $user->id,
                        $title,
                        $message,
                        $data
                    );
                    $successCount++;
                } catch (\Exception $e) {
                    $failCount++;
                    Log::warning("Failed to send emergency notification to user {$user->id}", [
                        'error' => $e->getMessage()
                    ]);
                }
            }

            Log::info("Emergency notification batch completed", [
                'news_id' => $this->news->id,
                'total_users' => $users->count(),
                'success_count' => $successCount,
                'fail_count' => $failCount,
                'target_blood_type' => $this->targetBloodType
            ]);

        } catch (\Exception $e) {
            Log::error("Failed to process emergency notification job", [
                'news_id' => $this->news->id,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    public function failed(\Exception $exception)
    {
        Log::error("Emergency notification job failed", [
            'news_id' => $this->news->id,
            'error' => $exception->getMessage()
        ]);
    }
}
