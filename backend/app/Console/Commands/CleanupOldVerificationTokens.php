<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CleanupOldVerificationTokens extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'tokens:cleanup {--hours=24 : Número de horas para considerar um token como antigo}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Remove tokens de verificação de e-mail antigos';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $hours = (int) $this->option('hours');
        $cutoffDate = now()->subHours($hours);
        
        $this->info("Removendo tokens de verificação mais antigos que {$hours} horas...");
        
        $deleted = DB::table('personal_access_tokens')
            ->where('name', 'email-verification')
            ->where('created_at', '<', $cutoffDate)
            ->delete();
            
        $this->info("{$deleted} tokens de verificação antigos foram removidos.");
        
        return 0;
    }
}
