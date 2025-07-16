<?php

use App\Http\Controllers\Auth\NewPasswordController;
use App\Http\Controllers\Auth\PasswordResetLinkController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BloodCenterController;
use App\Http\Controllers\VerificationController;
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

// ------------------ AUTHENTICATION  ------------------
Route::post('/user/login', [AuthController::class, 'store'])->name('user.login');
Route::post('/user/register', [UserController::class, 'store'])->name('user.store');
Route::post('/auth/google', [AuthController::class, 'handleGoogleCallback'])->name('google.login');
Route::post('/forgot-password', [PasswordResetLinkController::class, 'store'])->name('password.email');
Route::post('/reset-password', [NewPasswordController::class, 'store'])->name('password.update');

// Email verification routes
Route::post('/email/verification-notification', [VerificationController::class, 'send'])->name('verification.send');
Route::get('/email/verify/{id}/{hash}', [VerificationController::class, 'verify'])->name('verification.verify');
Route::get('/email/verify', [VerificationController::class, 'notice'])->name('verification.notice');

// Adicionar a rota para verificar o status de verificação do email
Route::get('/user/check-verification-status', [App\Http\Controllers\VerificationController::class, 'checkStatus']);

// ------------------ USER MANAGEMENT  ------------------
Route::middleware(['auth:sanctum'])->group(function () {
    Route::delete('/user/logout', [AuthController::class, 'destroy'])->name('user.logout');
    Route::get('/user', [UserController::class, 'index'])->name('user.index');
    Route::get('/user/donations', [DonationController::class, 'getDonationsForUser'])->name('user.donations');
    Route::put('/user/{user}', [UserController::class, 'update'])->name('user.update');
});
Route::delete('/user/{user}', [UserController::class, 'destroy'])->name('user.destroy');

// ------------------ BLOOD CENTER  ------------------
Route::get('/blood-center', [BloodCenterController::class, 'index'])->name('blood-center.index');
Route::get('/blood-center/{blood_center}', [BloodCenterController::class, 'show'])->name('blood-center.show');
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/blood-center/register', [BloodCenterController::class, 'store'])->name('blood-center.store');
    Route::put('/blood-center/{blood_center}', [BloodCenterController::class, 'update'])->name('blood-center.update');
    Route::delete('/blood-center/{blood_center}', [BloodCenterController::class, 'destroy'])->name('blood-center.destroy');
});

// ------------------ NEWS  ------------------
Route::get('/news', [NewsController::class, 'index'])->name('news.index');
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/news/register', [NewsController::class, 'store'])->name('news.store');
    Route::get('/news/{id}', [NewsController::class, 'show'])->name('news.show');
    Route::put('/news/{id}', [NewsController::class, 'update'])->name('news.update');
    Route::delete('/news/{id}', [NewsController::class, 'destroy'])->name('news.destroy');
});

// ------------------ DONATIONS  ------------------

// Public routes (no authentication required)
Route::get('/donations/{token}', [DonationController::class, 'show'])->name('donations.show');
Route::get('/donations/confirm/{token}', [DonationController::class, 'getByConfirmationToken'])->name('donations.confirm');

// Donor routes (require authentication and email verification)
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::post('/donations/schedule', [DonationController::class, 'store'])->name('donations.store');
    Route::put('/donations/{token}', [DonationController::class, 'update'])->name('donations.update');
    Route::post('/donations/{token}/cancel', [DonationController::class, 'cancel'])->name('donations.cancel');
    Route::post('/donations/{token}/complete', [DonationController::class, 'complete'])->name('donations.complete');
});

// Admin/Blood Center routes (require authentication and admin privileges)
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/donations', [DonationController::class, 'index'])->name('donations.index');
    Route::get('/donations/statistics', [DonationController::class, 'statistics'])->name('donations.statistics');
    Route::post('/donations/{token}/confirm', [DonationController::class, 'confirm'])->name('donations.confirm');
});