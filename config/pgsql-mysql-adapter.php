<?php
// Adaptador PostgreSQL -> MySQL para OrangeHRM
// Simula funciones MySQL usando PostgreSQL

// Mapear funciones MySQL a PostgreSQL
if (!function_exists('mysql_connect')) {
    function mysql_connect($server, $username, $password) {
        $host_port = explode(':', $server);
        $host = $host_port[0];
        $port = isset($host_port[1]) ? $host_port[1] : 5432;
        
        return pg_connect("host=$host port=$port user=$username password=$password");
    }
}

if (!function_exists('mysql_select_db')) {
    function mysql_select_db($database, $connection = null) {
        global $pg_db_name;
        $pg_db_name = $database;
        return true; // PostgreSQL selecciona la DB en la conexión
    }
}

if (!function_exists('mysql_query')) {
    function mysql_query($query, $connection = null) {
        // Convertir sintaxis MySQL básica a PostgreSQL
        $query = str_replace('`', '"', $query); // Comillas invertidas a comillas dobles
        $query = str_replace('AUTO_INCREMENT', 'SERIAL', $query);
        $query = str_replace('ENGINE=InnoDB', '', $query);
        $query = preg_replace('/CHARSET=\w+/', '', $query);
        
        return pg_query($connection, $query);
    }
}

if (!function_exists('mysql_fetch_array')) {
    function mysql_fetch_array($result, $result_type = PGSQL_BOTH) {
        return pg_fetch_array($result, null, $result_type);
    }
}

if (!function_exists('mysql_fetch_assoc')) {
    function mysql_fetch_assoc($result) {
        return pg_fetch_assoc($result);
    }
}

if (!function_exists('mysql_num_rows')) {
    function mysql_num_rows($result) {
        return pg_num_rows($result);
    }
}

if (!function_exists('mysql_error')) {
    function mysql_error($connection = null) {
        return pg_last_error($connection);
    }
}

if (!function_exists('mysql_errno')) {
    function mysql_errno($connection = null) {
        return pg_connection_status($connection) === PGSQL_CONNECTION_OK ? 0 : 1;
    }
}

if (!function_exists('mysql_close')) {
    function mysql_close($connection = null) {
        return pg_close($connection);
    }
}

// Definir constantes si no existen
if (!defined('MYSQL_ASSOC')) define('MYSQL_ASSOC', PGSQL_ASSOC);
if (!defined('MYSQL_NUM')) define('MYSQL_NUM', PGSQL_NUM);
if (!defined('MYSQL_BOTH')) define('MYSQL_BOTH', PGSQL_BOTH);
?>