<?php

namespace Database\Seeders;

use App\Models\BloodCenter;
use Illuminate\Database\Seeder;

class BloodCenterSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $centers = [
            [
                'name' => 'Fundação Pró-Sangue (Clínicas - SP)',
                'address' => 'Av. Dr. Enéas Carvalho de Aguiar, 155 - Cerqueira César, São Paulo - SP',
                'phone_number' => '(11) 4573-7800',
                'latitude' => -23.5576,
                'longitude' => -46.6687,
                'email' => 'atendimento@prosangue.sp.gov.br',
                'site' => 'http://www.prosangue.sp.gov.br',
            ],
            [
                'name' => 'Hemocentro da Unicamp (Campinas)',
                'address' => 'R. Carlos Chagas, 480 - Cidade Universitária, Campinas - SP',
                'phone_number' => '(19) 3521-8705',
                'latitude' => -22.8306,
                'longitude' => -47.0628,
                'email' => 'coleta@unicamp.br',
                'site' => 'https://www.hemocentro.unicamp.br',
            ],
            [
                'name' => 'Hemorio (RJ)',
                'address' => 'R. Frei Caneca, 8 - Centro, Rio de Janeiro - RJ',
                'phone_number' => '(21) 2332-8611',
                'latitude' => -22.9068,
                'longitude' => -43.1895,
                'email' => 'hemorio@saude.rj.gov.br',
                'site' => 'http://www.hemorio.rj.gov.br',
            ],
            [
                'name' => 'Hemominas (BH)',
                'address' => 'Alameda Ezequiel Dias, 321 - Santa Efigênia, Belo Horizonte - MG',
                'phone_number' => '155',
                'latitude' => -19.9242,
                'longitude' => -43.9317,
                'email' => 'faleconosco@hemominas.mg.gov.br',
                'site' => 'http://www.hemominas.mg.gov.br',
            ],
            [
                'name' => 'Hemepar (Curitiba)',
                'address' => 'Tv. João Prosdócimo, 145 - Alto da XV, Curitiba - PR',
                'phone_number' => '(41) 3281-4000',
                'latitude' => -25.4267,
                'longitude' => -49.2598,
                'email' => 'hemepar@sesa.pr.gov.br',
                'site' => 'http://www.saude.pr.gov.br',
            ],
        ];

        foreach ($centers as $center) {
            BloodCenter::updateOrCreate(
                ['name' => $center['name']], // Evita duplicatas se rodar o seeder 2x
                $center
            );
        }
    }
}
