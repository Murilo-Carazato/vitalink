<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    public function store(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(
                ['message' => 'Invalid credentials'],
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        return response()->json([
            'message' => 'Login successful',
            'token' => $user->createToken($request->email)->plainTextToken,
            'user' => User::where('email', $user->email)->first(),
        ], Response::HTTP_OK);
    }

    public function destroy(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout successful',
        ], Response::HTTP_OK);
    }
}
