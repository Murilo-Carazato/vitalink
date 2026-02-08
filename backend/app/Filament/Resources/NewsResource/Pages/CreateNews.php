<?php

namespace App\Filament\Resources\NewsResource\Pages;

use App\Filament\Resources\NewsResource;
use Filament\Pages\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateNews extends CreateRecord
{
    protected static string $resource = NewsResource::class;

    protected function afterCreate(): void
    {
        $record = $this->record;

        try {
            $firebaseService = app(\App\Services\FirebaseService::class);
            
            // If blood_type is set, send to specific topic. 
            // If not, send to 'general' topic.
            $topic = !empty($record->blood_type) ? $record->blood_type : 'general';
            
            \Illuminate\Support\Facades\Log::info('Sending notification', [
                'title' => $record->title,
                'blood_type_input' => $record->blood_type,
                'resolved_topic' => $topic
            ]);
            
            $firebaseService->sendNotification(
                $record->title,
                strip_tags($record->content), // Remove HTML tags for push notification
                $topic, 
                $record->type 
            );
        } catch (\Exception $e) {
            // Log error or show notification in Filament
             //Notification::make()->title('Erro ao enviar push')->body($e->getMessage())->danger()->send();
        }
    }
}
