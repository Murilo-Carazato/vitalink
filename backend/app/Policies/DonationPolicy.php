<?php

namespace App\Policies;

use App\Models\Donation;
use App\Models\User;
use App\Enums\DonationStatus;
use Illuminate\Auth\Access\HandlesAuthorization;

class DonationPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any donations.
     */
    public function viewAny(User $user): bool
    {
        return $user->isAdmin();
    }

    /**
     * Determine whether the user can view the donation.
     */
    public function view(User $user, Donation $donation): bool
    {
        // User can view their own donations
        if ($user->id === $donation->user_id) {
            return true;
        }

        // Blood center admins can view donations for their center
        if ($user->isAdmin() && $user->canManageBloodCenter($donation->bloodcenter)) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can create donations.
     */
    public function create(User $user): bool
    {
        // Only verified users can create donations
        if (!$user->hasVerifiedEmail()) {
            return false;
        }

        // Check if user already has active donations
        $hasActiveDonation = Donation::where('user_id', $user->id)
            ->whereIn('status', [DonationStatus::SCHEDULED, DonationStatus::CONFIRMED])
            ->whereDate('donation_date', '>=', now())
            ->exists();

        return !$hasActiveDonation;
    }

    /**
     * Determine whether the user can update the donation.
     */
    public function update(User $user, Donation $donation): bool
    {
        // Only the donation owner can update
        if ($user->id !== $donation->user_id) {
            return false;
        }

        // Can only update if donation is in editable state
        if (!$donation->canBeEdited()) {
            return false;
        }

        // Cannot update if donation is in the past
        if ($donation->donation_date->isPast()) {
            return false;
        }

        return true;
    }

    /**
     * Determine whether the user can delete the donation.
     */
    public function delete(User $user, Donation $donation): bool
    {
        // Only admins can delete donations
        if (!$user->isAdmin()) {
            return false;
        }

        // Blood center admins can only delete donations for their center
        if (!$user->isSuperAdmin() && !$user->canManageBloodCenter($donation->bloodcenter)) {
            return false;
        }

        return true;
    }

    /**
     * Determine whether the user can cancel the donation.
     */
    public function cancel(User $user, Donation $donation): bool
    {
        // Only the donation owner can cancel
        if ($user->id !== $donation->user_id) {
            return false;
        }

        // Can only cancel if donation is in cancellable state
        return $donation->canBeCancelled();
    }

    /**
     * Determine whether the user can confirm the donation.
     */
    public function confirm(User $user, Donation $donation): bool
    {
        // Only blood center staff can confirm
        if (!$user->isAdmin()) {
            return false;
        }

        // Must be able to manage the blood center
        if (!$user->canManageBloodCenter($donation->bloodcenter)) {
            return false;
        }

        // Can only confirm scheduled donations
        if ($donation->status !== DonationStatus::SCHEDULED) {
            return false;
        }

        return true;
    }

    /**
     * Determine whether the user can complete the donation.
     */
    public function complete(User $user, Donation $donation): bool
    {
        // Only blood center staff can complete
        if (!$user->isAdmin()) {
            return false;
        }

        // Must be able to manage the blood center
        if (!$user->canManageBloodCenter($donation->bloodcenter)) {
            return false;
        }

        // Can only complete confirmed donations
        if ($donation->status !== DonationStatus::CONFIRMED) {
            return false;
        }

        // Must be donation day
        if (!$donation->donation_date->isToday()) {
            return false;
        }

        return true;
    }

    /**
     * Determine whether the user can view donation statistics.
     */
    public function viewStatistics(User $user): bool
    {
        return $user->isAdmin();
    }
}
