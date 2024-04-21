// Armando Castro, Stephanie Sandoval | Abr 17. 24
// Tarea Programada 02 | Base de Datos I

/* CLASE PARA UTILIZAR BD CON MOVIMIENTOS
 * Realiza operaciones relacionadas con los movimientos
 * Es decir: lista e insercion
 */

/* Notas adicionales:
 * Trabaja con el patron Singleton
 * Hereda de la clase Repository 
 */

package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

import java.sql.Timestamp;
import java.util.Date;

public class MovimientoRepository extends Repository {
    
    private static MovimientoRepository instance;
	
	/* ------------------------------------------------------------ */
	// CONSTRUCTOR DE LA CLASE

    private MovimientoRepository() {
        super();
    }
	
	/* ------------------------------------------------------------ */
	// INSTANCIA DE LA CLASE

    public static synchronized MovimientoRepository getInstance() {
        if (instance == null){
            instance = new MovimientoRepository();
        }
        return instance;
    }
	
	/* ------------------------------------------------------------ */
	// LISTAR MOVIMIENTOS
	// retorna una lista con los movimientos registrados de un empleado especifico
	
	// parametros: cedula del empleado del que se realiza la consulta
	// retorna: result con dos codigos de resultado y un dataset
	// 		- codigo 1  : resultado de la bitacora
	//      - codigo 2  : resultado del sp
	// 		- dataset 1 : lista de movimientos (uno o varios items tipo Movimiento)
	
	// notas adicionales:
	// 		- la cedula debe ser proporcionada por el sistema, no el usuario

    public Result listarMovimientos(String cedula) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ListarMovimientos(?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, cedula);                                   // recibe la cedula

			// PARTE 3. Establecer los parametros de salida y ejecutar
            callableStatement.registerOutParameter(2, Types.INTEGER);                 // registrar el parametro de salida
            callableStatement.execute();                                              // ejecutar el sp

			// PARTE 4. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: bitacora
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            callableStatement.getMoreResults();                                       // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                             // obtener el segundo dataset: lista movimientos
            while (resultSet.next()){                                                 // mientras hayan filas (puede que no existan)
                Date fecha = resultSet.getDate(1);                                    // obtener la fecha
                String movimiento = resultSet.getString(2);                           // obtener el nombre del movimiento
				float monto = resultSet.getFloat(3);                                  // obtener el monto aplicado
				float nuevoSaldo = resultSet.getFloat(4);                             // obtener el nuevo saldo despues de aplicar el monto
				String username = resultSet.getString(5);                             // obtener el usuario que lo registro
				String IP = resultSet.getString(6);                                   // obtener el IP de registro
				Timestamp estampa = resultSet.getTimestamp(7);                        // obtener la estampa de registro
				// agregar movimiento a la lista de retorno:
				result.addDatasetItem(new Movimiento(fecha, movimiento, monto, nuevoSaldo, username, IP, estampa));
			}

			callableStatement.getMoreResults();                                       // buscar el siguiente dataset
			resultSet = callableStatement.getResultSet();                             // obtener el tercer dataset: sp
			resultSet.next();                                                         // obtener el valor del sp
			result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

        } catch (Exception e){} finally {                                             // cerrar conexion; metodo heredado
            closeResources();                  
        }
        return result;                                                                // retorna codigo y dataset      
    }
	
	/* ------------------------------------------------------------ */

    public Result agregarMovimiento(String cedula, String nombreMovimiento, float monto) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.IngresarMovimiento(?, ?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, cedula);                                   // recibe la cedula
            callableStatement.setString(2, nombreMovimiento);                         // recibe el nombre del tipo de movimiento
            callableStatement.setFloat(3, monto);                                     // recibe el monto

			// PARTE 3. Establecer los parametros de salida y ejecutar
            callableStatement.registerOutParameter(4, Types.INTEGER);                 // registrar el parametro de salida
            callableStatement.execute();                                              // ejecutar el sp

			// PARTE 4. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: bitacora
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            callableStatement.getMoreResults();                                       // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                             // obtener el segundo dataset: sp
            resultSet.next();                                                         // obtener el valor del sp
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

        } catch (Exception e){} finally {                                             // cerrar conexion; metodo heredado
            closeResources();                  
        }
        return result;                                                                // retorna codigo y dataset
    }
}