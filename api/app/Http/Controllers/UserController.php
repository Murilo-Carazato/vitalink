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
        $this->middleware('can:viewAny,' . User::class)->only('index');
        $this->middleware('can:view,user')->only('show');
        $this->middleware('can:update,user')->only('update');
        $this->middleware('can:delete,user')->only('destroy');
    }

    public function index()
    {
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

    public function show(User $user)
    {
        return response()->json(['data' => $user], Response::HTTP_OK);
    }

    public function update(UserUpdateRequest $request, User $user)
    {
        $updatedUser = $this->userService->updateUser($user, $request->validated());

        return response()->json(
            [
                'message' => 'User updated',
                'data' => $updatedUser
            ],
            Response::HTTP_OK
        );
    }

    public function destroy(User $user)
    {
        $this->userService->deleteUser($user);

        return response()->json(['message' => 'User deleted'], Response::HTTP_OK);
    }
}
