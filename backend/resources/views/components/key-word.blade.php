<div class="absolute z-40 flex flex-col items-center justify-center w-full py-10 bg-[#ED1C24] my-16 right-0 p-16">
    <h1 class="text-2xl font-semibold leading-9 text-center text-white md:text-3xl">
        Não encontrou sua notícia? Experimente usar palavras-chave
    </h1>
    <p class="mt-6 text-base leading-normal text-center text-white">
        Se você não encontrou a notícia que estava procurando, não desanime! Você pode tentar usar
        palavras-chave para refinar sua pesquisa.
        <br />
        Palavras-chave são termos que descrevem o assunto da notícia que você está procurando.
    </p>

    <form id="pesquisa-form" action="{{ route('news') }}" method="GET" class="flex flex-col items-center w-full mt-12 space-y-4 border-white sm:border sm:flex-row lg:w-5/12 sm:space-y-0">
        <input name="search" class="w-full p-4 text-base font-medium leading-none text-white placeholder-white bg-transparent border border-white sm:border-transparent focus:outline-none " placeholder="Palavra chave" />
        <button class="w-full px-6 py-4 bg-white border border-white focus:outline-none sm:border-transparent sm:w-auto hover:bg-opacity-75" type="submit">Buscar</button>
    </form>
    
    <script>
        const form = document.getElementById("pesquisa-form");
    
        form.addEventListener("submit", function (event) {
            event.preventDefault();
    
            const searchValue = form.querySelector('input[name="search"]').value;
    
            window.location.href = `{{ route('news') }}?search=${searchValue}#pesquisa`;
        });
    </script>

    
</div>
