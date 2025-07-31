<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add the "user" role to the isadmin ENUM and set it as default
        DB::statement("ALTER TABLE users MODIFY isadmin ENUM('superadmin', 'admin', 'user') NOT NULL DEFAULT 'user';");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert back to only superadmin & admin (no default)
        DB::statement("ALTER TABLE users MODIFY isadmin ENUM('superadmin', 'admin') NOT NULL;");
    }
};
