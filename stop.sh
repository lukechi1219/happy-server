#!/bin/bash

echo "Stopping PostgreSQL..."
docker rm -f happy-postgres 2>/dev/null || echo "PostgreSQL not running"

echo "Stopping Redis..."
docker rm -f happy-redis 2>/dev/null || echo "Redis not running"

echo "Stopping MinIO..."
docker rm -f happy-minio 2>/dev/null || echo "MinIO not running"

echo "Services stopped."
