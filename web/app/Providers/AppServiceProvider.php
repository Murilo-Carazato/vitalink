<?php

namespace App\Providers;
use Filament\Facades\Filament;
use Illuminate\Foundation\Vite;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Defer Filament logic until the framework has booted and the 'filament' binding is available.
        $this->app->booted(function () {
            if (app()->bound('filament')) {
                \Filament\Facades\Filament::serving(function () {
                    \Filament\Facades\Filament::registerTheme(
                        app(Vite::class)('resources/css/app.css'),
                    );
                });
            }
        });
    }
}
