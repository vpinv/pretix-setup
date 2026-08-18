#!/usr/bin/env bash
set -e

echo "========================================="
echo "🚀 Initializing Pretix Stack Setup..."
echo "========================================="

# Check if docker-compose.yml exists in the current directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in this directory!"
    echo "Please save the YAML file first, then run this script again."
    exit 1
fi

# 1. Clean out past broken instances safely
echo "🧹 Purging old container remnants and volumes..."
docker compose down -v

# 2. Boot database stack
echo "📦 Starting isolated Database and Cache services..."
docker compose up -d pretix_db pretix_redis

# 3. Run Django Table schema layouts
echo "🗄️ Executing structural database migrations. Please wait..."
docker compose run --rm pretix migrate

# 4. Hand over control for core Profile credentials
echo "👤 Launching Administrator creation menu..."
docker compose run --rm pretix createsuperuser

# 5. Bring up application servers globally
echo "🌐 Starting core web application servers..."
docker compose up -d

echo "========================================="
echo "🎉 SUCCESS: Pretix is fully deployed!"
echo "👉 Access URL: http://localhost:8345"
echo "========================================="

