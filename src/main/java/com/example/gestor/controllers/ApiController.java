package com.example.gestor.controllers;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.gestor.database.Empleado;
import com.example.gestor.database.SQLDatabaseConnection;

@RestController
@RequestMapping("/api")
public class ApiController {
	
	private SQLDatabaseConnection connection;
	
	@PostMapping("/iniciarSesion")
	public int iniciarSesion(@RequestBody String data) {
		connection = SQLDatabaseConnection.getInstance();
		JSONObject res = new JSONObject(data);
		String username = res.getString("username");
		String password = res.getString("password");
		int resultCode = connection.loginHandler(username, password);
		return resultCode;
	}
	
	@GetMapping("/getListaEmpleados")
	public List<Empleado> getListaEmpleados() {
		connection = SQLDatabaseConnection.getInstance();
		ArrayList<Empleado> employeeList = new ArrayList<>();
		employeeList = connection.listaEmpleados();
		return employeeList;
	}

}
