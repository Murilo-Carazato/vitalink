<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Adiciona índice para melhorar a busca por tokens de verificação antigos
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->index(['name', 'created_at']);
        });
        
        // Limpa tokens de verificação antigos (mais de 1 dia)
        DB::table('personal_access_tokens')
            ->where('name', 'email-verification')
            ->where('created_at', '<', now()->subDay())
            ->delete();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove o índice adicionado
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->dropIndex(['name', 'created_at']);
        });
    }
};
