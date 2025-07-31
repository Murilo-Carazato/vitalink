<?php

namespace App\Livewire;

use Livewire\Component;

class CardBlood extends Component
{
    public $pos = 0;

    public function render()
    {
        return view('livewire.card-blood');
    }


    public function x_click(int $pos)
    {
        $this->pos = $pos;
    }
}
