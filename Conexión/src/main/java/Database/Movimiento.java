package Database;

import java.sql.Timestamp;
import java.util.Date;

public class Movimiento {
    
    private String nombreMovimiento, username, IP;
    private float monto, nuevoSaldo;
    private Date fecha;
    private Timestamp estampa;

    public Movimiento (Date fecha, String nombreMovimiento, float monto, float nuevoSaldo, String username, String IP, Timestamp estampa) {
        this.fecha = fecha;
        this.nombreMovimiento = nombreMovimiento;
        this.monto = monto;
        this.nuevoSaldo = nuevoSaldo;
        this.username = username;
        this.IP = IP;
        this.estampa = estampa;
    }

    public void setNombreMovimiento (String nombreMovimiento){
        this.nombreMovimiento = nombreMovimiento;
    }

    public String getNombreMovimiento(){
        return this.nombreMovimiento;
    }

    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getUsername() {
        return this.username;
    }
    
    public void setIP(String IP) {
        this.IP = IP;
    }
    
    public String getIP() {
        return this.IP;
    }
    
    public void setEstampa(Timestamp estampa) {
        this.estampa = estampa;
    }
    
    public Timestamp getEstampa() {
        return this.estampa;
    }
    
    public void setMonto(float monto) {
        this.monto = monto;
    }
    
    public float getMonto() {
        return this.monto;
    }
    
    public void setNuevoSaldo(float nuevoSaldo) {
        this.nuevoSaldo = nuevoSaldo;
    }
    
    public float getNuevoSaldo() {
        return this.nuevoSaldo;
    }
    
    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }
    
    public Date getFecha() {
        return this.fecha;
    }

    public String toString (){
        return fecha.toString() + " | " + nombreMovimiento + " | " + monto + " | " + nuevoSaldo + " | "
            + username + " | " + IP + " | " + estampa.toString();
    }
}