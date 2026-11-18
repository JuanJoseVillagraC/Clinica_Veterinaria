package examen.veterinaria.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    private static String leerVariable(String nombre)
            throws SQLException {

        String valor = System.getenv(nombre);

        if (valor == null || valor.isBlank()) {
            throw new SQLException(
                    "Falta configurar la variable: " + nombre
            );
        }

        return valor;
    }

    public static Connection conectar()
            throws SQLException {

        String url = leerVariable("VET_DB_URL");
        String usuario = leerVariable("VET_DB_USER");
        String password = leerVariable("VET_DB_PASSWORD");

        return DriverManager.getConnection(
                url, usuario, password
        );
    }
}
