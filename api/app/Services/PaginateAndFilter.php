<?php

namespace App\Services;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class PaginateAndFilter
{
  /**
   * Apply filters to the given model.
   *
   * @param string $modelClass
   * @param string $searchFor
   * @param bool $filterByUser
   * @return Builder
   */
  public static function applyFilters(
    string $modelClass,
    string $searchFor = null,
    bool $filterByUser = false,
  ): Builder {
    $query = $modelClass::query();

    if (request('search')) {
      $query->where($searchFor, 'like', '%' . request('search') . '%');
    }

    if (request('order_by')) {
      $query->orderBy(request('order_by'), request('direction', 'asc'));
    }

    // if ($filterByUser && request('user_id')) {
    //   $query->where('user_id', request('user_id'));
    // }

    return $query;
  }

  /**
   * Paginate the given query.
   *
   * @param Builder $query
   * @param Request $request
   * @return LengthAwarePaginator|Collection
   */
  public static function response(Builder $query): LengthAwarePaginator|Collection
  {
    if (request('has_pagination', 'true') === 'true') {
      return $query->paginate(request('per_page', 15));
    }

    return $query->get();
  }
}