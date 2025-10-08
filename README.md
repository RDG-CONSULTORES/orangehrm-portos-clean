# 🚀 OrangeHRM Portos International - Instalación Limpia

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

## 📋 Descripción

Instalación limpia de OrangeHRM 5.7 usando la **imagen oficial Docker** para Portos International, empresa especializada en freight forwarding y logística internacional.

### ✨ Características

- ✅ **Imagen oficial** `orangehrm/orangehrm:5.7`
- ✅ **PostgreSQL** pre-configurado
- ✅ **Instalación automática** sin wizard
- ✅ **Datos demo** 25 empleados mexicanos
- ✅ **Estructura organizacional** freight forwarding
- ✅ **Configuración México** (es_MX, MXN, GMT-6)

## 🏢 Empresa Demo: Portos International

**Sector**: Freight Forwarding & International Logistics  
**Ubicación**: Monterrey, Nuevo León, México  
**Empleados**: 25 colaboradores  
**Departamentos**: 9 especializados en logística  

### Departamentos Incluidos:
- 🚢 Operaciones Marítimas
- ✈️ Operaciones Aéreas  
- 🚛 Operaciones Terrestres
- 📋 Aduanas y Comercio Exterior
- 👥 Atención al Cliente
- 💰 Finanzas y Cobranza
- 🏢 Recursos Humanos
- 💻 Tecnología e Innovación

## 🚀 Deploy en Render (Tier Gratuito)

### Opción 1: Deploy Automático
1. Hacer clic en el botón "Deploy to Render" arriba
2. Conectar con tu cuenta de GitHub
3. El sistema se desplegará automáticamente

### Opción 2: Deploy Manual
1. **Fork este repositorio** en tu GitHub
2. **Crear Web Service** en Render Dashboard:
   - Runtime: `Docker`
   - Branch: `main`
   - Build Command: `Auto-detected`
3. **Configurar variables de entorno** (automático desde render.yaml)
4. **Deploy** - La instalación se ejecuta automáticamente

## 🔐 Credenciales de Acceso

```
URL: https://orangehrm-portos-clean.onrender.com
Usuario: admin
Contraseña: PortosAdmin123!
```

## 📊 Estructura del Proyecto

```
orangehrm-portos-clean/
├── Dockerfile              # Imagen oficial + customizaciones mínimas
├── render.yaml             # Configuración Render automática
├── README.md               # Documentación completa
├── config/                 # Configuraciones PostgreSQL
├── scripts/
│   └── start-portos.sh     # Script de inicio inteligente
└── data/
    └── portos-data.sql     # Datos demo Portos International
```

## 🛠️ Desarrollo Local

### Requisitos
- Docker
- Docker Compose

### Iniciar localmente
```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/orangehrm-portos-clean.git
cd orangehrm-portos-clean

# Construir y ejecutar
docker build -t orangehrm-portos .
docker run -p 8080:10000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  orangehrm-portos

# Acceder
open http://localhost:8080
```

## 🔧 Configuración Avanzada

### Variables de Entorno

| Variable | Descripción | Valor por Defecto |
|----------|-------------|------------------|
| `DATABASE_URL` | Conexión PostgreSQL | Automático desde render.yaml |
| `PORT` | Puerto del servidor | 10000 |
| `TZ` | Zona horaria | America/Mexico_City |
| `ORANGEHRM_LOCALE` | Idioma del sistema | es_MX |

### Base de Datos

El sistema está configurado para usar **tu base de datos existente** `orangehrm-portos-db` en Render. La conexión se establece automáticamente.

## 🎯 Resultado Esperado

Al completar el deploy tendrás:

✅ **OrangeHRM 100% original** sin modificaciones  
✅ **Sistema completamente funcional** con datos reales  
✅ **Empresa Portos International** configurada  
✅ **25 empleados mexicanos** con datos demo  
✅ **Interfaz en español** optimizada para México  
✅ **Login funcional**: admin / PortosAdmin123!

---

**Desarrollado para Portos International**  
Freight Forwarding & International Logistics  
🇲🇽 Monterrey, Nuevo León, México