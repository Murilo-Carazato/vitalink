<?php

namespace App\Http\Controllers;

use App\Http\Requests\UserStoreRequest;
use App\Http\Requests\UserUpdateRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {

        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unathorized request'], Response::HTTP_UNAUTHORIZED);
        }

        $users = User::all();

        return response()->json(['users' => $users], Response::HTTP_OK);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(UserStoreRequest $request)
    {
        $user = User::create([
            'name' => $request->name,
            'password' => $request->password,
            'email' => $request->email,
            'isadmin' => "superadmin",
            'bloodcenter_id' => $request->bloodcenter_id,
        ]);

        return response()->json(['data' => $user], Response::HTTP_OK);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id, Request $request)
    {
        if (!$user = User::find($id)) {
            return response()->json(['message' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        if ($request->user()->isadmin != 'superadmin' || !$request->user()->id == $id) {
            return response()->json(['message' => 'Unathorized request'], Response::HTTP_UNAUTHORIZED);
        }

        return response()->json(['data' => $user], Response::HTTP_OK);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UserUpdateRequest $request, string $id)
    {
        if (!$user = User::find($id)) {
            return response()->json(['message' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized request'], Response::HTTP_UNAUTHORIZED);
        }
        $user->update([
            'name' => $request->name ?: $user->name,
            'email' => $request->email ?: $user->email,
            'isadmin' => $user->isadmin,
        ]);
        return response()->json(
            [
                'message' => 'User updated',
                'data' => $user
            ],
            Response::HTTP_OK
        );
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        if (!$user = User::find($id)) {
            return response()->json(['message' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized request'], Response::HTTP_UNAUTHORIZED);
        }

        $user->news()->delete();
        $user->delete();
        return response()->json(['message' => 'User deleted'], Response::HTTP_OK);
    }
}
