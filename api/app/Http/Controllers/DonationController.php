<?php

namespace App\Http\Controllers;

use App\Http\Requests\DonationStoreRequest;
use App\Http\Requests\DonationUpdateRequest;
use App\Http\Requests\DonationConfirmRequest;
use App\Models\Donation;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DonationController extends Controller
{
    /**
     * Display a listing of donations for the authenticated bloodcenter.
     */
    public function index(Request $request)
    {
        $query = Donation::query();

        // Aplicar filtros de data se especificados
        if ($request->has('date_from')) {
            $query->whereDate('donation_date', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('donation_date', '<=', $request->date_to);
        }

        // Filtro por status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filtro por tipo sanguíneo
        if ($request->has('blood_type')) {
            $query->where('blood_type', $request->blood_type);
        }

        $query->with('bloodcenter');
        $query->orderBy('donation_date', 'desc');

        return response()->json(['data' => PaginateAndFilter::response($query)]);
    }

    /**
     * Store a new donation (rota pública para agendamento).
     */
    public function store(DonationStoreRequest $request)
    {
        $donation = Donation::create($request->validated());

        return response()->json([
            'message' => 'Doação agendada com sucesso',
            'data' => $donation->load('bloodcenter'),
            'donation_token' => $donation->donation_token
        ], Response::HTTP_CREATED);
    }

    /**
     * Display the specified donation by token.
     */
    public function show(string $token)
    {
        $donation = Donation::where('donation_token', $token)
            ->with('bloodcenter')
            ->first();

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        return response()->json(['data' => $donation], Response::HTTP_OK);
    }

    /**
     * Update the specified donation (apenas dados não sensíveis).
     */
    public function update(DonationUpdateRequest $request, string $token)
    {
        $donation = Donation::where('donation_token', $token)->first();

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        // Verificar autorização
        if ($donation->bloodcenter_id != $request->user()->bloodcenter_id) {
            return response()->json(['message' => 'Acesso não autorizado'], Response::HTTP_UNAUTHORIZED);
        }

        // Verificar se a doação pode ser editada
        if (!$donation->canBeEdited()) {
            return response()->json(['message' => 'Doação não pode ser editada'], Response::HTTP_FORBIDDEN);
        }

        $donation->update($request->validated());

        return response()->json([
            'message' => 'Doação atualizada com sucesso',
            'data' => $donation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    /**
     * Confirm or cancel a donation (usado pelo hemocentro).
     */
    public function confirm(DonationConfirmRequest $request, string $token)
    {
        $donation = Donation::where('donation_token', $token)->first();

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        // Verificar autorização
        // if ($donation->bloodcenter_id != $request->user()->bloodcenter_id) {
        //     return response()->json(['message' => 'Acesso não autorizado'], Response::HTTP_UNAUTHORIZED);
        // }

        $donation->update($request->validated());

        return response()->json([
            'message' => 'Status da doação atualizado com sucesso',
            'data' => $donation->load('bloodcenter')
        ], Response::HTTP_OK);
    }

    /**
     * Cancel a donation (pode ser usado pelo app do doador).
     */
    public function cancel(string $token)
    {
        $donation = Donation::where('donation_token', $token)->first();

        if (!$donation) {
            return response()->json(['message' => 'Doação não encontrada'], Response::HTTP_NOT_FOUND);
        }

        if (!$donation->canBeCancelled()) {
            return response()->json(['message' => 'Doação não pode ser cancelada'], Response::HTTP_FORBIDDEN);
        }

        $donation->update(['status' => 'cancelled']);

        return response()->json([
            'message' => 'Doação cancelada com sucesso',
            'data' => $donation
        ], Response::HTTP_OK);
    }

    /**
     * Get donation statistics for a bloodcenter.
     */
    public function statistics(Request $request)
    {
        $query = Donation::query();

        // if ($request->user()->isadmin == 'admin') {
        // }
        // $query->where('bloodcenter_id', $request->user()->bloodcenter_id);

        $stats = [
            'total_donations' => $query->count(),
            'completed_donations' => $query->where('status', 'completed')->count(),
            'scheduled_donations' => $query->where('status', 'scheduled')->count(),
            'cancelled_donations' => $query->where('status', 'cancelled')->count(),
            'donations_today' => $query->whereDate('donation_date', today())->count(),
            'blood_type_distribution' => $query->groupBy('blood_type')
                ->selectRaw('blood_type, count(*) as total')
                ->pluck('total', 'blood_type'),
            'age_distribution' => $query->whereNotNull('donor_age_range')
                ->groupBy('donor_age_range')
                ->selectRaw('donor_age_range, count(*) as total')
                ->pluck('total', 'donor_age_range'),
        ];

        return response()->json(['data' => $stats], Response::HTTP_OK);
    }
}