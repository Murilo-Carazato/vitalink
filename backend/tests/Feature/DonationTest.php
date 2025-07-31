<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Donation;
use App\Models\BloodCenter;
use Illuminate\Support\Str;

class DonationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test that an unauthenticated user cannot access user donations.
     *
     * @return void
     */
    public function test_unauthenticated_user_cannot_access_donations()
    {
        $response = $this->getJson('/api/user/donations');

        $response->assertStatus(401);
    }

    /**
     * Test that an authenticated user can schedule a donation.
     *
     * @return void
     */
    public function test_authenticated_user_can_schedule_donation()
    {
        $user = User::factory()->create();
        $bloodCenter = BloodCenter::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/donations/schedule', [
            'donation_token' => Str::random(32),
            'blood_type' => 'positiveA',
            'bloodcenter_id' => $bloodCenter->id,
            'donation_date' => '2025-12-25 10:00:00',
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('donations', [
            'user_id' => $user->id,
            'bloodcenter_id' => $bloodCenter->id,
        ]);
    }
}
