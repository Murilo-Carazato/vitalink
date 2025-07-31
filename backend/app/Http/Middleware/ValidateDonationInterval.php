<?php

namespace App\Http\Middleware;

use App\Models\Donation;
use App\Enums\DonationStatus;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class ValidateDonationInterval
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();
        
        if (!$user) {
            return response()->json([
                'message' => 'Usuário não autenticado'
            ], Response::HTTP_UNAUTHORIZED);
        }

        // Check if user has any recent donations
        $recentDonation = Donation::where('user_id', $user->id)
            ->where('status', DonationStatus::COMPLETED)
            ->where('donation_date', '>=', now()->subDays(60)) // 60 days minimum interval
            ->orderBy('donation_date', 'desc')
            ->first();

        if ($recentDonation) {
            $daysSinceLastDonation = now()->diffInDays($recentDonation->donation_date);
            $minimumInterval = 60; // 60 days for all donors
            
            if ($daysSinceLastDonation < $minimumInterval) {
                $daysRemaining = $minimumInterval - $daysSinceLastDonation;
                
                return response()->json([
                    'message' => "Você deve aguardar {$daysRemaining} dias antes de fazer uma nova doação",
                    'data' => [
                        'last_donation_date' => $recentDonation->donation_date->format('Y-m-d'),
                        'days_remaining' => $daysRemaining,
                        'minimum_interval_days' => $minimumInterval
                    ]
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }
        }

        // Check if user has any scheduled or confirmed donations
        $activeDonation = Donation::where('user_id', $user->id)
            ->whereIn('status', [DonationStatus::SCHEDULED, DonationStatus::CONFIRMED])
            ->whereDate('donation_date', '>=', now())
            ->first();

        if ($activeDonation) {
            return response()->json([
                'message' => 'Você já possui uma doação agendada',
                'data' => [
                    'active_donation_date' => $activeDonation->donation_date->format('Y-m-d'),
                    'active_donation_time' => $activeDonation->donation_time->format('H:i'),
                    'bloodcenter_name' => $activeDonation->bloodcenter->name
                ]
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return $next($request);
    }
}
