<div>
    <div class="flex flex-col items-center justify-center">

        <div class="w-full space-y-20">

            {{-- Noticias --}}
            <div class="space-y-2" id="recentes">
                <x-title title="Recentes" />
                <livewire:recent-news>
            </div>


            <x-anchor id="pesquisa" />
            {{-- Maias noticias --}}
            <div class="space-y-2">
                <div class="flex flex-col justify-between md:items-center md:flex-row">
                    <x-title title="Mais notícias ({{ $news->count() }})" />
                    <div class="relative w-1/2 ml-6 md:ml-0">
                        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                            <svg class="w-4 h-4 text-gray-500 dark:text-gray-400" aria-hidden="true"
                                xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 20">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"
                                    stroke-width="2" d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z" />
                            </svg>
                        </div>
                        <input type="search" wire:model='search' id="search"
                            class="block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-[#ED1C24] focus:border-[#ED1C24] "
                            placeholder="Pesquise aqui" required>
                    </div>
                </div>

                <div class="w-full px-2 py-8 space-y-20 md:ml-6">
                    @forelse ($news as $n)
                        <div class="p-2 px-4 space-y-5 rounded-md shadow-md">
                            <h1 class="text-xl font-bold">{{ $n->title }}</h1>
                            <p class="text-lg font-semibold text-gray-600">
                                {{ $n->subtitle }}
                            </p>
                            {!! $n->lead !!}

                            <div class="flex items-center justify-between">
                                <span class="font-semibold">Publicado {{ $n->created_at->diffForHumans() }}</span>
                                <div class="flex items-center justify-end md:gap-5">
                                    <a href="{{ route('show.news', $n->id) }}"
                                        class="bg-[#ED1C24] hover:bg-[#f14e53] text-white px-4 py-2 rounded-md">Detalhes</a>
                                </div>
                            </div>
                        </div>
                    @empty
                        <div class="w-full flex flex-col justify-center items-center">
                            <div class="flex items-center flex-col justify-center w-full">
                                <img src="{{ asset('img/erro.png') }}" alt="404">
                                <p class="text-[#ED1C24] font-semibold whitespace-nowrap">Palavra chave não encontrada: </p>
                                <label for="search"
                                    class="flex items-center gap-2 w-auto py-2 px-2 text-sm rounded-lg hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 cursor-pointer">
                                    <strong class="text-black">{{ $search }}</strong>
                                    <svg class="w-2 h-2 text-gray-500" aria-hidden="true"
                                        xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                                        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"
                                            stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6" />
                                    </svg>
                                </label>
                            </div>
                        </div>
                    @endforelse

                    <div class="flex items-center justify-end w-full">{{ $news->links() }}</div>
                </div>
            </div>
        </div>
    </div>

</div>
