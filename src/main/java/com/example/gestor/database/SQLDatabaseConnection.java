/*
 * Java de la conexión de la base de datos SQL
 * Armando Castro - Stephanie Sandoval
 */

package com.example.gestor.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.sql.CallableStatement;

public class SQLDatabaseConnection {
	
	private static SQLDatabaseConnection instance;
	private Connection connection;
	private String connectionUrl;
	private CallableStatement callableStatement;
	
	//Constructor privado debido a el patrón Singleton.
	private SQLDatabaseConnection() {
		connectionUrl = "jdbc:sqlserver://25.53.45.8:1433;"
				+ "database=Vacaciones;"
				+ "user=progra-admin;"
				+ "password=admin;"
				+ "encrypt=false;"
				+ "trustServerCertificate=true;"
				+ "loginTimeout=30;";
	}
	
	//Getter de la instancia según patrón Singleton.
	public static synchronized SQLDatabaseConnection getInstance() {
		if (instance == null) {
			instance = new SQLDatabaseConnection();
		}
		return instance;
	}
	
	//Manejador de inicios de sesión
	public int loginHandler(String username, String password) {
		int resultCode = -1;
		
		try {
			connection = DriverManager.getConnection(connectionUrl);
			String storedProcedureQuery = "{CALL dbo.ValidarAcceso(?, ?, ?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
			callableStatement.setString(1, username);
			callableStatement.setString(2, password);
			
			callableStatement.registerOutParameter(3, Types.INTEGER);
			callableStatement.execute();
			resultCode = callableStatement.getInt(3);
			
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				if (connection != null) {
					connection.close();
				}
				if (callableStatement != null) {
					callableStatement.close();
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return resultCode;
	}
	
	//Fetch lista empleados
	public ArrayList<Empleado> listaEmpleados() {
		ArrayList<Empleado> listaEmpleados = new ArrayList<>();
		
		try {
			connection = DriverManager.getConnection(connectionUrl);
			
			String storedProcedureQuery = "{CALL dbo.ListarEmpleados(?)}";
			callableStatement = connection.prepareCall(storedProcedureQuery);
			
			callableStatement.registerOutParameter(1, Types.INTEGER);
			
			callableStatement.execute();
			callableStatement.getMoreResults();
			ResultSet resultSet = callableStatement.getResultSet();
			
			while (resultSet.next()) {
				
				String docId = resultSet.getString(1);
				String nombre = resultSet.getString(2);
			
				listaEmpleados.add( new Empleado(docId, nombre, 0) );
			}
			
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
                if (callableStatement != null) {
                    callableStatement.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (Exception e) {
            	System.out.println(e);
            }
		}
		
		
		return listaEmpleados;
	}
	
}
