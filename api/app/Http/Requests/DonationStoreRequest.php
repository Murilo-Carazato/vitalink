<?php

namespace App\Http\Requests;

use App\Enums\BloodType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DonationStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'blood_type' => ['required', Rule::enum(BloodType::class)],
            'donation_date' => [
                'required', 
                'date', 
                'after:today',
                function ($attribute, $value, $fail) {
                    // Don't allow scheduling on weekends
                    $date = new \DateTime($value);
                    if ($date->format('N') >= 6) {
                        $fail('Não é possível agendar doações para finais de semana.');
                    }
                    
                    // Don't allow scheduling more than 3 months in advance
                    $maxDate = now()->addMonths(3);
                    if ($date > $maxDate) {
                        $fail('Não é possível agendar com mais de 3 meses de antecedência.');
                    }
                },
            ],
            'donation_time' => [
                'required', 
                'date_format:H:i',
                function ($attribute, $value, $fail) {
                    $time = new \DateTime($value);
                    $startTime = new \DateTime('08:00');
                    $endTime = new \DateTime('17:00');
                    
                    if ($time < $startTime || $time > $endTime) {
                        $fail('O horário deve estar entre 08:00 e 17:00.');
                    }
                },
            ],
            'bloodcenter_id' => [
                'required', 
                'exists:bloodcenters,id',
                function ($attribute, $value, $fail) {
                    // Check if blood center is active
                    $bloodCenter = \App\Models\BloodCenter::find($value);
                    if (!$bloodCenter || !$bloodCenter->is_active) {
                        $fail('Este hemocentro não está disponível para agendamento.');
                    }
                },
            ],
            'donor_age_range' => ['required', 'in:18-25,26-35,36-45,46-55,56-65,65+'],
            'donor_gender' => ['required', 'in:M,F,O'],
            'is_first_time_donor' => ['required', 'boolean'],
            'medical_notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'donation_token.required' => 'Token de doação é obrigatório.',
            'donation_token.unique' => 'Token de doação já existe.',
            'blood_type.required' => 'Tipo sanguíneo é obrigatório.',
            'donation_date.required' => 'Data da doação é obrigatória.',
            'donation_date.after' => 'Data da doação deve ser futura.',
            'donation_date.date' => 'Formato de data inválido.',
            'donation_time.required' => 'Horário da doação é obrigatório.',
            'donation_time.date_format' => 'Formato de horário inválido. Use HH:MM.',
            'bloodcenter_id.required' => 'Hemocentro é obrigatório.',
            'bloodcenter_id.exists' => 'Hemocentro não encontrado.',
            'donor_age_range.required' => 'Faixa etária é obrigatória.',
            'donor_age_range.in' => 'Faixa etária inválida.',
            'donor_gender.required' => 'Gênero é obrigatório.',
            'donor_gender.in' => 'Gênero inválido. Use M, F ou O.',
            'is_first_time_donor.required' => 'Informe se é sua primeira doação.',
            'is_first_time_donor.boolean' => 'Valor inválido para primeira doação.',
            'medical_notes.max' => 'As observações médicas não podem ultrapassar 1000 caracteres.',
        ];
    }
}