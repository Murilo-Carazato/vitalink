<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

// Request para atualizações (apenas dados não sensíveis)
class DonationUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'donation_date' => ['nullable', 'date', 'after:today'],
            'donation_time' => ['nullable', 'date_format:H:i'],
            'status' => ['nullable', 'in:scheduled,confirmed,completed,cancelled,no_show'],
            'medical_notes' => ['nullable', 'string', 'max:1000'],
            'staff_notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}