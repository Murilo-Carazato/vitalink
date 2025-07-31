<div>
    <div class="flex flex-col items-center justify-center">

        <div class="w-full space-y-20">

            {{-- Noticias --}}
            <div class="space-y-2">
                <div class="flex items-center justify-between">
                    <x-title title="{{ $news->title }}" />
                    <x-views :number="$news->views" />
                </div>

                <div class="w-full p-6 space-y-5 md:p-0 md:ml-6">
                    <p class="text-lg font-semibold text-gray-600 ">
                        {{ $news->subtitle }}
                    </p>

                    <div class="space-y-10">
                        <div>{!! $news->lead !!}</div>

                        <div class="space-y-5">{!! $news->body !!}</div>
                    </div>
                </div>

            </div>
            <div class="space-y-2" id="recentes">
                <x-title title="Recentes" />

                <livewire:recent-news>
            </div>
            <div class="space-y-2">
                <x-title title="Outras Notícias" />

                <div class="w-full md:ml-6 swiper others">
                    <div class="w-full px-2 py-8 cursor-grab swiper-wrapper">
                        @foreach ($others as $other)
                            <div class="p-2 px-4 space-y-5 rounded-md shadow-md swiper-slide">
                                <h1 class="text-xl font-bold">{{ $other->title }}</h1>
                                <p class="text-lg font-semibold">
                                    {{ $other->subtitle }}
                                </p>
                                {!! $other->lead !!}

                                <div class="flex items-center justify-between">
                                    <span class="font-semibold">Publicado {{ $other->created_at->diffForHumans() }}</span>
                                    <div class="flex items-center justify-end md:gap-5">
                                        <x-views :number="$other->views" />
                                        <a href="{{ route('show.news', $other->id) }}" class="bg-[#ED1C24] hover:bg-[#f14e53] text-white px-4 py-2 rounded-md">Detalhes</a>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                    <div class="swiper-pagination"></div>


                    <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>

                    <script>
                        var swiper = new Swiper(".others", {
                            spaceBetween: 30,
                            centeredSlides: true,
                            autoplay: {
                                delay: 3000,
                                disableOnInteraction: false,
                            },
                            pagination: {
                                el: ".swiper-pagination",
                                clickable: true,
                            },
                        });
                    </script>
                </div>
            </div>


        </div>
    </div>

</div>
