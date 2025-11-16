<?php
// Quick bootstrap to inspect runtime config
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$config = $app['config'];
echo "config.session.driver=" . $config->get('session.driver') . PHP_EOL;
echo "env.SESSION_DRIVER=" . getenv('SESSION_DRIVER') . PHP_EOL;
echo "config.database.default=" . $config->get('database.default') . PHP_EOL;
echo "env.DB_CONNECTION=" . getenv('DB_CONNECTION') . PHP_EOL;
echo "env.DB_HOST=" . getenv('DB_HOST') . PHP_EOL;
echo "env.DB_DATABASE=" . getenv('DB_DATABASE') . PHP_EOL;
echo "env.DB_USERNAME=" . getenv('DB_USERNAME') . PHP_EOL;
echo "env.DB_PASSWORD=" . (getenv('DB_PASSWORD') ? 'SET' : 'EMPTY') . PHP_EOL;
// show session files driver path
echo "session.files=" . $config->get('session.files') . PHP_EOL;
// show storage permissions
$perm = @fileperms(__DIR__ . '/storage');
if ($perm !== false) { echo 'storage.perms=' . decoct($perm & 0777) . PHP_EOL; }

// check if session table exists (only if using database)
if ($config->get('session.driver') === 'database') {
    try {
        $pdo = DB::connection()->getPdo();
        $exists = DB::select("select 1 from information_schema.tables where table_name = 'sessions' limit 1");
        echo "db.sessions_check=" . (count($exists) ? 'yes' : 'no') . PHP_EOL;
    } catch (Exception $e) {
        echo "db.error=" . $e->getMessage() . PHP_EOL;
    }
}

