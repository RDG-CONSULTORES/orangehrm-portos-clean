<?php
session_start();

// Verificar si está logueado
if (!($_SESSION['logged_in'] ?? false)) {
    header('Location: index.php');
    exit;
}

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

// Obtener datos para dashboard
$stats = [];

// Total empleados
$stmt = $pdo->query("SELECT COUNT(*) as total FROM hs_hr_employee");
$stats['total_employees'] = $stmt->fetch()['total'];

// Empleados por género
$stmt = $pdo->query("SELECT emp_gender, COUNT(*) as count FROM hs_hr_employee GROUP BY emp_gender");
$gender_data = $stmt->fetchAll();
$stats['male'] = 0;
$stats['female'] = 0;
foreach ($gender_data as $row) {
    if ($row['emp_gender'] == 1) {
        $stats['male'] = $row['count'];
    } else {
        $stats['female'] = $row['count'];
    }
}

// Últimos empleados
$stmt = $pdo->query("
    SELECT emp_firstname, emp_lastname, emp_work_email, joined_date 
    FROM hs_hr_employee 
    ORDER BY emp_number DESC 
    LIMIT 5
");
$recent_employees = $stmt->fetchAll();

// Manejo de logout
if ($_GET['logout'] ?? false) {
    session_destroy();
    header('Location: index.php');
    exit;
}

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Portos International</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .navbar-brand {
            font-weight: bold;
        }
        .stat-card {
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-icon {
            font-size: 2rem;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="fas fa-ship me-2"></i>Portos International
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <i class="fas fa-user me-1"></i><?= $_SESSION['username'] ?>
                </span>
                <a class="btn btn-outline-light btn-sm" href="?logout=1">
                    <i class="fas fa-sign-out-alt me-1"></i>Salir
                </a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col">
                <h2><i class="fas fa-tachometer-alt me-2"></i>Dashboard</h2>
                <p class="text-muted">Freight Forwarding & International Logistics</p>
            </div>
        </div>

        <!-- Estadísticas principales -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card stat-card h-100 border-0 shadow-sm">
                    <div class="card-body text-center">
                        <div class="stat-icon text-primary mb-2">
                            <i class="fas fa-users"></i>
                        </div>
                        <h3 class="mb-1"><?= $stats['total_employees'] ?></h3>
                        <p class="text-muted mb-0">Total Empleados</p>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card stat-card h-100 border-0 shadow-sm">
                    <div class="card-body text-center">
                        <div class="stat-icon text-info mb-2">
                            <i class="fas fa-male"></i>
                        </div>
                        <h3 class="mb-1"><?= $stats['male'] ?></h3>
                        <p class="text-muted mb-0">Hombres</p>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card stat-card h-100 border-0 shadow-sm">
                    <div class="card-body text-center">
                        <div class="stat-icon text-success mb-2">
                            <i class="fas fa-female"></i>
                        </div>
                        <h3 class="mb-1"><?= $stats['female'] ?></h3>
                        <p class="text-muted mb-0">Mujeres</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Empleados recientes -->
            <div class="col-md-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="fas fa-user-plus me-2"></i>Empleados Recientes</h5>
                    </div>
                    <div class="card-body">
                        <?php if (empty($recent_employees)): ?>
                            <p class="text-muted text-center py-4">No hay empleados registrados</p>
                        <?php else: ?>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Nombre</th>
                                            <th>Email</th>
                                            <th>Fecha Ingreso</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($recent_employees as $emp): ?>
                                        <tr>
                                            <td><?= htmlspecialchars($emp['emp_firstname'] . ' ' . $emp['emp_lastname']) ?></td>
                                            <td><?= htmlspecialchars($emp['emp_work_email'] ?? 'N/A') ?></td>
                                            <td><?= $emp['joined_date'] ? date('d/m/Y', strtotime($emp['joined_date'])) : 'N/A' ?></td>
                                        </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- API Info -->
            <div class="col-md-4">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="fas fa-code me-2"></i>API REST</h5>
                    </div>
                    <div class="card-body">
                        <p class="text-muted small">Endpoints disponibles para integración:</p>
                        
                        <div class="d-grid gap-2">
                            <a href="/api/dashboard" class="btn btn-outline-primary btn-sm" target="_blank">
                                <i class="fas fa-chart-bar me-1"></i>Dashboard API
                            </a>
                            <a href="/api/employees" class="btn btn-outline-success btn-sm" target="_blank">
                                <i class="fas fa-users me-1"></i>Empleados API
                            </a>
                            <a href="/api/employees/count" class="btn btn-outline-info btn-sm" target="_blank">
                                <i class="fas fa-calculator me-1"></i>Conteo API
                            </a>
                            <a href="/api/company" class="btn btn-outline-warning btn-sm" target="_blank">
                                <i class="fas fa-building me-1"></i>Empresa API
                            </a>
                        </div>
                        
                        <div class="mt-3 pt-3 border-top">
                            <p class="text-muted small mb-2">
                                <i class="fas fa-info-circle me-1"></i>Formato: JSON
                            </p>
                            <p class="text-muted small mb-0">
                                <i class="fas fa-globe me-1"></i>CORS habilitado
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="mt-5 py-4 text-center text-muted">
            <hr>
            <p class="mb-0">
                <i class="fas fa-ship me-1"></i>Portos International - Freight Forwarding & International Logistics
                <br>
                <small>Monterrey, Nuevo León, México</small>
            </p>
        </footer>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Auto-refresh de estadísticas cada 30 segundos -->
    <script>
        setInterval(function() {
            // Refrescar estadísticas via AJAX si es necesario
            console.log('Estadísticas actualizadas:', new Date().toLocaleTimeString());
        }, 30000);
    </script>
</body>
</html>