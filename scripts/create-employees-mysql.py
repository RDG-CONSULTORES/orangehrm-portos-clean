#!/usr/bin/env python3
"""
Script para crear empleados de Portos International directamente en MySQL
Bypassa problemas de API usando conexión directa a base de datos
"""

import mysql.connector
from mysql.connector import Error
import sys

# Configuración MySQL Railway
DB_CONFIG = {
    'host': 'shinkansen.proxy.rlwy.net',
    'port': 49981,
    'database': 'railway',
    'user': 'root',
    'password': 'ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE'
}

def connect_mysql():
    """Conectar a MySQL Railway"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            print("✅ Conexión MySQL exitosa")
            return connection
    except Error as e:
        print(f"❌ Error conectando a MySQL: {e}")
        return None

def get_next_employee_number(cursor):
    """Obtener el siguiente número de empleado disponible"""
    cursor.execute("SELECT MAX(emp_number) FROM ohrm_employee")
    result = cursor.fetchone()
    return (result[0] + 1) if result[0] else 1

def create_employee_mysql(cursor, employee_data):
    """Crear empleado directamente en MySQL"""
    
    # Verificar si employee_id ya existe (usar tabla correcta)
    cursor.execute("SELECT emp_number FROM hs_hr_employee WHERE employee_id = %s", (employee_data['employee_id'],))
    if cursor.fetchone():
        print(f"⚠️ Employee ID {employee_data['employee_id']} ya existe, saltando...")
        return False
    
    # Insertar en hs_hr_employee (tabla correcta)
    insert_query = """
    INSERT INTO hs_hr_employee (
        employee_id, emp_lastname, emp_firstname, emp_middle_name, 
        emp_gender, emp_marital_status, emp_birthday, joined_date,
        emp_work_email, emp_status
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    values = (
        employee_data['employee_id'],
        employee_data['last_name'],
        employee_data['first_name'],
        employee_data.get('middle_name', ''),
        employee_data.get('gender', 1),  # 1=Male, 2=Female
        employee_data.get('marital_status', 'Single'),
        employee_data.get('birth_date', '1990-01-01'),
        employee_data.get('joined_date', '2024-01-01'),
        employee_data.get('work_email', ''),
        1  # emp_status = 1 (Active)
    )
    
    try:
        cursor.execute(insert_query, values)
        print(f"✅ Empleado creado: {employee_data['first_name']} {employee_data['last_name']}")
        return True
    except Error as e:
        print(f"❌ Error creando empleado {employee_data['first_name']}: {e}")
        return False

def main():
    print("🚀 PORTOS INTERNATIONAL - CREACIÓN DIRECTA EN MySQL")
    print("=" * 60)
    
    # Conectar a MySQL
    connection = connect_mysql()
    if not connection:
        print("❌ No se pudo conectar a MySQL. Abortando.")
        return
    
    cursor = connection.cursor()
    
    # Datos de empleados de Portos International
    employees = [
        {
            'employee_id': '1001',
            'first_name': 'Ricardo',
            'middle_name': 'Antonio',
            'last_name': 'González',
            'gender': 1,  # Male
            'marital_status': 'Married',
            'birth_date': '1975-03-15',
            'joined_date': '2015-01-15',
            'work_email': 'ricardo.gonzalez@portosinternational.com'
        },
        {
            'employee_id': '1002',
            'first_name': 'María',
            'middle_name': 'Elena',
            'last_name': 'Hernández',
            'gender': 2,  # Female
            'marital_status': 'Single',
            'birth_date': '1982-07-22',
            'joined_date': '2018-03-10',
            'work_email': 'maria.hernandez@portosinternational.com'
        },
        {
            'employee_id': '1003',
            'first_name': 'Carlos',
            'middle_name': 'Javier',
            'last_name': 'López',
            'gender': 1,  # Male
            'marital_status': 'Married',
            'birth_date': '1985-11-08',
            'joined_date': '2019-05-20',
            'work_email': 'carlos.lopez@portosinternational.com'
        },
        {
            'employee_id': '1004',
            'first_name': 'Ana',
            'middle_name': 'Sofía',
            'last_name': 'Martínez',
            'gender': 2,  # Female
            'marital_status': 'Married',
            'birth_date': '1988-02-14',
            'joined_date': '2020-02-01',
            'work_email': 'ana.martinez@portosinternational.com'
        },
        {
            'employee_id': '1005',
            'first_name': 'Luis',
            'middle_name': 'Fernando',
            'last_name': 'Rodríguez',
            'gender': 1,  # Male
            'marital_status': 'Single',
            'birth_date': '1983-09-30',
            'joined_date': '2017-08-15',
            'work_email': 'luis.rodriguez@portosinternational.com'
        },
        {
            'employee_id': '1006',
            'first_name': 'Patricia',
            'middle_name': 'Isabel',
            'last_name': 'García',
            'gender': 2,  # Female
            'marital_status': 'Single',
            'birth_date': '1990-06-18',
            'joined_date': '2021-01-10',
            'work_email': 'patricia.garcia@portosinternational.com'
        },
        {
            'employee_id': '1007',
            'first_name': 'Miguel',
            'middle_name': 'Ángel',
            'last_name': 'Sánchez',
            'gender': 1,  # Male
            'marital_status': 'Married',
            'birth_date': '1986-12-05',
            'joined_date': '2019-11-25',
            'work_email': 'miguel.sanchez@portosinternational.com'
        },
        {
            'employee_id': '1008',
            'first_name': 'Laura',
            'middle_name': 'Beatriz',
            'last_name': 'Ramírez',
            'gender': 2,  # Female
            'marital_status': 'Married',
            'birth_date': '1984-04-27',
            'joined_date': '2016-06-01',
            'work_email': 'laura.ramirez@portosinternational.com'
        },
        {
            'employee_id': '1009',
            'first_name': 'Alejandro',
            'middle_name': 'Daniel',
            'last_name': 'Torres',
            'gender': 1,  # Male
            'marital_status': 'Single',
            'birth_date': '1981-10-12',
            'joined_date': '2015-09-10',
            'work_email': 'alejandro.torres@portosinternational.com'
        },
        {
            'employee_id': '1010',
            'first_name': 'Carmen',
            'middle_name': 'Rosa',
            'last_name': 'Flores',
            'gender': 2,  # Female
            'marital_status': 'Married',
            'birth_date': '1987-08-03',
            'joined_date': '2018-12-01',
            'work_email': 'carmen.flores@portosinternational.com'
        }
    ]
    
    # Crear empleados
    success_count = 0
    try:
        for employee in employees:
            if create_employee_mysql(cursor, employee):
                success_count += 1
        
        # Commit cambios
        connection.commit()
        print("=" * 60)
        print(f"🎉 RESULTADO: {success_count}/{len(employees)} empleados creados exitosamente")
        
        if success_count == len(employees):
            print("✅ ¡Todos los empleados de Portos International fueron creados!")
            print("🔗 Verifica en: PIM → Employee List")
        else:
            print("⚠️ Algunos empleados no se pudieron crear (probablemente ya existían)")
            
    except Error as e:
        print(f"❌ Error durante la transacción: {e}")
        connection.rollback()
    
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("🔌 Conexión MySQL cerrada")

if __name__ == "__main__":
    main()