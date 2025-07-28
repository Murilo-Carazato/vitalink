<?php

namespace App\Http\Controllers;

use App\Http\Requests\DonationStoreRequest;
use App\Http\Requests\DonationUpdateRequest;
use App\Http\Requests\DonationConfirmRequest;
use App\Services\DonationService;
use App\Services\PaginateAndFilter;
use App\Models\Donation;
use App\Enums\DonationStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Cache;

class DonationController extends Controller
{
    protected $donationService;

    public function __construct(DonationService $donationService)
    {
        $this->donationService = $donationService;
    }

    /**
     * List donations with proper access control.
     */
    public function index(Request $request)
    {
        // Authorization is handled by DonationPolicy::viewAny
        $this->authorize('viewAny', Donation::class);

        $query = $this->donationService->getDonations($request);
        return response()->json(['data' => PaginateAndFilter::response($query)]);
    }

    /**
     * Schedule a new donation.
     */
    public function store(DonationStoreRequest $request)
    {
        // Authorization is handled by DonationPolicy::create
        $this->authorize('create', Donation::class);
        
        // Rate limiting: max 3 donation requests per day per user
        $maxAttempts = 3;
        $key = 'donation_attempts_' . $request->user()->id;
        
        if (RateLimiter::tooManyAttempts($key, $maxAttempts)) {
            $seconds = RateLimiter::availableIn($key);
            return response()->json([
                'message' => 'Muitas tentativas. Por favor, tente novamente em ' . ceil($seconds / 60) . ' minutos.'
            ], Response::HTTP_TOO_MANY_REQUESTS);
        }

        // Increment the rate limiter
        RateLimiter::hit($key, 24 * 60 * 60); // 24 hours

        // Check for existing active donations
        $hasActiveDonation = Donation::where('user_id', $request->user()->id)
            ->whereIn('status', [DonationStatus::SCHEDULED, DonationStatus::CONFIRMED])
            ->whereDate('donation_date', '>=', now())
            ->exists();

        if ($hasActiveDonation) {
            return response()->json([
                'message' => 'Você já possui uma doação agendada ou confirmada.'
            ], Response::HTTP_CONFLICT);
        }

        $data = $request->validated();
        $data['user_id'] = $request->user()->id;
        
        try {
            $donation = $this->donationService->createDonation($data);

            return response()->json([
                'message' => 'Doação agendada com sucesso',
                'data' => $donation->load('bloodcenter'),
                'donation_token' => $donation->donation_token,
                'confirmation_token' => $donation->confirmation_token,
            ], Response::HTTP_CREATED);
            
        } catch (\Exception $e) {
            // Decrement rate limiter on error
            RateLimiter::clear($key);
            
            return response()->json([
                'message' => 'Erro ao agendar doação. Por favor, tente novamente.'
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get donation by token (public access).
     */
    public function show(string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json([
                'message' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        // Return minimal data for public access
        return response()->json([
            'data' => [
                'donation_token' => $donation->donation_token,
                'blood_type' => $donation->blood_type,
                'donation_date' => $donation->donation_date,
                'donation_time' => $donation->donation_time,
                'status' => $donation->status,
                'bloodcenter' => [
                    'name' => $donation->bloodcenter->name,
                    'address' => $donation->bloodcenter->address,
                ],
            ]
        ], Response::HTTP_OK);
    }

    /**
     * Update donation (user can only update their own).
     */
    public function update(DonationUpdateRequest $request, string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json([
                'message' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        // Check ownership
        if ($donation->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Acesso não autorizado'
            ], Response::HTTP_FORBIDDEN);
        }

        $this->authorize('update', $donation);

        $updatedDonation = $this->donationService->updateDonation($donation, $request->validated(), $request->user());

        return response()->json([
            'message' => 'Doação atualizada com sucesso',
            'data' => $updatedDonation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    /**
     * Confirm donation (blood center access).
     */
    public function confirm(DonationConfirmRequest $request, string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json([
                'message' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        // Check if user can manage this blood center
        if (!$request->user()->canManageBloodCenter($donation->bloodcenter)) {
            return response()->json([
                'message' => 'Acesso não autorizado'
            ], Response::HTTP_FORBIDDEN);
        }

        $confirmedDonation = $this->donationService->confirmDonation($donation, $request->validated());

        return response()->json([
            'message' => 'Status da doação atualizado com sucesso',
            'data' => $confirmedDonation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    /**
     * Cancel donation (user can only cancel their own).
     */
    public function cancel(Request $request, string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json([
                'message' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        // Check ownership
        if ($donation->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Acesso não autorizado'
            ], Response::HTTP_FORBIDDEN);
        }

        $this->donationService->cancelDonation($donation, $request->user());

        return response()->json([
            'message' => 'Doação cancelada com sucesso',
            'data' => $donation
        ], Response::HTTP_OK);
    }

    /**
     * Get donation statistics (admin only).
     */
    public function statistics(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json([
                'message' => 'Acesso não autorizado'
            ], Response::HTTP_FORBIDDEN);
        }

        $stats = $this->donationService->getDonationStatistics($request);
        return response()->json(['data' => $stats], Response::HTTP_OK);
    }

    /**
     * Get user's own donations.
     */
    public function getDonationsForUser(Request $request)
    {
        $donations = $this->donationService->getDonationsForUser($request->user());
        return response()->json(['data' => $donations]);
    }

    /**
     * Complete donation (only blood center staff can complete).
     */
    public function complete(Request $request, string $token)
    {
        // This endpoint should not be accessible to regular users
        // Only blood center staff through admin authentication
        if (!$request->user()->isAdmin()) {
            return response()->json([
                'message' => 'Acesso não autorizado - apenas funcionários de hemocentros'
            ], Response::HTTP_FORBIDDEN);
        }

        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json([
                'message' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        // Verify blood center association
        if (!$request->user()->canManageBloodCenter($donation->bloodcenter)) {
            return response()->json([
                'message' => 'Você não tem permissão para gerenciar este hemocentro'
            ], Response::HTTP_FORBIDDEN);
        }

        // Additional validation: donation must be today and confirmed
        if (!$donation->donation_date->isToday() || $donation->status !== DonationStatus::CONFIRMED) {
            return response()->json([
                'message' => 'Doação não pode ser concluída neste momento'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $completedDonation = $this->donationService->completeDonation($donation, $request->user());

        return response()->json([
            'message' => 'Doação marcada como concluída',
            'data' => $completedDonation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    /**
     * Get donation by confirmation token (public access for blood centers).
     */
    public function getByConfirmationToken(string $token)
    {
        $donation = $this->donationService->getDonationByConfirmationToken($token);

        if (!$donation) {
            return response()->json([
                'message' => 'Token de confirmação inválido'
            ], Response::HTTP_NOT_FOUND);
        }

        if (!$donation->isConfirmationTokenValid()) {
            return response()->json([
                'message' => 'Token de confirmação expirado'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return response()->json([
            'data' => [
                'donation_token' => $donation->donation_token,
                'blood_type' => $donation->blood_type,
                'donation_date' => $donation->donation_date,
                'donation_time' => $donation->donation_time,
                'status' => $donation->status,
                'bloodcenter' => [
                    'name' => $donation->bloodcenter->name,
                    'address' => $donation->bloodcenter->address,
                ],
            ]
        ], Response::HTTP_OK);
    }
}