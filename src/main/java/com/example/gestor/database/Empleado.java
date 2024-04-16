package com.example.gestor.database;

public class Empleado {
	
	private int id;
	private String valorDocumentoIdentidad;
	private String nombre;
	private float saldoVacaciones;
	
	public Empleado(int pId, String pDocId, String pNombre, float pSaldoVacaciones) {
		id = pId;
		valorDocumentoIdentidad = pDocId;
		nombre = pNombre;
		saldoVacaciones = pSaldoVacaciones;
	}
	
	public Empleado(String pDocId, String pNombre, float pSaldoVacaciones) {
		valorDocumentoIdentidad = pDocId;
		nombre = pNombre;
		saldoVacaciones = pSaldoVacaciones;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getValorDocumentoIdentidad() {
		return valorDocumentoIdentidad;
	}

	public void setValorDocumentoIdentidad(String valorDocumentoIdentidad) {
		this.valorDocumentoIdentidad = valorDocumentoIdentidad;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	public float getSaldoVacaciones() {
		return saldoVacaciones;
	}

	public void setSaldoVacaciones(float saldoVacaciones) {
		this.saldoVacaciones = saldoVacaciones;
	}
	
}
