-- 01-init-db.sql
-- Initialize PostgreSQL database for OrangeHRM

-- Create database if not exists (run as superuser)
-- CREATE DATABASE orangehrm_portos;

-- Set timezone
SET timezone = 'America/Mexico_City';

-- Create schema
CREATE SCHEMA IF NOT EXISTS public;

-- Grant permissions
GRANT ALL ON SCHEMA public TO orangehrm_user;

-- Set search path
SET search_path TO public;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Set default encoding
SET client_encoding = 'UTF8';

-- Start transaction
BEGIN;

-- Clear existing data if any
DROP TABLE IF EXISTS ohrm_user CASCADE;
DROP TABLE IF EXISTS hs_hr_employee CASCADE;
DROP TABLE IF EXISTS ohrm_organization_gen_info CASCADE;
DROP TABLE IF EXISTS hs_hr_config CASCADE;
DROP TABLE IF EXISTS ohrm_job_title CASCADE;
DROP TABLE IF EXISTS ohrm_employment_status CASCADE;

COMMIT;

-- Database initialized
\echo 'Database initialization complete'