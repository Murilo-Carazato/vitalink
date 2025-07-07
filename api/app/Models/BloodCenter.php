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
    ];

    public function users()
    {
        return $this->has(User::class);
    }
}
