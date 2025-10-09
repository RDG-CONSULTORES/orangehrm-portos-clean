<?php
/**
 * Portos International HR System
 * Sistema de gestión de recursos humanos funcional
 */

session_start();

// Configuración de base de datos
$db_config = [
    'host' => 'shinkansen.proxy.rlwy.net',
    'port' => 49981,
    'database' => 'railway',
    'username' => 'root',
    'password' => 'ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE'
];

try {
    $pdo = new PDO(
        "mysql:host={$db_config['host']};port={$db_config['port']};dbname={$db_config['database']};charset=utf8",
        $db_config['username'],
        $db_config['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    die("Error de conexión: " . $e->getMessage());
}

// Manejo de login
if ($_POST['username'] ?? false) {
    $username = $_POST['username'];
    $password = $_POST['password'];
    
    // Login simple para demo (en producción usar hash)
    if ($username === 'admin' && $password === 'admin123') {
        $_SESSION['logged_in'] = true;
        $_SESSION['username'] = $username;
        header('Location: dashboard.php');
        exit;
    } else {
        $error = "Credenciales incorrectas";
    }
}

// Si ya está logueado, redirigir al dashboard
if ($_SESSION['logged_in'] ?? false) {
    header('Location: dashboard.php');
    exit;
}

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portos International - HR System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        }
        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            font-weight: bold;
            margin: 0 auto 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-4">
                <div class="login-card p-4">
                    <div class="text-center mb-4">
                        <div class="logo">PI</div>
                        <h2 class="mb-1">Portos International</h2>
                        <p class="text-muted">Sistema de Recursos Humanos</p>
                    </div>
                    
                    <?php if (isset($error)): ?>
                        <div class="alert alert-danger"><?= $error ?></div>
                    <?php endif; ?>
                    
                    <form method="POST">
                        <div class="mb-3">
                            <label for="username" class="form-label">Usuario</label>
                            <input type="text" class="form-control" id="username" name="username" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="password" class="form-label">Contraseña</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100 mb-3">Iniciar Sesión</button>
                    </form>
                    
                    <div class="text-center">
                        <small class="text-muted">
                            Demo: admin / admin123<br>
                            Freight Forwarding & International Logistics
                        </small>
                    </div>
                    
                    <div class="mt-4 pt-3 border-top">
                        <h6 class="text-center mb-3">API Endpoints Disponibles</h6>
                        <div class="d-grid gap-2">
                            <a href="/api/dashboard" class="btn btn-outline-info btn-sm" target="_blank">
                                📊 Dashboard API
                            </a>
                            <a href="/api/employees" class="btn btn-outline-success btn-sm" target="_blank">
                                👥 Empleados API
                            </a>
                            <a href="/api/company" class="btn btn-outline-warning btn-sm" target="_blank">
                                🏢 Empresa API
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>