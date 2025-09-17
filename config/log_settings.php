<?php
/**
 * OrangeHRM Log Settings
 */

// Set timezone
date_default_timezone_set('America/Mexico_City');

// Error reporting for production
error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT);
ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);

// Log settings
ini_set('log_errors', 1);
ini_set('error_log', '/var/www/html/symfony/log/orangehrm.log');

// Session settings
ini_set('session.cookie_httponly', 1);
ini_set('session.use_only_cookies', 1);
ini_set('session.cookie_secure', 0); // Set to 1 for HTTPS

// Memory and upload limits
ini_set('memory_limit', '256M');
ini_set('upload_max_filesize', '32M');
ini_set('post_max_size', '32M');
ini_set('max_execution_time', 600);

// Ensure log directory exists
$logDir = '/var/www/html/symfony/log';
if (!is_dir($logDir)) {
    mkdir($logDir, 0777, true);
}