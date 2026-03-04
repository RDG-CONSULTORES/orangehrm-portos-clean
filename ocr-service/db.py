"""
Conexión a MySQL de Railway para OrangeHRM.
Usa las mismas variables de entorno que start-portos.sh.
"""
import os
import pymysql
from contextlib import contextmanager


def get_db_config():
    return {
        'host': os.environ.get('MYSQLHOST', 'localhost'),
        'port': int(os.environ.get('MYSQLPORT', 3306)),
        'database': os.environ.get('MYSQLDATABASE', 'railway'),
        'user': os.environ.get('MYSQLUSER', 'root'),
        'password': os.environ.get('MYSQLPASSWORD', ''),
    }


@contextmanager
def get_connection():
    config = get_db_config()
    conn = pymysql.connect(
        host=config['host'],
        port=config['port'],
        user=config['user'],
        password=config['password'],
        database=config['database'],
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def search_employees(query: str, limit: int = 20) -> list[dict]:
    """Busca empleados activos por nombre o CURP."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            sql = """
                SELECT
                    e.emp_number,
                    e.employee_id,
                    e.emp_firstname,
                    e.emp_middle_name,
                    e.emp_lastname,
                    e.custom1 AS curp,
                    e.custom2 AS rfc,
                    e.joined_date,
                    e.emp_gender,
                    j.job_title,
                    s.name AS grupo_operativo,
                    l.name AS sucursal
                FROM hs_hr_employee e
                LEFT JOIN ohrm_job_title j ON e.job_title_code = j.id
                LEFT JOIN ohrm_subunit s ON e.work_station = s.id
                LEFT JOIN hs_hr_emp_locations el ON e.emp_number = el.emp_number
                LEFT JOIN ohrm_location l ON el.location_id = l.id
                WHERE e.termination_id IS NULL
                  AND (
                    CONCAT(COALESCE(e.emp_firstname,''), ' ', COALESCE(e.emp_lastname,'')) LIKE %s
                    OR e.custom1 LIKE %s
                    OR e.employee_id LIKE %s
                  )
                ORDER BY e.emp_lastname, e.emp_firstname
                LIMIT %s
            """
            like = f'%{query}%'
            cur.execute(sql, (like, like, like, limit))
            return cur.fetchall()


def get_employee(emp_number: int) -> dict | None:
    """Obtiene un empleado por emp_number."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            sql = """
                SELECT
                    e.*,
                    j.job_title,
                    s.name AS grupo_operativo,
                    l.name AS sucursal
                FROM hs_hr_employee e
                LEFT JOIN ohrm_job_title j ON e.job_title_code = j.id
                LEFT JOIN ohrm_subunit s ON e.work_station = s.id
                LEFT JOIN hs_hr_emp_locations el ON e.emp_number = el.emp_number
                LEFT JOIN ohrm_location l ON el.location_id = l.id
                WHERE e.emp_number = %s
            """
            cur.execute(sql, (emp_number,))
            return cur.fetchone()


def create_employee(data: dict) -> int:
    """Crea un empleado nuevo y retorna el emp_number."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            # Obtener siguiente emp_number
            cur.execute("SELECT COALESCE(MAX(emp_number), 0) + 1 AS next_num FROM hs_hr_employee")
            next_num = cur.fetchone()['next_num']

            # Generar employee_id
            employee_id = f"EPL-{next_num:04d}"

            sql = """
                INSERT INTO hs_hr_employee (
                    emp_number, employee_id,
                    emp_firstname, emp_middle_name, emp_lastname,
                    emp_gender, emp_birthday, emp_marital_status,
                    emp_work_email, emp_mobile,
                    joined_date, job_title_code, emp_status, work_station,
                    custom1, custom2, custom3, custom4,
                    custom5, custom6, custom7, custom8,
                    custom9, custom10
                ) VALUES (
                    %s, %s,
                    %s, %s, %s,
                    %s, %s, %s,
                    %s, %s,
                    %s, %s, %s, %s,
                    %s, %s, %s, %s,
                    %s, %s, %s, %s,
                    %s, %s
                )
            """
            cur.execute(sql, (
                next_num, employee_id,
                data.get('nombre', ''), data.get('apellido_materno', ''), data.get('apellido_paterno', ''),
                1 if data.get('sexo') == 'H' else 2,
                data.get('fecha_nacimiento'),
                data.get('estado_civil', 'Single'),
                data.get('email', ''),
                data.get('telefono', ''),
                data.get('fecha_ingreso'),
                data.get('job_title_code'),
                data.get('emp_status', 1),
                data.get('work_station'),
                data.get('curp', ''),
                data.get('rfc', ''),
                data.get('nss', ''),
                data.get('no_ine', ''),
                data.get('tipo_sangre', ''),
                data.get('no_infonavit', ''),
                data.get('clabe', ''),
                data.get('banco', ''),
                data.get('tipo_contrato', ''),
                data.get('turno', ''),
            ))

            # Link a location si se proporcionó
            if data.get('location_id'):
                cur.execute(
                    "INSERT INTO hs_hr_emp_locations (emp_number, location_id) VALUES (%s, %s)",
                    (next_num, data['location_id'])
                )

            return next_num


def terminate_employee(emp_number: int, reason_id: int, date: str, note: str = '') -> bool:
    """Registra la baja de un empleado."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            # Insertar registro de terminación
            cur.execute(
                """INSERT INTO ohrm_emp_termination (emp_number, reason_id, termination_date, note)
                   VALUES (%s, %s, %s, %s)""",
                (emp_number, reason_id, date, note)
            )
            termination_id = cur.lastrowid

            # Actualizar empleado
            cur.execute(
                "UPDATE hs_hr_employee SET termination_id = %s WHERE emp_number = %s",
                (termination_id, emp_number)
            )
            return True


def get_subunits() -> list[dict]:
    """Obtiene los grupos operativos (subunits)."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name FROM ohrm_subunit WHERE level > 0 ORDER BY name"
            )
            return cur.fetchall()


def get_locations() -> list[dict]:
    """Obtiene las sucursales (locations)."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, city, province FROM ohrm_location ORDER BY name"
            )
            return cur.fetchall()


def get_job_titles() -> list[dict]:
    """Obtiene los puestos."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, job_title FROM ohrm_job_title ORDER BY job_title"
            )
            return cur.fetchall()


def get_termination_reasons() -> list[dict]:
    """Obtiene los motivos de baja."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name FROM ohrm_emp_termination_reason ORDER BY name"
            )
            return cur.fetchall()
