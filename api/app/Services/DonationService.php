<?php

namespace App\Services;

use App\Models\Donation;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Database\Eloquent\Builder;
use App\Enums\DonationStatus;
use Illuminate\Support\Facades\Cache;

class DonationService
{
    /**
     * Get a paginated and filtered list of donations (admin only).
     */
    public function getDonations(Request $request): Builder
    {
        $query = Donation::query();

        if ($request->has('date_from')) {
            $query->whereDate('donation_date', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('donation_date', '<=', $request->date_to);
        }
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }
        if ($request->has('blood_type')) {
            $query->where('blood_type', $request->blood_type);
        }
        if ($request->has('bloodcenter_id')) {
            $query->where('bloodcenter_id', $request->bloodcenter_id);
        }

        $query->with('bloodcenter')->orderBy('donation_date', 'desc');

        return $query;
    }

    /**
     * Find a donation by its token.
     */
    public function getDonationByToken(string $token): ?Donation
    {
        return Donation::findByToken($token);
    }

    /**
     * Find a donation by its confirmation token.
     */
    public function getDonationByConfirmationToken(string $token): ?Donation
    {
        return Donation::where('confirmation_token', $token)
                      ->with('bloodcenter')
                      ->first();
    }

    /**
     * Schedule a new donation.
     */
    public function createDonation(array $data): Donation
    {
        return Donation::create($data);
    }

    /**
     * Update a donation.
     */
    public function updateDonation(Donation $donation, array $data, User $user): Donation
    {
        if ($donation->user_id !== $user->id) {
            abort(Response::HTTP_UNAUTHORIZED, 'Acesso não autorizado');
        }

        if (!$donation->canBeEdited()) {
            abort(Response::HTTP_FORBIDDEN, 'Doação não pode ser editada');
        }

        $donation->update($data);
        return $donation;
    }
    
    /**
     * Confirm a donation.
     */
    public function confirmDonation(Donation $donation, array $data, User $staff): Donation
    {
        // Only allow confirming future donations
        if ($data['status'] === DonationStatus::CONFIRMED->value && $donation->donation_date->isPast()) {
            throw new \Exception('Não é possível confirmar uma doação passada.');
        }

        // Verify staff has permission to manage this blood center
        if (!$staff->canManageBloodCenter($donation->bloodcenter)) {
            throw new \Exception('Acesso não autorizado a este hemocentro.');
        }

        // Update donation with staff info and notes
        $donation->update([
            'status' => $data['status'],
            'confirmed_by' => $staff->id,
            'confirmed_at' => now(),
            'staff_notes' => $data['staff_notes'] ?? null,
            'donation_time' => $data['donation_time'] ?? $donation->donation_time,
        ]);

        // If status is confirmed, mark as confirmed
        if ($data['status'] === DonationStatus::CONFIRMED->value) {
            $donation->markAsConfirmed();
            
            // Invalidate any other pending confirmations
            Donation::where('user_id', $donation->user_id)
                ->where('id', '!=', $donation->id)
                ->whereIn('status', [DonationStatus::SCHEDULED, DonationStatus::PENDING])
                ->update(['status' => DonationStatus::CANCELLED]);
                
            // Send confirmation notification to donor
            $this->sendConfirmationNotification($donation);
        }
        
        return $donation->refresh();
    }

    /**
     * Cancel a donation.
     */
    public function cancelDonation(Donation $donation, User $user): Donation
    {
        if ($donation->user_id !== $user->id) {
            abort(Response::HTTP_UNAUTHORIZED, 'Acesso não autorizado');
        }

        if (!$donation->canBeCancelled()) {
            abort(Response::HTTP_FORBIDDEN, 'Doação não pode ser cancelada');
        }

        $donation->markAsCancelled();
        return $donation;
    }

    /**
     * Mark a donation as completed.
     */
    public function completeDonation(Donation $donation, User $user): Donation
    {
        if ($donation->user_id !== $user->id) {
            abort(Response::HTTP_UNAUTHORIZED, 'Acesso não autorizado');
        }

        if (!in_array($donation->status, [DonationStatus::SCHEDULED, DonationStatus::CONFIRMED])) {
            abort(Response::HTTP_FORBIDDEN, 'A doação não pode ser concluída no estado atual.');
        }

        $donation->markAsCompleted();
        return $donation;
    }

    /**
     * Get donation statistics (admin only).
     */
    public function getDonationStatistics(Request $request): array
    {
        $query = Donation::query();

        // Filter by blood center if user is admin (not super admin)
        if ($request->user()->isAdmin() && !$request->user()->isSuperAdmin()) {
            $query->where('bloodcenter_id', $request->user()->bloodcenter_id);
        }

        return [
            'total_donations' => (clone $query)->count(),
            'completed_donations' => (clone $query)->where('status', DonationStatus::COMPLETED)->count(),
            'scheduled_donations' => (clone $query)->where('status', DonationStatus::SCHEDULED)->count(),
            'confirmed_donations' => (clone $query)->where('status', DonationStatus::CONFIRMED)->count(),
            'cancelled_donations' => (clone $query)->where('status', DonationStatus::CANCELLED)->count(),
            'donations_today' => (clone $query)->whereDate('donation_date', today())->count(),
            'blood_type_distribution' => (clone $query)->groupBy('blood_type')
                ->selectRaw('blood_type, count(*) as total')
                ->pluck('total', 'blood_type'),
            'age_distribution' => (clone $query)->whereNotNull('donor_age_range')
                ->groupBy('donor_age_range')
                ->selectRaw('donor_age_range, count(*) as total')
                ->pluck('total', 'donor_age_range'),
        ];
    }

    /**
     * Get all donations for a specific user.
     */
    public function getDonationsForUser(User $user)
    {
        return $user->donations()
                   ->with('bloodcenter')
                   ->orderBy('donation_date', 'desc')
                   ->get();
    }

    /**
     * Get donations that need reminders.
     */
    public function getDonationsNeedingReminders()
    {
        return Donation::where('status', DonationStatus::SCHEDULED)
                      ->where('reminder_sent', false)
                      ->where('donation_date', '>', now())
                      ->where('donation_date', '<=', now()->addDay())
                      ->with('user', 'bloodcenter')
                      ->get();
    }

    /**
     * Send reminder for a donation.
     */
    public function sendReminder(Donation $donation): bool
    {
        if (!$donation->needsReminder()) {
            return false;
        }

        // Here you would implement the actual reminder sending logic
        // For now, just mark as sent
        $donation->markReminderSent();
        
        return true;
    }

    /**
     * Get donations for a specific blood center.
     */
    public function getDonationsForBloodCenter(int $bloodcenterId, Request $request = null)
    {
        $query = Donation::where('bloodcenter_id', $bloodcenterId)
                        ->with('bloodcenter');

        if ($request) {
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }
            if ($request->has('date_from')) {
                $query->whereDate('donation_date', '>=', $request->date_from);
            }
            if ($request->has('date_to')) {
                $query->whereDate('donation_date', '<=', $request->date_to);
            }
        }

        return $query->orderBy('donation_date', 'desc')->get();
    }
}