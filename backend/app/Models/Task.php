<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected $table = 'tasks';

    // Only allow these fields to be mass assigned from the API
    protected $fillable = [
        'title',
        'description',
        'status',
        'priority',
        'due_date',
        'karada_project',
    ];

    // Casts
    protected $casts = [
        'due_date' => 'date',
    ];

    /**
     * Boot method to set karada_test_label and importance_score on create/update
     */
    protected static function booted()
    {
        static::creating(function (Task $task) {
            // Ensure protected fields are set by backend
            $task->karada_test_label = 'KARADA_FULLSTACK_TEST';
            $task->importance_score = (int)($task->priority ?? 1) * 20;
        });

        static::updating(function (Task $task) {
            // Recalculate importance score if priority changes
            $task->karada_test_label = 'KARADA_FULLSTACK_TEST';
            $task->importance_score = (int)($task->priority ?? 1) * 20;
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

