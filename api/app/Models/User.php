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
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'bloodcenter_id',
        'isadmin',
        'email_verified_at',
        'last_login_at',
        'is_active',
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
            'name' => $this->name,
            'email' => $this->email,
            'bloodcenter_id' => $this->bloodcenter_id,
            'isadmin' => $this->isadmin,
        ];
    }

    /**
     * Check if user is active and verified.
     */
    public function isActiveAndVerified(): bool
    {
        return $this->is_active && $this->hasVerifiedEmail();
    }
}
