package Database;

import java.sql.Connection;
import java.sql.CallableStatement;

public class Repository {
    
    protected static DatabaseRepository instance;
    protected Connection connection;
    protected String connectionURL;
    protected CallableStatement callableStatement;

    protected Repository() {
        connectionURL = "jdbc:sqlserver://25.53.45.8:1433;"
                        + "database=Vacaciones;"
                        + "user=progra-admin;"
                        + "password=admin;"
                        + "encrypt=false;"
                        + "trustServerCertificate=true;"
                        + "loginTimeout=30;";
    }

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
