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
            $table->string('confirmation_token', 16)->nullable()->after('donation_token');
            $table->timestamp('confirmation_expires_at')->nullable()->after('confirmation_token');
            $table->index('confirmation_token');
            $table->index(['status', 'donation_date']);
            $table->index(['bloodcenter_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            $table->dropIndex(['bloodcenter_id', 'status']);
            $table->dropIndex(['status', 'donation_date']);
            $table->dropIndex('confirmation_token');
            $table->dropColumn(['confirmation_token', 'confirmation_expires_at']);
        });
    }
}; 