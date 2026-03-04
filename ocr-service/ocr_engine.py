"""
Motor OCR para INE mexicana usando Tesseract + OpenCV.
Extrae: CURP, nombre, fecha nacimiento, sexo, clave de elector.
"""
import io
import re
from typing import Optional

import cv2
import numpy as np
from PIL import Image
import pytesseract

from validators import (
    extract_curp_from_text,
    extract_clave_elector,
    extract_dates,
    sex_from_curp,
    birthdate_from_curp,
    validate_curp,
)


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """Preprocesa imagen para mejorar OCR: grayscale, denoise, contrast."""
    # Leer imagen
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("No se pudo leer la imagen")

    # Resize si es muy grande (max 3000px de ancho)
    h, w = img.shape[:2]
    if w > 3000:
        scale = 3000 / w
        img = cv2.resize(img, (3000, int(h * scale)), interpolation=cv2.INTER_LANCZOS4)
    elif w < 1000:
        # Escalar hacia arriba si es muy pequeña
        scale = 1500 / w
        img = cv2.resize(img, (1500, int(h * scale)), interpolation=cv2.INTER_LANCZOS4)

    # Convertir a grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Denoise
    gray = cv2.fastNlMeansDenoising(gray, h=10)

    # Contrast enhancement (CLAHE)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    gray = clahe.apply(gray)

    # Binarización adaptativa
    gray = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
    )

    return gray


def ocr_image(image_bytes: bytes) -> dict:
    """
    Procesa imagen de INE y extrae datos estructurados.
    Retorna dict con campos extraídos y texto crudo.
    """
    result = {
        'curp': None,
        'nombre': None,
        'apellido_paterno': None,
        'apellido_materno': None,
        'fecha_nacimiento': None,
        'sexo': None,
        'clave_elector': None,
        'confidence': 0.0,
        'raw_text': '',
        'curp_valid': False,
        'errors': [],
    }

    try:
        # Preprocesar
        processed = preprocess_image(image_bytes)

        # OCR con Tesseract
        # --psm 6: Assume a single uniform block of text
        # --psm 3: Fully automatic page segmentation (default, mejor para INE)
        custom_config = r'--oem 3 --psm 3 -l spa'
        text = pytesseract.image_to_string(
            Image.fromarray(processed),
            config=custom_config,
        )

        result['raw_text'] = text

        # También intentar con la imagen original para comparar
        original_img = Image.open(io.BytesIO(image_bytes))
        text_original = pytesseract.image_to_string(original_img, config=r'--oem 3 --psm 3 -l spa')

        # Combinar ambos textos para búsqueda
        combined_text = text + '\n' + text_original

        # Extraer CURP
        curp = extract_curp_from_text(combined_text)
        if curp:
            result['curp'] = curp
            result['curp_valid'] = validate_curp(curp)

            # Extraer sexo y fecha de nacimiento del CURP
            result['sexo'] = sex_from_curp(curp)
            result['fecha_nacimiento'] = birthdate_from_curp(curp)
        else:
            result['errors'].append('No se encontró CURP en la imagen')

        # Extraer clave de elector
        clave = extract_clave_elector(combined_text)
        if clave:
            result['clave_elector'] = clave

        # Extraer nombre de la INE
        name_data = extract_name_from_ine(combined_text)
        if name_data:
            result['apellido_paterno'] = name_data.get('apellido_paterno')
            result['apellido_materno'] = name_data.get('apellido_materno')
            result['nombre'] = name_data.get('nombre')

        # Si no encontramos fecha de nacimiento del CURP, buscar en texto
        if not result['fecha_nacimiento']:
            dates = extract_dates(combined_text)
            if dates:
                # La primera fecha suele ser la de nacimiento
                result['fecha_nacimiento'] = dates[0]

        # Calcular confidence
        fields_found = sum(1 for f in ['curp', 'nombre', 'apellido_paterno', 'fecha_nacimiento', 'sexo']
                          if result.get(f))
        result['confidence'] = round(fields_found / 5, 2)

    except Exception as e:
        result['errors'].append(f'Error procesando imagen: {str(e)}')

    return result


def extract_name_from_ine(text: str) -> Optional[dict]:
    """
    Extrae nombre de una INE.
    En la INE, el formato es:
    APELLIDO PATERNO
    APELLIDO MATERNO
    NOMBRE(S)

    Busca patrones comunes de la INE.
    """
    lines = [l.strip() for l in text.split('\n') if l.strip()]

    # Buscar indicadores de nombre en la INE
    name_data = {}

    # Método 1: Buscar etiquetas "NOMBRE", "APELLIDO PATERNO", etc.
    for i, line in enumerate(lines):
        line_upper = line.upper()

        if 'APELLIDO PATERNO' in line_upper or 'PATERNO' in line_upper:
            # El valor puede estar en la misma línea o en la siguiente
            value = re.sub(r'(?i)apellido\s*paterno\s*:?\s*', '', line).strip()
            if not value and i + 1 < len(lines):
                value = lines[i + 1].strip()
            if value and len(value) > 1:
                name_data['apellido_paterno'] = clean_name(value)

        elif 'APELLIDO MATERNO' in line_upper or 'MATERNO' in line_upper:
            value = re.sub(r'(?i)apellido\s*materno\s*:?\s*', '', line).strip()
            if not value and i + 1 < len(lines):
                value = lines[i + 1].strip()
            if value and len(value) > 1:
                name_data['apellido_materno'] = clean_name(value)

        elif 'NOMBRE' in line_upper and 'APELLIDO' not in line_upper:
            value = re.sub(r'(?i)nombre\s*\(?s?\)?\s*:?\s*', '', line).strip()
            if not value and i + 1 < len(lines):
                value = lines[i + 1].strip()
            if value and len(value) > 1:
                name_data['nombre'] = clean_name(value)

    # Método 2: Si no encontramos etiquetas, buscar por posición
    # En la INE, los nombres suelen estar en las primeras líneas después del escudo
    if not name_data:
        # Filtrar líneas que parezcan nombres (solo letras y espacios, más de 2 chars)
        name_candidates = []
        for line in lines:
            cleaned = re.sub(r'[^A-ZÁÉÍÓÚÑa-záéíóúñ\s]', '', line).strip()
            if cleaned and len(cleaned) > 2 and cleaned.upper() == cleaned:
                # Es una línea en mayúsculas que parece nombre
                name_candidates.append(cleaned)

        if len(name_candidates) >= 3:
            name_data['apellido_paterno'] = name_candidates[0]
            name_data['apellido_materno'] = name_candidates[1]
            name_data['nombre'] = name_candidates[2]
        elif len(name_candidates) == 2:
            name_data['apellido_paterno'] = name_candidates[0]
            name_data['nombre'] = name_candidates[1]

    return name_data if name_data else None


def clean_name(name: str) -> str:
    """Limpia un nombre extraído por OCR."""
    # Quitar caracteres no alfabéticos excepto espacios
    name = re.sub(r'[^A-ZÁÉÍÓÚÑa-záéíóúñ\s]', '', name)
    # Quitar espacios extras
    name = ' '.join(name.split())
    # Capitalizar
    return name.upper().strip()
