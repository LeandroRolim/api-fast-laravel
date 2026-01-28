<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/ip', fn () => request()->ip());
Route::get('/header', fn () => request()->header());
