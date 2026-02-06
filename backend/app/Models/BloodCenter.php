<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BloodCenter extends Model
{
    use HasFactory;
    
    protected $table = 'bloodcenters';
    protected $fillable = [
        'name',
        'email',
        'latitude',
        'longitude',
        'address',
        'phone_number',
        'site',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function users()
    {
        return $this->has(User::class);
    }

    public function donations()
    {
        return $this->hasMany(Donation::class);
    }
}
