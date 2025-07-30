<?php

namespace App\Models;

use App\Enums\BloodType;
use App\Enums\DonationStatus;
use App\Services\EncryptionService;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Cache;

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
        'encrypted_medical_notes',
        'medical_notes_hash',
        'encrypted_health_questions',
        'health_questions_hash',
        'encrypted_at',
        'confirmation_token',
        'confirmation_expires_at',
        'confirmed_by',
        'confirmed_at',
    ];

    protected $casts = [
        'donation_date' => 'date',
        'donation_time' => 'datetime:H:i',
        'reminder_sent_at' => 'datetime',
        'confirmation_expires_at' => 'datetime',
        'confirmed_at' => 'datetime',
        'is_first_time_donor' => 'boolean',
        'reminder_sent' => 'boolean',
        'blood_type' => BloodType::class,
        'status' => DonationStatus::class,
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($donation) {
            if (empty($donation->donation_token)) {
                $donation->donation_token = self::generateDonationToken();
            }
            if (empty($donation->confirmation_token)) {
                $donation->confirmation_token = self::generateConfirmationToken();
            }
            if (empty($donation->confirmation_expires_at)) {
                $donation->confirmation_expires_at = now()->addHours(24);
            }
        });
    }

    // Relacionamento com hemocentro
    public function bloodcenter()
    {
        return $this->belongsTo(BloodCenter::class);
    }

    // Relacionamento com usuário (minimal)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    // Relacionamento com o funcionário que confirmou a doação
    public function confirmedBy()
    {
        return $this->belongsTo(User::class, 'confirmed_by');
    }

    // Gera token único para a doação
    public static function generateDonationToken(): string
    {
        do {
            $token = Str::random(32);
        } while (self::where('donation_token', $token)->exists());

        return $token;
    }

    // Gera token de confirmação
    public static function generateConfirmationToken(): string
    {
        do {
            $token = Str::random(16);
        } while (self::where('confirmation_token', $token)->exists());

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
        return $query->where('status', DonationStatus::SCHEDULED);
    }

    // Scope para doações ativas (não canceladas)
    public function scopeActive($query)
    {
        return $query->whereNotIn('status', [DonationStatus::CANCELLED, DonationStatus::NO_SHOW]);
    }

    // Verifica se a doação pode ser editada
    public function canBeEdited(): bool
    {
        return in_array($this->status, [DonationStatus::SCHEDULED, DonationStatus::CONFIRMED]);
    }

    // Verifica se a doação pode ser cancelada
    public function canBeCancelled(): bool
    {
        return in_array($this->status, [DonationStatus::SCHEDULED, DonationStatus::CONFIRMED]) &&
               $this->donation_date->isFuture();
    }

    // Verifica se o token de confirmação é válido
    public function isConfirmationTokenValid(): bool
    {
        return $this->confirmation_token && 
               $this->confirmation_expires_at && 
               $this->confirmation_expires_at->isFuture();
    }

    // Gera novo token de confirmação
    public function refreshConfirmationToken(): void
    {
        $this->update([
            'confirmation_token' => self::generateConfirmationToken(),
            'confirmation_expires_at' => now()->addHours(24),
        ]);
    }

    // Marca como confirmada
    public function markAsConfirmed(): void
    {
        $this->update([
            'status' => DonationStatus::CONFIRMED,
            'confirmation_token' => null,
            'confirmation_expires_at' => null,
        ]);
    }

    // Marca como concluída
    public function markAsCompleted(): void
    {
        $this->update(['status' => DonationStatus::COMPLETED]);
    }

    // Marca como cancelada
    public function markAsCancelled(): void
    {
        $this->update(['status' => DonationStatus::CANCELLED]);
    }

    // Verifica se precisa de lembrança
    public function needsReminder(): bool
    {
        return !$this->reminder_sent && 
               $this->status === DonationStatus::SCHEDULED &&
               $this->donation_date->isFuture() &&
               $this->donation_date->diffInDays(now()) <= 1;
    }

    // Marca lembrança como enviada
    public function markReminderSent(): void
    {
        $this->update([
            'reminder_sent' => true,
            'reminder_sent_at' => now(),
        ]);
    }

    // Cache para doações por token
    public static function findByToken(string $token): ?self
    {
        $cacheKey = "donation_token_{$token}";
        
        return Cache::remember($cacheKey, 300, function () use ($token) {
            return self::where('donation_token', $token)
                      ->with('bloodcenter')
                      ->first();
        });
    }

    // Métodos de criptografia automática para campos sensíveis
    public function setMedicalNotesAttribute(?string $value): void
    {
        if ($value) {
            $this->attributes['encrypted_medical_notes'] = EncryptionService::encryptMedicalNotes($value);
            $this->attributes['medical_notes_hash'] = EncryptionService::hashForSearch($value);
            $this->attributes['encrypted_at'] = now();
            $this->attributes['medical_notes'] = null; // Não armazenar texto plano
        }
    }

    public function getMedicalNotesAttribute(): ?string
    {
        return EncryptionService::decryptMedicalNotes($this->encrypted_medical_notes);
    }

    public function setHealthQuestionsAttribute(?string $value): void
    {
        if ($value) {
            $this->attributes['encrypted_health_questions'] = EncryptionService::encryptSensitiveData($value);
            $this->attributes['health_questions_hash'] = EncryptionService::hashForSearch($value);
            $this->attributes['encrypted_at'] = now();
        }
    }

    public function getHealthQuestionsAttribute(): ?string
    {
        return EncryptionService::decryptSensitiveData($this->encrypted_health_questions);
    }

    // Busca por notas médicas usando hash
    public static function findByMedicalNotesHash(string $hash): Collection
    {
        return self::where('medical_notes_hash', $hash)->get();
    }

    // Busca por questões de saúde usando hash
    public static function findByHealthQuestionsHash(string $hash): Collection
    {
        return self::where('health_questions_hash', $hash)->get();
    }

    // Verifica se tem dados criptografados
    public function hasEncryptedData(): bool
    {
        return !empty($this->encrypted_medical_notes) || !empty($this->encrypted_health_questions);
    }

    // Exporta dados para auditoria (sem informações sensíveis)
    public function toAuditArray(): array
    {
        return [
            'id' => $this->id,
            'donation_token' => $this->donation_token,
            'user_id' => $this->user_id,
            'blood_type' => $this->blood_type,
            'donation_date' => $this->donation_date,
            'status' => $this->status,
            'bloodcenter_id' => $this->bloodcenter_id,
            'has_encrypted_data' => $this->hasEncryptedData(),
            'encrypted_at' => $this->encrypted_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

    // Limpa cache ao atualizar
    protected static function booted()
    {
        static::updated(function ($donation) {
            Cache::forget("donation_token_{$donation->donation_token}");
        });
    }
}