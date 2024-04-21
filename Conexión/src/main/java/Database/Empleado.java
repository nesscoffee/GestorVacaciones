package Database;

public class Empleado {
	
	private String cedula, nombre, puesto;
	private float saldo;

	public Empleado (String cedula, String nombre) {
		this.cedula = cedula;
		this.nombre = nombre;
	}
	
	public Empleado(String cedula, String nombre, String puesto, float saldo) {
		this.cedula = cedula;
		this.nombre = nombre;
		this.puesto = puesto;
		this.saldo = saldo;
	}

	public String getCedula () {
		return cedula;
	}

	public void setCedula (String cedula) {
		this.cedula = cedula;
	}

	public String getNombre() {
		return this.nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	public String getPuesto() {
		return this.puesto;
	}

	public void setPuesto(String puesto) {
		this.puesto = puesto;
	}

	public float getSaldo() {
		return this.saldo;
	}

	public void setSaldo (float saldo) {
		this.saldo = saldo;
	}
	
	public String toStringShort (){
		return "Empleado: " + this.nombre + " - ID: " + this.cedula;
	}

	public String toStringLong (){
		return "Empleado: " + this.nombre + " - ID: " + this.cedula 
			+ " - Puesto: " + this.puesto + " - Saldo: " + this.saldo;
	}
}