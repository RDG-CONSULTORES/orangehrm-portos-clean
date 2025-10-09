<?php
/**
 * API REST para Dashboard Portos International
 * Conexión directa a Railway MySQL
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Configuración MySQL Railway
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
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed', 'message' => $e->getMessage()]);
    exit;
}

// Router simple
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);
$path = str_replace('/api', '', $path);
$method = $_SERVER['REQUEST_METHOD'];

// Endpoints disponibles
switch ($path) {
    case '/employees':
        handleEmployees($pdo, $method);
        break;
    
    case '/employees/count':
        handleEmployeeCount($pdo);
        break;
    
    case '/departments':
        handleDepartments($pdo);
        break;
    
    case '/company':
        handleCompanyInfo($pdo);
        break;
    
    case '/dashboard':
        handleDashboard($pdo);
        break;
    
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
        break;
}

function handleEmployees($pdo, $method) {
    if ($method === 'GET') {
        try {
            $stmt = $pdo->query("
                SELECT 
                    emp_number,
                    employee_id,
                    emp_firstname as first_name,
                    emp_middle_name as middle_name,
                    emp_lastname as last_name,
                    emp_work_email as email,
                    joined_date,
                    emp_gender as gender,
                    emp_marital_status as marital_status
                FROM hs_hr_employee 
                ORDER BY emp_lastname, emp_firstname
            ");
            
            $employees = $stmt->fetchAll();
            
            // Convertir gender a texto
            foreach ($employees as &$employee) {
                $employee['gender'] = $employee['gender'] == 1 ? 'Male' : 'Female';
            }
            
            echo json_encode([
                'success' => true,
                'data' => $employees,
                'count' => count($employees)
            ]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Query failed', 'message' => $e->getMessage()]);
        }
    }
}

function handleEmployeeCount($pdo) {
    try {
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM hs_hr_employee");
        $result = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'data' => [
                'total_employees' => (int)$result['total']
            ]
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Query failed', 'message' => $e->getMessage()]);
    }
}

function handleDepartments($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT 
                id,
                name as department_name,
                description
            FROM ohrm_subunit 
            WHERE name != 'Portos International'
            ORDER BY name
        ");
        
        $departments = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $departments,
            'count' => count($departments)
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Query failed', 'message' => $e->getMessage()]);
    }
}

function handleCompanyInfo($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT 
                name,
                tax_id,
                phone,
                email,
                country,
                city,
                street1,
                street2
            FROM ohrm_organization_gen_info 
            LIMIT 1
        ");
        
        $company = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'data' => $company ?: [
                'name' => 'Portos International',
                'tax_id' => 'PTI850314X1A',
                'phone' => '+52 81 1234 5678',
                'email' => 'info@portosinternational.com',
                'country' => 'Mexico',
                'city' => 'Monterrey',
                'street1' => 'Av. Constitución 2450',
                'street2' => 'Colonia Obrera'
            ]
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Query failed', 'message' => $e->getMessage()]);
    }
}

function handleDashboard($pdo) {
    try {
        // Resumen completo para dashboard
        $dashboard = [];
        
        // Total empleados
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM hs_hr_employee");
        $dashboard['total_employees'] = (int)$stmt->fetch()['total'];
        
        // Empleados por género
        $stmt = $pdo->query("
            SELECT 
                emp_gender,
                COUNT(*) as count 
            FROM hs_hr_employee 
            GROUP BY emp_gender
        ");
        $gender_data = $stmt->fetchAll();
        $dashboard['employees_by_gender'] = [
            'male' => 0,
            'female' => 0
        ];
        foreach ($gender_data as $row) {
            if ($row['emp_gender'] == 1) {
                $dashboard['employees_by_gender']['male'] = (int)$row['count'];
            } else {
                $dashboard['employees_by_gender']['female'] = (int)$row['count'];
            }
        }
        
        // Total departamentos
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM ohrm_subunit WHERE name != 'Portos International'");
        $dashboard['total_departments'] = (int)$stmt->fetch()['total'];
        
        // Información de la empresa
        $stmt = $pdo->query("SELECT name, city, country FROM ohrm_organization_gen_info LIMIT 1");
        $company = $stmt->fetch();
        $dashboard['company'] = $company ?: [
            'name' => 'Portos International',
            'city' => 'Monterrey',
            'country' => 'Mexico'
        ];
        
        echo json_encode([
            'success' => true,
            'data' => $dashboard,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Dashboard query failed', 'message' => $e->getMessage()]);
    }
}
?>