"""
Validadores para documentos mexicanos: CURP y RFC.
"""
import re
from typing import Optional


# CURP: 18 caracteres
# Estructura: AAAA YYMMDD H EECCC DD
# 4 letras (nombre) + 6 dígitos (fecha) + 1 letra (sexo) + 5 letras (estado+consonantes) + 1 alfanum (homoclave) + 1 dígito (verificador)
CURP_PATTERN = re.compile(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$')

# RFC personas físicas: 13 caracteres
RFC_PATTERN = re.compile(r'^[A-ZÑ&]{4}\d{6}[A-Z0-9]{3}$')

# Patrón flexible para encontrar CURP en texto OCR (puede tener ruido)
CURP_SEARCH_PATTERN = re.compile(r'[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d')

# Patrón para clave de elector (18 caracteres alfanuméricos)
CLAVE_ELECTOR_PATTERN = re.compile(r'[A-Z]{6}\d{8}[HM]\d{3}')

# Patrón fecha DD/MM/YYYY
DATE_PATTERN = re.compile(r'(\d{2})[/\-.](\d{2})[/\-.](\d{4})')

# Caracteres para validación de dígito verificador CURP
CURP_CHARS = '0123456789ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'


def validate_curp(curp: str) -> bool:
    """Valida formato y dígito verificador de CURP."""
    if not curp or len(curp) != 18:
        return False
    curp = curp.upper().strip()
    if not CURP_PATTERN.match(curp):
        return False
    # Validar dígito verificador
    try:
        total = 0
        for i in range(17):
            char = curp[i]
            if char == 'Ñ':
                value = 10
            else:
                value = CURP_CHARS.index(char)
            total += value * (18 - i)
        check = (10 - (total % 10)) % 10
        return int(curp[17]) == check
    except (ValueError, IndexError):
        return False


def validate_rfc(rfc: str) -> bool:
    """Valida formato básico de RFC (persona física, 13 chars)."""
    if not rfc or len(rfc) not in (12, 13):
        return False
    rfc = rfc.upper().strip()
    if not RFC_PATTERN.match(rfc):
        return False
    # Validar componente de fecha
    date_part = rfc[4:10]
    try:
        yy = int(date_part[0:2])
        mm = int(date_part[2:4])
        dd = int(date_part[4:6])
        return 1 <= mm <= 12 and 1 <= dd <= 31
    except ValueError:
        return False


def extract_curp_from_text(text: str) -> Optional[str]:
    """Busca y extrae CURP de un bloque de texto OCR."""
    text_upper = text.upper()
    match = CURP_SEARCH_PATTERN.search(text_upper)
    if match:
        curp = match.group(0)
        if validate_curp(curp):
            return curp
        return curp  # Retorna aunque no pase validación (OCR puede tener errores)
    return None


def extract_clave_elector(text: str) -> Optional[str]:
    """Busca clave de elector en texto OCR."""
    text_upper = text.upper()
    match = CLAVE_ELECTOR_PATTERN.search(text_upper)
    return match.group(0) if match else None


def extract_dates(text: str) -> list[str]:
    """Extrae todas las fechas DD/MM/YYYY del texto."""
    matches = DATE_PATTERN.findall(text)
    dates = []
    for dd, mm, yyyy in matches:
        try:
            d, m, y = int(dd), int(mm), int(yyyy)
            if 1 <= d <= 31 and 1 <= m <= 12 and 1900 <= y <= 2030:
                dates.append(f"{yyyy}-{mm}-{dd}")
        except ValueError:
            continue
    return dates


def sex_from_curp(curp: str) -> Optional[str]:
    """Extrae sexo del CURP (posición 10): H=Hombre, M=Mujer."""
    if curp and len(curp) >= 11:
        sex_char = curp[10].upper()
        if sex_char in ('H', 'M'):
            return sex_char
    return None


def birthdate_from_curp(curp: str) -> Optional[str]:
    """Extrae fecha de nacimiento del CURP (posiciones 4-9: YYMMDD)."""
    if not curp or len(curp) < 10:
        return None
    try:
        yy = int(curp[4:6])
        mm = int(curp[6:8])
        dd = int(curp[8:10])
        # Determinar siglo: si YY > 30, es 1900s; si no, 2000s
        year = 1900 + yy if yy > 30 else 2000 + yy
        if 1 <= mm <= 12 and 1 <= dd <= 31:
            return f"{year:04d}-{mm:02d}-{dd:02d}"
    except ValueError:
        pass
    return None
