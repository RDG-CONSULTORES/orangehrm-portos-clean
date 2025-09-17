-- 02-schema.sql
-- OrangeHRM Core Tables for PostgreSQL
-- Adapted from MySQL schema

BEGIN;

-- Organization Info
CREATE TABLE IF NOT EXISTS ohrm_organization_gen_info (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    tax_id VARCHAR(30),
    registration_number VARCHAR(30),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(30),
    country VARCHAR(30),
    province VARCHAR(30),
    city VARCHAR(30),
    zip_code VARCHAR(30),
    street1 VARCHAR(100),
    street2 VARCHAR(100),
    note VARCHAR(255)
);

-- System Configuration
CREATE TABLE IF NOT EXISTS hs_hr_config (
    name VARCHAR(100) PRIMARY KEY,
    value TEXT
);

-- User Roles
CREATE TABLE IF NOT EXISTS ohrm_user_role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    is_assignable BOOLEAN DEFAULT TRUE,
    is_predefined BOOLEAN DEFAULT TRUE
);

-- Users
CREATE TABLE IF NOT EXISTS ohrm_user (
    id SERIAL PRIMARY KEY,
    user_role_id INTEGER NOT NULL,
    emp_number INTEGER,
    user_name VARCHAR(40) UNIQUE,
    user_password VARCHAR(255),
    deleted BOOLEAN DEFAULT FALSE,
    status BOOLEAN DEFAULT TRUE,
    date_entered TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    FOREIGN KEY (user_role_id) REFERENCES ohrm_user_role(id)
);

-- Employment Status
CREATE TABLE IF NOT EXISTS ohrm_employment_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

-- Job Titles
CREATE TABLE IF NOT EXISTS ohrm_job_title (
    id SERIAL PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    job_description TEXT,
    note TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Job Categories
CREATE TABLE IF NOT EXISTS ohrm_job_category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

-- Subunits (Departments)
CREATE TABLE IF NOT EXISTS ohrm_subunit (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit_id VARCHAR(100),
    description TEXT,
    lft INTEGER,
    rgt INTEGER,
    level INTEGER
);

-- Locations
CREATE TABLE IF NOT EXISTS ohrm_location (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country_code VARCHAR(3) NOT NULL,
    province VARCHAR(60),
    city VARCHAR(60),
    address VARCHAR(255),
    zip_code VARCHAR(35),
    phone VARCHAR(35),
    fax VARCHAR(35),
    notes TEXT
);

-- Employees
CREATE TABLE IF NOT EXISTS hs_hr_employee (
    emp_number SERIAL PRIMARY KEY,
    employee_id VARCHAR(50) UNIQUE,
    emp_lastname VARCHAR(100) NOT NULL,
    emp_firstname VARCHAR(100) NOT NULL,
    emp_middle_name VARCHAR(100),
    emp_nick_name VARCHAR(100),
    emp_smoker SMALLINT DEFAULT 0,
    ethnic_race_code VARCHAR(13),
    emp_birthday DATE,
    nation_code INTEGER,
    emp_gender SMALLINT,
    emp_marital_status VARCHAR(20),
    emp_ssn_num VARCHAR(100),
    emp_sin_num VARCHAR(100),
    emp_other_id VARCHAR(100),
    emp_dri_lice_num VARCHAR(100),
    emp_dri_lice_exp_date DATE,
    emp_military_service VARCHAR(100),
    emp_status INTEGER,
    job_title_code INTEGER,
    eeo_cat_code INTEGER,
    work_station INTEGER,
    emp_street1 VARCHAR(100),
    emp_street2 VARCHAR(100),
    city_code VARCHAR(100),
    coun_code VARCHAR(100),
    provin_code VARCHAR(100),
    emp_zipcode VARCHAR(20),
    emp_hm_telephone VARCHAR(50),
    emp_mobile VARCHAR(50),
    emp_work_telephone VARCHAR(50),
    emp_work_email VARCHAR(50),
    sal_grd_code VARCHAR(13),
    joined_date DATE,
    emp_oth_email VARCHAR(50),
    termination_id INTEGER,
    custom1 VARCHAR(250),
    custom2 VARCHAR(250),
    custom3 VARCHAR(250),
    custom4 VARCHAR(250),
    custom5 VARCHAR(250),
    custom6 VARCHAR(250),
    custom7 VARCHAR(250),
    custom8 VARCHAR(250),
    custom9 VARCHAR(250),
    custom10 VARCHAR(250),
    FOREIGN KEY (job_title_code) REFERENCES ohrm_job_title(id),
    FOREIGN KEY (work_station) REFERENCES ohrm_subunit(id),
    FOREIGN KEY (nation_code) REFERENCES ohrm_location(id)
);

-- Leave Types
CREATE TABLE IF NOT EXISTS ohrm_leave_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    deleted BOOLEAN DEFAULT FALSE,
    exclude_in_reports_if_no_entitlement BOOLEAN DEFAULT FALSE,
    operational_country_id INTEGER
);

-- Nationalities
CREATE TABLE IF NOT EXISTS ohrm_nationality (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Countries
CREATE TABLE IF NOT EXISTS ohrm_country (
    cou_code VARCHAR(2) PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    cou_name VARCHAR(80) NOT NULL,
    iso3 VARCHAR(3),
    numcode SMALLINT
);

-- Create indexes for performance
CREATE INDEX idx_employee_lastname ON hs_hr_employee(emp_lastname);
CREATE INDEX idx_employee_firstname ON hs_hr_employee(emp_firstname);
CREATE INDEX idx_employee_empid ON hs_hr_employee(employee_id);
CREATE INDEX idx_user_username ON ohrm_user(user_name);

COMMIT;

\echo 'Schema creation complete'