package com.example.gestor.controllers;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.gestor.database.DatabaseRepository;
import com.example.gestor.database.Empleado;
import com.example.gestor.database.EmpleadoRepository;
import com.example.gestor.database.MovimientoRepository;
import com.example.gestor.database.Result;

@RestController
@RequestMapping("/api")
public class ApiController {
	
	DatabaseRepository dbrep;
	EmpleadoRepository emrep;
	MovimientoRepository movrep;
	Result result;
	
	@PostMapping("/iniciarSesion")
	public int iniciarSesion(@RequestBody String data) {
		JSONObject res = new JSONObject(data);
		String username = res.getString("username");
		String password = res.getString("password");
		dbrep = DatabaseRepository.getInstance();
		result = dbrep.login(username, password, "25.55.155.63");
		return result.getResultCodes().get(1);
	}
	
	@GetMapping("/logout")
	public int logout() {
		dbrep = DatabaseRepository.getInstance();
		result = dbrep.logout();
		return result.getResultCodes().get(0);
	}
	
	@GetMapping("/getListaEmpleados")
	public ArrayList<Object> getListaEmpleados() {
		emrep = EmpleadoRepository.getInstance();
		result = emrep.listarEmpleados();
		return result.getDataset();
	}
	
	@PostMapping("/getListaEmpleadosFiltro")
	public ArrayList<Object> getListaEmpleadosFiltro(@RequestBody String data) {
		emrep = EmpleadoRepository.getInstance();
		String parametro = new JSONObject(data).getString("parametroBusqueda");
		result = emrep.filtrarEmpleados(parametro);
		return result.getDataset();
	}
	
	@PostMapping("/getInfoEmpleado")
	public Object getInfoEmpleado(@RequestBody String data) {
		emrep = EmpleadoRepository.getInstance();
		String cedula = new JSONObject(data).getString("cedula");
		result = emrep.consultarEmpleado(cedula);
		return result.getDataset();
	}

	@PostMapping("/borrarEmpleado")
	public int borrarEmpleado(@RequestBody String data) {
		emrep = EmpleadoRepository.getInstance();
		String cedula = new JSONObject(data).getString("cedula");
		result = emrep.borrarEmpleado(cedula, true);
		return result.getResultCodes().get(0);
	}
	
	@PostMapping("/actualizarEmpleado")
	public int actualizarEmpleado(@RequestBody String data) {
		emrep = EmpleadoRepository.getInstance();
		JSONObject objeto = new JSONObject(data);
		String oldCedula = objeto.getString("oldDocId");
		String cedula = objeto.getString("docId");
		String nombre = objeto.getString("nombre");
		String idPuesto = objeto.getString("idPuesto");
		result = emrep.actualizarEmpleado(oldCedula, cedula, nombre, idPuesto);
		return result.getResultCodes().get(0);
	}
	
	@PostMapping("/getListaMovimientos")
	public ArrayList<Object> getListaMovimientos(@RequestBody String data) {
		movrep = MovimientoRepository.getInstance();
		String cedula = new JSONObject(data).getString("cedula");
		result = movrep.listarMovimientos(cedula);
		return result.getDataset();
	}
	
	@PostMapping("/insertarEmpleado")
	public int insertarEmpleado(@RequestBody String data) {
		emrep = EmpleadoRepository.getInstance();
		JSONObject objeto = new JSONObject(data);
		String cedula = objeto.getString("docId");
		String nombre = objeto.getString("nombre");
		String idPuesto = objeto.getString("idPuesto");
		result = emrep.agregarEmpleado(cedula, nombre, idPuesto);
		return result.getResultCodes().get(0);
	}
	
	@PostMapping("/insertarMovimiento")
	public int insertarMovimiento(@RequestBody String data) {
		movrep = MovimientoRepository.getInstance();
		JSONObject objeto = new JSONObject(data);
		String cedula = objeto.getString("cedula");
		String tipoMovimiento = objeto.getString("tipoMovimiento");
		Float monto = objeto.getFloat("montoFloat");
		result = movrep.agregarMovimiento(cedula, tipoMovimiento, monto);
		return result.getResultCodes().get(0);
	}
}
