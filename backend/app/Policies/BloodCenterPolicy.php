<?php

namespace App\Policies;

use App\Models\BloodCenter;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class BloodCenterPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(?User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(?User $user, BloodCenter $bloodCenter): bool
    {
        return true;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->isadmin === 'superadmin';
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, BloodCenter $bloodCenter): bool
    {
        return $user->isadmin === 'superadmin' || $user->bloodcenter_id === $bloodCenter->id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, BloodCenter $bloodCenter): bool
    {
        return $user->isadmin === 'superadmin';
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, BloodCenter $bloodCenter): bool
    {
        return $user->isadmin === 'superadmin';
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, BloodCenter $bloodCenter): bool
    {
        return $user->isadmin === 'superadmin';
    }
}
