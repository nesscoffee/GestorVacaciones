-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Ingresa un empleado nuevo a la tabla correspondiente

-- Descripion de parametros:
	-- @inCedula: valor del documento de identidad del empleado
	-- @inNombre: nombre del empleado
	-- @inPuesto: puesto del empleado (string no int)
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.IngresarEmpleado 'cedula', 'nombre', 'puesto', @outResultCode OUTPUT

-- Notas adicionales:
-- se verifica que no existan duplicados (misma cedula o nombre)
-- la cedula solo puede contener valores numericos
-- el nombre puede contener letras o espacios en blanco (se acepta que sean solo espacios)
-- el puesto se da como string, dentro del sp se mapea el id
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.IngresarEmpleado
	@inCedula VARCHAR(64),
	@inNombre VARCHAR(64),
	@inPuesto VARCHAR(64),
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	-- declaracion de variables:
	DECLARE @IDPuesto INT;
	DECLARE @IDUsername INT;
	DECLARE @outResultCodeEvento INT;             -- para insertar eventos en la bitacora
	DECLARE @descripcionEvento VARCHAR(512);
	DECLARE @descripcionError VARCHAR(128);

	-- inicializacion de variables:
	SET @outResultCode = 0;
	SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);

	-- buscar el ID del puesto con base en el nombre:
	SELECT @IDPuesto = ID FROM Puesto P WHERE P.Nombre = @inPuesto;

	-- validacion de datos:
	-- nombre no contiene solo letras o espacios en blanco:
	IF (PATINDEX('%[^a-zA-Z ]%', @inNombre) != 0 OR LEN(@inNombre) <= 0)
	BEGIN
		SET @outResultCode = 50009;
		SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
		SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula: ', @inCedula, ', nombre: ', @inNombre, ', puesto: ', @inPuesto));
		EXEC dbo.IngresarEvento 'Insercion no exitosa', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
	END

	-- cedula no contiene solo numeros:
	IF ISNUMERIC(@inCedula) != 1
	BEGIN
		SET @outResultCode = 50010;
		SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
		SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula: ', @inCedula, ', nombre: ', @inNombre, ', puesto: ', @inPuesto));
		EXEC dbo.IngresarEvento 'Insercion no exitosa', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
	END

	-- revision de duplicados:
	-- existe algun empleado con el mismo nombre:
	IF @outResultCode = 0 AND EXISTS (SELECT 1 FROM Empleado E WHERE E.Nombre = @inNombre)
	BEGIN
		SET @outResultCode = 50005;
		SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
		SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula: ', @inCedula, ', nombre: ', @inNombre, ', puesto: ', @inPuesto));
		EXEC dbo.IngresarEvento 'Insercion no exitosa', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
	END

	-- existe algun empleado con la misma cedula
	IF @outResultCode = 0 AND EXISTS (SELECT 1 FROM Empleado E WHERE E.ValorDocumentoIdentidad = @inCedula)
	BEGIN
		SET @outResultCode = 50004;
		SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
		SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula: ', @inCedula, ', nombre: ', @inNombre, ', puesto: ', @inPuesto));
		EXEC dbo.IngresarEvento 'Insercion no exitosa', @IDUsername, ' ', @outResultCodeEvento OUTPUT;
	END

	-- insercion del empleado:
	-- (en caso de que no existan duplicados)
	IF @outResultCode = 0
	BEGIN
		INSERT Empleado (IDPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, EsActivo)
		VALUES (@IDPuesto, @inCedula, @inNombre, GETDATE(), 0, 1);
		SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula, ', nombre: ', @inNombre, ', puesto: ', @inPuesto));
		EXEC dbo.IngresarEvento 'Insercion exitosa', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
	END

	SELECT @outResultCode AS outResultCode;
	END TRY
	
	BEGIN CATCH
		INSERT INTO DBError VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);

		SET @outResultCode = 50008;           -- error: problema base de datos

	END CATCH;
	SET NOCOUNT OFF;
END;