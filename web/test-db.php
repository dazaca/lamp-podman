<?php
// Datos de conexión: nombre del contenedor de la base, usuario y contraseña definidos en el YAML
$host = 'mysql';
$usuario = 'usuario';
$password = 'clave123';
$bd = 'prueba';

// Crea la conexión usando MySQLi orientado a objetos
$conn = new mysqli($host, $usuario, $password, $bd);

// Verifica si hubo error de conexión
if ($conn->connect_error) {
    die("❌ Conexión fallida: " . $conn->connect_error);
}

// Si llega aquí, la conexión ha sido exitosa
echo "✅ Conexión exitosa a la base de datos MySQL.";

// Cierra la conexión (buena práctica)
$conn->close();
?>

