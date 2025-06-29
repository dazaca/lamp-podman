#!/bin/bash

cd "$(dirname "$0")"

while true; do
    clear
    echo "=========== MENÚ DEL ENTORNO LAMP ==========="
    echo "1) 🔼 Iniciar contenedores (podman-compose up)"
    echo "2) 🔻 Detener contenedores (podman-compose down)"
    echo "3) ♻️  Reiniciar contenedores"
    echo "4) 📜 Ver logs en vivo"
    echo "5) 🧾 Ver contenedores activos"
    echo "0) ❌ Salir"
    echo "============================================"
    echo -n "Elige una opción: "
    read opcion

    case $opcion in
        1) podman-compose up -d ;;
        2) podman-compose down ;;
        3) podman-compose down && podman-compose up -d ;;
        4) podman-compose logs -f ;;
        5) podman ps ;;
        0) echo "Saliendo..." && break ;;
        *) echo "Opción no válida" && sleep 1 ;;
    esac

    echo
    echo -n "Presiona ENTER para volver al menú..."
    read
done

