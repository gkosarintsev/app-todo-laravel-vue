<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('title', 120);
            $table->text('description')->nullable();
            $table->string('status', 32)->default('new');
            $table->tinyInteger('priority')->unsigned()->default(1);
            $table->date('due_date')->nullable();
            $table->string('karada_project', 32);
            $table->string('karada_test_label')->default('KARADA_FULLSTACK_TEST');
            $table->integer('importance_score')->default(20);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};

