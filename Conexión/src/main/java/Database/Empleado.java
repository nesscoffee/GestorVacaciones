// Armando Castro, Stephanie Sandoval | Abr 17. 24
// Tarea Programada 02 | Base de Datos I

/* CLASE EMPLEADO
 * Guarda informacion relacionada con los empleados
 * Almacena: cedula, nombre, puesto y saldo
 */

package Database;

public class Empleado {
		
	private String cedula, nombre, puesto;
	private float saldo;
		
	/* ------------------------------------------------------------ */
	// CONSTRUCTOR DE LA CLASE

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
		
	/* ------------------------------------------------------------ */
	// GETTERS Y SETTERS

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
		
	/* ------------------------------------------------------------ */
	// METODOS TO STRING
		
	public String toStringShort (){
		return "Empleado: " + this.nombre + " - ID: " + this.cedula;
	}

	public String toStringLong (){
		return "Empleado: " + this.nombre + " - ID: " + this.cedula 
			+ " - Puesto: " + this.puesto + " - Saldo: " + this.saldo;
	}
}