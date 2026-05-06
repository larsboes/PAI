# Dockerfile Patterns — Best Practices

## Layer Caching Strategy

```dockerfile
# GOOD: Dependencies change less often than code
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

# BAD: Any code change busts the npm ci cache
COPY . .
RUN npm ci
```

## Common Base Images

| Use Case | Image | Size |
|----------|-------|------|
| Node.js (smallest) | `node:22-alpine` | ~50MB |
| Node.js (full, for native deps) | `node:22-slim` | ~200MB |
| Python | `python:3.12-slim` | ~130MB |
| Go (build only) | `golang:1.22-alpine` | ~250MB |
| Go (production) | `gcr.io/distroless/static` | ~2MB |
| Rust (build) | `rust:1.78-alpine` | ~300MB |
| Rust (production) | `debian:bookworm-slim` | ~80MB |
| General (tiny with package mgr) | `alpine:3.19` | ~7MB |

## Multi-Stage Patterns

### Go Binary
```dockerfile
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /app ./cmd/server

FROM gcr.io/distroless/static
COPY --from=build /app /app
ENTRYPOINT ["/app"]
```

### Python with UV
```dockerfile
FROM python:3.12-slim AS builder
RUN pip install uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /app/.venv .venv
COPY . .
ENV PATH="/app/.venv/bin:$PATH"
CMD ["python", "-m", "app"]
```

### Bun/TypeScript
```dockerfile
FROM oven/bun:1 AS builder
WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun build ./src/index.ts --target=bun --outdir=./dist

FROM oven/bun:1-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER bun
EXPOSE 3000
CMD ["bun", "run", "dist/index.js"]
```

## Security Best Practices

```dockerfile
# 1. Non-root user
RUN addgroup -S app && adduser -S app -G app
USER app

# 2. Read-only filesystem (at runtime)
# docker run --read-only --tmpfs /tmp app:latest

# 3. No secrets in image
# Use --secret flag instead:
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm ci

# 4. Pin versions
FROM node:22.1.0-alpine3.19@sha256:abc123...

# 5. Minimal final stage
# Only copy what's needed, leave build tools behind
```

## .dockerignore (Always Add)

```
node_modules
.git
.env*
dist
*.log
.DS_Store
coverage
.next
__pycache__
*.pyc
.venv
target
```

## Build Arguments vs Environment Variables

```dockerfile
# Build-time (not in final image)
ARG NODE_ENV=production
RUN npm ci --production=$([ "$NODE_ENV" = "production" ] && echo "true" || echo "false")

# Runtime (available to running container)
ENV PORT=3000
EXPOSE $PORT
```

## Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Or with curl
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

## Debugging Build Issues

```bash
# Build with full output (no cache)
docker build --no-cache --progress=plain -t app .

# Build up to specific stage
docker build --target=builder -t app-debug .
docker run --rm -it app-debug /bin/sh

# See what's in each layer
docker history app:latest --no-trunc

# Dive tool (if installed) — interactive layer explorer
dive app:latest
```
