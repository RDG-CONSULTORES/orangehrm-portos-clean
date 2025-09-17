#!/bin/bash

echo "🐳 TESTING DOCKER BUILD FOR ORANGEHRM PORTOS..."
echo "================================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Build the image
echo "🔨 Building OrangeHRM Docker image..."
docker build -t orangehrm-portos-test .

if [ $? -eq 0 ]; then
    echo "✅ Docker build successful!"
    
    echo "🏃 Starting container for testing..."
    docker run -d -p 8080:80 --name orangehrm-test orangehrm-portos-test
    
    if [ $? -eq 0 ]; then
        echo "✅ Container started successfully!"
        echo "🌐 Test URL: http://localhost:8080"
        echo "👤 Login: admin / PortosAdmin123!"
        echo ""
        echo "To stop the test container:"
        echo "docker stop orangehrm-test && docker rm orangehrm-test"
    else
        echo "❌ Failed to start container"
        exit 1
    fi
else
    echo "❌ Docker build failed"
    exit 1
fi