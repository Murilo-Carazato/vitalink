<?php

namespace App\Http\Controllers;

use App\Http\Requests\DonationStoreRequest;
use App\Http\Requests\DonationUpdateRequest;
use App\Http\Requests\DonationConfirmRequest;
use App\Services\DonationService;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
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
        // Only admins can list all donations
        if (!$request->user()->isAdmin()) {
            return response()->json([
                'message' => 'Acesso não autorizado'
            ], Response::HTTP_FORBIDDEN);
        }

        $query = $this->donationService->getDonations($request);
        return response()->json(['data' => PaginateAndFilter::response($query)]);
    }

    /**
     * Schedule a new donation.
     */
    public function store(DonationStoreRequest $request)
    {
        $data = $request->validated();
        $data['user_id'] = $request->user()->id;
        
        $donation = $this->donationService->createDonation($data);

        return response()->json([
            'message' => 'Doação agendada com sucesso',
            'data' => $donation->load('bloodcenter'),
            'donation_token' => $donation->donation_token,
            'confirmation_token' => $donation->confirmation_token,
        ], Response::HTTP_CREATED);
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
     * Complete donation (user can only complete their own).
     */
    public function complete(Request $request, string $token)
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