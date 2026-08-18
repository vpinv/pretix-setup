#!/usr/bin/env bash
set -e

echo "========================================="
echo "🚀 Initializing Pretix Stack Setup..."
echo "========================================="

# Check if docker-compose.yml exists in the current directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in this directory!"
    exit 1
fi

# 1. Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker compose down 2>/dev/null || true

# 2. Remove old volumes to start fresh
echo "🧹 Removing old volumes..."
docker volume rm pretix-setup_pretix_app_data pretix-setup_pretix_db_data pretix-setup_pretix_redis_data 2>/dev/null || true

# 3. Start services
echo "📦 Starting database and cache services..."
docker compose up -d pretix_db pretix_redis

# 4. Wait for DB to be ready
echo "⏳ Waiting for database to be ready..."
for i in {1..30}; do
    if docker compose exec -T pretix_db pg_isready -U pretix >/dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# 5. Run migrations
echo "🗄️ Running database migrations..."
docker compose run --rm pretix migrate

# 6. Create superuser
echo "👤 Creating administrator account..."
docker compose run --rm pretix createsuperuser

# 7. Start pretix app
echo "🌐 Starting Pretix application..."
docker compose up -d pretix

# 8. Wait for pretix to be ready
echo "⏳ Waiting for Pretix to start..."
sleep 5

# 9. Update the site URL using Django's Site framework
echo "🔧 Configuring site URL in database..."
docker compose exec -T pretix python manage.py shell << 'PYEOF'
from django.contrib.sites.models import Site
site = Site.objects.get_or_create(id=1)[0]
site.domain = '168.144.69.28.sslip.io:8345'
site.name = 'My Ticket Shop'
site.save()
print('✅ Site URL updated successfully!')
PYEOF

# 10. Start nginx
echo "🚀 Starting Nginx reverse proxy..."
docker compose up -d nginx

echo ""
echo "========================================="
echo "🎉 SUCCESS: Pretix is fully deployed!"
echo "👉 Access URL: http://168.144.69.28.sslip.io:8345"
echo "========================================="
