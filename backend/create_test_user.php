<?php
// create_test_user.php - запускается внутри контейнера в /var/www/html
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';

// Bootstrap the application kernel so we can use Eloquent
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;

$email = 'test@example.com';
$password = 'password';

$user = User::updateOrCreate(
    ['email' => $email],
    [
        'name' => 'Test',
        'password' => bcrypt($password),
    ]
);

if ($user) {
    echo "User ensured: {$email}\n";
    echo "ID: {$user->id}\n";
} else {
    echo "Failed to create/update user: {$email}\n";
}
