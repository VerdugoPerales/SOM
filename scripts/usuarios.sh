#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como superusuario (root)."
  exit 1
fi

echo "Eres superusuario. Continuando con el script..."
echo ""
read -p "Introduce el nombre del departamento: " departamento

if getent group "$departamento" >/dev/null; then
  echo "El grupo '$departamento' ya existe."
else
  sudo groupadd "$departamento"
  echo "Grupo '$departamento' creado."
fi

read -p "¿Cuántos usuarios deseas crear para el departamento? " num_usuarios

for ((i=1; i<=num_usuarios; i++)); do
    read -p "Introduce el nombre del usuario $i: " usuario
    
    if id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' ya existe."
    else
        sudo useradd -m -G "$departamento" "$usuario"
        echo "Usuario '$usuario' creado y añadido al grupo '$departamento'."
    fi
    #&>/dev/null: Redirige tanto la salida estándar (stdout) como la salida de error (stderr).
    #Esto asegura que cualquier mensaje (ya sea informativo o de error) no se muestre en pantalla.

    read -p "¿Quieres asignar una contraseña a '$usuario'? (s/n, por defecto sí): " respuesta
    case "$respuesta" in
    "" | "s" | "S")
        echo "$usuario:1234" | sudo chpasswd
        echo "Se asignó la contraseña '1234' al usuario '$usuario'."
        ;;
    "n" | "N")
        echo "No se asignó contraseña al usuario '$usuario'."
        ;;
    *)
        echo "Respuesta no válida, no se asignó contraseña al usuario '$usuario'."
        ;;
    esac
done

