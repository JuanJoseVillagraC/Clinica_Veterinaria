package examen.veterinaria.repository;

import examen.veterinaria.model.Cliente;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioClienteMySQL implements RepositorioCliente {

    // LISTAR TODOS LOS CLIENTES
    @Override
    public List<Cliente> cargarTodos() {

        List<Cliente> clientes = new ArrayList<>();

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_listar_clientes()}"
                );
                ResultSet rs = cs.executeQuery()
        ) {

            while (rs.next()) {

                Cliente cliente = new Cliente(
                        rs.getString("cedula"),
                        rs.getString("nombre"),
                        rs.getString("telefono")
                );

                clientes.add(cliente);
            }

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al cargar clientes: " + e.getMessage(), e
            );
        }

        return clientes;
    }

    // INSERTAR CLIENTE
    @Override
    public void insertar(Cliente cliente) {

        try (
                Connection conexion = ConexionBD.conectar();
                CallableStatement cs = conexion.prepareCall(
                        "{CALL sp_insertar_cliente(?,?,?)}"
                )
        ) {

            cs.setString(1, cliente.getCedula());
            cs.setString(2, cliente.getNombre());
            cs.setString(3, cliente.getTelefono());

            cs.executeUpdate();

        } catch (SQLException e) {
            throw new PersistenciaException(
                    "Error al insertar cliente: " + e.getMessage(), e
            );
        }
    }
}
