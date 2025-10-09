#!/usr/bin/env python3
"""
Script para crear empleados de Portos International via OrangeHRM API
"""

import requests
import json
import time

# Configuración OrangeHRM
ORANGEHRM_BASE_URL = "https://orangehrm-portos-clean-production.up.railway.app"
CLIENT_ID = "ae0109a668f042e0e9bcce276c7dae2d"
CLIENT_SECRET = "bZyUf/gyxiKZ+04LeFhuQHCLoy05RBpdTkJEYEaH6CQ="

def get_access_token():
    """Obtener access token usando OAuth 2.0"""
    data = {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'grant_type': 'client_credentials'
    }
    
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    # Endpoint OAuth correcto según documentación oficial
    url = f"{ORANGEHRM_BASE_URL}/index.php/oauth/issueToken"
    
    print(f"🔑 Obteniendo access token desde: {url}")
    
    try:
        response = requests.post(url, data=data, headers=headers, allow_redirects=False)
        
        if response.status_code == 200:
            token_data = response.json()
            print("✅ Access token obtenido exitosamente")
            return token_data['access_token']
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def create_employee(access_token, employee_data):
    """Crear un empleado via API"""
    # Endpoint correcto según documentación: /api/v1/ para versiones anteriores a 5.5
    # Para 5.7 debería ser /api/v2/ pero probamos ambos
    url = f"{ORANGEHRM_BASE_URL}/index.php/api/v2/pim/employees"
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    
    print(f"👤 Creando empleado: {employee_data['firstName']} {employee_data['lastName']}")
    response = requests.post(url, json=employee_data, headers=headers)
    
    if response.status_code == 200:
        print(f"✅ Empleado creado: {employee_data['firstName']} {employee_data['lastName']}")
        return True
    else:
        print(f"❌ Error creando empleado: {response.status_code}")
        print(f"Response: {response.text}")
        return False

def main():
    print("🚀 PORTOS INTERNATIONAL - CREACIÓN DE EMPLEADOS VIA API")
    print("=" * 60)
    
    # Obtener access token
    access_token = get_access_token()
    if not access_token:
        print("❌ No se pudo obtener access token. Abortando.")
        return
    
    # Datos de empleados de Portos International
    employees = [
        {
            "firstName": "Ricardo",
            "middleName": "Antonio", 
            "lastName": "González",
            "employeeId": "1001"
        },
        {
            "firstName": "María",
            "middleName": "Elena",
            "lastName": "Hernández", 
            "employeeId": "1002"
        },
        {
            "firstName": "Carlos",
            "middleName": "Javier",
            "lastName": "López",
            "employeeId": "1003"
        },
        {
            "firstName": "Ana",
            "middleName": "Sofía", 
            "lastName": "Martínez",
            "employeeId": "1004"
        },
        {
            "firstName": "Luis",
            "middleName": "Fernando",
            "lastName": "Rodríguez",
            "employeeId": "1005"
        },
        {
            "firstName": "Patricia",
            "middleName": "Isabel",
            "lastName": "García",
            "employeeId": "1006"
        },
        {
            "firstName": "Miguel",
            "middleName": "Ángel",
            "lastName": "Sánchez",
            "employeeId": "1007"
        },
        {
            "firstName": "Laura",
            "middleName": "Beatriz",
            "lastName": "Ramírez",
            "employeeId": "1008"
        },
        {
            "firstName": "Alejandro",
            "middleName": "Daniel",
            "lastName": "Torres",
            "employeeId": "1009"
        },
        {
            "firstName": "Carmen",
            "middleName": "Rosa",
            "lastName": "Flores",
            "employeeId": "1010"
        }
    ]
    
    # Crear empleados
    success_count = 0
    for employee in employees:
        if create_employee(access_token, employee):
            success_count += 1
        time.sleep(1)  # Pausa entre requests
    
    print("=" * 60)
    print(f"🎉 RESULTADO: {success_count}/{len(employees)} empleados creados exitosamente")
    
    if success_count == len(employees):
        print("✅ ¡Todos los empleados de Portos International fueron creados!")
        print("🔗 Verifica en: PIM → Employee List")
    else:
        print("⚠️ Algunos empleados no se pudieron crear. Revisar errores arriba.")

if __name__ == "__main__":
    main()