<?php

namespace App\Livewire;


use App\Models\News;
use Livewire\Component;

class RecentNews extends Component
{
    public function render()
    {
        return view('livewire.recent-news', [
            'news' => News::limit(5)->orderBy('created_at', 'desc')->get()
        ]);
    }
}
