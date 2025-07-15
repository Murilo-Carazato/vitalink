<?php

use App\Enums\BloodType;
use App\Enums\DonationStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('donations', function (Blueprint $table) {
            $table->id();
            // Token único para identificar a doação (gerado no app)
            $table->string('donation_token', 64)->unique();
            
            // Dados não sensíveis necessários para operação
            $table->enum('blood_type', Arr::pluck(BloodType::cases(), 'value'));
            $table->date('donation_date');
            $table->time('donation_time')->nullable(); // Horário específico
            $table->enum('status', Arr::pluck(DonationStatus::cases(), 'value'))->default(DonationStatus::SCHEDULED->value);
            $table->foreignId('bloodcenter_id')->constrained('bloodcenters');
            
            // Dados para estatísticas/relatórios (sem identificação)
            $table->enum('donor_age_range', ['18-25', '26-35', '36-45', '46-55', '56-65', '65+'])->nullable();
            $table->enum('donor_gender', ['M', 'F', 'O'])->nullable(); // Opcional para estatísticas
            $table->boolean('is_first_time_donor')->default(false);
            
            // Observações não sensíveis do hemocentro
            $table->text('medical_notes')->nullable(); // Só dados médicos relevantes
            $table->text('staff_notes')->nullable(); // Observações da equipe
            
            // Controle de notificações
            $table->boolean('reminder_sent')->default(false);
            $table->timestamp('reminder_sent_at')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('donations');
    }
};