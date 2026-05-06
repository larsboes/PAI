#!/usr/bin/env bash
# Show Docker images sorted by size with optional layer breakdown
# Usage: docker-size.sh [IMAGE_NAME] [--layers]

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "=== Docker Images by Size ==="
  echo ""
  docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedSince}}" \
    | (head -1 && tail -n +2 | sort -k2 -h -r)
  echo ""
  echo "Total disk usage:"
  docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"
else
  IMAGE="$1"
  
  if [[ "${2:-}" == "--layers" ]]; then
    echo "=== Layer Breakdown: $IMAGE ==="
    echo ""
    docker history "$IMAGE" --format "table {{.Size}}\t{{.CreatedBy}}" --no-trunc \
      | sed 's|/bin/sh -c #(nop) ||g' | sed 's|/bin/sh -c ||g' | cut -c1-120
  else
    echo "=== Image Details: $IMAGE ==="
    docker inspect "$IMAGE" | jq '.[0] | {
      size: (.Size / 1048576 | floor | tostring + " MB"),
      layers: (.RootFS.Layers | length),
      created: .Created,
      architecture: .Architecture,
      os: .Os,
      entrypoint: .Config.Entrypoint,
      cmd: .Config.Cmd,
      env: [.Config.Env[] | select(startswith("PATH") | not)],
      exposed_ports: (.Config.ExposedPorts | keys)
    }'
  fi
fi
