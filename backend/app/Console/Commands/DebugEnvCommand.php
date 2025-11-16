<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class DebugEnvCommand extends Command
{
    protected $signature = 'debug:env';
    protected $description = 'Dump key env/config values and file permissions for debugging';

    public function handle(): int
    {
        $this->info('=== ENV VALUES ===');
        $this->line('DB_CONNECTION=' . env('DB_CONNECTION'));
        $this->line('DB_DATABASE=' . env('DB_DATABASE'));
        $this->line('DB_HOST=' . env('DB_HOST'));
        $this->line('SESSION_DRIVER=' . env('SESSION_DRIVER'));
        $this->line('SESSION_PATH=' . env('SESSION_PATH'));
        $this->line('SESSION_DOMAIN=' . env('SESSION_DOMAIN'));
        $this->line('APP_URL=' . env('APP_URL'));

        $this->info('\n=== FILES AND PERMS ===');
        $base = base_path();
        $dbFile = $base . '/database/database.sqlite';
        if (file_exists($dbFile)) {
            $perms = substr(sprintf('%o', fileperms($dbFile)), -4);
            $this->line("database.sqlite: exists ($perms)");
        } else {
            $this->line('database.sqlite: missing');
        }

        $sessDir = $base . '/storage/framework/sessions';
        if (is_dir($sessDir)) {
            $this->line('storage/framework/sessions: ' . implode(' ', array_slice(preg_split('/\s+/', `ls -la $sessDir 2>&1`), 0, 30)));
        } else {
            $this->line('storage/framework/sessions: missing');
        }

        $this->info('\n=== PHP Info (pdo drivers) ===');
        $this->line(implode(', ', explode("\n", `php -m | grep -E 'pdo|mysql|sqlite' || true`)));

        return 0;
    }
}

