#!/bin/bash
# Este script detiene y elimina los contenedores del stack

echo "🔻 Deteniendo contenedores Apache + MySQL..."
podman-compose down

