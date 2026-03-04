"""
OCR Service - Alta y Baja de Colaboradores EPL CAS
FastAPI app que procesa INE con Tesseract y gestiona empleados en OrangeHRM.
"""
import os
from pathlib import Path

from fastapi import FastAPI, UploadFile, File, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

import db
from ocr_engine import ocr_image

BASE_DIR = Path(__file__).parent

app = FastAPI(title="EPL CAS OCR Service", docs_url="/ocr/docs", openapi_url="/ocr/openapi.json")

# Static files and templates
app.mount("/ocr/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))


# ---------- Pages ----------

@app.get("/ocr/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request, "active": "index"})


@app.get("/ocr/alta", response_class=HTMLResponse)
async def alta_page(request: Request):
    try:
        subunits = db.get_subunits()
        locations = db.get_locations()
        job_titles = db.get_job_titles()
    except Exception:
        subunits, locations, job_titles = [], [], []

    return templates.TemplateResponse("alta.html", {
        "request": request,
        "active": "alta",
        "subunits": subunits,
        "locations": locations,
        "job_titles": job_titles,
    })


@app.get("/ocr/baja", response_class=HTMLResponse)
async def baja_page(request: Request):
    try:
        reasons = db.get_termination_reasons()
    except Exception:
        reasons = []

    return templates.TemplateResponse("baja.html", {
        "request": request,
        "active": "baja",
        "reasons": reasons,
    })


# ---------- OCR API ----------

@app.post("/ocr/alta/scan")
async def scan_ine(file: UploadFile = File(...)):
    """Procesa imagen de INE y retorna datos extraidos."""
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(400, "Solo se aceptan imagenes (JPG, PNG)")

    contents = await file.read()
    if len(contents) > 5 * 1024 * 1024:
        raise HTTPException(400, "La imagen es muy grande (max 5MB)")

    result = ocr_image(contents)
    return JSONResponse(result)


# ---------- Employee API ----------

@app.post("/ocr/alta/crear")
async def crear_empleado(request: Request):
    """Crea un empleado nuevo en OrangeHRM."""
    data = await request.json()

    # Validar campos requeridos
    if not data.get('nombre') or not data.get('apellido_paterno'):
        raise HTTPException(400, "Nombre y apellido paterno son requeridos")
    if not data.get('curp'):
        raise HTTPException(400, "CURP es requerido")

    try:
        # Convertir campos numéricos
        for field in ('job_title_code', 'work_station', 'location_id', 'emp_status'):
            if data.get(field):
                data[field] = int(data[field]) if data[field] else None

        emp_number = db.create_employee(data)
        employee_id = f"EPL-{emp_number:04d}"

        return JSONResponse({
            "success": True,
            "emp_number": emp_number,
            "employee_id": employee_id,
            "message": f"Colaborador {data['nombre']} {data['apellido_paterno']} dado de alta exitosamente",
        })

    except Exception as e:
        raise HTTPException(500, f"Error creando empleado: {str(e)}")


@app.get("/ocr/baja/buscar")
async def buscar_empleado(q: str = ""):
    """Busca empleados activos por nombre o CURP."""
    if not q or len(q) < 2:
        raise HTTPException(400, "Escribe al menos 2 caracteres")

    try:
        employees = db.search_employees(q)
        # Serializar fechas
        for emp in employees:
            for key, val in emp.items():
                if hasattr(val, 'isoformat'):
                    emp[key] = val.isoformat()
        return JSONResponse({"employees": employees, "count": len(employees)})
    except Exception as e:
        raise HTTPException(500, f"Error buscando empleados: {str(e)}")


@app.post("/ocr/baja/ejecutar")
async def ejecutar_baja(request: Request):
    """Registra la baja de un empleado."""
    data = await request.json()

    emp_number = data.get('emp_number')
    reason_id = data.get('reason_id')
    fecha_baja = data.get('fecha_baja')

    if not emp_number or not reason_id or not fecha_baja:
        raise HTTPException(400, "emp_number, reason_id y fecha_baja son requeridos")

    try:
        emp_number = int(emp_number)
        reason_id = int(reason_id)
        note = data.get('note', '')

        # Verificar que el empleado existe y está activo
        emp = db.get_employee(emp_number)
        if not emp:
            raise HTTPException(404, "Empleado no encontrado")
        if emp.get('termination_id'):
            raise HTTPException(400, "Este empleado ya tiene una baja registrada")

        db.terminate_employee(emp_number, reason_id, fecha_baja, note)

        return JSONResponse({
            "success": True,
            "message": f"Baja registrada para empleado #{emp_number}",
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, f"Error registrando baja: {str(e)}")


# ---------- Health ----------

@app.get("/ocr/health")
async def health():
    """Health check."""
    health_status = {"status": "ok", "service": "ocr"}

    try:
        with db.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        health_status["database"] = "connected"
    except Exception as e:
        health_status["database"] = f"error: {str(e)}"
        health_status["status"] = "degraded"

    return JSONResponse(health_status)
