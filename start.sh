#!/usr/bin/env bash
set -e

echo "========================================="
echo "🚀 Starting Pretix Stack..."
echo "========================================="

# Check if docker-compose.yml exists in the current directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in this directory!"
    echo "Please save the YAML file first, then run this script again."
    exit 1
fi

# 1. Start services (preserve volumes)
echo "📦 Starting Database and Cache services..."
docker compose up -d pretix_db pretix_redis

# 2. Wait for DB to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# 3. Start the main application
echo "🌐 Starting core web application servers..."
docker compose up -d

echo "========================================="
echo "🎉 SUCCESS: Pretix is running!"
echo "👉 Access URL: http://168.144.69.28.sslip.io:8345"
echo "========================================="
