<?php
/**
 * OrangeHRM Database Configuration
 * Pre-configured for PostgreSQL
 */

class Conf {
    
    private $dbHost = 'dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com';
    private $dbPort = '5432';
    private $dbName = 'orangehrm_portos';
    private $dbUser = 'orangehrm_user';
    private $dbPass = 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX';
    
    // IMPORTANT: Use PostgreSQL driver
    private $dbDriver = 'pgsql';
    
    public function __construct() {
        // Override with environment variables if available
        if (getenv('DATABASE_HOST')) {
            $this->dbHost = getenv('DATABASE_HOST');
        }
        if (getenv('DATABASE_PORT')) {
            $this->dbPort = getenv('DATABASE_PORT');
        }
        if (getenv('DATABASE_NAME')) {
            $this->dbName = getenv('DATABASE_NAME');
        }
        if (getenv('DATABASE_USER')) {
            $this->dbUser = getenv('DATABASE_USER');
        }
        if (getenv('DATABASE_PASSWORD')) {
            $this->dbPass = getenv('DATABASE_PASSWORD');
        }
    }
    
    public function getDbHost() {
        return $this->dbHost;
    }
    
    public function getDbPort() {
        return $this->dbPort;
    }
    
    public function getDbName() {
        return $this->dbName;
    }
    
    public function getDbUser() {
        return $this->dbUser;
    }
    
    public function getDbPass() {
        return $this->dbPass;
    }
    
    public function getDbDriver() {
        return $this->dbDriver;
    }
    
    /**
     * Get PDO DSN for PostgreSQL
     */
    public function getDSN() {
        return sprintf(
            "%s:host=%s;port=%s;dbname=%s",
            $this->dbDriver,
            $this->dbHost,
            $this->dbPort,
            $this->dbName
        );
    }
}

// Mark installation as complete
if (!defined('INSTALLATION_COMPLETED')) {
    define('INSTALLATION_COMPLETED', true);
}