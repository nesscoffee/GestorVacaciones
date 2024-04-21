// Armando Castro, Stephanie Sandoval | Abr 17. 24
// Tarea Programada 02 | Base de Datos I

/* CLASE REPOSITORIO
 * Tiene los atributos y funcionalidades basicas de un repo
 * Se usa para las conexiones a la BD con los diferentes objetos
 */

package Database;

import java.sql.Connection;
import java.sql.CallableStatement;

public class Repository {
    
    protected static DatabaseRepository instance;
    protected Connection connection;
    protected String connectionURL;
    protected CallableStatement callableStatement;
	
	/* ------------------------------------------------------------ */
	// CONSTRUCTOR DE LA CLASE

    protected Repository() {
        connectionURL = "jdbc:sqlserver://25.53.45.8:1433;"
                        + "database=Vacaciones;"
                        + "user=progra-admin;"
                        + "password=admin;"
                        + "encrypt=false;"
                        + "trustServerCertificate=true;"
                        + "loginTimeout=30;";
    }
	
	/* ------------------------------------------------------------ */
	// CERRAR RECURSOS
	// cierra la llamada a la BD y la conexion
	
    protected void closeResources() {
        try {
            if (callableStatement != null) {
                callableStatement.close();
            }
            if (connection != null) {
                connection.close();
            }
        } catch (Exception e) {}
    }
}