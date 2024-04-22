//Armando Castro, Stephanie Sandoval | Abr 17. 24
//Tarea Programada 02 | Base de Datos I

/* CLASE RESULTADO
* Se utiliza para retornar los resultados de los sp de la BD
* Tiene dos atributos: codigos de resultado y filas de un dataset
*/

/* Notas adicionales:
* Todos los sp devuelven como maximo un dataset, por eso Result solo guarda uno
* En cambio, los sp pueden devolver mas de un codigo de resultado, por eso el arreglo
*/

package com.example.gestor.database;

import java.util.ArrayList;

public class Result {
 
 private ArrayList<Integer> resultCodes;
 private ArrayList<Object> dataset;
     
 /* ------------------------------------------------------------ */
 // CONSTRUCTOR DE LA CLASE

 public Result (){
     resultCodes = new ArrayList<>();
     dataset = new ArrayList<>();
 }
     
 /* ------------------------------------------------------------ */
 // MODIFICAR ESTRUCTURAS
 // metodos para agregar codigo de resultado y item de un dataset

 public void addCode (int resultCode){
     resultCodes.add(resultCode);
 }

 public void addDatasetItem (Object item){
     dataset.add(item);
 }
     
 /* ------------------------------------------------------------ */
 // GETTERS

 public ArrayList<Integer> getResultCodes (){
     return this.resultCodes;
 }

 public ArrayList<Object> getDataset (){
     return this.dataset;
 }
}