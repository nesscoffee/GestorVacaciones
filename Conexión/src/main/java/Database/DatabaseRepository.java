// Armando Castro, Stephanie Sandoval | Abr 17. 24
// Tarea Programada 02 | Base de Datos I

/* CLASE PARA EL ACCESO A LA BASE DE DATOS
 * Realiza operaciones relacionadas directamente con el acceso
 * Es decir: login, logout y consulta del significado de errores
 */

/* Notas adicionales:
 * Trabaja con el patron Singleton
 */

package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

public class DatabaseRepository extends Repository {

    private static DatabaseRepository instance;

    private DatabaseRepository() {
        super();
    }

    /* ------------------------------------------------------------ */
    // obtener instancia de la clase

    public static synchronized DatabaseRepository getInstance() {
        if (instance == null){
            instance = new DatabaseRepository();
        }
        return instance;
    }

    /* ------------------------------------------------------------ */
    // realizar login
    // parametros: usuario y contrasena de la persona que intenta acceder
    // retorna: result con dos codigos de resultado y cero datasets
    //      - codigo 1: resultado de la bitacora
    //      - codigo 2: resultado del sp

    public Result login (String username, String password) {
		ResultSet resultSet;                                              // para obtener los datasets
        Result result = new Result();                                     // resultados del procedimiento
		
		try {
            // PASO 1. Establecer conexion y llamar sp
			connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.ValidarAcceso(?, ?, ?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
            // PASO 2. Establecer los parametros de entrada
			callableStatement.setString(1, username);                     // recibe el usuario
			callableStatement.setString(2, password);                     // recibe la contrasena
			
            // PASO 3. Establecer los parametros de salida y ejecutar
			callableStatement.registerOutParameter(3, Types.INTEGER);     // registrar el parametro de salida
			callableStatement.execute();                                  // ejecutar el sp

            // PASO 4. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                 // obtener el primer dataset: bitacora
            resultSet.next();                                             // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));              // agregar valor al resultado

            callableStatement.getMoreResults();                           // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                 // obtener el segundo dataset: sp
            resultSet.next();                                             // obtener el valor del sp
            result.addCode(resultSet.getInt(1));              // agregar valor al resultado
			
		} catch (Exception e) {} finally {
			closeResources();                                             // cerrar conexion; metodo heredado
		}
		return result;                                                    // retorna codigos
	}

    /* ------------------------------------------------------------ */
    // realizar logout
    // parametros: no recibe
    // retorna: result con dos codigos de resultado y cero datasets
    //      - codigo 1: resultado de la bitacora
    //      - codigo 2: resultado del sp 

    public Result logout() {
        ResultSet resultSet;                                              // para obtener los datasets
        Result result = new Result();                                     // resultados del procedimiento
		
		try {
            // PASO 1. Establecer conexion y llamar sp
			connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.Salir(?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
            // PASO 2. Establecer los parametros de salida y ejecutar
			callableStatement.registerOutParameter(1, Types.INTEGER);     // registrar el parametro de salida
			callableStatement.execute();                                  // ejecutar el sp

            // PASO 3. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                 // obtener el primer dataset: bitacora
            resultSet.next();                                             // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));              // agregar valor al resultado

            callableStatement.getMoreResults();                           // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                 // obtener el segundo dataset: sp
            resultSet.next();                                             // obtener el valor del sp
            result.addCode(resultSet.getInt(1));              // agregar valor al resultado
			
		} catch (Exception e) {} finally {
			closeResources();
		}
		return result;
    }

    /* ------------------------------------------------------------ */

    public Result consultarError (int resultCode) {
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.ConsultarError(?, ?, ?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
			callableStatement.setInt(1, resultCode);

            callableStatement.registerOutParameter(2, Types.VARCHAR);
            callableStatement.registerOutParameter(3, Types.INTEGER);
            callableStatement.execute();

            result.addDatasetItem(callableStatement.getString(2));
            result.addCode(callableStatement.getInt(3));

        } catch (Exception e) {} finally {
            closeResources();
        }

        return result;
    }
    
}