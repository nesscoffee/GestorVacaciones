// Armando Castro, Stephanie Sandoval | Abr 17. 24
// Tarea Programada 02 | Base de Datos I

/* CLASE PARA EL ACCESO A LA BASE DE DATOS
 * Realiza operaciones relacionadas directamente con el acceso
 * Es decir: login, logout y consulta del significado de errores
 */

/* Notas adicionales:
 * Trabaja con el patron Singleton
 * Hereda de la clase Repository 
 */

package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

public class DatabaseRepository extends Repository {

    private static DatabaseRepository instance;
	
	/* ------------------------------------------------------------ */
	// CONSTRUCTOR DE LA CLASE

    private DatabaseRepository() {
        super();
    }

    /* ------------------------------------------------------------ */
    // INSTANCIA DE LA CLASE

    public static synchronized DatabaseRepository getInstance() {
        if (instance == null){
            instance = new DatabaseRepository();
        }
        return instance;
    }

    /* ------------------------------------------------------------ */
    // LOGIN
	
    // parametros: usuario y contrasena de la persona que intenta acceder
    // retorna: result con dos codigos de resultado y cero datasets
    // 		- codigo 1  : resultado de la bitacora
    //      - codigo 2  : resultado del sp

    public Result login (String username, String password) {
		ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento
		
		try {
			// PARTE 1. Establecer conexion y llamar sp
			connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.ValidarAcceso(?, ?, ?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
            // PARTE 2. Establecer los parametros de entrada
			callableStatement.setString(1, username);                                 // recibe el usuario
			callableStatement.setString(2, password);                                 // recibe la contrasena
			
            // PARTE 3. Establecer los parametros de salida y ejecutar
			callableStatement.registerOutParameter(3, Types.INTEGER);                 // registrar el parametro de salida
			callableStatement.execute();                                              // ejecutar el sp

            // PARTE 4. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: bitacora
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            callableStatement.getMoreResults();                                       // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                             // obtener el segundo dataset: sp
            resultSet.next();                                                         // obtener el valor del sp
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado
			
		} catch (Exception e) {} finally {
			closeResources();                                                         // cerrar conexion; metodo heredado
		}
		return result;                                                                // retorna codigos
	}

    /* ------------------------------------------------------------ */
    // LOGOUT
	
    // parametros: no recibe
    // retorna: result con dos codigos de resultado y cero datasets
    //      - codigo 1  : resultado de la bitacora
    //      - codigo 2  : resultado del sp 

    public Result logout() {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento
		
		try {
            // PARTE 1. Establecer conexion y llamar sp
			connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.Salir(?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
            // PARTE 2. Establecer los parametros de salida y ejecutar
			callableStatement.registerOutParameter(1, Types.INTEGER);                 // registrar el parametro de salida
			callableStatement.execute();                                              // ejecutar el sp

            // PARTE 3. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: bitacora
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            callableStatement.getMoreResults();                                       // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                             // obtener el segundo dataset: sp
            resultSet.next();                                                         // obtener el valor del sp
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado
			
		} catch (Exception e) {} finally {
			closeResources();                                                         // cerrar conexion; metodo heredado
		}
		return result;                                                                // retorna codigos
    }

    /* ------------------------------------------------------------ */
    // CONSULTAR ERRORES PRODUCIDOS POR LA BD
	// permite obtener la descripcion de un codigo de error de la bd
	
    // parametros: codigo de resultado para hacer consulta
    // retorna: result con un codigo de resultado y un datasets
    //      - codigo 1  : resultado del sp
    //      - dataset 1 : descripcion del error (un solo item tipo String)

    public Result consultarError (int resultCode) {
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.ConsultarError(?, ?, ?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
			// PARTE 2. Establecer los parametros de entrada
			callableStatement.setInt(1, resultCode);                                  // recibe el codigo de error

			// PARTE 3. Obtener los resultados del sp
            callableStatement.registerOutParameter(2, Types.VARCHAR);                 // registrar parametro de salida: descripcion
            callableStatement.registerOutParameter(3, Types.INTEGER);                 // registrar parametro de salida: sp
            callableStatement.execute();

			// PARTE 4. Obtener los resultados del sp
            result.addDatasetItem(callableStatement.getString(2));                    // obtener la descripcion del error
            result.addCode(callableStatement.getInt(3));                              // obtener el codigo de ejecucion del sp

        } catch (Exception e) {} finally {
            closeResources();                                                         // cerrar conexion; metodo heredado
        }

        return result;                                                                // retorna codigo y dataset
    }
}