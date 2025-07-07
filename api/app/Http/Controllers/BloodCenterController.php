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
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = PaginateAndFilter::applyFilters(BloodCenter::class,'name');
        return response()->json(['data'=>PaginateAndFilter::response($query)]); 
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(BloodCenterRequest $request)
    {
        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }
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
    public function show(string $id)
    {
        if (!$bloodcenter = BloodCenter::find($id)) {
            return response()->json(['message' => 'Blood center not found'], Response::HTTP_NOT_FOUND);
        }

        return response()->json(['data' => $bloodcenter], Response::HTTP_OK);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(BloodCenterUpdateRequest $request, string $id)
    {

        if (!$bloodcenter = BloodCenter::find($id)) {
            return response()->json(['message' => 'Blood center not found'], Response::HTTP_NOT_FOUND);
        }

        if (!$request->user()->bloodcenter_id == $id && $request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }

        $bloodcenter->update([
            'name' => $request->name ?: $bloodcenter->name,
            'address' => $request->address ?: $bloodcenter->address,
            'phone_number' => $request->phone_number ?: $bloodcenter->phone_number,
            'email' => $request->email ?: $bloodcenter->email,
            'site' => $request->site ?: $bloodcenter->site,
        ]);
        return response()->json(
            [
                'message' => 'bloodcenter updated',
                'data' => $bloodcenter
            ],
            Response::HTTP_OK
        );
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        if (!$bloodcenter = BloodCenter::find($id)) {
            return response()->json(['message' => 'Blood center not found'], Response::HTTP_NOT_FOUND);
        }
        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }
        $user = User::where('bloodcenter_id', $id)->first();
        if (!$user) {
            $bloodcenter->delete();
            return response()->json(['message' => 'Blood center deleted'], Response::HTTP_OK);
        }

        $user->news()->delete();
        $user->delete();
        $bloodcenter->delete();
        return response()->json(['message' => 'Blood center deleted'], Response::HTTP_OK);
    }
}
