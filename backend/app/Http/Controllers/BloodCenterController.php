<?php

namespace App\Http\Controllers;

use App\Http\Requests\BloodCenterRequest;
use App\Http\Requests\BloodCenterUpdateRequest;
use App\Models\BloodCenter;
use App\Models\User;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class BloodCenterController extends Controller
{
    public function __construct()
    {
        $this->authorizeResource(BloodCenter::class, 'blood_center');
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // Cache key based on request parameters
        $cacheKey = 'blood_centers_' . md5($request->getQueryString() ?? '');
        
        $result = Cache::remember($cacheKey, 3600, function () use ($request) { // 1 hour cache
            $query = PaginateAndFilter::applyFilters(BloodCenter::class, 'name');

            if ($request->has(['latitude', 'longitude'])) {
                $lat = $request->latitude;
                $lon = $request->longitude;
                $radius = $request->input('radius', 500); // Raio em KM, default bem alto para pegar tudo se não especificado, mas mobile filtra 20km normal

                // Haversine Formula
                $query->selectRaw("*, (
                    6371 * acos(
                        cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) +
                        sin(radians(?)) * sin(radians(latitude))
                    )
                ) AS distance", [$lat, $lon, $lat]);

                $query->having('distance', '<=', $radius);
                $query->orderBy('distance', 'asc');
                
                // Se for busca geoespacial, geralmente queremos os top X, não paginação padrão
                // Mas mantemos a lógica de paginação se o cliente pedir.
                // O mobile pede `has_pagination=false` para o nearby normalmente se fosse pegar tudo,
                // mas agora com otimização, podemos forçar limit 5 se for para nearby específico.
                
                // Observação: O mobile usa `getNearbyBCs` que pega top 5.
                // Vamos dar limit 5 aqui se não tiver paginação explícita diferente.
                 if ($request->input('has_pagination') !== 'true') {
                     $query->limit(5);
                 }
            }

            return PaginateAndFilter::response($query);
        });
        
        return response()->json(['data' => $result]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(BloodCenterRequest $request)
    {
        $bloodcenter = BloodCenter::create([
            'name' => $request->name,
            'address' => $request->address,
            'latitude' => (float)$request->latitude,
            'longitude' => (float)$request->longitude,
            'phone_number' => $request->phone_number,
            'email' => $request->email,
            'site' => $request->site,
        ]);
        
        // Clear cache when new blood center is created
        Cache::forget('blood_centers_*');
        
        return response()->json(
            [
                'message' => 'bloodcenter created',
                'data' => $bloodcenter
            ],
            Response::HTTP_OK
        );
    }

    /**
     * Display the specified resource.
     */
    public function show(BloodCenter $blood_center)
    {
        return response()->json(['data' => $blood_center], Response::HTTP_OK);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(BloodCenterUpdateRequest $request, BloodCenter $blood_center)
    {
        $blood_center->update($request->validated());
        
        // Clear cache when blood center is updated
        Cache::forget('blood_centers_*');
        
        return response()->json(
            [
                'message' => 'bloodcenter updated',
                'data' => $blood_center
            ],
            Response::HTTP_OK
        );
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(BloodCenter $blood_center)
    {
        $user = User::where('bloodcenter_id', $blood_center->id)->first();
        if (!$user) {
            $blood_center->delete();
            
            // Clear cache when blood center is deleted
            Cache::forget('blood_centers_*');
            
            return response()->json(['message' => 'Blood center deleted'], Response::HTTP_OK);
        }

        $user->news()->delete();
        $user->delete();
        $blood_center->delete();
        
        // Clear cache when blood center is deleted
        Cache::forget('blood_centers_*');
        
        return response()->json(['message' => 'Blood center deleted'], Response::HTTP_OK);
    }
}
