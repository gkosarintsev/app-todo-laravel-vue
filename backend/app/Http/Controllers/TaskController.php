<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

class TaskController extends Controller
{
    /**
     * Display a listing of the user's tasks.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $tasks = Task::where('user_id', $user->id)->get();

        return response()->json($tasks, Response::HTTP_OK);
    }

    /**
     * Store a newly created task in storage.
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|min:5|max:120',
            'description' => 'nullable|string',
            'status' => ['required', Rule::in(['new', 'in_progress', 'done', 'archived'])],
            'priority' => 'required|integer|between:1,5',
            'due_date' => 'nullable|date',
            'karada_project' => ['required', Rule::in(['karada_u', 'prohuntr', 'other'])],
        ]);

        $task = new Task($data);
        $task->user_id = $request->user()->id; // enforce owner
        $task->save();

        return response()->json($task, Response::HTTP_CREATED);
    }

    /**
     * Display the specified task.
     */
    public function show(Request $request, Task $task)
    {
        if (! $request->user()->can('view', $task)) {
            abort(Response::HTTP_FORBIDDEN);
        }

        return response()->json($task, Response::HTTP_OK);
    }

    /**
     * Update the specified task in storage.
     */
    public function update(Request $request, Task $task)
    {
        if (! $request->user()->can('update', $task)) {
            abort(Response::HTTP_FORBIDDEN);
        }

        $data = $request->validate([
            'title' => 'required|string|min:5|max:120',
            'description' => 'nullable|string',
            'status' => ['required', Rule::in(['new', 'in_progress', 'done', 'archived'])],
            'priority' => 'required|integer|between:1,5',
            'due_date' => 'nullable|date',
            'karada_project' => ['required', Rule::in(['karada_u', 'prohuntr', 'other'])],
        ]);

        // Only fill allowed fields
        $task->fill($data);
        $task->save(); // model events recalc importance_score

        return response()->json($task, Response::HTTP_OK);
    }

    /**
     * Remove the specified task from storage.
     */
    public function destroy(Request $request, Task $task)
    {
        if (! $request->user()->can('delete', $task)) {
            abort(Response::HTTP_FORBIDDEN);
        }

        $task->delete();

        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}
