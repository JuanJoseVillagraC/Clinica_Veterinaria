CREATE DATABASE IF NOT EXISTS veterinaria;
USE veterinaria;

-- 1. Tabla cliente:
CREATE TABLE IF NOT EXISTS cliente (
    cedula VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NOT NULL,

    CONSTRAINT chk_cliente_cedula
    CHECK (TRIM(cedula) <> ''),
    CONSTRAINT chk_cliente_nombre
    CHECK (TRIM(nombre) <> ''),
    CONSTRAINT chk_cliente_telefono
    CHECK (TRIM(telefono) <> '')
    );

-- 2. Tabla mascotas:
CREATE TABLE IF NOT EXISTS mascota (
    codigo VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    especie ENUM('PERRO', 'GATO', 'OTRO') NOT NULL,
    edad INT NOT NULL,
    cedula_cliente VARCHAR(20) NOT NULL,

    CONSTRAINT chk_mascota_codigo
    CHECK (TRIM(codigo) <> ''),
    CONSTRAINT chk_mascota_nombre
    CHECK (TRIM(nombre) <> ''),
    CONSTRAINT chk_mascota_edad
    CHECK (edad BETWEEN 0 AND 40),

    CONSTRAINT fk_mascota_cliente
    FOREIGN KEY (cedula_cliente)
    REFERENCES cliente(cedula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
    );

-- Creación del vet_definer con sus permisos:

USE veterinaria;

-- Usuario técnico:
CREATE USER IF NOT EXISTS 'vet_definer'@'localhost'
IDENTIFIED BY 'Juan123';

-- Permisos sobre clientes:
GRANT SELECT, INSERT
      ON veterinaria.cliente
          TO 'vet_definer'@'localhost';

-- Permisos sobre mascotas:
GRANT SELECT, INSERT, UPDATE, DELETE
      ON veterinaria.mascota
          TO 'vet_definer'@'localhost';

-- Procedimientos Almacenados:

USE veterinaria;

DROP PROCEDURE IF EXISTS sp_listar_clientes;
DROP PROCEDURE IF EXISTS sp_insertar_cliente;
DROP PROCEDURE IF EXISTS sp_listar_mascotas;
DROP PROCEDURE IF EXISTS sp_insertar_mascota;
DROP PROCEDURE IF EXISTS sp_actualizar_mascota;
DROP PROCEDURE IF EXISTS sp_eliminar_mascota;
DROP PROCEDURE IF EXISTS sp_listar_mascotas_con_dueno;

DELIMITER $$

-- 1. LISTAR CLIENTES
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_listar_clientes()
SQL SECURITY DEFINER
BEGIN
SELECT cedula, nombre, telefono
FROM cliente
ORDER BY cedula;
END$$

-- 2. INSERTAR CLIENTE
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_insertar_cliente(
    IN p_cedula VARCHAR(20),
    IN p_nombre VARCHAR(80),
    IN p_telefono VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
INSERT INTO cliente (cedula, nombre, telefono)
VALUES (p_cedula, p_nombre, p_telefono);
END$$

-- 3. LISTAR MASCOTAS
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_listar_mascotas()
SQL SECURITY DEFINER
BEGIN
SELECT codigo, nombre, especie, edad,
       cedula_cliente
FROM mascota
ORDER BY codigo;
END$$

-- 4. INSERTAR MASCOTA
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_insertar_mascota(
    IN p_codigo VARCHAR(15),
    IN p_nombre VARCHAR(80),
    IN p_especie VARCHAR(20),
    IN p_edad INT,
    IN p_cedula_cliente VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
INSERT INTO mascota
(codigo, nombre, especie, edad, cedula_cliente)
VALUES
    (p_codigo, p_nombre, p_especie,
     p_edad, p_cedula_cliente);
END$$

-- 5. ACTUALIZAR MASCOTA
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_actualizar_mascota(
    IN p_codigo VARCHAR(15),
    IN p_nombre VARCHAR(80),
    IN p_especie VARCHAR(20),
    IN p_edad INT,
    IN p_cedula_cliente VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM mascota
        WHERE codigo = p_codigo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no existe';
END IF;

UPDATE mascota
SET nombre = p_nombre,
    especie = p_especie,
    edad = p_edad,
    cedula_cliente = p_cedula_cliente
WHERE codigo = p_codigo;
END$$

-- 6. ELIMINAR MASCOTA
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_eliminar_mascota(
    IN p_codigo VARCHAR(15)
)
SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM mascota
        WHERE codigo = p_codigo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no existe';
END IF;

DELETE FROM mascota
WHERE codigo = p_codigo;
END$$

-- 7. LISTAR MASCOTAS CON DUEÑO
CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_listar_mascotas_con_dueno()
SQL SECURITY DEFINER
BEGIN
SELECT
    m.codigo,
    m.nombre,
    m.especie,
    m.edad,
    m.cedula_cliente,
    c.nombre AS nombre_cliente
FROM mascota m
         INNER JOIN cliente c
                    ON m.cedula_cliente = c.cedula
ORDER BY m.codigo;
END$$

DELIMITER ;

-- Creación del vet_app con sus permisos:

USE veterinaria;

-- Usuario que utilizará nuestra aplicación Java
CREATE USER IF NOT EXISTS 'vet_app'@'localhost'
IDENTIFIED BY 'Juan321';

-- Permitir ejecutar los 7 procedimientos
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno
TO 'vet_app'@'localhost';

-- ---------------------------------------

USE veterinaria;

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes
TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente
TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas
TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota
TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota
TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota
TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno
TO 'vet_definer'@'localhost';

USE veterinaria;

CALL sp_listar_clientes();
CALL sp_listar_mascotas();
CALL sp_listar_mascotas_con_dueno();