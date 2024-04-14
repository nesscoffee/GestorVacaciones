-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Script para la lectura del archivo XML
-- El archivo se tiene de forma local en una de las computadoras
-- Se lee y se mapea la informacion hacia las tablas correspondientes

-- Declaracion de variable para almacenar el xml
DECLARE @xmlData XML

-- Carga del xml en la variable creada
SELECT @xmlData = X
FROM OPENROWSET (BULK 'C:\Users\Stephanie\Documents\SQL Server Management Studio\datos.xml', SINGLE_BLOB) AS xmlfile(X)

-- Preparar el archivo xml
DECLARE @value int
EXEC sp_xml_preparedocument @value OUTPUT, @xmlData

-- Ingresar informacion de la seccion Puestos en la tabla Puesto
INSERT INTO Puesto (Nombre, SalarioxHora)
SELECT Nombre, SalarioxHora
FROM OPENXML (@value, '/Datos/Puestos/Puesto' , 1)
WITH (
    Nombre VARCHAR(64),
    SalarioxHora MONEY
)

-- Ingresar informacion de la seccion TiposEvento en la tabla TipoEvento
INSERT INTO TipoEvento (ID, Nombre)
SELECT Id, Nombre
FROM OPENXML (@value, '/Datos/TiposEvento/TipoEvento' , 1)
WITH (
	Id INT,
	Nombre VARCHAR(64)
)

-- Ingresar informacion de la seccion TiposMovimiento en la tabla TipoMovimiento
INSERT INTO TipoMovimiento (ID, Nombre, TipoAccion)
SELECT Id, Nombre, TipoAccion
FROM OPENXML (@value, '/Datos/TiposMovimientos/TipoMovimiento' , 1)
WITH (
	Id INT,
	Nombre VARCHAR(64),
	TipoAccion VARCHAR(64)
)

-- Ingresar informacion de la seccion Empleados en la tabla Empleado
INSERT INTO Empleado (IDPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, EsActivo)
SELECT
    P.Id AS IDPuesto,
    E.empleado.value('@ValorDocumentoIdentidad', 'int') AS ValorDocumentoIdentidad,
    E.empleado.value('@Nombre', 'varchar(64)') AS Nombre,
    E.empleado.value('@FechaContratacion', 'date') AS FechaContratacion,
    0 AS SaldoVacaciones, -- Hardcoded value for SaldoVacaciones
    1 AS EsActivo -- Hardcoded value for EsActivo
FROM @xmlData.nodes('/Datos/Empleados/empleado') AS E(empleado)
JOIN Puesto AS P ON E.empleado.value('@Puesto', 'varchar(64)') = P.Nombre                      -- Mapeo de informacion con Puesto

-- Inresar informacion de la seccion Usuarios en la tabla Usuario
INSERT INTO Usuario (ID, Username, Password)
SELECT Id, Nombre, Pass
FROM OPENXML (@value, '/Datos/Usuarios/usuario' , 1)
WITH (
    Id INT,
    Nombre VARCHAR(64),
    Pass VARCHAR(64)
)

-- Ingresar informacion de la seccion Movimientos en la tabla Movimiento
INSERT INTO Movimiento (IDEmpleado, IDTipoMovimiento, Fecha, Monto, NuevoSaldo, IDPostByUser, PostInIP, PostTime)
SELECT
    E.Id AS IDEmpleado,
    T.Id AS IDTipoMovimiento,
    M.movimiento.value('@Fecha', 'DATE') AS Fecha,
    M.movimiento.value('@Monto', 'MONEY') AS Monto,
    0 AS NuevoSaldo,
    U.ID AS IDPostByUser,
    M.movimiento.value('@PostInIP', 'VARCHAR(64)') AS PostInIP,
    M.movimiento.value('@PostTime', 'VARCHAR(64)') AS PostTime
FROM @xmlData.nodes('/Datos/Movimientos/movimiento') AS M(movimiento)
JOIN Empleado AS E ON M.movimiento.value('@ValorDocId', 'INT') = E.ValorDocumentoIdentidad     -- Mapeo de informacion con Empleado
JOIN TipoMovimiento AS T ON M.movimiento.value('@IdTipoMovimiento', 'VARCHAR(64)') = T.Nombre  -- Mapeo de informacion con TipoMovimiento
JOIN Usuario AS U ON M.movimiento.value('@PostByUser', 'VARCHAR(64)') = U.Username             -- Mapeo de informacion con Usuario

-- Ingresar la informacion de la seccion Error en la tabla Error
INSERT INTO Error (Codigo, Descripcion)
SELECT Codigo, Descripcion
FROM OPENXML (@value, '/Datos/Error/error' , 1)
WITH (
	Codigo INT,
	Descripcion VARCHAR(128)
)

-- Cerrar documento xml
EXEC sp_xml_removedocument @value