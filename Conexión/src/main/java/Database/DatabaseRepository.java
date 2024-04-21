package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

public class DatabaseRepository extends Repository {

    private static DatabaseRepository instance;

    private DatabaseRepository() {
        super();
    }

    public static synchronized DatabaseRepository getInstance() {
        if (instance == null){
            instance = new DatabaseRepository();
        }
        return instance;
    }

    public Result login (String username, String password) {
		ResultSet resultSet;
        Result result = new Result();
		
		try {
			connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.ValidarAcceso(?, ?, ?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
			callableStatement.setString(1, username);
			callableStatement.setString(2, password);
			
			callableStatement.registerOutParameter(3, Types.INTEGER);
			callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));
			
		} catch (Exception e) {} finally {
			closeResources();
		}
		return result;
	}

    public Result logout() {
        ResultSet resultSet;
        Result result = new Result();
		
		try {
			connection = DriverManager.getConnection(connectionURL);
			String storedProcedureQuery = "{CALL dbo.Salir(?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
			callableStatement.registerOutParameter(1, Types.INTEGER);
			callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));
			
		} catch (Exception e) {} finally {
			closeResources();
		}
		return result;
    }

    public Result consultError (int resultCode) {
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