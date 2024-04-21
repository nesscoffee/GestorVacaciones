package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

public class EmpleadoRepository extends Repository {

    private static EmpleadoRepository instance;

    private EmpleadoRepository() {
        super();
    }

    public static synchronized EmpleadoRepository getInstance() {
        if (instance == null){
            instance = new EmpleadoRepository();
        }
        return instance;
    }

    public Result listarEmpleados() {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ListarEmpleados(?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.registerOutParameter(1, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()){
                String cedula = resultSet.getString(1);
                String nombre = resultSet.getString(2);
                result.addDatasetItem(new Empleado(cedula, nombre)); 
            }

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }

    public Result agregarEmpleado (String cedula, String nombre, String puesto) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.IngresarEmpleado(?, ?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, cedula);
            callableStatement.setString(2, nombre);
            callableStatement.setString(3, puesto);

            callableStatement.registerOutParameter(4, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }

    public Result actualizarEmpleado (String cedulaOriginal, String cedulaNueva, String nombreNuevo, String puestoNuevo) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ActualizarEmpleado(?, ?, ?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, cedulaOriginal);
            callableStatement.setString(2, cedulaNueva);
            callableStatement.setString(3, nombreNuevo);
            callableStatement.setString(4, puestoNuevo);

            callableStatement.registerOutParameter(5, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }

    public Result borrarEmpleado (String cedula, Boolean confirmado) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.BorrarEmpleado(?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, cedula);
            callableStatement.setBoolean(2, confirmado);

            callableStatement.registerOutParameter(3, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }

    public Result consultarEmpleado (String cedula) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarEmpleado(?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, cedula);

            callableStatement.registerOutParameter(2, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()){
                String nombre = resultSet.getString(2);
                String puesto = resultSet.getString(3);
                float saldo = resultSet.getFloat(4);
                result.addDatasetItem(new Empleado(cedula, nombre, puesto, saldo)); 
            }

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }

    public Result filtrarEmpleados (String filtro) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.FiltrarEmpleados(?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, filtro);

            callableStatement.registerOutParameter(2, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            if (callableStatement.getMoreResults()){
                resultSet = callableStatement.getResultSet();
                while (resultSet.next()){
                    String cedula = resultSet.getString(1);
                    String nombre = resultSet.getString(2);
                    result.addDatasetItem(new Empleado(cedula, nombre)); 
                }

                callableStatement.getMoreResults();
                resultSet = callableStatement.getResultSet();
                resultSet.next();
                result.addCode(resultSet.getInt(1));
            }

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }

}