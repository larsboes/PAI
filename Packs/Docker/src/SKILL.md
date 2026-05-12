---
name: Docker
description: "Docker and Compose patterns for local dev and production — multi-stage builds, networking, volumes, debugging containers, and compose orchestration. Direct docker/compose CLI. Use when building images, running containers, debugging services, or setting up local dev environments."
---

# Docker — Direct CLI Patterns

No Docker Desktop GUI. Pure CLI.

## Quick Reference: Essential Commands

```bash
# Build
docker build -t app:latest .
docker build -t app:latest --target=prod -f Dockerfile.multi .

# Run
docker run -d --name myapp -p 3000:3000 --env-file .env app:latest
docker run --rm -it app:latest /bin/sh    # interactive debug shell

# Compose
docker compose up -d                      # start all services
docker compose up -d --build              # rebuild + start
docker compose down -v                    # stop + remove volumes
docker compose logs -f service_name       # follow logs
docker compose exec service_name sh       # shell into running container

# Debug
docker logs myapp --tail 100 -f           # follow container logs
docker exec -it myapp /bin/sh             # shell into running container
docker inspect myapp | jq '.[0].NetworkSettings'
docker stats --no-stream                  # resource usage snapshot

# Cleanup
docker system prune -af --volumes         # nuclear cleanup
docker image prune -af                    # remove unused images
docker volume prune -f                    # remove unused volumes
```

## Multi-Stage Build (Production Pattern)

```dockerfile
# --- Build stage ---
FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json bun.lockb ./
RUN npm ci --production=false
COPY . .
RUN npm run build

# --- Production stage ---
FROM node:22-alpine AS prod
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
USER app
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Compose Patterns

### Dev Environment (hot reload + deps)
```yaml
# compose.yaml
services:
  app:
    build: .
    ports: ["3000:3000"]
    volumes:
      - .:/app
      - /app/node_modules   # exclude node_modules from mount
    environment:
      - NODE_ENV=development
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
    ports: ["5432:5432"]
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

volumes:
  pgdata:
```

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| "build image", "Dockerfile", "multi-stage" | `Workflows/Build.md` |
| "compose", "local dev setup", "services" | `Workflows/Compose.md` |
| "debug container", "container not starting" | `Workflows/Debug.md` |
| "optimize image", "reduce size" | `Workflows/Optimize.md` |
| "networking", "containers can't connect" | `Workflows/Networking.md` |

## Deep References

- `references/dockerfile-patterns.md` — Best practices, caching, layer optimization
- `references/compose-patterns.md` — Multi-service setups, profiles, overrides
- `references/networking.md` — Bridge, host, overlay, DNS resolution
- `references/volumes.md` — Bind mounts vs named volumes, tmpfs, permissions
- `references/debugging.md` — Troubleshooting non-starting containers, networking issues

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/docker-cleanup.sh` | Smart cleanup (dangling images, stopped containers, unused volumes) |
| `scripts/docker-size.sh` | Show image sizes sorted, with layer breakdown |
| `scripts/docker-enter.sh` | Enter any running container (auto-detects shell) |

## Output
- Produces: Dockerfiles, compose.yaml, or shell commands
- Format: Executable configuration files
