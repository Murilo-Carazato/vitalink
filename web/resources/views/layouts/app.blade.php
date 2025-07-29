<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="scroll-smooth">

<head>
    <meta charset="utf-8">

    <meta name="application-name" content="{{ config('app.name') }}">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css" />

    <link rel="icon" href="{{ asset('img/blood.png') }}">
    <title>{{ config('app.name') }}</title>

    <style>
        [x-cloak] {
            display: none !important;
        }
    </style>
    @livewireStyles
    @vite(['resources/css/app.css','resources/js/app.js'])
</head>

<body class="antialiased">
    @include('layouts.navbar')

    <div class="px-8 my-24 overflow-hidden md:mx-32">
        {{ $slot }}
    </div>

    @livewireScripts
    @include('layouts.footer')
</body>

</html>
