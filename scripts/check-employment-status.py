#!/usr/bin/env python3
import mysql.connector

DB_CONFIG = {
    'host': 'shinkansen.proxy.rlwy.net',
    'port': 49981,
    'database': 'railway',
    'user': 'root',
    'password': 'ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE'
}

try:
    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()
    
    print("🔍 Employment Status disponibles:")
    cursor.execute("SELECT id, name FROM ohrm_employment_status")
    statuses = cursor.fetchall()
    for status in statuses:
        print(f"  ID: {status[0]} - {status[1]}")
    
finally:
    if connection.is_connected():
        cursor.close()
        connection.close()