-- 03-data-portos.sql
-- Initial data for Portos International

BEGIN;

-- Organization Information
INSERT INTO ohrm_organization_gen_info (name, tax_id, registration_number, phone, email, country, city, street1)
VALUES (
    'Portos International',
    'PIN-RFC-2024-MX',
    'FREIGHT-MX-001',
    '+52 55 1234 5678',
    'info@portosinternational.com',
    'MX',
    'Ciudad de México',
    'Av. Reforma 123, Col. Polanco'
);

-- System Configuration
INSERT INTO hs_hr_config (name, value) VALUES
('admin.default_language', 'es'),
('admin.localization.default_language', 'es'),
('admin.product_name', 'OrangeHRM - Portos International'),
('admin.company_name', 'Portos International'),
('admin.country', 'MX'),
('admin.timezone', 'America/Mexico_City'),
('admin.default_currency', 'MXN'),
('admin.date_format', 'd/m/Y'),
('leave.work_week_monday', '1'),
('leave.work_week_tuesday', '1'),
('leave.work_week_wednesday', '1'),
('leave.work_week_thursday', '1'),
('leave.work_week_friday', '1'),
('leave.work_week_saturday', '0'),
('leave.work_week_sunday', '0');

-- User Roles
INSERT INTO ohrm_user_role (name, display_name, is_assignable, is_predefined) VALUES
('Admin', 'Administrador', true, true),
('ESS', 'Empleado', true, true),
('Supervisor', 'Supervisor', true, true);

-- Admin User (password: PortosAdmin123!)
-- Note: This is a bcrypt hash of PortosAdmin123!
INSERT INTO ohrm_user (user_role_id, user_name, user_password, emp_number)
VALUES (1, 'admin', '$2y$10$pVmqvITVXVU2p.UHZVVpR.QkKmHGeU9RmtYrqkKxho8WqgYW3Fwwm', 1);

-- Employment Status
INSERT INTO ohrm_employment_status (name) VALUES
('Tiempo Completo'),
('Tiempo Parcial'),
('Contrato'),
('Practicante'),
('Freelance');

-- Job Categories
INSERT INTO ohrm_job_category (name) VALUES
('Operaciones'),
('Administración'),
('Ventas'),
('Tecnología'),
('Recursos Humanos'),
('Logística');

-- Job Titles
INSERT INTO ohrm_job_title (job_title, job_description) VALUES
('Director General', 'Responsable de la dirección estratégica de la empresa'),
('Gerente de Operaciones', 'Gestión de operaciones de freight forwarding'),
('Gerente de Ventas', 'Desarrollo de negocios y relaciones con clientes'),
('Coordinador de Logística', 'Coordinación de envíos y rutas'),
('Ejecutivo de Cuenta', 'Atención y gestión de cuentas de clientes'),
('Analista de Operaciones', 'Análisis y optimización de procesos operativos'),
('Asistente Administrativo', 'Soporte administrativo general'),
('Especialista en Aduanas', 'Gestión de trámites aduanales'),
('Supervisor de Almacén', 'Supervisión de operaciones de almacén'),
('Contador', 'Gestión contable y financiera');

-- Departments (Subunits)
INSERT INTO ohrm_subunit (name, unit_id, description, lft, rgt, level) VALUES
('Portos International', 'PORTOS', 'Empresa matriz', 1, 12, 0),
('Dirección General', 'DIR', 'Dirección ejecutiva', 2, 3, 1),
('Operaciones', 'OPS', 'Departamento de operaciones', 4, 5, 1),
('Ventas', 'VEN', 'Departamento comercial', 6, 7, 1),
('Administración', 'ADM', 'Departamento administrativo', 8, 9, 1),
('Logística', 'LOG', 'Departamento de logística', 10, 11, 1);

-- Locations
INSERT INTO ohrm_location (name, country_code, province, city, address) VALUES
('Oficina Central CDMX', 'MX', 'Ciudad de México', 'Ciudad de México', 'Av. Reforma 123, Col. Polanco'),
('Almacén Vallejo', 'MX', 'Ciudad de México', 'Azcapotzalco', 'Calle Industrial 456, Vallejo'),
('Oficina Guadalajara', 'MX', 'Jalisco', 'Guadalajara', 'Av. Américas 789, Col. Providencia');

-- Countries
INSERT INTO ohrm_country (cou_code, name, cou_name, iso3, numcode) VALUES
('MX', 'MEXICO', 'México', 'MEX', 484),
('US', 'UNITED STATES', 'Estados Unidos', 'USA', 840),
('CA', 'CANADA', 'Canadá', 'CAN', 124),
('CN', 'CHINA', 'China', 'CHN', 156),
('DE', 'GERMANY', 'Alemania', 'DEU', 276);

-- Nationalities
INSERT INTO ohrm_nationality (name) VALUES
('Mexicana'),
('Estadounidense'),
('Canadiense'),
('China'),
('Alemana');

-- Leave Types
INSERT INTO ohrm_leave_type (name, deleted) VALUES
('Vacaciones', false),
('Enfermedad', false),
('Personal', false),
('Maternidad', false),
('Paternidad', false);

-- First Employee (Admin)
INSERT INTO hs_hr_employee (
    employee_id, emp_lastname, emp_firstname, emp_middle_name,
    emp_work_email, emp_mobile, joined_date, emp_status,
    job_title_code, work_station
) VALUES (
    'ADMIN001', 'Administrador', 'Sistema', '',
    'admin@portosinternational.com', '+52 55 1234 5678', '2024-01-01', 1,
    1, 2
);

COMMIT;

\echo 'Initial data loaded successfully'