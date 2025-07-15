<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    protected $firebaseAuth;

    public function __construct(FirebaseAuth $firebaseAuth)
    {
        $this->firebaseAuth = $firebaseAuth;
    }

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

    public function handleGoogleCallback(Request $request)
    {
        $request->validate([
            'idToken' => 'required|string',
        ]);

        try {
            $verifiedIdToken = $this->firebaseAuth->verifyIdToken($request->idToken);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Token do Firebase inválido: ' . $e->getMessage()], Response::HTTP_UNAUTHORIZED);
        }

        $uid = $verifiedIdToken->claims()->get('sub');
        $firebaseUser = $this->firebaseAuth->getUser($uid);

        $user = User::updateOrCreate(
            ['email' => $firebaseUser->email],
            [
                'name' => $firebaseUser->displayName ?? 'Usuário Google',
                'password' => Hash::make(Str::random(24)),
                'isadmin' => 'admin',
                'email_verified_at' => $firebaseUser->emailVerified ? now() : null,
            ]
        );

        return response()->json([
            'message' => 'Login com Google bem-sucedido',
            'token' => $user->createToken($firebaseUser->email)->plainTextToken,
            'user' => $user,
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
