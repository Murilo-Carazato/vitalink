<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BloodCenterController;
use App\Http\Controllers\NewsController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\DonationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


//php -S 0.0.0.0:8000 -t public
// precisa disso pq o laravel+firebase cloud está bugado com o comando serve

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});


// ------------------ CRUD USER  ------------------
Route::middleware(['auth:sanctum'])->group(function () {
    Route::delete('/user/logout', [AuthController::class, 'destroy'])->name('user.logout');
    Route::get('/user', [UserController::class, 'index'])->name('user.index');
    Route::get('/user/donations', [DonationController::class, 'getDonationsForUser'])->name('user.donations');
    Route::put('/user/{user}', [UserController::class, 'update'])->name('user.update');
    Route::delete('/user/{user}', [UserController::class, 'destroy'])->name('user.destroy');
});
Route::post('/user/login', [AuthController::class, 'store'])->name('user.login');
Route::post('/user/register', [UserController::class, 'store'])->name('user.store');

// ------------------ CRUD BLOOD CENTER  ------------------
Route::get('/blood-center', [BloodCenterController::class, 'index'])->name('blood-center.index');
Route::get('/blood-center/{blood_center}', [BloodCenterController::class, 'show'])->name('blood-center.show');
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/blood-center/register', [BloodCenterController::class, 'store'])->name('blood-center.store');
    Route::put('/blood-center/{blood_center}', [BloodCenterController::class, 'update'])->name('blood-center.update');
    Route::delete('/blood-center/{blood_center}', [BloodCenterController::class, 'destroy'])->name('blood-center.destroy');
});

// ------------------ CRUD NEWS  ------------------
// Route::post('/news/register', [NewsController::class, 'store'])->name('news.store');
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/news/register', [NewsController::class, 'store'])->name('news.store');
    Route::get('/news/{id}', [NewsController::class, 'show'])->name('news.show');
    Route::put('/news/{id}', [NewsController::class, 'update'])->name('news.update');
    Route::delete('/news/{id}', [NewsController::class, 'destroy'])->name('news.destroy');
});
Route::get('/news', [NewsController::class, 'index'])->name('news.index'); // como funciona no firebase?


// ------------------ DONATIONS  ------------------

// Rotas de doação que exigem autenticação (doador)
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/donations/schedule', [DonationController::class, 'store'])->name('donations.store');
    Route::post('/donations/{token}/cancel', [DonationController::class, 'cancel'])->name('donations.cancel');
    Route::post('/donations/{token}/complete', [DonationController::class, 'complete'])->name('donations.complete');
});

// Rotas para admin/hemocentro (podem exigir outro tipo de auth no futuro)
Route::get('/donations', [DonationController::class, 'index'])->name('donations.index');
Route::get('/donations/statistics', [DonationController::class, 'statistics'])->name('donations.statistics');
Route::get('/donations/{token}', [DonationController::class, 'show'])->name('donations.show');
Route::put('/donations/{token}', [DonationController::class, 'update'])->name('donations.update');
Route::post('/donations/{token}/confirm', [DonationController::class, 'confirm'])->name('donations.confirm');

// Rota pública para consultar status da doação
Route::get('/donations/{token}/status', [DonationController::class, 'show'])->name('donations.status');