@props(['slot', 'href', 'active' => false])

@php 
$styleActive = "hover:text-[#333138] text-[#ED1C24]";
$styleDefault = "hover:text-[#ED1C24] text-[#333138]";
@endphp

<li>
    <a x-on:click="show = false"
    class="@if($active) {{ $styleActive }} @else {{ $styleDefault }} @endif text-base font-semibold"
        href="{{ $href }}">
        {{ $slot }}
    </a>
</li>
