package Database;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

import java.sql.Timestamp;
import java.util.Date;

public class MovimientoRepository extends Repository {
    
    private static MovimientoRepository instance;

    private MovimientoRepository() {
        super();
    }

    public static synchronized MovimientoRepository getInstance() {
        if (instance == null){
            instance = new MovimientoRepository();
        }
        return instance;
    }

    public Result listarMovimientos(String cedula) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.ListarMovimientos(?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, cedula);

            callableStatement.registerOutParameter(2, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            result.addCode(resultSet.getInt(1));

            if (callableStatement.getMoreResults()){
                resultSet = callableStatement.getResultSet();
                while (resultSet.next()){
                    Date fecha = resultSet.getDate(1);
                    String movimiento = resultSet.getString(2);
                    float monto = resultSet.getFloat(3);
                    float nuevoSaldo = resultSet.getFloat(4);
                    String username = resultSet.getString(5);
                    String IP = resultSet.getString(6);
                    Timestamp estampa = resultSet.getTimestamp(7);
                    result.addDatasetItem(new Movimiento(fecha, movimiento, monto, nuevoSaldo, username, IP, estampa));
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

    public Result agregarMovimiento(String cedula, String nombreMovimiento, float monto) {
        ResultSet resultSet;
        Result result = new Result();

        try {
            connection = DriverManager.getConnection(connectionURL);
            String storedProcedureQuery = "{CALL dbo.IngresarMovimiento(?, ?, ?, ?)}";
            callableStatement = connection.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, cedula);
            callableStatement.setString(2, nombreMovimiento);
            callableStatement.setFloat(3, monto);

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
}