<?php

namespace App\Livewire;


use App\Models\News;
use Livewire\Component;
use Illuminate\Support\Facades\Cookie;

use Illuminate\Database\Eloquent\Collection;

class ShowNews extends Component
{
    public function render()
    {

        return view('livewire.show-news')->layout('layouts.app');
    }

    public News $news;
    public Collection $others;

    public function mount(News $news): void
    {
        $this->news = $news;
        $this->others = News::where('id', '!=', $news->id)->latest()->limit(5)->get();
    }
}
