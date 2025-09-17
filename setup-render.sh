#!/bin/bash

echo "🎯 SETUP PARA RENDER DEPLOYMENT"
echo "==============================="

# 1. Crear el repositorio en GitHub (manual)
echo "📋 PASO 1: Crear repositorio en GitHub"
echo "Ir a: https://github.com/new"
echo "Repository name: orangehrm-portos-clean"
echo "Organization: RDG-CONSULTORES"
echo "Description: OrangeHRM 5.7 clean installation for Portos International"
echo ""

# 2. Configurar Git
echo "📋 PASO 2: Configurar Git"
git config --global user.email "admin@portosinternational.com"
git config --global user.name "Portos International"

# 3. Actualizar archivos para Render
echo "📋 PASO 3: Optimizando para Render..."

# Crear archivo de validación
cat > validate-setup.php << 'EOF'
<?php
/**
 * Validate OrangeHRM Setup
 */
echo "🔍 VALIDATING ORANGEHRM SETUP\n\n";

// Check PHP version
echo "PHP Version: " . phpversion() . "\n";

// Check extensions
$required_extensions = ['pdo', 'pdo_pgsql', 'gd', 'intl', 'zip', 'opcache'];
foreach ($required_extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "✅ $ext extension loaded\n";
    } else {
        echo "❌ $ext extension missing\n";
    }
}

// Check database connection
try {
    $host = 'dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com';
    $port = '5432';
    $dbname = 'orangehrm_portos';
    $user = 'orangehrm_user';
    $password = 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX';
    
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'");
    $tableCount = $stmt->fetchColumn();
    
    echo "✅ Database connected: $tableCount tables\n";
    
} catch (Exception $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
}

echo "\n🎯 Setup validation complete\n";
?>
EOF

echo "✅ validate-setup.php creado"

# 4. Commit changes
echo "📋 PASO 4: Commit de cambios..."
git add -A
git commit -m "feat: Setup optimizations for Render deployment

- Enhanced docker-entrypoint.sh with better DB handling
- Added test-docker-build.sh for local testing
- Added setup-render.sh for deployment guide
- Added validate-setup.php for system validation

Ready for Render deployment 🚀"

echo "✅ Cambios committed"

# 5. Instructions for manual steps
echo ""
echo "📋 PASOS MANUALES NECESARIOS:"
echo "=============================="
echo ""
echo "1. 🌐 CREAR REPOSITORIO EN GITHUB:"
echo "   - Ir a: https://github.com/new"
echo "   - Owner: RDG-CONSULTORES"
echo "   - Repository name: orangehrm-portos-clean"
echo "   - Description: OrangeHRM 5.7 clean installation for Portos International"
echo "   - Public"
echo "   - No README, no .gitignore (ya los tenemos)"
echo ""
echo "2. 📤 PUSH AL REPOSITORIO:"
echo "   git remote set-url origin https://github.com/RDG-CONSULTORES/orangehrm-portos-clean.git"
echo "   git push -u origin main"
echo ""
echo "3. 🚀 DEPLOY EN RENDER:"
echo "   - Ir a: https://dashboard.render.com"
echo "   - New > Web Service"
echo "   - Connect GitHub: RDG-CONSULTORES/orangehrm-portos-clean"
echo "   - Runtime: Docker"
echo "   - Branch: main"
echo "   - Root Directory: ."
echo ""
echo "4. 🗄️ USAR BASE DE DATOS EXISTENTE:"
echo "   En Environment Variables agregar:"
echo "   DATABASE_HOST=dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com"
echo "   DATABASE_PORT=5432"
echo "   DATABASE_NAME=orangehrm_portos"
echo "   DATABASE_USER=orangehrm_user"
echo "   DATABASE_PASSWORD=A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX"
echo ""
echo "🎯 Después del deploy:"
echo "   - URL: https://orangehrm-portos-clean.onrender.com"
echo "   - Login: admin / PortosAdmin123!"
echo ""

# Show git status
echo "📊 Git Status:"
git status --short

echo ""
echo "🚀 READY FOR DEPLOYMENT!"