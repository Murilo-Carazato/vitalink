<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Rules;

class RegisteredUserController extends Controller
{
    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'isadmin' => ['nullable', 'string', 'in:superadmin,admin']
        ]);

        $userData = [
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'isadmin' => in_array($request->isadmin, ['admin', 'superadmin']) ? $request->isadmin : null,
            'is_active' => true, // Ativar o usuário por padrão
        ];

        $user = User::create($userData);
        
        // Log para depuração
        Log::info('Classe do usuário: ' . get_class($user));
        Log::info('Métodos disponíveis: ' . implode(', ', get_class_methods($user)));
        
        try {
            // Verificar se o método createToken existe
            if (!method_exists($user, 'createToken')) {
                Log::error('Método createToken não encontrado no modelo User');
                throw new \RuntimeException('Método createToken não encontrado no modelo User');
            }
            
            // Criar token de autenticação
            $token = $user->createToken('auth_token');
            Log::info('Token criado com sucesso');
            $plainTextToken = $token->plainTextToken;
            Log::info('Token de texto simples gerado');
        } catch (\Exception $e) {
            Log::error('Erro ao criar token: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            throw $e;
        }

        event(new Registered($user));

        return response()->json([
            'user' => $user->makeHidden(['password']),
            'token' => $plainTextToken,
            'token_type' => 'Bearer',
        ], Response::HTTP_CREATED);
    }
}
