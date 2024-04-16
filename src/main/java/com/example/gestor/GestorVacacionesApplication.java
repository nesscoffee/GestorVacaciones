package com.example.gestor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.example.gestor.database.SQLDatabaseConnection;

@SpringBootApplication
public class GestorVacacionesApplication {

	public static void main(String[] args) {
		SpringApplication.run(GestorVacacionesApplication.class, args);
		/*
		 * SQLDatabaseConnection connection = SQLDatabaseConnection.getInstance(); int
		 * inicioSesion = connection.loginHandler("UsuarioScripts", "UsuarioScripts");
		 * System.out.println(inicioSesion);
		 */
	}

}
