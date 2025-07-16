<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class UserService
{
    public function getAllUsers(): \Illuminate\Database\Eloquent\Collection|static
    {
        // if (Gate::denies('viewAny', User::class)) {
        //     abort(Response::HTTP_UNAUTHORIZED, 'Acesso não autorizado');
        // }
        return User::all();
    }

    public function createUser(array $data): array
    {
        $data['password'] = Hash::make($data['password']);
        $data['isadmin'] = $data['isadmin'] ?? 'user'; // Default para usuário comum se não especificado
        $data['email_verified_at'] = null; // Garante que o email não está verificado

        $user = User::create($data);
        
        // Envia o email de verificação explicitamente (custom notification)
        $user->sendEmailVerificationNotification();

        return [
            'user' => $user,
            'token' => $user->createToken($data['email'])->plainTextToken,
            'email_verified' => false
        ];
    }

    public function getUserById(string $id): ?User
    {
        return User::find($id);
    }

    public function updateUser(User $user, array $data): User
    {
        if (Gate::denies('update', $user)) {
            abort(Response::HTTP_UNAUTHORIZED, 'Acesso não autorizado');
        }

        // A validação deve garantir que os campos opcionais não sobrescrevam com null
        $user->update($data);
        return $user;
    }

    public function deleteUser(User $user): void
    {
        // if (Gate::denies('delete', $user)) {
        //     abort(Response::HTTP_UNAUTHORIZED, 'Acesso não autorizado');
        // }

        // A lógica de apagar em cascata pode ser movida para um observer do model
        $user->news()->delete();
        $user->delete();
    }
}
