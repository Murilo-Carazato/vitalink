<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BloodCenterController;
use App\Http\Controllers\NewsController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;



//php -S 127.0.0.1:8000 -t public
// precisa disso pq o laravel+firebase cloud está bugado com o comando serve

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});


// ------------------ CRUD USER  ------------------
Route::middleware(['auth:sanctum'])->group(function () {
    Route::delete('/user/logout', [AuthController::class, 'destroy'])->name('user.logout');
    Route::get('/user', [UserController::class, 'index'])->name('user.index');
    Route::put('/user/{id}', [UserController::class, 'update'])->name('user.update');
    Route::delete('/user/{id}', [UserController::class, 'destroy'])->name('user.destroy');
});
Route::post('/user/login', [AuthController::class, 'store'])->name('user.login');
Route::post('/user/register', [UserController::class, 'store'])->name('user.store');

// ------------------ CRUD BLOOD CENTER  ------------------
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/blood-center', [BloodCenterController::class, 'index'])->name('blood-center.index');
    Route::post('/blood-center/register', [BloodCenterController::class, 'store'])->name('blood-center.store');
    Route::put('/blood-center/{id}', [BloodCenterController::class, 'update'])->name('blood-center.update');
    Route::delete('/blood-center/{id}', [BloodCenterController::class, 'destroy'])->name('blood-center.destroy');
    Route::get('/blood-center/{id}', [BloodCenterController::class, 'show'])->name('blood-center.show');
});

// ------------------ CRUD NEWS  ------------------
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/news/{id}', [NewsController::class, 'show'])->name('news.show');
    Route::post('/news/register', [NewsController::class, 'store'])->name('news.store');
    Route::put('/news/{id}', [NewsController::class, 'update'])->name('news.update');
    Route::delete('/news/{id}', [NewsController::class, 'destroy'])->name('news.destroy');
});
Route::get('/news', [NewsController::class, 'index'])->name('news.index'); // como funciona no firebase?