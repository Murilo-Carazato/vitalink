<div class="md:space-y-[432px] space-y-[682px]">
    <div class="flex flex-col items-center justify-center">

        <div class="w-full space-y-20">

            {{-- Doar sangue é um ato de amor que pode salvar vidas --}}
            <div class="w-full space-y-2">
                <x-title title="Doar sangue é um ato de amor que pode salvar vidas" />


                <div class="flex flex-col items-start justify-center ml-6 md:flex-row md:ml-0">

                    <img src="{{ asset('gif/doacao-de-sangue.gif') }}" alt="Gota de sangue"
                        class="hidden md:w-1/6 lg:block">

                    <div class="space-y-5">
                        <p>
                            Doar sangue é um gesto simples que pode fazer uma grande diferença na vida de outras pessoas. O sangue é um
                            tecido vital que é necessário para a sobrevivência de pacientes que passam por cirurgias, acidentes,
                            doenças e outras condições médicas.
                        </p>
                        <p>
                            A cada dois segundos, alguém no mundo precisa de transfusão de sangue. No Brasil, são coletadas cerca de 3,5
                            milhões de bolsas de sangue por ano, mas ainda assim, não é suficiente para atender a demanda.
                        </p>
                        <p>
                            Qualquer pessoa saudável entre 16 e 69 anos pode doar sangue. O processo é simples e rápido, e não há riscos para o doador.
                        </p>
                    </div>
                    <x-anchor id="download"/>
                </div>
            </div>

            {{-- Download --}}
            <div class="w-full space-y-2">
                <x-title title="Download" />


                <div class="w-full p-8 text-center rounded-lg shadow-md md:ml-6">
                    <h5 class="mb-2 text-3xl font-bold">Tenha um controle de suas doações</h5>
                    <p class="mb-5 text-base">
                        Baixar o aplicativo do banco de sangue é um ato de solidariedade que pode ajudar a salvar vidas.
                        Faça o download do aplicativo hoje mesmo e ajude a salvar vidas!
                    </p>
                    <div class="items-center justify-center space-y-4 sm:flex sm:space-y-0 sm:space-x-4">
                        <a href="#"
                            class="w-full sm:w-auto bg-[#ED1C24] hover:bg-[#f14e53] focus:ring-4 focus:outline-none focus:ring-[#ED1C24] text-white rounded-lg inline-flex items-center justify-center px-4 py-2.5">
                            <svg class="mr-3 w-7 h-7" aria-hidden="true" focusable="false" data-prefix="fab"
                                data-icon="apple" role="img" xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 384 512">
                                <path fill="currentColor"
                                    d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z">
                                </path>
                            </svg>
                            <div class="text-left">
                                <div class="mb-1 text-xs">Download na</div>
                                <div class="-mt-1 font-sans text-sm font-semibold">Mac App Store</div>
                            </div>
                        </a>
                        <a href="#"
                            class="w-full sm:w-auto bg-[#ED1C24] hover:bg-[#f14e53] focus:ring-4 focus:outline-none focus:ring-[#ED1C24] text-white rounded-lg inline-flex items-center justify-center px-4 py-2.5">
                            <svg class="mr-3 w-7 h-7" aria-hidden="true" focusable="false" data-prefix="fab"
                                data-icon="google-play" role="img" xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 512 512">
                                <path fill="currentColor"
                                    d="M325.3 234.3L104.6 13l280.8 161.2-60.1 60.1zM47 0C34 6.8 25.3 19.2 25.3 35.3v441.3c0 16.1 8.7 28.5 21.7 35.3l256.6-256L47 0zm425.2 225.6l-58.9-34.1-65.7 64.5 65.7 64.5 60.1-34.1c18-14.3 18-46.5-1.2-60.8zM104.6 499l280.8-161.2-60.1-60.1L104.6 499z">
                                </path>
                            </svg>
                            <div class="text-left">
                                <div class="mb-1 text-xs">Download na</div>
                                <div class="-mt-1 font-sans text-sm font-semibold">Google Play</div>
                            </div>
                        </a>
                    </div>
                    <x-anchor id="noticias"/>
                </div>
            </div>
            
            {{-- Noticias --}}
            <div class="w-full space-y-2" >
                <div class="flex items-center justify-between ">
                    <x-title title="Notícias mais recentes" />
                    <a href="{{ route('news') }}"
                        class="text-[#ED1C24] hover:underline whitespace-nowrap text-sm font-semibold md:mr-0 mr-6">Ver todos</a>
                </div>

                <livewire:recent-news>
            </div>


            <x-key-word />

        </div>
    </div>




    <div class="flex items-center justify-center">

        <div class="flex-col items-center justify-center w-full space-y-10">

            {{-- Como doar sangue? --}}
            <div class="space-y-2">
                <x-title title="Como doar sangue?" />

                <div class="ml-6 space-y-5">
                    <p class="text-base ">
                        Para doar sangue, basta procurar um hemocentro ou um posto de coleta de sangue perto de você. O
                        processo de doação de sangue é simples e rápido. Ele dura cerca de 45 minutos, incluindo o tempo
                        de
                        triagem, a coleta do sangue e o repouso.
                    </p>

                    <livewire:card-blood>

                </div>

            </div>

        </div>
    </div>
</div>
