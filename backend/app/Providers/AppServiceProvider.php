<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;
use Illuminate\Auth\Middleware\Authenticate;

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
        // Ensure Authenticate middleware doesn't throw if route('login') is missing
        Authenticate::redirectUsing(function ($request) {
            // For API requests or when client expects JSON -> no redirect
            if ($request->expectsJson() || $request->is('api/*') || str_contains($request->header('Accept', ''), 'application/json')) {
                return null;
            }

            // If a named 'login' route exists use it, otherwise fallback to /login
            try {
                if (Route::has('login')) {
                    return route('login');
                }
            } catch (\Throwable $e) {
                // ignore route resolution errors
            }

            return '/login';
        });
    }
}
