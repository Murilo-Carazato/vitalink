<div class="w-full md:ml-6 swiper mySwiper">
    <div class="w-full px-2 py-8 cursor-grab swiper-wrapper">
        @foreach ($news as $n)
            <div class="p-2 px-4 space-y-5 rounded-md shadow-md swiper-slide">
                <h1 class="text-xl font-bold">{{ $n->title }}</h1>
                <p class="text-lg font-semibold">
                    {{ $n->subtitle }}  
                </p>
                {!! $n->lead !!} 
             
                <div class="flex items-center justify-between">
                    <span class="font-semibold">Publicado {{ $n->created_at->diffForHumans() }}</span>
                    <div class="flex items-center justify-end md:gap-5">
                        <a href="{{ route('show.news', $n->id) }}" class="bg-[#ED1C24] hover:bg-[#f14e53] text-white px-4 py-2 rounded-md">Detalhes</a>
                    </div>
                </div>
            </div>
        @endforeach
    </div>
    <div class="swiper-pagination"></div>


    <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>

    <script>
        var swiper = new Swiper(".mySwiper", {
            spaceBetween: 30,
            centeredSlides: true,
            autoplay: {
                delay: 2500,
                disableOnInteraction: false,
            },
            pagination: {
                el: ".swiper-pagination",
                clickable: true,
            },
        });
    </script>
</div>
