-- 04-employees-data.sql
-- 25 Mexican employees for Portos International

BEGIN;

-- Additional employees (2-25)
INSERT INTO hs_hr_employee (
    employee_id, emp_lastname, emp_firstname, emp_middle_name,
    emp_work_email, emp_mobile, emp_gender, emp_birthday, joined_date,
    emp_status, job_title_code, work_station, emp_street1, city_code,
    coun_code, provin_code
) VALUES 
-- Management Team
('PORT002', 'García', 'María', 'Elena', 'maria.garcia@portosinternational.com', '+52 55 2345 6789', 2, '1985-03-15', '2024-01-15', 1, 2, 3, 'Calle Morelos 234', 'Ciudad de México', 'MX', 'CDMX'),
('PORT003', 'López', 'Carlos', 'Alberto', 'carlos.lopez@portosinternational.com', '+52 55 3456 7890', 1, '1982-07-22', '2024-02-01', 1, 3, 4, 'Av. Insurgentes 567', 'Ciudad de México', 'MX', 'CDMX'),
('PORT004', 'Martínez', 'Ana', 'Sofía', 'ana.martinez@portosinternational.com', '+52 55 4567 8901', 2, '1988-11-08', '2024-02-15', 1, 4, 5, 'Calle Juárez 890', 'Ciudad de México', 'MX', 'CDMX'),

-- Operations Team
('PORT005', 'Hernández', 'Luis', 'Fernando', 'luis.hernandez@portosinternational.com', '+52 55 5678 9012', 1, '1990-05-12', '2024-03-01', 1, 6, 3, 'Av. Universidad 123', 'Ciudad de México', 'MX', 'CDMX'),
('PORT006', 'González', 'Patricia', 'Isabel', 'patricia.gonzalez@portosinternational.com', '+52 55 6789 0123', 2, '1987-09-30', '2024-03-15', 1, 6, 3, 'Calle Revolución 456', 'Ciudad de México', 'MX', 'CDMX'),
('PORT007', 'Rodríguez', 'Miguel', 'Ángel', 'miguel.rodriguez@portosinternational.com', '+52 55 7890 1234', 1, '1991-01-18', '2024-04-01', 1, 8, 3, 'Av. Constitución 789', 'Ciudad de México', 'MX', 'CDMX'),
('PORT008', 'Fernández', 'Carmen', 'Lucía', 'carmen.fernandez@portosinternational.com', '+52 55 8901 2345', 2, '1989-06-25', '2024-04-15', 1, 8, 3, 'Calle Independencia 012', 'Ciudad de México', 'MX', 'CDMX'),

-- Sales Team
('PORT009', 'Morales', 'Roberto', 'Carlos', 'roberto.morales@portosinternational.com', '+52 55 9012 3456', 1, '1986-12-03', '2024-05-01', 1, 5, 4, 'Av. Madero 345', 'Ciudad de México', 'MX', 'CDMX'),
('PORT010', 'Jiménez', 'Elena', 'Victoria', 'elena.jimenez@portosinternational.com', '+52 55 0123 4567', 2, '1992-04-14', '2024-05-15', 1, 5, 4, 'Calle Hidalgo 678', 'Ciudad de México', 'MX', 'CDMX'),
('PORT011', 'Ruiz', 'Francisco', 'Javier', 'francisco.ruiz@portosinternational.com', '+52 55 1234 5679', 1, '1984-10-07', '2024-06-01', 1, 5, 4, 'Av. 5 de Mayo 901', 'Ciudad de México', 'MX', 'CDMX'),

-- Logistics Team
('PORT012', 'Vargas', 'Daniela', 'Alejandra', 'daniela.vargas@portosinternational.com', '+52 55 2345 6780', 2, '1990-08-19', '2024-06-15', 1, 4, 5, 'Calle Aldama 234', 'Ciudad de México', 'MX', 'CDMX'),
('PORT013', 'Castro', 'Andrés', 'Manuel', 'andres.castro@portosinternational.com', '+52 55 3456 7891', 1, '1988-02-28', '2024-07-01', 1, 9, 5, 'Av. Chapultepec 567', 'Ciudad de México', 'MX', 'CDMX'),
('PORT014', 'Ortega', 'Gabriela', 'Monserrat', 'gabriela.ortega@portosinternational.com', '+52 55 4567 8902', 2, '1993-11-11', '2024-07-15', 1, 4, 5, 'Calle Allende 890', 'Ciudad de México', 'MX', 'CDMX'),

-- Administrative Team
('PORT015', 'Ramírez', 'Jorge', 'Antonio', 'jorge.ramirez@portosinternational.com', '+52 55 5678 9013', 1, '1987-05-16', '2024-08-01', 1, 10, 6, 'Av. Reforma 123', 'Ciudad de México', 'MX', 'CDMX'),
('PORT016', 'Torres', 'Mónica', 'Beatriz', 'monica.torres@portosinternational.com', '+52 55 6789 0124', 2, '1991-09-05', '2024-08-15', 1, 7, 6, 'Calle Cuauhtémoc 456', 'Ciudad de México', 'MX', 'CDMX'),
('PORT017', 'Flores', 'Ricardo', 'Edmundo', 'ricardo.flores@portosinternational.com', '+52 55 7890 1235', 1, '1989-01-12', '2024-09-01', 1, 7, 6, 'Av. Tlalpan 789', 'Ciudad de México', 'MX', 'CDMX'),

-- Warehouse Team
('PORT018', 'Mendoza', 'Susana', 'Esperanza', 'susana.mendoza@portosinternational.com', '+52 55 8901 2346', 2, '1986-06-29', '2024-09-15', 1, 9, 5, 'Calle Vallejo 012', 'Azcapotzalco', 'MX', 'CDMX'),
('PORT019', 'Aguilar', 'Fernando', 'Raúl', 'fernando.aguilar@portosinternational.com', '+52 55 9012 3457', 1, '1992-12-08', '2024-10-01', 1, 9, 5, 'Av. Central 345', 'Azcapotzalco', 'MX', 'CDMX'),
('PORT020', 'Medina', 'Rosa', 'María', 'rosa.medina@portosinternational.com', '+52 55 0123 4568', 2, '1988-03-21', '2024-10-15', 1, 7, 5, 'Calle Norte 678', 'Azcapotzalco', 'MX', 'CDMX'),

-- Guadalajara Office
('PORT021', 'Reyes', 'Alejandro', 'Salvador', 'alejandro.reyes@portosinternational.com', '+52 33 1234 5670', 1, '1990-07-14', '2024-11-01', 1, 5, 4, 'Av. Américas 901', 'Guadalajara', 'MX', 'JAL'),
('PORT022', 'Guerrero', 'Claudia', 'Fernanda', 'claudia.guerrero@portosinternational.com', '+52 33 2345 6781', 2, '1985-11-27', '2024-11-15', 1, 6, 3, 'Calle Libertad 234', 'Guadalajara', 'MX', 'JAL'),

-- Recent Hires
('PORT023', 'Moreno', 'Diego', 'Sebastián', 'diego.moreno@portosinternational.com', '+52 55 3456 7892', 1, '1994-04-09', '2024-12-01', 1, 7, 6, 'Av. Insurgentes 567', 'Ciudad de México', 'MX', 'CDMX'),
('PORT024', 'Peña', 'Valeria', 'Ximena', 'valeria.pena@portosinternational.com', '+52 55 4567 8903', 2, '1991-08-17', '2024-12-15', 1, 8, 3, 'Calle Doctores 890', 'Ciudad de México', 'MX', 'CDMX'),
('PORT025', 'Silva', 'Emilio', 'Gustavo', 'emilio.silva@portosinternational.com', '+52 55 5678 9014', 1, '1987-02-06', '2024-12-20', 1, 4, 5, 'Av. San Juan 123', 'Ciudad de México', 'MX', 'CDMX');

-- Update the admin user's employee number to match the first employee
UPDATE ohrm_user SET emp_number = 1 WHERE user_name = 'admin';

COMMIT;

\echo '25 employees data loaded successfully'