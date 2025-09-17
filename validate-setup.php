<?php
/**
 * Validate OrangeHRM Setup
 */
echo "🔍 VALIDATING ORANGEHRM SETUP\n\n";

// Check PHP version
echo "PHP Version: " . phpversion() . "\n";

// Check extensions
$required_extensions = ['pdo', 'pdo_pgsql', 'gd', 'intl', 'zip', 'opcache'];
foreach ($required_extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "✅ $ext extension loaded\n";
    } else {
        echo "❌ $ext extension missing\n";
    }
}

// Check database connection
try {
    $host = 'dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com';
    $port = '5432';
    $dbname = 'orangehrm_portos';
    $user = 'orangehrm_user';
    $password = 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX';
    
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'");
    $tableCount = $stmt->fetchColumn();
    
    echo "✅ Database connected: $tableCount tables\n";
    
} catch (Exception $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
}

echo "\n🎯 Setup validation complete\n";
?>
