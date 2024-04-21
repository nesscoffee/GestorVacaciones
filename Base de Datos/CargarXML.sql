-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Script:
-- REALIZA LA LECTURA DEL ARCHIVO XML

-- Notas adicionales:
-- el archivo se tiene de forma local en una de las computadoras
-- se lee y se mapea la informacion hacia las tablas correspondientes

-- DECLARAR VARIABLES:

DECLARE @xmlData XML

-- ------------------------------------------------------------- --
-- INICIALIZAR VARIABLES:

SELECT @xmlData = X
FROM OPENROWSET (BULK 'C:\Users\Stephanie\Documents\SQL Server Management Studio\datos.xml', SINGLE_BLOB) AS xmlfile(X)

-- preparar el archivo xml:
DECLARE @value int
EXEC sp_xml_preparedocument @value OUTPUT, @xmlData

-- ------------------------------------------------------------- --
-- CARGAR DATOS:

-- ingresar informacion de la seccion Puestos en la tabla Puesto:
INSERT INTO Puesto (Nombre
	, SalarioxHora)
SELECT Nombre
	 , SalarioxHora
FROM OPENXML (@value, '/Datos/Puestos/Puesto' , 1)
WITH (
    Nombre VARCHAR(64)
	, SalarioxHora MONEY
)

-- ingresar informacion de la seccion TiposEvento en la tabla TipoEvento:
INSERT INTO TipoEvento (ID
	, Nombre)
SELECT Id
	 , Nombre
FROM OPENXML (@value, '/Datos/TiposEvento/TipoEvento' , 1)
WITH (
	Id INT
	, Nombre VARCHAR(64)
)

-- ingresar informacion de la seccion TiposMovimiento en la tabla TipoMovimiento:
INSERT INTO TipoMovimiento (ID
	, Nombre
	, TipoAccion)
SELECT Id
	, Nombre
	, TipoAccion
FROM OPENXML (@value, '/Datos/TiposMovimientos/TipoMovimiento' , 1)
WITH (
	Id INT
	, Nombre VARCHAR(64)
	, TipoAccion VARCHAR(64)
)

-- ingresar informacion de la seccion Empleados en la tabla Empleado:
INSERT INTO Empleado (IDPuesto
	, ValorDocumentoIdentidad
	, Nombre
	, FechaContratacion
	, SaldoVacaciones
	, EsActivo)
SELECT P.Id AS IDPuesto
    , E.empleado.value('@ValorDocumentoIdentidad', 'int') AS ValorDocumentoIdentidad
    , E.empleado.value('@Nombre', 'varchar(64)') AS Nombre
    , E.empleado.value('@FechaContratacion', 'date') AS FechaContratacion
    , 0 AS SaldoVacaciones
    , 1 AS EsActivo
FROM @xmlData.nodes('/Datos/Empleados/empleado') AS E(empleado)
JOIN Puesto AS P ON E.empleado.value('@Puesto', 'varchar(64)') = P.Nombre                      -- mapeo de informacion con Puesto

-- ingresar informacion de la seccion Usuarios en la tabla Usuario:
INSERT INTO Usuario (ID
	, Username
	, Password)
SELECT Id
	, Nombre
	, Pass
FROM OPENXML (@value, '/Datos/Usuarios/usuario' , 1)
WITH (
    Id INT
    , Nombre VARCHAR(64)
    , Pass VARCHAR(64)
)

-- ingresar informacion de la seccion de Movimientos en la tabla Movimiento:
-- crear tabla variable para registrar los datos originales:
DECLARE @MovimientoData TABLE (
	ID INT IDENTITY(1,1) PRIMARY KEY
    , inCedula VARCHAR(64)
    , inNombreMovimiento VARCHAR(64)
    , inFecha DATE
    , inMonto MONEY
    , inUsername VARCHAR(64)
    , inIP VARCHAR(64)
    , inTime DATETIME
);

-- llenar la tabla con los datos
INSERT INTO @MovimientoData (inCedula
	, inNombreMovimiento
	, inFecha
	, inMonto
	, inUsername
	, inIP
	, inTime)
SELECT M.movimiento.value('@ValorDocId', 'VARCHAR(64)')
    , M.movimiento.value('@IdTipoMovimiento', 'VARCHAR(64)')
    , M.movimiento.value('@Fecha', 'DATE')
    , M.movimiento.value('@Monto', 'MONEY')
    , M.movimiento.value('@PostByUser', 'VARCHAR(64)')
    , M.movimiento.value('@PostInIP', 'VARCHAR(64)')
    , M.movimiento.value('@PostTime', 'DATETIME')
FROM @xmlData.nodes('/Datos/Movimientos/movimiento') AS M(movimiento)
ORDER BY M.movimiento.value('@PostTime', 'DATETIME');

-- llamar al sp encargado de agregar un movimiento nuevo (se encarga de mapear correctamente)
DECLARE @outResultCode INT;
DECLARE @rowCount INT = (SELECT COUNT(1) FROM @MovimientoData);
DECLARE @index INT = 1;

WHILE @index <= @rowCount
BEGIN
    DECLARE @inCedula VARCHAR(64);
    DECLARE @inNombreMovimiento VARCHAR(64);
    DECLARE @inFecha DATE;
    DECLARE @inMonto MONEY;
    DECLARE @inUsername VARCHAR(64);
    DECLARE @inIP VARCHAR(64);
    DECLARE @inTime DATETIME;

    SELECT TOP 1 @inCedula = inCedula
        , @inNombreMovimiento = inNombreMovimiento
        , @inFecha = inFecha
        , @inMonto = inMonto
        , @inUsername = inUsername
        , @inIP = inIP
        , @inTime = inTime
    FROM @MovimientoData
    WHERE ID = @index;

    EXEC dbo.IngresarMovimientoXML @inCedula, @inNombreMovimiento, @inFecha, 
        @inMonto, @inUsername, @inIP, @inTime, @outResultCode OUTPUT;

    SET @index = @index + 1;
END;

-- ingresar la informacion de la seccion Error en la tabla Error:
INSERT INTO Error (Codigo
	, Descripcion)
SELECT Codigo
	, Descripcion
FROM OPENXML (@value, '/Datos/Error/error' , 1)
WITH (
	Codigo INT
	, Descripcion VARCHAR(128)
)

-- ------------------------------------------------------------- ---- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- FINALIZAR CARGA:

EXEC sp_xml_removedocument @value