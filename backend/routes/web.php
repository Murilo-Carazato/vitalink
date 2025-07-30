<?php

use App\Livewire\Home;
use App\Livewire\News;
use App\Livewire\ShowNews;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/',Home::class)->name('home');
Route::get('/noticias', News::class)->name('news');
Route::get('/noticias/{slug}', ShowNews::class)->name('show.news');
