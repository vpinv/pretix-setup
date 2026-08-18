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

# 1. Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker compose down 2>/dev/null || true

# 2. Remove old volumes to start fresh
echo "🧹 Removing old volumes..."
docker volume rm pretix-setup_pretix_app_data pretix-setup_pretix_db_data pretix-setup_pretix_redis_data 2>/dev/null || true

# 3. Boot database stack
echo "📦 Starting isolated Database and Cache services..."
docker compose up -d pretix_db pretix_redis

# 4. Wait for DB to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# 5. Run Django Table schema layouts
echo "🗄️ Executing structural database migrations. Please wait..."
docker compose run --rm pretix migrate

# 6. Create superuser
echo "👤 Launching Administrator creation menu..."
docker compose run --rm pretix createsuperuser

# 7. Update pretix configuration in the database
echo "🔧 Configuring Pretix URL settings..."
docker compose run --rm pretix shell << 'EOF'
from pretix.base.models import GlobalSettings
GlobalSettings.set('pretix_url', 'http://168.144.69.28.sslip.io:8345')
print('✅ Pretix URL configured successfully!')
EOF

# 8. Bring up application servers
echo "🌐 Starting core web application servers..."
docker compose up -d

echo "========================================="
echo "🎉 SUCCESS: Pretix is fully deployed!"
echo "👉 Access URL: http://168.144.69.28.sslip.io:8345"
echo "========================================="
