<?php

namespace App\Livewire;


use Livewire\Component;
use Livewire\WithPagination;

class News extends Component
{
    use WithPagination;
    public $search;
    protected $queryString = ['search'];
    public function render()
    {
        return view('livewire.news',[

            'news' => \App\Models\News::where('slug', 'like', '%'.$this->search.'%')
            ->orWhere('title', 'like', '%'.$this->search.'%')
            ->orWhere('subtitle', 'like', '%'.$this->search.'%')
            ->orWhere('lead', 'like', '%'.$this->search.'%')
            ->orWhere('body', 'like', '%'.$this->search.'%')
            ->orWhere('views', 'like', '%'.$this->search.'%')
            ->orderBy('created_at', 'desc')
            ->paginate(8, ['*'], 'pagina')
        ])->layout('layouts.app');
    }
    public function updatingSearch()
    {
        $this->resetPage('pagina');
    }

}
