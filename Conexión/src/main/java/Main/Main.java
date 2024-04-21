package Main;

import Database.DatabaseRepository;
import Database.Empleado;
import Database.EmpleadoRepository;
import Database.Movimiento;
import Database.MovimientoRepository;
import Database.Result;

public class Main {
    public static void main(String[] args) {
        DatabaseRepository dbrepo = DatabaseRepository.getInstance();
        EmpleadoRepository emrepo = EmpleadoRepository.getInstance();
        MovimientoRepository movrepo = MovimientoRepository.getInstance();
        Result result;
        
         result = dbrepo.login("UsuarioScripts", "UsuarioScripts");
        for (int code : result.getResultCodes()){
            System.out.println("Login: " + code);
            if (code != 0){
                String description = (String)((dbrepo.consultarError(code)).getDataset().get(0));
                System.out.println(description);
            }
        }

        result = emrepo.agregarEmpleado("0000001", "Olaf", "Conductor");
        for (int code : result.getResultCodes()){
            System.out.println("Agregar empleado: " + code);
            if (code != 0){
                String description = (String)((dbrepo.consultarError(code)).getDataset().get(0));
                System.out.println(description);
            }
        }

        result = emrepo.actualizarEmpleado("1206827", "1206829", "", "Cajero");
        for (int code : result.getResultCodes()){
            System.out.println("Actualizar empleado: " + code);
            if (code != 0){
                String description = (String)((dbrepo.consultarError(code)).getDataset().get(0));
                System.out.println(description);
            }
        }

        result = emrepo.borrarEmpleado("0000001", true);
        for (int code : result.getResultCodes()){
            System.out.println("Borrar empleado: " + code);
            if (code != 0){
                String description = (String)((dbrepo.consultarError(code)).getDataset().get(0));
                System.out.println(description);
            }
        }

        result = emrepo.consultarEmpleado("1039590");
        if (result.getResultCodes().get(0) == 0){
            for (Object empleado : result.getDataset()){
                System.out.println(((Empleado)(empleado)).toStringLong());
            }
        }

        result = emrepo.filtrarEmpleados("6");
        int codeFiltro = result.getResultCodes().get(0);
        if (codeFiltro == 0){
            for (Object empleado : result.getDataset()){
                System.out.println(((Empleado)(empleado)).toStringShort());
            }
        } else {
            System.out.println("Code: " + codeFiltro);
            String description = (String)((dbrepo.consultarError(codeFiltro)).getDataset().get(0));
            System.out.println(description);
        }

        result = movrepo.listarMovimientos("6713229");
        int codeLista = result.getResultCodes().get(0);
        if (codeLista == 0){
            if (result.getDataset().size() == 0){
                System.out.println("sin movimientos");
            } else {
                for (Object movimiento : result.getDataset()){
                    System.out.println(((Movimiento)(movimiento)).toString());
                }
            }
        } else {
            System.out.println("Code: " + codeLista);
            String description = (String)((dbrepo.consultarError(codeLista)).getDataset().get(0));
            System.out.println(description);
        }

        result = movrepo.agregarMovimiento("1039590", "Venta de vacaciones", 3);
        for (int code : result.getResultCodes()){
            System.out.println("Agregar movimiento: " + code);
            if (code != 0){
                String description = (String)((dbrepo.consultarError(code)).getDataset().get(0));
                System.out.println(description);
            }
        }

        result = emrepo.listarEmpleados();
        if (result.getResultCodes().get(0) == 0){
            for (Object empleado : result.getDataset()){
                System.out.println(((Empleado)(empleado)).toStringShort());
            }
        }

        result = dbrepo.logout();
        for (int code : result.getResultCodes()){
            System.out.println("Logout: " + code);
        }
    }
}