<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return ['Laravel' => app()->version()];
});

// Dummy GET /login to avoid 405 for deep link fallback
Route::get('/login', function () {
    return response()->json(['message' => 'Login via API only.'], 200);
});

require __DIR__.'/auth.php';
