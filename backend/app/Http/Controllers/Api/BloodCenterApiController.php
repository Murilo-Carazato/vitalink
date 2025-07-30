<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BloodCenter;
use App\Models\Donation;
use App\Models\User;
use App\Services\SecurityLogService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\Response;

class BloodCenterApiController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
        $this->middleware('verified');
    }

    /**
     * Authenticate blood center staff
     */
    public function authenticate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
            'blood_center_id' => 'required|exists:blood_centers,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Dados inválidos',
                'details' => $validator->errors()
            ], Response::HTTP_BAD_REQUEST);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            SecurityLogService::logSecurityViolation('blood_center_auth_failed', [
                'email' => $request->email,
                'blood_center_id' => $request->blood_center_id,
                'ip' => $request->ip()
            ]);

            return response()->json([
                'error' => 'Credenciais inválidas'
            ], Response::HTTP_UNAUTHORIZED);
        }

        // Verificar se é staff do hemocentro
        if ($user->isadmin !== 'admin') {
            SecurityLogService::logSecurityViolation('unauthorized_blood_center_access', [
                'user_id' => $user->id,
                'blood_center_id' => $request->blood_center_id
            ]);

            return response()->json([
                'error' => 'Acesso não autorizado'
            ], Response::HTTP_FORBIDDEN);
        }

        // Criar token específico para API do hemocentro
        $token = $user->createToken(
            'blood_center_api_token',
            ['blood-center-api'],
            now()->addHours(8) // Token expira em 8 horas
        );

        SecurityLogService::logAuthEvent('blood_center_api_auth', [
            'user_id' => $user->id,
            'blood_center_id' => $request->blood_center_id
        ]);

        return response()->json([
            'access_token' => $token->plainTextToken,
            'token_type' => 'Bearer',
            'expires_in' => 8 * 3600, // 8 horas em segundos
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'blood_center_id' => $request->blood_center_id
            ]
        ]);
    }

    /**
     * Get donations for today
     */
    public function getTodayDonations(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'blood_center_id' => 'required|exists:blood_centers,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Dados inválidos',
                'details' => $validator->errors()
            ], Response::HTTP_BAD_REQUEST);
        }

        $donations = Donation::where('bloodcenter_id', $request->blood_center_id)
            ->whereDate('donation_date', today())
            ->with(['user:id,name,email', 'bloodcenter:id,name'])
            ->get()
            ->map(function ($donation) {
                return [
                    'id' => $donation->id,
                    'donation_token' => $donation->donation_token,
                    'donor_name' => $donation->user->name,
                    'donor_email' => $donation->user->email,
                    'blood_type' => $donation->blood_type,
                    'donation_time' => $donation->donation_time,
                    'status' => $donation->status,
                    'donor_age_range' => $donation->donor_age_range,
                    'donor_gender' => $donation->donor_gender,
                    'is_first_time_donor' => $donation->is_first_time_donor,
                    'has_encrypted_data' => $donation->hasEncryptedData(),
                    'created_at' => $donation->created_at,
                    'updated_at' => $donation->updated_at,
                ];
            });

        return response()->json([
            'date' => today()->format('Y-m-d'),
            'total_donations' => $donations->count(),
            'donations' => $donations
        ]);
    }

    /**
     * Confirm donation
     */
    public function confirmDonation(Request $request, $donationToken)
    {
        $validator = Validator::make($request->all(), [
            'blood_center_id' => 'required|exists:blood_centers,id',
            'staff_notes' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Dados inválidos',
                'details' => $validator->errors()
            ], Response::HTTP_BAD_REQUEST);
        }

        $donation = Donation::where('donation_token', $donationToken)
            ->where('bloodcenter_id', $request->blood_center_id)
            ->first();

        if (!$donation) {
            return response()->json([
                'error' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        if ($donation->status !== 'SCHEDULED') {
            return response()->json([
                'error' => 'Doação não pode ser confirmada neste status'
            ], Response::HTTP_BAD_REQUEST);
        }

        $donation->update([
            'status' => 'CONFIRMED',
            'confirmed_by' => Auth::id(),
            'confirmed_at' => now(),
            'staff_notes' => $request->staff_notes,
            'confirmation_token' => null,
            'confirmation_expires_at' => null,
        ]);

        SecurityLogService::logDonationEvent('donation_confirmed_api', [
            'donation_id' => $donation->id,
            'donation_token' => $donationToken,
            'confirmed_by' => Auth::id(),
            'blood_center_id' => $request->blood_center_id
        ]);

        return response()->json([
            'message' => 'Doação confirmada com sucesso',
            'donation' => [
                'id' => $donation->id,
                'donation_token' => $donation->donation_token,
                'status' => $donation->status,
                'confirmed_at' => $donation->confirmed_at,
                'staff_notes' => $donation->staff_notes
            ]
        ]);
    }

    /**
     * Complete donation
     */
    public function completeDonation(Request $request, $donationToken)
    {
        $validator = Validator::make($request->all(), [
            'blood_center_id' => 'required|exists:blood_centers,id',
            'completion_notes' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Dados inválidos',
                'details' => $validator->errors()
            ], Response::HTTP_BAD_REQUEST);
        }

        $donation = Donation::where('donation_token', $donationToken)
            ->where('bloodcenter_id', $request->blood_center_id)
            ->whereDate('donation_date', today())
            ->first();

        if (!$donation) {
            return response()->json([
                'error' => 'Doação não encontrada ou não agendada para hoje'
            ], Response::HTTP_NOT_FOUND);
        }

        if ($donation->status !== 'CONFIRMED') {
            return response()->json([
                'error' => 'Doação deve estar confirmada antes de ser completada'
            ], Response::HTTP_BAD_REQUEST);
        }

        $donation->update([
            'status' => 'COMPLETED',
            'completed_by' => Auth::id(),
            'completed_at' => now(),
            'completion_notes' => $request->completion_notes,
        ]);

        SecurityLogService::logDonationEvent('donation_completed_api', [
            'donation_id' => $donation->id,
            'donation_token' => $donationToken,
            'completed_by' => Auth::id(),
            'blood_center_id' => $request->blood_center_id
        ]);

        return response()->json([
            'message' => 'Doação concluída com sucesso',
            'donation' => [
                'id' => $donation->id,
                'donation_token' => $donation->donation_token,
                'status' => $donation->status,
                'completed_at' => $donation->completed_at,
                'completion_notes' => $donation->completion_notes
            ]
        ]);
    }

    /**
     * Get blood center statistics
     */
    public function getStatistics(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'blood_center_id' => 'required|exists:blood_centers,id',
            'period' => 'in:today,week,month,year'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Dados inválidos',
                'details' => $validator->errors()
            ], Response::HTTP_BAD_REQUEST);
        }

        $period = $request->get('period', 'today');
        $bloodCenterId = $request->blood_center_id;

        $query = Donation::where('bloodcenter_id', $bloodCenterId);

        switch ($period) {
            case 'today':
                $query->whereDate('donation_date', today());
                break;
            case 'week':
                $query->whereBetween('donation_date', [now()->startOfWeek(), now()->endOfWeek()]);
                break;
            case 'month':
                $query->whereMonth('donation_date', now()->month);
                break;
            case 'year':
                $query->whereYear('donation_date', now()->year);
                break;
        }

        $donations = $query->get();

        $stats = [
            'period' => $period,
            'total_donations' => $donations->count(),
            'by_status' => [
                'SCHEDULED' => $donations->where('status', 'SCHEDULED')->count(),
                'CONFIRMED' => $donations->where('status', 'CONFIRMED')->count(),
                'COMPLETED' => $donations->where('status', 'COMPLETED')->count(),
                'CANCELLED' => $donations->where('status', 'CANCELLED')->count(),
            ],
            'by_blood_type' => $donations->groupBy('blood_type')->map->count(),
            'first_time_donors' => $donations->where('is_first_time_donor', true)->count(),
            'completion_rate' => $donations->count() > 0 
                ? round(($donations->where('status', 'COMPLETED')->count() / $donations->count()) * 100, 2)
                : 0
        ];

        return response()->json($stats);
    }

    /**
     * Get medical notes for donation (only for authorized staff)
     */
    public function getMedicalNotes(Request $request, $donationToken)
    {
        $validator = Validator::make($request->all(), [
            'blood_center_id' => 'required|exists:blood_centers,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Dados inválidos',
                'details' => $validator->errors()
            ], Response::HTTP_BAD_REQUEST);
        }

        $donation = Donation::where('donation_token', $donationToken)
            ->where('bloodcenter_id', $request->blood_center_id)
            ->first();

        if (!$donation) {
            return response()->json([
                'error' => 'Doação não encontrada'
            ], Response::HTTP_NOT_FOUND);
        }

        // Log acesso a dados médicos
        SecurityLogService::logSecurityEvent('medical_notes_accessed', [
            'donation_id' => $donation->id,
            'accessed_by' => Auth::id(),
            'blood_center_id' => $request->blood_center_id
        ]);

        return response()->json([
            'donation_token' => $donationToken,
            'medical_notes' => $donation->medical_notes,
            'health_questions' => $donation->health_questions,
            'has_encrypted_data' => $donation->hasEncryptedData(),
            'encrypted_at' => $donation->encrypted_at,
        ]);
    }
}
