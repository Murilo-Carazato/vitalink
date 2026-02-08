<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Notifications\ResetPasswordNotification;
use App\Notifications\VerifyEmailNotification;
use Illuminate\Contracts\Auth\MustVerifyEmail;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasFactory, Notifiable, HasApiTokens {
        HasApiTokens::createToken as baseCreateToken;
    }

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'email',
        'password',
        'isadmin',
        'email_verified_at',
        'last_login_at',
        'is_active',
        'bloodcenter_id', // Only for admin users
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'email_verified_at',
        'last_login_at',
        'is_active',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'last_login_at' => 'datetime',
            'is_active' => 'boolean',
            'isadmin' => 'string',
        ];
    }

    /**
     * Send the password reset notification.
     *
     * @param  string  $token
     * @return void
     */
    public function sendPasswordResetNotification($token)
    {
        $this->notify(new ResetPasswordNotification($token));
    }

    /**
     * Send the email verification notification.
     *
     * @return void
     */
    public function sendEmailVerificationNotification()
    {
        $this->notify(new VerifyEmailNotification());
    }

    /**
     * Get the user's blood center.
     */
    public function bloodcenter()
    {
        return $this->belongsTo(BloodCenter::class);
    }

    /**
     * Get the user's news (only for admin users).
     */
    public function news()
    {
        return $this->hasMany(News::class);
    }

    /**
     * Get the user's donations (minimal data only).
     */
    public function donations()
    {
        return $this->hasMany(Donation::class);
    }

    /**
     * Check if user is admin.
     */
    public function isAdmin(): bool
    {
        return in_array($this->isadmin, ['admin', 'superadmin']);
    }

    /**
     * Check if user is super admin.
     */
    public function isSuperAdmin(): bool
    {
        return $this->isadmin === 'superadmin';
    }

    /**
     * Check if user can manage blood center.
     */
    public function canManageBloodCenter(BloodCenter $bloodCenter): bool
    {
        return $this->isSuperAdmin() || 
               ($this->isAdmin() && $this->bloodcenter_id === $bloodCenter->id);
    }

    /**
     * Update last login timestamp.
     */
    public function updateLastLogin(): void
    {
        $this->update(['last_login_at' => now()]);
    }

    /**
     * Get public profile data (minimal).
     */
    public function getPublicProfile(): array
    {
        return [
            'id' => $this->id,
            'email' => $this->email,
            'isadmin' => $this->isadmin,
            'email_verified' => $this->hasVerifiedEmail(),
            'blood_type' => $this->blood_type,
            'birth_date' => $this->birth_date,
        ];
    }

    /**
     * Check if user is active and verified.
     */
    public function isActiveAndVerified(): bool
    {
        return $this->is_active && $this->hasVerifiedEmail();
    }

    /**
     * Get the verification tokens for the user.
     */
    public function verificationTokens()
    {
        return $this->hasMany(\Laravel\Sanctum\PersonalAccessToken::class, 'tokenable_id')
            ->where('name', 'email-verification');
    }
    
    /**
     * Create a new personal access token for the user.
     *
     * @param  string  $name
     * @param  array  $abilities
     * @param  \DateTimeInterface|null  $expiresAt
     * @return \Laravel\Sanctum\NewAccessToken
     */
    public function createToken(string $name, array $abilities = ['*'], \DateTimeInterface $expiresAt = null)
    {
        // Remove tokens antigos do mesmo tipo criados há mais de 1 h
        $this->tokens()
            ->where('name', $name)
            ->where('created_at', '<', now()->subHour())
            ->delete();

        // Chama a implementação original do trait
        return $this->baseCreateToken($name, $abilities, $expiresAt);
    }
    
    /**
     * Get the email address that should be used for verification.
     *
     * @return string
     */
    public function getEmailForVerification()
    {
        return $this->email;
    }
}
