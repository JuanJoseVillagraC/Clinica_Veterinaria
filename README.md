# Clínica Veterinaria — Examen Final Programación III

## 1. Descripción del proyecto

Aplicación de escritorio desarrollada en Java Swing y Maven para la gestión de clientes y mascotas de una clínica veterinaria.

El proyecto fue adaptado para migrar su persistencia original basada en archivos TXT hacia una base de datos relacional MySQL, conservando la interfaz gráfica, los modelos, el controlador y las reglas de negocio existentes.

La comunicación con la base de datos se realiza mediante JDBC, el patrón Repository y procedimientos almacenados.

## 2. Tecnologías utilizadas

- Java JDK 25
- Java Swing
- Maven
- MySQL y MySQL Workbench
- JDBC (MySQL Connector/J)
- IntelliJ IDEA
- Git y GitHub

## 3. Modelo relacional

La base de datos utilizada se llama `veterinaria` y contiene dos tablas principales.

**Tabla cliente:** almacena la cédula, el nombre y el teléfono. La cédula funciona como clave primaria (PK).

**Tabla mascota:** almacena el código, nombre, especie, edad y cédula del cliente propietario. El código funciona como clave primaria (PK) y `cedula_cliente` como clave foránea (FK).

La relación es **uno a muchos (1:N)**: un cliente puede tener varias mascotas, pero cada mascota pertenece a un único cliente.

La clave foránea garantiza que no puedan registrarse mascotas con propietarios inexistentes. Se utiliza `ON DELETE RESTRICT` para impedir la eliminación de clientes que tengan mascotas asociadas.

## 4. Configuración de MySQL

Abrir MySQL Workbench con una cuenta administradora y ejecutar el archivo:

`database/01_veterinaria.sql`

Este script contiene la creación de la base de datos, las tablas, las restricciones, los procedimientos almacenados y los permisos de seguridad.

Antes de ejecutarlo en otra computadora, deben establecerse contraseñas locales seguras y diferentes para los usuarios `vet_definer` y `vet_app`, reemplazando los valores de ejemplo.

Las contraseñas reales no se incluyen en el repositorio.

## 5. Procedimientos almacenados

La aplicación utiliza siete procedimientos:

1. `sp_listar_clientes()`: consulta los clientes.
2. `sp_insertar_cliente(...)`: registra un cliente.
3. `sp_listar_mascotas()`: consulta las mascotas.
4. `sp_insertar_mascota(...)`: registra una mascota.
5. `sp_actualizar_mascota(...)`: actualiza una mascota.
6. `sp_eliminar_mascota(...)`: elimina una mascota.
7. `sp_listar_mascotas_con_dueno()`: consulta las mascotas y los nombres de sus propietarios mediante INNER JOIN.

Los procedimientos utilizan `SQL SECURITY DEFINER`.

## 6. Seguridad y permisos

Se utilizan dos cuentas MySQL con responsabilidades diferentes.

**vet_definer:** cuenta técnica con permisos limitados sobre las tablas, utilizada para ejecutar las operaciones internas de los procedimientos.

**vet_app:** cuenta utilizada por Java. Tiene únicamente permisos `EXECUTE` sobre los procedimientos almacenados y no tiene acceso directo a las tablas.

La aplicación no utiliza el usuario `root`.

### Prueba de seguridad 1: ejecución permitida

Conectarse a MySQL Workbench utilizando `vet_app` y ejecutar:

`CALL veterinaria.sp_listar_mascotas();`

**Resultado esperado:** la consulta se ejecuta correctamente y devuelve los registros disponibles.

### Prueba de seguridad 2: acceso directo denegado

Con la misma conexión `vet_app`, ejecutar:

`SELECT * FROM veterinaria.mascota;`

**Resultado esperado:** MySQL rechaza la consulta por falta de permisos directos sobre la tabla.

Estas pruebas permiten verificar el principio de privilegios mínimos.

## 7. Configuración de JDBC

El proyecto utiliza MySQL Connector/J mediante la dependencia declarada en `pom.xml`.

En IntelliJ IDEA se deben configurar las siguientes variables de entorno en **Run → Edit Configurations → Main → Environment variables**:

| Variable | Valor |
|---|---|
| VET_DB_URL | `jdbc:mysql://localhost:3306/veterinaria?serverTimezone=UTC` |
| VET_DB_USER | `vet_app` |
| VET_DB_PASSWORD | Contraseña local configurada para vet_app |

Las variables son obtenidas desde Java mediante `System.getenv()`.

Las credenciales reales no se almacenan en el código fuente.

## 8. Ejecución de la aplicación

1. Abrir el proyecto Maven en IntelliJ IDEA.
2. Configurar el JDK 25.
3. Ejecutar **Reload All Maven Projects**.
4. Verificar que MySQL esté en funcionamiento y que el script SQL se haya ejecutado correctamente.
5. Configurar las variables de entorno.
6. Ejecutar la clase `examen.veterinaria.Main`.

La aplicación mostrará la ventana Swing de Clínica Veterinaria.

## 9. Pruebas funcionales

Para comprobar la migración se pueden realizar las siguientes operaciones:

- Registrar y listar clientes.
- Registrar y listar mascotas con propietarios existentes.
- Consultar mascotas junto con el nombre de su propietario.
- Filtrar mascotas por cédula del cliente.
- Actualizar y eliminar mascotas.
- Cerrar y volver a abrir la aplicación para verificar la persistencia.
- Intentar insertar identificadores duplicados.
- Intentar registrar una mascota con un propietario inexistente.

Las operaciones válidas deben persistirse en MySQL y las operaciones inválidas deben ser rechazadas.

## 10. Arquitectura del proyecto

Se conserva la separación original de responsabilidades:

**Main → Vista Swing → Controller → Service → Repository MySQL → JDBC → MySQL**

Las clases `RepositorioClienteMySQL` y `RepositorioMascotaMySQL` implementan las interfaces Repository existentes y utilizan `CallableStatement` para ejecutar los procedimientos almacenados.

La interfaz gráfica y el Service no realizan consultas SQL directamente.

---
