<?php

namespace App\Http\Controllers;

use App\Http\Requests\NewsStoreRequest;
use App\Http\Requests\NewsUpdateRequest;
use App\Models\News;
use App\Services\FirebaseService;
use App\Services\PaginateAndFilter;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class NewsController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $query = PaginateAndFilter::applyFilters(News::class,'title');
        return response()->json(['data'=>PaginateAndFilter::response($query)]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(NewsStoreRequest $request)
    {
        $notification = 'Not sent';
        if (!$request->user()->isadmin == 'admin') {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }
        if ($request->type == 'emergency') {
            $request->validate([
                'blood_type' => ['required', 'string', 'in:positiveA,negativeA,positiveB,negativeB,negativeAB,positiveAB,negativeO,positiveO']
            ]);
            $this->firebaseService->sendNotification(
                $request->title,
                $request->content,
                $request->blood_type,
                $request->type
            );
            $notification = 'Sent';
        }
        $news = News::create([
            'title' => $request->title,
            'content' => $request->content,
            'user_id' => $request->user()->id,
            'image' => $request->image,
            'type' => $request->type,
        ]);

        return response()->json([
            'message' => 'News created successfully',
            'data' => $news,
            'notification' => $notification
        ], Response::HTTP_OK);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        if (!$news = News::find($id)) {
            return response()->json(['message' => 'No news found'], Response::HTTP_NOT_FOUND);
        }

        return response()->json(['data' => $news], Response::HTTP_OK);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(NewsUpdateRequest $request, string $id)
    {
        if (!$news = News::find($id)) {
            return response()->json(['message' => 'No news found'], Response::HTTP_NOT_FOUND);
        }

        if (!$request->user()->id == $news->user_id) {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }

        $news->update([
            'title' => $request->title ?: $news->title,
            'content' => $request->content ?: $news->content,
            'image' => $request->image ?: $news->image,
            'type' => $request->type ?: $news->type,
            'user_id' => $news->user_id,
        ]);

        return response()->json(['message' => 'News updated successfully', 'data' => $news], Response::HTTP_OK);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        if (!$news = News::find($id)) {
            return response()->json(['message' => 'No news found'], Response::HTTP_NOT_FOUND);
        }

        if (!$request->user()->id == $news->user_id) {
            return response()->json(['message' => 'Unauthorized access'], Response::HTTP_UNAUTHORIZED);
        }

        $news->delete();

        return response()->json(['message' => 'News deleted successfully'], Response::HTTP_OK);
    }
}
