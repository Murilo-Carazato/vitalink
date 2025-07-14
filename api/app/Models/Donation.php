<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Donation extends Model
{
    use HasFactory;

    protected $fillable = [
        'donation_token',
        'user_id',
        'blood_type',
        'donation_date',
        'donation_time',
        'status',
        'bloodcenter_id',
        'donor_age_range',
        'donor_gender',
        'is_first_time_donor',
        'medical_notes',
        'staff_notes',
        'reminder_sent',
        'reminder_sent_at',
    ];

    protected $casts = [
        'donation_date' => 'date',
        'donation_time' => 'datetime:H:i',
        'reminder_sent_at' => 'datetime',
        'is_first_time_donor' => 'boolean',
        'reminder_sent' => 'boolean',
    ];

    // Relacionamento com hemocentro
    public function bloodcenter()
    {
        return $this->belongsTo(BloodCenter::class);
    }

    // Gera token único para a doação
    public static function generateDonationToken(): string
    {
        do {
            $token = Str::random(32);
        } while (self::where('donation_token', $token)->exists());

        return $token;
    }

    // Scope para filtrar por hemocentro
    public function scopeForBloodCenter($query, $bloodcenterId)
    {
        return $query->where('bloodcenter_id', $bloodcenterId);
    }

    // Scope para doações de hoje
    public function scopeToday($query)
    {
        return $query->whereDate('donation_date', today());
    }

    // Scope para doações pendentes de confirmação
    public function scopePendingConfirmation($query)
    {
        return $query->where('status', 'scheduled');
    }

    // Verifica se a doação pode ser editada
    public function canBeEdited(): bool
    {
        return in_array($this->status, ['scheduled', 'confirmed']);
    }

    // Verifica se a doação pode ser cancelada
    public function canBeCancelled(): bool
    {
        return in_array($this->status, ['scheduled', 'confirmed']) && 
               $this->donation_date->isFuture();
    }
}