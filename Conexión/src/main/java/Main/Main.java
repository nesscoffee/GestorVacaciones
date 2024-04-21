package Main;

import Database.DatabaseRepository;
import Database.Empleado;
import Database.EmpleadoRepository;
import Database.Result;

public class Main {
    public static void main(String[] args) {
        DatabaseRepository dbrepo = DatabaseRepository.getInstance();
        EmpleadoRepository emrepo = EmpleadoRepository.getInstance();
        Result result;
        
        result = dbrepo.login("UsuarioScripts", "UsuarioScripts");
        for (int code : result.getResultCodes()){
            System.out.println("Code: " + code);
            if (code != 0){
                String description = (String)((dbrepo.consultError(code)).getDataset().get(0));
                System.out.println(description);
            }
        }

        result = emrepo.listEmployees();
        if (result.getResultCodes().get(0) == 0){
            for (Object empleado : result.getDataset()){
                System.out.println(((Empleado)(empleado)).toString());
            }
        }

        result = dbrepo.logout();
        for (int code : result.getResultCodes()){
            System.out.println("Code: " + code);
        }
    }
}