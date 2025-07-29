<?php

namespace App\Livewire;


use App\Models\News;
use Livewire\Component;
use Illuminate\Support\Facades\Cookie;

class ShowNews extends Component
{
    public function render()
    {

        $cookieName = 'news_viewed_' . $this->news->id;

        if (!Cookie::get($cookieName)) {
            $this->news->increment('views');

            Cookie::queue($cookieName, '1', 1440);
        }

        return view('livewire.show-news')->layout('layouts.app');
    }

    public $news;
    public $others;
    public function mount($slug)
    {
        $this->news = News::where('slug', $slug)->first();
        $this->others = News::where('slug', '!=', $slug)->limit(5)->get();
    }
}
