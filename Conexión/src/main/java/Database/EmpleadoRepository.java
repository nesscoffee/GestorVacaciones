// Armando Castro, Stephanie Sandoval | Abr 17. 24
// Tarea Programada 02 | Base de Datos I

/* CLASE PARA UTILIZAR BD CON EMPLEADOS
 * Realiza operaciones relacionadas con los empleados
 * Es decir: lista, consulta, insercion, borrado, actualizado y filtrado
 */

/* Notas adicionales:
 * Trabaja con el patron Singleton
 * Hereda de la clase Repository 
 */

package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

public class EmpleadoRepository extends Repository {

    private static EmpleadoRepository instance;
	
    /* ------------------------------------------------------------ */
    // CONSTRUCTOR DE LA CLASE

    private EmpleadoRepository() {
        super();
    }
	
    /* ------------------------------------------------------------ */
    // INSTANCIA DE LA CLASE

    public static synchronized EmpleadoRepository getInstance() {
        if (instance == null){
            instance = new EmpleadoRepository();
        }
        return instance;
    }
	
    /* ------------------------------------------------------------ */
	// LISTAR EMPLEADOS
	// retorna una lista con los empleados activos
	
	// parametros: no recibe
	// retorna: result con un codigo de resultado y un dataset
	// 		- codigo 1  : resultado del sp
	// 		- dataset 1 : lista de empleados (uno o varios items tipo Empleado)

    public Result listarEmpleados() {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ListarEmpleados(?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de salida y ejecutar
            callableStatement.registerOutParameter(1, Types.INTEGER);                 // registrar el parametro de salida
            callableStatement.execute();                                              // ejecutar el sp

			// PARTE 3. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: sp
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            callableStatement.getMoreResults();                                       // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                             // obtener el segundo dataset: empleados
            while (resultSet.next()){                                                 // mientras hayan 
                String cedula = resultSet.getString(1);                               // obtener la cedula del empleado
                String nombre = resultSet.getString(2);                               // obtener el nombre del empleado
                result.addDatasetItem(new Empleado(cedula, nombre));                  // agregar empleado a la lista de retorno
            }

        } catch (Exception e){} finally {
            closeResources();                                                         // cerrar conexion; metodo heredado
        } 
        return result;                                                                // retorna codigo y dataset
    }
	
	/* ------------------------------------------------------------ */
	// AGREGAR EMPLEADO A BD
	// permite agregrar un empleado nuevo a la base de datos
	
	// parametros: cedula, nombre y puesto del empleado
	// retorna: result con dos codigos de resultado y cero datasets
	// 		- codigo 1  : resultado de la bitacora
	// 		- codigo 2  : resultado del sp 
	
    public Result agregarEmpleado (String cedula, String nombre, String puesto) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.IngresarEmpleado(?, ?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, cedula);                                   // recibe la cedula
            callableStatement.setString(2, nombre);                                   // recibe el nombre
            callableStatement.setString(3, puesto);                                   // recibe el puesto

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
			
		} catch (Exception e) {} finally {
			closeResources();                                                         // cerrar conexion; metodo heredado
		}
		return result;                                                                // retorna codigos
    }
	
	/* ------------------------------------------------------------ */
	// ACTUALIZAR EMPLEADO EN BD
	// permite actualizar la informacion de un empleado existente
	
	// parametros: cedula original, cedula nueva, nombre nuevo y puesto nuevo del empleado
	// retorna: result con dos codigos de resultado y cero datasets
	// 		- codigo 1  : resultado de la bitacora
	// 		- codigo 2  : resultado del sp
	
	// notas adicionales:
	// 		- la cedula original debe ser proporcionada por el sistema, no el usuario
	// 		- el sp permite que los valores nuevos sean nulos ('')
	// 		- si los valores nuevos son nulos, se mantiene el valor anterior
	
    public Result actualizarEmpleado (String cedulaOriginal, String cedulaNueva, String nombreNuevo, String puestoNuevo) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ActualizarEmpleado(?, ?, ?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, cedulaOriginal);                           // recibe el valor de la cedula original
            callableStatement.setString(2, cedulaNueva);                              // recibe el valor de la nueva cedula
            callableStatement.setString(3, nombreNuevo);                              // recibe el nuevo nombre del empleado
            callableStatement.setString(4, puestoNuevo);                              // recibe el nuevo puesto del empleado

			// PARTE 3. Establecer los parametros de salida y ejecutar
            callableStatement.registerOutParameter(5, Types.INTEGER);                 // registrar el parametro de salida
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
	// BORRAR EMPLEADO
	// borra un empleado existente (borrado logico)
	
	// parametros: cedula del empleado y boolean que indica si el usuario confirmo el borrado
	// retorna: result con dos codigos de resultado y cero datasets
	// 		- codigo 1  : resultado de la bitacora
	// 		- codigo 2  : resultado del sp

    public Result borrarEmpleado (String cedula, Boolean confirmado) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.BorrarEmpleado(?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, cedula);                                   // recibe la cedula
            callableStatement.setBoolean(2, confirmado);                              // recibe el dato de confirmacion

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
	// CONSULTAR EMPLEADO
	// retorna la informacion de un empleado especifico
	
	// parametros: cedula del empleado del que se realiza la consulta
	// retorna: result con un codigo de resultado y un dataset
	// 		- codigo 1  : resultado del sp
	// 		- dataset 1 : informacion del empleado (un solo item tipo Empleado)
	
	// notas adicionales:
	// 		- la cedula debe ser proporcionada por el sistema, no el usuario

    public Result consultarEmpleado (String cedula) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarEmpleado(?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, cedula);                                   // recibe la cedula

			// PARTE 3. Establecer los parametros de salida y ejecutar
            callableStatement.registerOutParameter(2, Types.INTEGER);                 // registrar el parametro de salida
            callableStatement.execute();                                              // ejecutar el sp

			// PARTE 4. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: sp
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            callableStatement.getMoreResults();                                       // buscar el siguiente dataset
            resultSet = callableStatement.getResultSet();                             // obtener el segundo dataset: info empleado
            while (resultSet.next()){                                                 // mientras hayan filas (solo debe haber una)
                String nombre = resultSet.getString(2);                               // obtener el nombre del empleado
                String puesto = resultSet.getString(3);                               // obtener el puesto del empleado
                float saldo = resultSet.getFloat(4);                                  // obtener el saldo actual del empleado
                result.addDatasetItem(new Empleado(cedula, nombre, puesto, saldo));   // agregar empleado a la lista de retorno
            }
			
        } catch (Exception e){} finally {                                             // cerrar conexion; metodo heredado
            closeResources();                  
        }
        return result;                                                                // retorna codigo y dataset
    }
	
	/* ------------------------------------------------------------ */
	// APLICAR FILTRO A LA LISTA DE EMPLEADOS
	// retorna una lista con los empleados cuya info coincide con el filtro

	// parametros: filtro que se desea aplicar
	// retorna: hay dos posibles estructuras de retorno
	// 	estructura 1: dos codigos de resultado y un dataset:
	// 		- codigo 1  : resultado de la bitacora
	// 		- codigo 2  : resultado del sp
	// 		- dataset 1 : lista de empleados despues de aplicaar filtro
	// 	estructura 2: un codigo de resultado y cero datasets
	//		- codigo 1  : resultado del sp
    
	// notas adicionales:
	// 		- el metodo retorna un solo resultado cuando el error es 50013
	// 		- es decir, cuando el filtro no es valido y, por tanto, no hay lista ni entrada a bitacora

    public Result filtrarEmpleados (String filtro) {
        ResultSet resultSet;                                                          // para obtener los datasets
        Result result = new Result();                                                 // resultados del procedimiento

        try {
			// PARTE 1. Establecer conexion y llamar sp
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.FiltrarEmpleados(?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

			// PARTE 2. Establecer los parametros de entrada
            callableStatement.setString(1, filtro);                                   // recibe el filtro

			// PARTE 3. Establecer los parametros de salida y ejecutar
            callableStatement.registerOutParameter(2, Types.INTEGER);                 // registrar el parametro de salida
            callableStatement.execute();                                              // ejecutar el sp

			// PARTE 4. Obtener los resultados del sp
            resultSet = callableStatement.getResultSet();                             // obtener el primer dataset: bitacora
            resultSet.next();                                                         // obtener el valor del dataset
            result.addCode(resultSet.getInt(1));                                      // agregar valor al resultado

            if (callableStatement.getMoreResults()){                                  // si hay mas resultados (no 50013)
                resultSet = callableStatement.getResultSet();                         // obtener el segundo dataset: lista empleados
                while (resultSet.next()){                                             // mientras hayan filas
                    String cedula = resultSet.getString(1);                           // obtener la cedula del empleado
                    String nombre = resultSet.getString(2);                           // obtener el nombre del empleado
                    result.addDatasetItem(new Empleado(cedula, nombre));              // agregar empleado a la lista de retorno
                }

                callableStatement.getMoreResults();                                   // buscar el siguiente dataset
                resultSet = callableStatement.getResultSet();                         // obtener el tercer dataset: sp
                resultSet.next();                                                     // obtener el valor del sp
                result.addCode(resultSet.getInt(1));                                  // agregar valor al resultado
            }

        } catch (Exception e){} finally {
            closeResources();                                                         // cerrar conexion; metodo heredado
        }
        return result;                                                                // retorna codigos (y posible dataset)
    }
}