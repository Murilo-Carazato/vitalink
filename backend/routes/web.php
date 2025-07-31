<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Home;
use App\Livewire\News;
use App\Livewire\ShowNews;

// Route::get('/', function () {
//     return ['Laravel' => app()->version()];
// });

// // Dummy GET /login to avoid 405 for deep link fallback
// Route::get('/login', function () {
//     return response()->json(['message' => 'Login via API only.'], 200);
// });

Route::get('/',Home::class)->name('home');
Route::get('/noticias', News::class)->name('news');
Route::get('/noticias/{news}', ShowNews::class)->name('show.news');

require __DIR__.'/auth.php';
