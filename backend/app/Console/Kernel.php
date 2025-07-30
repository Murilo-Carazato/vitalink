<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Send donation reminders daily at 9 AM
        $schedule->command('donations:send-reminders')
            ->dailyAt('09:00')
            ->withoutOverlapping()
            ->onOneServer();

        // Clean up old logs weekly
        $schedule->command('queue:clear')
            ->weekly()
            ->sundays()
            ->at('02:00');

        // Prune old Sanctum tokens daily
        $schedule->command('sanctum:prune-expired --hours=24')
            ->daily()
            ->at('03:00');

        // Limpa tokens de verificação antigos diariamente à meia-noite
        $schedule->command('tokens:cleanup --hours=24')
                 ->daily()
                 ->onOneServer()
                 ->timezone('America/Sao_Paulo')
                 ->withoutOverlapping();
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
