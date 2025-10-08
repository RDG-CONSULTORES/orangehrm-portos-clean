<?php
// Override completo del sistema de base de datos de OrangeHRM para PostgreSQL

// Configuración directa de PDO PostgreSQL
$pdo_dsn = 'pgsql:host=dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com;port=5432;dbname=orangehrm_portos';
$pdo_user = 'orangehrm_user';
$pdo_pass = 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX';

// Crear conexión global
try {
    $GLOBALS['orangehrm_pdo'] = new PDO($pdo_dsn, $pdo_user, $pdo_pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    // Override funciones de conexión
    function orangehrm_get_connection() {
        return $GLOBALS['orangehrm_pdo'];
    }
    
} catch (Exception $e) {
    error_log("PostgreSQL Connection Error: " . $e->getMessage());
}

// Override configuración Doctrine
if (class_exists('Doctrine\DBAL\DriverManager')) {
    $connectionParams = [
        'driver' => 'pdo_pgsql',
        'host' => 'dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com',
        'port' => 5432,
        'dbname' => 'orangehrm_portos',
        'user' => 'orangehrm_user',
        'password' => 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX',
        'charset' => 'utf8'
    ];
    
    try {
        $GLOBALS['orangehrm_doctrine'] = \Doctrine\DBAL\DriverManager::getConnection($connectionParams);
    } catch (Exception $e) {
        error_log("Doctrine PostgreSQL Error: " . $e->getMessage());
    }
}

// Bypass installer checks
if (defined('INSTALLER_PATH') || strpos($_SERVER['REQUEST_URI'], 'installer') !== false) {
    // Simular que la DB está configurada
    $_SESSION['installer_db_configured'] = true;
    $_SESSION['installer_db_host'] = 'dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com';
    $_SESSION['installer_db_port'] = 5432;
    $_SESSION['installer_db_name'] = 'orangehrm_portos';
    $_SESSION['installer_db_user'] = 'orangehrm_user';
    $_SESSION['installer_db_pass'] = 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX';
}
?>