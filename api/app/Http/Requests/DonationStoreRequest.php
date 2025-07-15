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
            'donation_date' => ['required', 'date', 'after:today'],
            'donation_time' => ['nullable', 'date_format:H:i'],
            'bloodcenter_id' => ['required', 'exists:bloodcenters,id'],
            'donor_age_range' => ['nullable', 'in:18-25,26-35,36-45,46-55,56-65,65+'],
            'donor_gender' => ['nullable', 'in:M,F,O'],
            'is_first_time_donor' => ['boolean'],
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
            'bloodcenter_id.required' => 'Hemocentro é obrigatório.',
            'bloodcenter_id.exists' => 'Hemocentro não encontrado.',
        ];
    }
}