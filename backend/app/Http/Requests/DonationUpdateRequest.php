<?php

namespace App\Http\Requests;

use App\Enums\DonationStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

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
            'status' => ['nullable', Rule::enum(DonationStatus::class)],
            'medical_notes' => ['nullable', 'string', 'max:1000'],
            'staff_notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}