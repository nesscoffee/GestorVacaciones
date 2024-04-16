package com.example.gestor.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    @GetMapping("/listaEmpleados")
    public String test() {
    	return "forward:/";
    }
	
}
