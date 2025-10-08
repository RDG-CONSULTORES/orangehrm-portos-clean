-- ================================================================
-- DATOS DE PORTOS INTERNATIONAL - FREIGHT FORWARDING
-- ================================================================

-- Actualizar información de la organización
UPDATE ohrm_organization_gen_info SET 
    name = 'Portos International',
    tax_id = 'PTI850314X1A',
    registration_number = 'RFC-PTI-2015-001',
    phone = '+52 81 1234 5678',
    fax = '+52 81 1234 5679',
    email = 'info@portosinternational.com',
    country = 'MX',
    province = 'Nuevo León',
    city = 'Monterrey',
    zip_code = '64000',
    street1 = 'Av. Constitución 2450',
    street2 = 'Colonia Obrera',
    note = 'Empresa líder en freight forwarding y logística internacional'
WHERE organization_id = 1;

-- Crear estructura organizacional especializada en freight forwarding
INSERT INTO ohrm_subunit (name, unit_id, description, lft, rgt, level) VALUES
('Portos International', 'HQ', 'Casa matriz - Freight Forwarding & International Logistics', 1, 20, 0),
('Dirección General', 'DIR', 'Dirección ejecutiva y estratégica', 2, 3, 1),
('Operaciones Marítimas', 'MAR', 'Gestión de carga marítima y consolidación', 4, 5, 1),
('Operaciones Aéreas', 'AIR', 'Transporte aéreo y carga urgente', 6, 7, 1),
('Operaciones Terrestres', 'LAND', 'Transporte terrestre y distribución local', 8, 9, 1),
('Aduanas y Comercio Exterior', 'CUSTOMS', 'Despacho aduanero y documentación', 10, 11, 1),
('Atención al Cliente', 'CS', 'Servicio al cliente y seguimiento de embarques', 12, 13, 1),
('Finanzas y Cobranza', 'FIN', 'Administración financiera y cobranza', 14, 15, 1),
('Recursos Humanos', 'HR', 'Gestión de personal y desarrollo organizacional', 16, 17, 1),
('Tecnología e Innovación', 'IT', 'Sistemas y automatización logística', 18, 19, 1);

-- Crear puestos especializados en freight forwarding
INSERT INTO ohrm_job_title (job_title, job_description, note, is_deleted) VALUES
('Director General', 'Responsable de la estrategia corporativa y desarrollo de negocio en freight forwarding', 'Liderazgo ejecutivo', 0),
('Gerente de Operaciones Marítimas', 'Supervisión de operaciones de carga marítima, consolidación y LCL/FCL', 'Especialista en transporte marítimo', 0),
('Coordinador de Embarques Aéreos', 'Gestión de carga aérea, documentación IATA y embarques urgentes', 'Experto en logística aérea', 0),
('Agente Aduanal', 'Despacho aduanero, clasificación arancelaria y cumplimiento normativo', 'Certificación SAT requerida', 0),
('Especialista en Comercio Exterior', 'Documentación internacional, cartas de crédito y INCOTERMS', 'Conocimiento en regulaciones internacionales', 0),
('Coordinador de Transporte Terrestre', 'Gestión de flotas, rutas de distribución y last mile delivery', 'Especialista en transporte multimodal', 0),
('Customer Service Representative', 'Atención a clientes, tracking de embarques y resolución de incidencias', 'Comunicación bilingüe español-inglés', 0),
('Analista Financiero', 'Control de costos logísticos, facturación y análisis de rentabilidad', 'Especialización en costos logísticos', 0),
('Especialista en RRHH', 'Reclutamiento, capacitación y desarrollo de personal logístico', 'Enfoque en talento logístico', 0),
('Desarrollador de Sistemas Logísticos', 'Desarrollo de WMS, TMS y sistemas de tracking', 'Especialización en logtech', 0);

-- Insertar empleados mexicanos demo con datos realistas
INSERT INTO ohrm_employee (employee_id, emp_lastname, emp_firstname, emp_middle_name, emp_nick_name, emp_smoker, ethnic_race_code, emp_birthday, nation_code, emp_gender, emp_marital_status, emp_ssn, emp_sin, emp_other_id, emp_dri_lice_num, emp_dri_lice_exp_date, emp_military_service, emp_status, job_title_code, eeo_cat_code, work_station, emp_street1, emp_street2, city_code, coun_code, provin_code, emp_zipcode, emp_hm_telephone, emp_mobile, emp_work_telephone, emp_work_email, sal_grd_code, joined_date, emp_directDeb, emp_workPhone, emp_created_by, emp_created_date) VALUES

-- Dirección General
(1001, 'González', 'Ricardo', 'Antonio', 'Rick', 0, NULL, '1975-03-15', 484, 1, 'Married', '1234567890123456789', NULL, 'PTI-001', 'MTY123456', '2025-03-15', NULL, 1, 1, NULL, 1, 'Av. Constitución 2450, Piso 10', 'Colonia Obrera', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 1000', '+52 81 1234 5001', '+52 81 8350 1001', 'ricardo.gonzalez@portosinternational.com', NULL, '2015-01-15', NULL, NULL, 1, '2024-01-01'),

-- Operaciones Marítimas
(1002, 'Hernández', 'María', 'Elena', 'Mary', 0, NULL, '1982-07-22', 484, 2, 'Single', '2345678901234567890', NULL, 'PTI-002', 'MTY234567', '2025-07-22', NULL, 1, 2, NULL, 2, 'Calle Morelos 1234', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 2000', '+52 81 1234 5002', '+52 81 8350 2001', 'maria.hernandez@portosinternational.com', NULL, '2018-03-10', NULL, NULL, 1, '2024-01-01'),

(1003, 'López', 'Carlos', 'Javier', 'Charlie', 0, NULL, '1985-11-08', 484, 1, 'Married', '3456789012345678901', NULL, 'PTI-003', 'MTY345678', '2025-11-08', NULL, 1, 2, NULL, 2, 'Av. Universidad 567', 'Mitras Centro', 'Monterrey', 'MX', 'NL', '64460', '+52 81 8350 2000', '+52 81 1234 5003', '+52 81 8350 2002', 'carlos.lopez@portosinternational.com', NULL, '2019-05-20', NULL, NULL, 1, '2024-01-01'),

-- Operaciones Aéreas  
(1004, 'Martínez', 'Ana', 'Sofía', 'Annie', 0, NULL, '1988-02-14', 484, 2, 'Married', '4567890123456789012', NULL, 'PTI-004', 'MTY456789', '2025-02-14', NULL, 1, 3, NULL, 3, 'Calle Hidalgo 890', 'Barrio Antiguo', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 3000', '+52 81 1234 5004', '+52 81 8350 3001', 'ana.martinez@portosinternational.com', NULL, '2020-02-01', NULL, NULL, 1, '2024-01-01'),

(1005, 'Rodríguez', 'Luis', 'Fernando', 'Luis', 0, NULL, '1983-09-30', 484, 1, 'Single', '5678901234567890123', NULL, 'PTI-005', 'MTY567890', '2025-09-30', NULL, 1, 3, NULL, 3, 'Av. Revolución 234', 'Obrera', 'Monterrey', 'MX', 'NL', '64040', '+52 81 8350 3000', '+52 81 1234 5005', '+52 81 8350 3002', 'luis.rodriguez@portosinternational.com', NULL, '2017-08-15', NULL, NULL, 1, '2024-01-01'),

-- Operaciones Terrestres
(1006, 'García', 'Patricia', 'Isabel', 'Paty', 0, NULL, '1990-06-18', 484, 2, 'Single', '6789012345678901234', NULL, 'PTI-006', 'MTY678901', '2025-06-18', NULL, 1, 6, NULL, 4, 'Calle Allende 456', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 4000', '+52 81 1234 5006', '+52 81 8350 4001', 'patricia.garcia@portosinternational.com', NULL, '2021-01-10', NULL, NULL, 1, '2024-01-01'),

(1007, 'Sánchez', 'Miguel', 'Ángel', 'Mike', 0, NULL, '1986-12-05', 484, 1, 'Married', '7890123456789012345', NULL, 'PTI-007', 'MTY789012', '2025-12-05', NULL, 1, 6, NULL, 4, 'Av. Lincoln 789', 'Mitras Norte', 'Monterrey', 'MX', 'NL', '64420', '+52 81 8350 4000', '+52 81 1234 5007', '+52 81 8350 4002', 'miguel.sanchez@portosinternational.com', NULL, '2019-11-25', NULL, NULL, 1, '2024-01-01'),

-- Aduanas y Comercio Exterior
(1008, 'Ramírez', 'Laura', 'Beatriz', 'Lau', 0, NULL, '1984-04-27', 484, 2, 'Married', '8901234567890123456', NULL, 'PTI-008', 'MTY890123', '2025-04-27', NULL, 1, 4, NULL, 5, 'Calle Zaragoza 123', 'Barrio Estrella', 'Monterrey', 'MX', 'NL', '64108', '+52 81 8350 5000', '+52 81 1234 5008', '+52 81 8350 5001', 'laura.ramirez@portosinternational.com', NULL, '2016-06-01', NULL, NULL, 1, '2024-01-01'),

(1009, 'Torres', 'Alejandro', 'Daniel', 'Alex', 0, NULL, '1981-10-12', 484, 1, 'Single', '9012345678901234567', NULL, 'PTI-009', 'MTY901234', '2025-10-12', NULL, 1, 5, NULL, 5, 'Av. Madero 678', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 5000', '+52 81 1234 5009', '+52 81 8350 5002', 'alejandro.torres@portosinternational.com', NULL, '2015-09-10', NULL, NULL, 1, '2024-01-01'),

(1010, 'Flores', 'Carmen', 'Rosa', 'Carmen', 0, NULL, '1987-08-03', 484, 2, 'Married', '0123456789012345678', NULL, 'PTI-010', 'MTY012345', '2025-08-03', NULL, 1, 5, NULL, 5, 'Calle Juárez 345', 'Obrera', 'Monterrey', 'MX', 'NL', '64040', '+52 81 8350 5000', '+52 81 1234 5010', '+52 81 8350 5003', 'carmen.flores@portosinternational.com', NULL, '2018-12-01', NULL, NULL, 1, '2024-01-01'),

-- Atención al Cliente
(1011, 'Morales', 'Roberto', 'Carlos', 'Rob', 0, NULL, '1989-01-25', 484, 1, 'Single', '1234567890123456780', NULL, 'PTI-011', 'MTY123450', '2025-01-25', NULL, 1, 7, NULL, 6, 'Av. Chapultepec 567', 'Residencial San Agustín', 'San Pedro Garza García', 'MX', 'NL', '66220', '+52 81 8350 6000', '+52 81 1234 5011', '+52 81 8350 6001', 'roberto.morales@portosinternational.com', NULL, '2020-07-15', NULL, NULL, 1, '2024-01-01'),

(1012, 'Jiménez', 'Gabriela', 'Monserrat', 'Gaby', 0, NULL, '1991-05-19', 484, 2, 'Single', '2345678901234567801', NULL, 'PTI-012', 'MTY234501', '2025-05-19', NULL, 1, 7, NULL, 6, 'Calle Pino Suárez 890', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 6000', '+52 81 1234 5012', '+52 81 8350 6002', 'gabriela.jimenez@portosinternational.com', NULL, '2021-03-08', NULL, NULL, 1, '2024-01-01'),

(1013, 'Vázquez', 'Fernando', 'Javier', 'Fer', 0, NULL, '1986-09-07', 484, 1, 'Married', '3456789012345678012', NULL, 'PTI-013', 'MTY345012', '2025-09-07', NULL, 1, 7, NULL, 6, 'Av. Gonzalitos 234', 'Mitras Centro', 'Monterrey', 'MX', 'NL', '64460', '+52 81 8350 6000', '+52 81 1234 5013', '+52 81 8350 6003', 'fernando.vazquez@portosinternational.com', NULL, '2019-04-20', NULL, NULL, 1, '2024-01-01'),

-- Finanzas y Cobranza
(1014, 'Castillo', 'Andrea', 'Lucía', 'Andy', 0, NULL, '1985-12-28', 484, 2, 'Married', '4567890123456789023', NULL, 'PTI-014', 'MTY456023', '2025-12-28', NULL, 1, 8, NULL, 7, 'Calle Ocampo 456', 'Barrio Antiguo', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 7000', '+52 81 1234 5014', '+52 81 8350 7001', 'andrea.castillo@portosinternational.com', NULL, '2017-01-15', NULL, NULL, 1, '2024-01-01'),

(1015, 'Mendoza', 'Jorge', 'Eduardo', 'George', 0, NULL, '1983-03-16', 484, 1, 'Single', '5678901234567890234', NULL, 'PTI-015', 'MTY567234', '2025-03-16', NULL, 1, 8, NULL, 7, 'Av. Constitución 789', 'Obrera', 'Monterrey', 'MX', 'NL', '64040', '+52 81 8350 7000', '+52 81 1234 5015', '+52 81 8350 7002', 'jorge.mendoza@portosinternational.com', NULL, '2016-11-10', NULL, NULL, 1, '2024-01-01'),

-- Recursos Humanos
(1016, 'Guerrero', 'Claudia', 'Alejandra', 'Clau', 0, NULL, '1988-07-11', 484, 2, 'Married', '6789012345678901345', NULL, 'PTI-016', 'MTY678345', '2025-07-11', NULL, 1, 9, NULL, 8, 'Calle Aramberri 123', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 8000', '+52 81 1234 5016', '+52 81 8350 8001', 'claudia.guerrero@portosinternational.com', NULL, '2019-08-01', NULL, NULL, 1, '2024-01-01'),

(1017, 'Ruiz', 'Arturo', 'Manuel', 'Art', 0, NULL, '1984-11-23', 484, 1, 'Single', '7890123456789012456', NULL, 'PTI-017', 'MTY789456', '2025-11-23', NULL, 1, 9, NULL, 8, 'Av. Madero 567', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 8000', '+52 81 1234 5017', '+52 81 8350 8002', 'arturo.ruiz@portosinternational.com', NULL, '2018-05-15', NULL, NULL, 1, '2024-01-01'),

-- Tecnología e Innovación
(1018, 'Ortega', 'Daniela', 'Victoria', 'Dani', 0, NULL, '1992-04-09', 484, 2, 'Single', '8901234567890123567', NULL, 'PTI-018', 'MTY890567', '2025-04-09', NULL, 1, 10, NULL, 9, 'Av. Universidad 890', 'San Nicolás de los Garza', 'San Nicolás', 'MX', 'NL', '66400', '+52 81 8350 9000', '+52 81 1234 5018', '+52 81 8350 9001', 'daniela.ortega@portosinternational.com', NULL, '2022-01-10', NULL, NULL, 1, '2024-01-01'),

(1019, 'Silva', 'David', 'Alberto', 'Dave', 0, NULL, '1987-06-14', 484, 1, 'Married', '9012345678901234678', NULL, 'PTI-019', 'MTY901678', '2025-06-14', NULL, 1, 10, NULL, 9, 'Calle Escobedo 234', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 9000', '+52 81 1234 5019', '+52 81 8350 9002', 'david.silva@portosinternational.com', NULL, '2020-09-01', NULL, NULL, 1, '2024-01-01'),

(1020, 'Navarro', 'Valeria', 'Fernanda', 'Vale', 0, NULL, '1990-10-26', 484, 2, 'Single', '0123456789012345789', NULL, 'PTI-020', 'MTY012789', '2025-10-26', NULL, 1, 10, NULL, 9, 'Av. Revolución 456', 'Obrera', 'Monterrey', 'MX', 'NL', '64040', '+52 81 8350 9000', '+52 81 1234 5020', '+52 81 8350 9003', 'valeria.navarro@portosinternational.com', NULL, '2021-06-15', NULL, NULL, 1, '2024-01-01'),

-- Empleados adicionales para completar los 25
(1021, 'Peña', 'Manuel', 'Ricardo', 'Manny', 0, NULL, '1989-08-12', 484, 1, 'Married', '1234567890123456791', NULL, 'PTI-021', 'MTY123791', '2025-08-12', NULL, 1, 6, NULL, 4, 'Calle Reforma 789', 'Moderna', 'Monterrey', 'MX', 'NL', '64530', '+52 81 8350 4000', '+52 81 1234 5021', '+52 81 8350 4003', 'manuel.pena@portosinternational.com', NULL, '2020-04-01', NULL, NULL, 1, '2024-01-01'),

(1022, 'Cruz', 'Mónica', 'Alejandra', 'Moni', 0, NULL, '1986-02-08', 484, 2, 'Single', '2345678901234567802', NULL, 'PTI-022', 'MTY234802', '2025-02-08', NULL, 1, 7, NULL, 6, 'Av. Simón Bolívar 321', 'Mitras Centro', 'Monterrey', 'MX', 'NL', '64460', '+52 81 8350 6000', '+52 81 1234 5022', '+52 81 8350 6004', 'monica.cruz@portosinternational.com', NULL, '2019-10-15', NULL, NULL, 1, '2024-01-01'),

(1023, 'Aguilar', 'Ricardo', 'José', 'Ricky', 0, NULL, '1985-05-20', 484, 1, 'Married', '3456789012345678913', NULL, 'PTI-023', 'MTY345913', '2025-05-20', NULL, 1, 2, NULL, 2, 'Calle Doctor Coss 654', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 2000', '+52 81 1234 5023', '+52 81 8350 2003', 'ricardo.aguilar@portosinternational.com', NULL, '2018-07-01', NULL, NULL, 1, '2024-01-01'),

(1024, 'Ramos', 'Karla', 'Patricia', 'Karla', 0, NULL, '1991-09-15', 484, 2, 'Single', '4567890123456789024', NULL, 'PTI-024', 'MTY456024', '2025-09-15', NULL, 1, 5, NULL, 5, 'Av. Félix U. Gómez 987', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 5000', '+52 81 1234 5024', '+52 81 8350 5004', 'karla.ramos@portosinternational.com', NULL, '2021-12-01', NULL, NULL, 1, '2024-01-01'),

(1025, 'Moreno', 'Enrique', 'Javier', 'Kike', 0, NULL, '1987-01-30', 484, 1, 'Married', '5678901234567890135', NULL, 'PTI-025', 'MTY567135', '2025-01-30', NULL, 1, 3, NULL, 3, 'Calle Washington 159', 'Centro', 'Monterrey', 'MX', 'NL', '64000', '+52 81 8350 3000', '+52 81 1234 5025', '+52 81 8350 3003', 'enrique.moreno@portosinternational.com', NULL, '2019-02-20', NULL, NULL, 1, '2024-01-01');

-- Insertar campos personalizados para freight forwarding
INSERT INTO ohrm_hs_hr_config (hs_hr_key, hs_hr_value) VALUES
('custom_field_freight_cert', 'Certificaciones en Freight Forwarding'),
('custom_field_customs_license', 'Licencia Aduanal'),
('custom_field_languages', 'Idiomas (Comercio Internacional)'),
('custom_field_incoterms_knowledge', 'Conocimiento de INCOTERMS'),
('custom_field_maritime_experience', 'Experiencia Marítima (años)'),
('custom_field_air_cargo_cert', 'Certificación IATA Carga Aérea'),
('custom_field_dangerous_goods', 'Certificación Mercancías Peligrosas'),
('locale_package', 'es'),
('admin.default_workshift_start_time', '08:00'),
('admin.default_workshift_end_time', '17:00'),
('admin.default_workshift_hours_per_day', '8.00'),
('leave.work_schedule', 'Monday to Friday'),
('leave.holidays_country', 'MX');

-- Insertar configuración del sistema para México
UPDATE ohrm_hs_hr_config SET hs_hr_value = 'es' WHERE hs_hr_key = 'admin.localization.default_language';
UPDATE ohrm_hs_hr_config SET hs_hr_value = 'MX' WHERE hs_hr_key = 'admin.localization.default_country';
UPDATE ohrm_hs_hr_config SET hs_hr_value = 'MXN' WHERE hs_hr_key = 'admin.localization.default_currency';
UPDATE ohrm_hs_hr_config SET hs_hr_value = 'America/Mexico_City' WHERE hs_hr_key = 'admin.localization.default_timezone';

-- Configurar días festivos mexicanos
INSERT INTO ohrm_holiday (description, date, recurring, length) VALUES
('Año Nuevo', '2024-01-01', 1, 1),
('Día de la Constitución', '2024-02-05', 1, 1),
('Natalicio de Benito Juárez', '2024-03-18', 1, 1),
('Jueves Santo', '2024-03-28', 0, 1),
('Viernes Santo', '2024-03-29', 0, 1),
('Día del Trabajo', '2024-05-01', 1, 1),
('Día de la Independencia', '2024-09-16', 1, 1),
('Día de la Revolución Mexicana', '2024-11-18', 1, 1),
('Navidad', '2024-12-25', 1, 1);

-- Mensaje de finalización
SELECT 'Datos de Portos International aplicados exitosamente' as resultado;