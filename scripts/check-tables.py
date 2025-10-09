#!/usr/bin/env python3
"""
Script para verificar qué tablas existen en la base de datos
"""

import mysql.connector
from mysql.connector import Error

# Configuración MySQL Railway
DB_CONFIG = {
    'host': 'shinkansen.proxy.rlwy.net',
    'port': 49981,
    'database': 'railway',
    'user': 'root',
    'password': 'ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE'
}

def check_tables():
    """Verificar qué tablas existen en la base de datos"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        print("🔍 Verificando tablas en la base de datos...")
        
        # Listar todas las tablas
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        print(f"📊 Total de tablas encontradas: {len(tables)}")
        print("=" * 50)
        
        ohrm_tables = []
        other_tables = []
        
        for table in tables:
            table_name = table[0]
            if table_name.startswith('ohrm_'):
                ohrm_tables.append(table_name)
            else:
                other_tables.append(table_name)
        
        print(f"🏢 Tablas OrangeHRM (ohrm_*): {len(ohrm_tables)}")
        for table in sorted(ohrm_tables)[:10]:  # Mostrar solo las primeras 10
            print(f"  - {table}")
        if len(ohrm_tables) > 10:
            print(f"  ... y {len(ohrm_tables) - 10} más")
        
        print(f"\n📋 Otras tablas: {len(other_tables)}")
        for table in other_tables:
            print(f"  - {table}")
        
        # Verificar específicamente tabla de empleados
        if 'ohrm_employee' in [t[0] for t in tables]:
            print("\n✅ Tabla ohrm_employee EXISTE")
            cursor.execute("SELECT COUNT(*) FROM ohrm_employee")
            count = cursor.fetchone()[0]
            print(f"👥 Empleados existentes: {count}")
        else:
            print("\n❌ Tabla ohrm_employee NO EXISTE")
            # Buscar tablas similares
            similar = [t[0] for t in tables if 'employee' in t[0].lower() or 'emp' in t[0].lower()]
            if similar:
                print("🔍 Tablas similares encontradas:")
                for table in similar:
                    print(f"  - {table}")
        
    except Error as e:
        print(f"❌ Error: {e}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

if __name__ == "__main__":
    check_tables()