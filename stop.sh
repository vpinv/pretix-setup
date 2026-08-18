#!/usr/bin/env bash
set -e

echo "========================================="
echo "🛑 Stopping Pretix Stack..."
echo "========================================="

# Check if docker-compose.yml exists in the current directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in this directory!"
    exit 1
fi

# Stop and remove containers, preserving the persistent volumes
docker compose down

echo "========================================="
echo "✅ SUCCESS: Pretix stack has been stopped cleanly."
echo "💡 Note: Your database and event data are safe inside Docker volumes."
echo "========================================="
