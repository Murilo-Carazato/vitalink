<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            // Adicionar campos criptografados para informações médicas sensíveis
            $table->longText('encrypted_medical_notes')->nullable()->after('medical_notes');
            $table->string('medical_notes_hash', 64)->nullable()->after('encrypted_medical_notes');
            
            // Adicionar campos para questões de saúde sensíveis
            $table->longText('encrypted_health_questions')->nullable()->after('medical_notes_hash');
            $table->string('health_questions_hash', 64)->nullable()->after('encrypted_health_questions');
            
            // Adicionar timestamp para controle de criptografia
            $table->timestamp('encrypted_at')->nullable()->after('health_questions_hash');
            
            // Adicionar índice para hash de busca
            $table->index('medical_notes_hash');
            $table->index('health_questions_hash');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            $table->dropIndex(['medical_notes_hash']);
            $table->dropIndex(['health_questions_hash']);
            
            $table->dropColumn([
                'encrypted_medical_notes',
                'medical_notes_hash',
                'encrypted_health_questions',
                'health_questions_hash',
                'encrypted_at'
            ]);
        });
    }
};
