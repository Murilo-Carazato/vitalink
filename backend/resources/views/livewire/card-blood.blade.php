
@php 
$styleActive = "text-[#ED1C24] hover:text-[#f14e53]";
$styleDefault = "hover:text-gray-600";
@endphp
<div class="w-full bg-white border border-gray-200 rounded-lg shadow ">
    <ul
        class="flex flex-wrap justify-center ml-0 text-sm font-medium text-center text-gray-500 list-none border-b border-gray-200 rounded-t-lg bg-gray-50 md:justify-between">
        <li>
            <button type="button" wire:click="x_click(0)"
                class="rounded-tl-lg p-4 lg:hover:bg-gray-100 @if ($pos == 0) {{ $styleActive }} @else {{ $styleDefault }} @endif">Requisitos
                para doar sangue</button>
        </li>
        <li>
            <button type="button" wire:click="x_click(1)"
                class="p-4 lg:hover:bg-gray-100 @if ($pos == 1) {{ $styleActive }} @else {{ $styleDefault }} @endif">Passos
                para doar sangue</button>
        </li>
        <li>
            <button type="button" wire:click="x_click(2)"
                class="p-4 lg:hover:bg-gray-100 @if ($pos == 2) {{ $styleActive }} @else {{ $styleDefault }} @endif">Para
                se preparar para doar sangue, é importante</button>
        </li>
        <li>
            <button type="button" wire:click="x_click(3)"
                class="rounded-tr-lg  p-4 lg:hover:bg-gray-100 @if ($pos == 3) {{ $styleActive }} @else {{ $styleDefault }} @endif">Cuidados
                após doar sangue</button>
        </li>
    </ul>
    <div>
        @switch($pos)
            @case(0)
                <div class="p-4 bg-white rounded-lg md:p-8 dark:bg-gray-800">
                    <h2 class="mb-3 text-2xl font-extrabold tracking-tight text-gray-900 md:text-3xl dark:text-white">Requisitos
                    </h2>
                    <div class="flex flex-col justify-between mt-6 2xl:whitespace-nowrap xl:flex-row">
                        <ul class="ml-6 space-y-2">
                            <li class="list">Ter entre 16 e 69 anos;</li>
                            <li class="list">Pesar mais de 50 kg;</li>
                            <li class="list">Estar em bom estado de saúde;</li>
                            <li class="list">Não estar grávida ou amamentando;</li>
                            <li class="list">Não ter ingerido bebidas alcoólicas nas últimas 12 horas;</li>
                            <li class="list">Não ter feito tatuagem ou piercing nos últimos 12 meses;</li>
                        </ul>
                        <ul class="ml-6 space-y-2">
                            <li class="list">Não ter feito endoscopia ou colonoscopia nos últimos 6 meses;</li>
                            <li class="list">Não ter tido hepatite B, hepatite C ou HIV;</li>
                            <li class="list">Não ter tido sífilis ou chagas;</li>
                            <li class="list">Não ter tido malária;</li>
                            <li class="list">Não ter tido dengue, chikungunya ou zika nos últimos 12 meses;</li>
                            <li class="list">Não estar tomando medicamentos que impeçam a doação de sangue;</li>
                        </ul>
                    </div>
                </div>
            @break

            @case(1)
                <div class="p-4 bg-white rounded-lg md:p-8 dark:bg-gray-800">
                    <h2 class="mb-3 text-2xl font-extrabold tracking-tight text-gray-900 md:text-3xl dark:text-white">Passos
                        para doar sangue</h2>
                    <!-- List -->
                    <div class="flex flex-col justify-between mt-6 2xl:whitespace-nowrap xl:flex-row">
                        <ul class="ml-6 space-y-2">
                            <li class="list">
                                <span>
                                    <strong>Triagem:</strong> O doador será entrevistado por um profissional de saúde para avaliar sua condição física e verificar se ele atende aos requisitos para doação
                                </span>
                            </li>
                            <li class="list">
                                <span>
                                    <strong>Coleta de sangue:</strong> O doador terá seu sangue coletado por um profissional de saúde. O procedimento é indolor e leva cerca de 10 minutos.
                                </span>
                            </li>
                            <li class="list">
                                <span>
                                    <strong>Repouso:</strong> Após a coleta, o doador deverá descansar por alguns minutos antes de sair.
                                </span>
                            </li>
                        </ul>
                    </div>
                </div>
            @break

            @case(2)
                <div class="p-4 bg-white rounded-lg md:p-8 dark:bg-gray-800">
                    <h2 class="mb-3 text-2xl font-extrabold tracking-tight text-gray-900 md:text-3xl dark:text-white">Para se
                        preparar para doar sangue, é importante</h2>
                    <!-- List -->
                    <div class="flex flex-col justify-between mt-6 2xl:whitespace-nowrap xl:flex-row">
                        <ul class="ml-6 space-y-2">
                            <li class="list">Dormir bem na noite anterior à doação;</li>
                            <li class="list">Comer uma refeição leve antes da doação;</li>
                            <li class="list">Evitar bebidas alcoólicas nas últimas 12 horas;</li>
                        </ul>
                        <ul class="ml-6 space-y-2">
                            <li class="list">Evitar fumar nas duas horas anteriores à doação;</li>
                            <li class="list">Beber bastante líquido nas horas que antecedem a doação.</li>
                        </ul>
                    </div>
                </div>
            @break

            @case(3)
                <div class="p-4 bg-white rounded-lg md:p-8 dark:bg-gray-800" id="statistics" role="tabpanel"
                    aria-labelledby="statistics-tab">
                    <h2 class="mb-3 text-2xl font-extrabold tracking-tight text-gray-900 md:text-3xl dark:text-white">Cuidados
                        após doar sangue</h2>
                    <!-- List -->
                    <div class="flex flex-col justify-between mt-6 2xl:whitespace-nowrap xl:flex-row">
                        <ul class="ml-6 space-y-2">
                            <li class="list">Beber bastante líquido;</li>
                            <li class="list">Evitar atividades físicas intensas por 24 horas;</li>
                            <li class="list">Evitar fumar por 24 horas;</li>
                            <li class="list">Observar a área da punção por sinais de sangramento ou hematomas.</li>
                        </ul>
                    </div>
                </div>
            @break
        @endswitch

    </div>
</div>
