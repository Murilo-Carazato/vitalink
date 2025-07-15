<?php

namespace App\Services;

use App\Models\News;
use App\Models\User;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpFoundation\Response;

class NewsService
{
    protected $firebaseService;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function getNews()
    {
        return PaginateAndFilter::applyFilters(News::class, 'title');
    }

    public function createNews(array $data, User $user): array
    {
        $data['user_id'] = $user->id;
        $news = News::create($data);

        $notification = 'Not sent';
        if ($data['type'] == 'emergency' && !empty($data['blood_type'])) {
            $this->firebaseService->sendNotification(
                $data['title'],
                $data['content'],
                $data['blood_type'],
                $data['type']
            );
            $notification = 'Sent';
        }

        return ['news' => $news, 'notification' => $notification];
    }

    public function getNewsById(string $id): ?News
    {
        return News::find($id);
    }

    public function updateNews(News $news, array $data, User $user): News
    {
        if (Gate::denies('update', $news)) {
            abort(Response::HTTP_UNAUTHORIZED, 'Unauthorized access');
        }

        $news->update($data);
        return $news;
    }

    public function deleteNews(News $news, User $user): void
    {
        if (Gate::denies('delete', $news)) {
            abort(Response::HTTP_UNAUTHORIZED, 'Unauthorized access');
        }

        $news->delete();
    }
}
