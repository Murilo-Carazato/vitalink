<?php

namespace App\Console\Commands;

use App\Models\Donation;
use App\Services\EncryptionService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class MigrateSensitiveData extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'data:encrypt-sensitive
                            {--dry-run : Execute a dry run without making changes}
                            {--batch-size=100 : Number of records to process per batch}';

    /**
     * The console command description.
     */
    protected $description = 'Encrypt existing sensitive data in donations table';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $dryRun = $this->option('dry-run');
        $batchSize = (int) $this->option('batch-size');

        $this->info('Starting sensitive data encryption migration...');
        
        if ($dryRun) {
            $this->warn('DRY RUN MODE - No changes will be made');
        }

        // Buscar doações com notas médicas não criptografadas
        $query = Donation::whereNotNull('medical_notes')
            ->where('medical_notes', '!=', '')
            ->whereNull('encrypted_medical_notes');

        $totalRecords = $query->count();

        if ($totalRecords === 0) {
            $this->info('No records found to encrypt.');
            return self::SUCCESS;
        }

        $this->info("Found {$totalRecords} records to encrypt");

        $progressBar = $this->output->createProgressBar($totalRecords);
        $progressBar->start();

        $processed = 0;
        $errors = 0;

        $query->chunk($batchSize, function ($donations) use ($dryRun, &$processed, &$errors, $progressBar) {
            foreach ($donations as $donation) {
                try {
                    if (!$dryRun) {
                        $this->encryptDonationData($donation);
                    }
                    
                    $processed++;
                    $progressBar->advance();
                    
                } catch (\Exception $e) {
                    $errors++;
                    Log::error('Error encrypting donation data', [
                        'donation_id' => $donation->id,
                        'error' => $e->getMessage()
                    ]);
                    
                    $this->error("Error processing donation {$donation->id}: " . $e->getMessage());
                }
            }
        });

        $progressBar->finish();
        $this->newLine();

        $this->info("Migration completed!");
        $this->info("Processed: {$processed} records");
        
        if ($errors > 0) {
            $this->error("Errors: {$errors} records failed");
        }

        if ($dryRun) {
            $this->info("This was a dry run - no changes were made");
        }

        return self::SUCCESS;
    }

    /**
     * Encrypt sensitive data for a donation
     */
    private function encryptDonationData(Donation $donation): void
    {
        DB::beginTransaction();
        
        try {
            $updates = [];

            // Criptografar medical_notes se presente
            if (!empty($donation->medical_notes)) {
                $updates['encrypted_medical_notes'] = EncryptionService::encryptMedicalNotes($donation->medical_notes);
                $updates['medical_notes_hash'] = EncryptionService::hashForSearch($donation->medical_notes);
                $updates['encrypted_at'] = now();
                
                // Limpar o campo original após criptografia
                $updates['medical_notes'] = null;
            }

            // Criptografar outros campos sensíveis se necessário
            if (!empty($donation->staff_notes) && $this->isSensitiveData($donation->staff_notes)) {
                $updates['encrypted_health_questions'] = EncryptionService::encryptSensitiveData($donation->staff_notes);
                $updates['health_questions_hash'] = EncryptionService::hashForSearch($donation->staff_notes);
            }

            if (!empty($updates)) {
                $donation->updateQuietly($updates);
            }

            DB::commit();
            
        } catch (\Exception $e) {
            DB::rollback();
            throw $e;
        }
    }

    /**
     * Check if data contains sensitive information
     */
    private function isSensitiveData(string $data): bool
    {
        $sensitiveTerms = [
            'medicamento', 'doença', 'sintoma', 'diagnóstico', 'tratamento',
            'cirurgia', 'alergia', 'histórico médico', 'pressão arterial',
            'diabetes', 'hepatite', 'HIV', 'AIDS', 'sífilis', 'chagas',
            'malária', 'remédio', 'medicação', 'complicação',
            'cpf', 'cnpj', 'cartão', 'telefone', 'celular'
        ];

        $dataLower = strtolower($data);

        foreach ($sensitiveTerms as $term) {
            if (strpos($dataLower, $term) !== false) {
                return true;
            }
        }

        return false;
    }
}
