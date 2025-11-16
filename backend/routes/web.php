<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Laravel\Sanctum\Http\Controllers\CsrfCookieController;

Route::get('/', function () {
    return view('welcome');
});

// CSRF cookie for Sanctum (served via web middleware)
Route::get('/sanctum/csrf-cookie', [CsrfCookieController::class, 'show']);

// Fallback named route for 'login' to avoid RouteNotFoundException from auth middleware
Route::get('/login', function () {
    // If an auth login view exists, developers can replace this with `return view('auth.login');`
    return redirect('/');
})->name('login');

// Session-based login endpoint for compatibility with frontend calling /login
Route::post('/login', function (Request $request) {
    $credentials = $request->only('email', 'password');

    if (Auth::attempt($credentials)) {
        // Regenerate session to prevent fixation
        $request->session()->regenerate();
        return response()->json(['message' => 'logged_in', 'user' => Auth::user()], 200);
    }

    return response()->json(['message' => 'Unauthorized'], 401);
});
