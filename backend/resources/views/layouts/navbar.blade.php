<nav class="w-full bg-white border-gray-200 shadow-md border-b-[0.5px] fixed top-0 z-50" x-data="{ show: false }">
    <div class="flex flex-wrap items-center justify-between max-w-screen-xl p-4 mx-auto">
        <a class="ml-12 w-44 md:text-2xl" href="{{ route('home') }}">
            <x-logo />
        </a>
        <button type="button" x-on:click="show = !show"
            class="inline-flex items-center justify-center w-10 h-10 p-2 text-sm text-gray-500 rounded-lg lg:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
            aria-controls="navbar-default" aria-expanded="false">
            <span class="sr-only">Open main menu</span>
            <svg class="w-5 h-5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 17 14">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M1 1h15M1 7h15M1 13h15" />
            </svg>
        </button>

        <div class="hidden w-auto lg:block">
            <ul class="flex space-x-8 font-medium list-none rounded-lg">
                <x-nav-link 
                    :active="request()->routeIs('home')"
                    href="{{ request()->routeIs('home') ? route('home') . '#' : route('home') }}">
                    Início
                </x-nav-link>

                <x-nav-link 
                    href="{{ route('home') }}#download"
                    >Download
                </x-nav-link>

                <x-nav-link 
                    :active="request()->routeIs('news')"
                    href="{{ request()->routeIs('home') ? route('home') . '#noticias' : route('news').'#' }}">
                    Notícias
                </x-nav-link>
            </ul>
        </div>

        <div class="w-full lg:hidden" x-show="show" 
            x-transition:enter="transition ease-out duration-300"
            x-transition:enter-start="opacity-0 scale-90"
            x-transition:enter-end="opacity-100 scale-100"
            x-transition:leave="transition ease-in duration-300"
            x-transition:leave-start="opacity-100 scale-100"
            x-transition:leave-end="opacity-0 scale-90">
            <ul class="flex flex-col p-4 mt-4 font-medium list-none border border-gray-100 rounded-lg ">
                <x-nav-link 
                    :active="request()->routeIs('home')"
                    href="{{ request()->routeIs('home') ? route('home') . '#' : route('home') }}">
                    Início
                </x-nav-link>

                <x-nav-link 
                    href="{{ route('home') }}#download"
                    >Download
                </x-nav-link>

                <x-nav-link 
                    :active="request()->routeIs('news')"
                    href="{{ request()->routeIs('home') ? route('home') . '#noticias' : route('news').'#' }}">
                    Notícias
                </x-nav-link>
            </ul>
        </div>
    </div>
</nav>
