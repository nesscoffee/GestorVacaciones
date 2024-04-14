DECLARE @xmlData XML

-- Load XML data into @xmlData variable
SELECT @xmlData = P
FROM OPENROWSET (BULK 'C:\Users\Stephanie\Documents\SQL Server Management Studio\datos.xml', SINGLE_BLOB) AS puesto(P)

-- Prepare the XML document
DECLARE @value int
EXEC sp_xml_preparedocument @value OUTPUT, @xmlData

-- Insert data from Puestos section into Puesto table
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

-- Insert data from Empleados section into Empleado table
INSERT INTO Empleado (IDPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, EsActivo)
SELECT
    P.Id AS IDPuesto,
    E.empleado.value('@ValorDocumentoIdentidad', 'int') AS ValorDocumentoIdentidad,
    E.empleado.value('@Nombre', 'varchar(64)') AS Nombre,
    E.empleado.value('@FechaContratacion', 'date') AS FechaContratacion,
    0 AS SaldoVacaciones, -- Hardcoded value for SaldoVacaciones
    1 AS EsActivo -- Hardcoded value for EsActivo
FROM @xmlData.nodes('/Datos/Empleados/empleado') AS E(empleado)
JOIN Puesto AS P ON E.empleado.value('@Puesto', 'varchar(64)') = P.Nombre

-- Insert data from Usuarios section into Usuario table
INSERT INTO Usuario (ID, Username, Password)
SELECT Id, Nombre, Pass
FROM OPENXML (@value, '/Datos/Usuarios/usuario' , 1)
WITH (
    Id INT,
    Nombre VARCHAR(64),
    Pass VARCHAR(64)
)

-- Insert data from Movimientos section into Movimiento table
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
JOIN Empleado AS E ON M.movimiento.value('@ValorDocId', 'INT') = E.ValorDocumentoIdentidad
JOIN TipoMovimiento AS T ON M.movimiento.value('@IdTipoMovimiento', 'VARCHAR(64)') = T.Nombre
JOIN Usuario AS U ON M.movimiento.value('@PostByUser', 'VARCHAR(64)') = U.Username

-- Ingresar la informacion de la seccion Error en la tabla Error
INSERT INTO Error (Codigo, Descripcion)
SELECT Codigo, Descripcion
FROM OPENXML (@value, '/Datos/Error/error' , 1)
WITH (
	Codigo INT,
	Descripcion VARCHAR(128)
)

-- Clean up the XML document
EXEC sp_xml_removedocument @value

SELECT * FROM Puesto
SELECT * FROM TipoEvento
SELECT * FROM TipoMovimiento
SELECT * FROM Empleado
SELECT * FROM Usuario
SELECT * FROM Movimiento