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

    public Result listEmployees() {
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
                String IDdocument = resultSet.getString(1);
                String name = resultSet.getString(2);
                result.addDatasetItem(new Empleado(IDdocument, name, 0)); 
            }

        } catch (Exception e){} finally {
            closeResources();
        }
        return result;
    }



}