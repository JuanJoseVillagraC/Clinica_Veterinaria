package examen.veterinaria;

import examen.veterinaria.controller.VeterinariaController;
import examen.veterinaria.repository.RepositorioCliente;
import examen.veterinaria.repository.RepositorioClienteMySQL;
import examen.veterinaria.repository.RepositorioMascota;
import examen.veterinaria.repository.RepositorioMascotaMySQL;
import examen.veterinaria.service.VeterinariaService;
import examen.veterinaria.view.VentanaVeterinaria;

import javax.swing.SwingUtilities;

public class Main {

    public static void main(String[] args) {

        SwingUtilities.invokeLater(() -> {

            // Repositorios con persistencia en MySQL
            RepositorioCliente clientes =
                    new RepositorioClienteMySQL();

            RepositorioMascota mascotas =
                    new RepositorioMascotaMySQL();

            // Servicio original
            VeterinariaService service =
                    new VeterinariaService(clientes, mascotas);

            // Controlador y ventana Swing originales
            VeterinariaController controller =
                    new VeterinariaController(service);

            new VentanaVeterinaria(controller)
                    .setVisible(true);
        });
    }
}

