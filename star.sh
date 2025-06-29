#!/bin/bash
# Este script levanta el entorno completo con Podman Compose

echo "🔼 Iniciando contenedores Apache + MySQL..."
podman-compose up -d

