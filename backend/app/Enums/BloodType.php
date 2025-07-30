<?php

namespace App\Enums;

enum BloodType: string
{
    case POSITIVE_A = 'positiveA';
    case NEGATIVE_A = 'negativeA';
    case POSITIVE_B = 'positiveB';
    case NEGATIVE_B = 'negativeB';
    case POSITIVE_AB = 'positiveAB';
    case NEGATIVE_AB = 'negativeAB';
    case POSITIVE_O = 'positiveO';
    case NEGATIVE_O = 'negativeO';
} 