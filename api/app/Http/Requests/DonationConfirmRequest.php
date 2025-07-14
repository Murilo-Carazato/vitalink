<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DonationConfirmRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'in:confirmed,cancelled'],
            'staff_notes' => ['nullable', 'string', 'max:1000'],
            'donation_time' => ['nullable', 'date_format:H:i'],
        ];
    }
}