<?php

namespace App\Http\Controllers;

use App\Http\Requests\NewsStoreRequest;
use App\Http\Requests\NewsUpdateRequest;
use App\Services\NewsService;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class NewsController extends Controller
{
    protected $newsService;

    public function __construct(NewsService $newsService)
    {
        $this->newsService = $newsService;
    }

    public function index()
    {
        $query = $this->newsService->getNews();
        return response()->json(['data' => PaginateAndFilter::response($query)]);
    }

    public function store(NewsStoreRequest $request)
    {
        if ($request->user()->isadmin != 'admin' && $request->user()->isadmin != 'superadmin') {
            return response()->json(['error' => 'Unauthorized'], Response::HTTP_FORBIDDEN);
        }

        $result = $this->newsService->createNews($request->validated(), $request->user());

        return response()->json([
            'notification' => $result['notification'],
            'data' => $result['news'],
        ], Response::HTTP_CREATED);
    }

    public function show(string $id)
    {
        $news = $this->newsService->getNewsById($id);

        if (!$news) {
            return response()->json(['message' => 'No news found'], Response::HTTP_NOT_FOUND);
        }

        return response()->json(['data' => $news], Response::HTTP_OK);
    }

    public function update(NewsUpdateRequest $request, string $id)
    {
        $news = $this->newsService->getNewsById($id);

        if (!$news) {
            return response()->json(['message' => 'No news found'], Response::HTTP_NOT_FOUND);
        }

        if ($request->user()->id != $news->user_id) {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }

        $updatedNews = $this->newsService->updateNews($news, $request->validated(), $request->user());

        return response()->json(['message' => 'News updated successfully', 'data' => $updatedNews], Response::HTTP_OK);
    }

    public function destroy(Request $request, string $id)
    {
        $news = $this->newsService->getNewsById($id);

        if (!$news) {
            return response()->json(['message' => 'No news found'], Response::HTTP_NOT_FOUND);
        }

        if ($request->user()->id != $news->user_id) {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }

        $this->newsService->deleteNews($news, $request->user());

        return response()->json(['message' => 'News deleted successfully'], Response::HTTP_OK);
    }
}
