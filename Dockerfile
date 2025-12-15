# Stage 1: Build dependencies and generate Prisma client
FROM node:20-bookworm-slim AS builder

# 安裝 OpenSSL (Prisma 需要) 和編譯工具
# Install dependencies
RUN apt-get update && apt-get install -y openssl python3 ffmpeg make g++ build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./
COPY ./prisma ./prisma

# Install dependencies
RUN yarn install --frozen-lockfile --ignore-engines

COPY . .

# 產生 Prisma Client
RUN npx prisma generate

# Type check (no build output, Fastify runs with tsx directly)
RUN yarn build

# Stage 2: Runtime
FROM node:20-bookworm-slim AS runner

WORKDIR /app

# 安裝 Production 執行所需的系統套件 (Prisma 需要 OpenSSL,ffmpeg)
# Install dependencies
RUN apt-get update && apt-get install -y openssl python3 ffmpeg && rm -rf /var/lib/apt/lists/*

# Set environment to production
ENV NODE_ENV=production

# 1. 複製 Prisma schema (因應 Migration 需求) - 這是 Dockerfile 2 的優點
COPY --from=builder /app/prisma ./prisma

# 2. 複製依賴 (包含生成的 Prisma Client)
# Copy necessary files from the builder stage
COPY --from=builder /app/tsconfig.json ./tsconfig.json
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# 3. 複製 Source (Fastify with tsx - 直接執行 TypeScript)
COPY --from=builder /app/sources ./sources

# 4. 複製 entrypoint script
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh

# Expose the port the app will run on
EXPOSE 3000

# Command to run the application (with migration)
CMD ["./entrypoint.sh"] 
