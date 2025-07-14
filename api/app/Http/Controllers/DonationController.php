<?php

namespace App\Http\Controllers;

use App\Http\Requests\DonationStoreRequest;
use App\Http\Requests\DonationUpdateRequest;
use App\Http\Requests\DonationConfirmRequest;
use App\Services\DonationService;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DonationController extends Controller
{
    protected $donationService;

    public function __construct(DonationService $donationService)
    {
        $this->donationService = $donationService;
    }

    public function index(Request $request)
    {
        $query = $this->donationService->getDonations($request);
        return response()->json(['data' => PaginateAndFilter::response($query)]);
    }

    public function store(DonationStoreRequest $request)
    {
        $data = $request->validated();
        $data['user_id'] = $request->user()->id;
        $donation = $this->donationService->createDonation($data);

        return response()->json([
            'message' => 'Doação agendada com sucesso',
            'data' => $donation->load('bloodcenter'),
            'donation_token' => $donation->donation_token
        ], Response::HTTP_CREATED);
    }

    public function show(string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        return response()->json(['data' => $donation], Response::HTTP_OK);
    }

    public function update(DonationUpdateRequest $request, string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        $updatedDonation = $this->donationService->updateDonation($donation, $request->validated(), $request->user());

        return response()->json([
            'message' => 'Doação atualizada com sucesso',
            'data' => $updatedDonation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    public function confirm(DonationConfirmRequest $request, string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        $confirmedDonation = $this->donationService->confirmDonation($donation, $request->validated());

        return response()->json([
            'message' => 'Status da doação atualizado com sucesso',
            'data' => $confirmedDonation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    public function cancel(Request $request, string $token)
    {
        $donation = $this->donationService->getDonationByToken($token);

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        $this->donationService->cancelDonation($donation);

        return response()->json([
            'message' => 'Doação cancelada com sucesso',
            'data' => $donation
        ], Response::HTTP_OK);
    }

    public function statistics(Request $request)
    {
        $stats = $this->donationService->getDonationStatistics($request);
        return response()->json(['data' => $stats], Response::HTTP_OK);
    }

    public function generateToken()
    {
        $token = $this->donationService->generateToken();
        return response()->json(['token' => $token]);
    }

    public function getDonationsForUser(Request $request)
    {
        $donations = $this->donationService->getDonationsForUser($request->user());
        return response()->json(['data' => $donations]);
    }
}