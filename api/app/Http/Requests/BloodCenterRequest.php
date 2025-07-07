<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class BloodCenterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:5', 'max:80'],
            'address' => ['required', 'string'],
            'latitude' => ['required', 'decimal:5,20'],
            'longitude' => ['required', 'decimal:5,20'],
            'email' => ['required', 'email', Rule::unique('bloodcenters')->ignore($this->id)],
            'site' => ['URL'],
        ];
    }
}
