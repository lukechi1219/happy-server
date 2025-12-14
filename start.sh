#!/bin/bash

echo "Starting PostgreSQL..."
docker run -d \
    --name happy-postgres \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_DB=handy \
    -v $(pwd)/.pgdata:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:16

echo "Starting Redis..."
docker run -d \
    --name happy-redis \
    -p 6379:6379 \
    redis

if [ "$1" = "--s3" ]; then
    echo "Starting MinIO (S3)..."
    docker run -d \
        --name happy-minio \
        -p 9000:9000 \
        -p 9001:9001 \
        -e MINIO_ROOT_USER=minioadmin \
        -e MINIO_ROOT_PASSWORD=minioadmin \
        -v $(pwd)/.minio/data:/data \
        minio/minio server /data --console-address :9001
fi

echo "Services started."
echo "Run 'yarn dev' to start the server."
