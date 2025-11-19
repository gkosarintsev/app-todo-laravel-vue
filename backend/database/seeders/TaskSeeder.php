<?php

namespace Database\Seeders;

use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $user = User::where('email', 'karada@example.com')->first();
        if (! $user) {
            return;
        }

        $tasks = [
            [
                'title' => 'Купить продукты',
                'description' => 'Хлеб, молоко, яйца',
                'status' => 'new',
                'priority' => 2,
                'due_date' => now()->addDays(3)->toDateString(),
                'karada_project' => 'other',
            ],
            [
                'title' => 'Прочитать документацию',
                'description' => 'Прочитать задания по KARADA',
                'status' => 'in_progress',
                'priority' => 4,
                'due_date' => now()->addWeek()->toDateString(),
                'karada_project' => 'karada_u',
            ],
            [
                'title' => 'Закончить тестовое задание',
                'description' => 'Отправить репозиторий',
                'status' => 'done',
                'priority' => 5,
                'due_date' => now()->subDays(1)->toDateString(),
                'karada_project' => 'prohuntr',
            ],
        ];

        foreach ($tasks as $t) {
            $task = new Task($t);
            $task->user_id = $user->id;
            $task->save();
        }
    }
}

