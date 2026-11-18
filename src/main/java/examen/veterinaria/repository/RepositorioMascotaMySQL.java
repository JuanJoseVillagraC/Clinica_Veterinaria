package examen.veterinaria.repository;

import examen.veterinaria.model.Especie;
import examen.veterinaria.model.Mascota;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioMascotaMySQL implements RepositorioMascota {

    // CONVERTIR UNA FILA SQL EN UN OBJETO MASCOTA
    private Mascota mapear(ResultSet rs) throws SQLException {

        return new Mascota(
                rs.getString("codigo"),
                rs.getString("nombre"),
                Especie.valueOf(rs.getString("especie")),
                rs.getInt("edad"),
                rs.getString("cedula_cliente")
        );
    }

    // ASIGNAR LOS PARAMETROS DE UNA MASCOTA
    private void llenarParametros(
            CallableStatement cs,
            Mascota mascota
    ) throws SQLException {

        cs.setString(1, mascota.getCodigo());
        cs.setString(2, mascota.getNombre());
        cs.setString(3, mascota.getEspecie().name());
        cs.setInt(4, mascota.getEdad());
        cs.setString(5, mascota.getCedulaCliente());
    }

    // LISTAR TODAS LAS MASCOTAS
    @Override
    public List<Mascota> cargarTodos() {

        List<Mascota> mascotas = new ArrayList<>();

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_listar_mascotas()}"
                );
                ResultSet rs = cs.executeQuery()
        ) {

            while (rs.next()) {
                mascotas.add(mapear(rs));
            }

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al cargar mascotas: " + e.getMessage(), e
            );
        }

        return mascotas;
    }

    // INSERTAR UNA MASCOTA
    @Override
    public void insertar(Mascota mascota) {

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_insertar_mascota(?,?,?,?,?)}"
                )
        ) {

            llenarParametros(cs, mascota);
            cs.executeUpdate();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al insertar mascota: " + e.getMessage(), e
            );
        }
    }

    // ACTUALIZAR UNA MASCOTA
    @Override
    public void actualizar(Mascota mascota) {

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_actualizar_mascota(?,?,?,?,?)}"
                )
        ) {

            llenarParametros(cs, mascota);
            cs.executeUpdate();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al actualizar mascota: " + e.getMessage(), e
            );
        }
    }

    // ELIMINAR UNA MASCOTA
    @Override
    public void eliminar(String codigo) {

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_eliminar_mascota(?)}"
                )
        ) {

            cs.setString(1, codigo);
            cs.executeUpdate();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al eliminar mascota: " + e.getMessage(), e
            );
        }
    }

    // LISTAR MASCOTAS CON EL NOMBRE DEL DUENO
    @Override
    public List<String> listarConDueno() {

        List<String> filas = new ArrayList<>();

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_listar_mascotas_con_dueno()}"
                );
                ResultSet rs = cs.executeQuery()
        ) {

            while (rs.next()) {

                Mascota mascota = mapear(rs);

                String nombreCliente =
                        rs.getString("nombre_cliente");

                filas.add(
                        mascota + " | Cliente: " + nombreCliente
                );
            }

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al listar mascotas con dueño: "
                            + e.getMessage(), e
            );
        }

        return filas;
    }
}
