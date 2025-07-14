<?php

namespace App\Services;

use App\Models\Donation;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Database\Eloquent\Builder;

class DonationService
{
    /**
     * Get a paginated and filtered list of donations.
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

        $query->with('bloodcenter')->orderBy('donation_date', 'desc');

        return $query;
    }

    /**
     * Find a donation by its token.
     */
    public function getDonationByToken(string $token): ?Donation
    {
        return Donation::where('donation_token', $token)->with('bloodcenter')->first();
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
        if ($donation->bloodcenter_id != $user->bloodcenter_id) {
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
    public function confirmDonation(Donation $donation, array $data): Donation
    {
        $donation->update($data);
        return $donation;
    }

    /**
     * Cancel a donation.
     */
    public function cancelDonation(Donation $donation): Donation
    {
        if (!$donation->canBeCancelled()) {
            abort(Response::HTTP_FORBIDDEN, 'Doação não pode ser cancelada');
        }

        $donation->update(['status' => 'cancelled']);
        return $donation;
    }

    /**
     * Get donation statistics.
     */
    public function getDonationStatistics(Request $request): array
    {
        $query = Donation::query();

        // Adicionar lógica de permissão se necessário
        // if ($request->user()->isadmin == 'admin') {
        //     $query->where('bloodcenter_id', $request->user()->bloodcenter_id);
        // }

        return [
            'total_donations' => (clone $query)->count(),
            'completed_donations' => (clone $query)->where('status', 'completed')->count(),
            'scheduled_donations' => (clone $query)->where('status', 'scheduled')->count(),
            'cancelled_donations' => (clone $query)->where('status', 'cancelled')->count(),
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
     * Generate a unique donation token.
     */
    public function generateToken(): string
    {
        return Donation::generateDonationToken();
    }

    /**
     * Get all donations for a specific user.
     */
    public function getDonationsForUser(User $user)
    {
        return $user->donations()->with('bloodcenter')->orderBy('donation_date', 'desc')->get();
    }
}