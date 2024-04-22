package com.example.gestor.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping(method = { RequestMethod.GET })
public class MainController {

    @GetMapping("/listaEmpleados")
    public String test() {
    	return "forward:/";
    }
	
}
