<?php

namespace App\Http\Controllers;

use App\Http\Requests\BloodCenterRequest;
use App\Http\Requests\BloodCenterUpdateRequest;
use App\Models\BloodCenter;
use App\Models\User;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class BloodCenterController extends Controller
{
    public function __construct()
    {
        $this->authorizeResource(BloodCenter::class, 'blood_center');
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $query = PaginateAndFilter::applyFilters(BloodCenter::class,'name');
        return response()->json(['data'=>PaginateAndFilter::response($query)]); 
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
            return response()->json(['message' => 'Blood center deleted'], Response::HTTP_OK);
        }

        $user->news()->delete();
        $user->delete();
        $blood_center->delete();
        return response()->json(['message' => 'Blood center deleted'], Response::HTTP_OK);
    }
}
