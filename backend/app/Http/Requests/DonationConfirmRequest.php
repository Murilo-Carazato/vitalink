<?php

namespace App\Http\Requests;

use App\Enums\DonationStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DonationConfirmRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => [
                'required', 
                Rule::in([DonationStatus::CONFIRMED, DonationStatus::CANCELLED]),
                function ($attribute, $value, $fail) {
                    // Only allow confirming future donations
                    $donation = $this->route('donation');
                    if ($value === DonationStatus::CONFIRMED->value && 
                        $donation->donation_date->isPast()) {
                        $fail('Não é possível confirmar uma doação passada.');
                    }
                },
            ],
            'staff_notes' => ['nullable', 'string', 'max:1000'],
            'donation_time' => [
                'required_if:status,' . DonationStatus::CONFIRMED->value,
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
            'staff_id' => [
                'required',
                'exists:users,id',
                function ($attribute, $value, $fail) {
                    // Verify staff member belongs to the same blood center
                    $staff = \App\Models\User::find($value);
                    $donation = $this->route('donation');
                    
                    if (!$staff || !$staff->canManageBloodCenter($donation->bloodcenter)) {
                        $fail('Funcionário não autorizado a confirmar doações neste hemocentro.');
                    }
                },
            ],
        ];
    }
}