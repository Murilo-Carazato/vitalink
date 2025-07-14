<?php

namespace App\Http\Controllers;

use App\Http\Requests\UserStoreRequest;
use App\Http\Requests\UserUpdateRequest;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class UserController extends Controller
{
    protected $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    public function index(Request $request)
    {
        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unathorized request'], Response::HTTP_UNAUTHORIZED);
        }

        $users = $this->userService->getAllUsers();
        return response()->json(['users' => $users], Response::HTTP_OK);
    }

    public function store(UserStoreRequest $request)
    {
        $result = $this->userService->createUser($request->validated());

        return response()->json([
            'data' => $result['user'],
            'token' => $result['token'],
        ], Response::HTTP_CREATED);
    }

    public function show(string $id, Request $request)
    {
        $user = $this->userService->getUserById($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if ($request->user()->isadmin != 'superadmin' && $request->user()->id != $id) {
            return response()->json(['message' => 'Unathorized request'], Response::HTTP_UNAUTHORIZED);
        }

        return response()->json(['data' => $user], Response::HTTP_OK);
    }

    public function update(UserUpdateRequest $request, string $id)
    {
        $user = $this->userService->getUserById($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized request'], Response::HTTP_UNAUTHORIZED);
        }

        $updatedUser = $this->userService->updateUser($user, $request->validated());

        return response()->json(
            [
                'message' => 'User updated',
                'data' => $updatedUser
            ],
            Response::HTTP_OK
        );
    }

    public function destroy(Request $request, string $id)
    {
        $user = $this->userService->getUserById($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if ($request->user()->isadmin != 'superadmin') {
            return response()->json(['message' => 'Unauthorized request'], Response::HTTP_UNAUTHORIZED);
        }

        $this->userService->deleteUser($user);

        return response()->json(['message' => 'User deleted'], Response::HTTP_OK);
    }
}
