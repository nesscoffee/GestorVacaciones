-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Actualiza un empleado existente

-- Descripion de parametros:
	-- @inCedulaOriginal: valor del documento de identidad del empleado antes de la actualizacion 
	-- @inCedulaNueva: nuevo valor para el documento de identidad del empleado
	-- @inNombreOriginal: nombre del empleado antes de la actualizacion
	-- @inNombreNuevo: nuevo valor para el nombre del empleado
	-- @inPuesto: puesto del empleado (string no int)
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ActualizarEmpleado 'cedula', 'nombre', 'puesto', @outResultCode OUTPUT

-- Notas adicionales:
-- si alguno de los espacios viene en blanco, se mantiene la informacion previa
-- no se permite actualizar si el nombre o la cedula ya existen
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.ActualizarEmpleado
	@inCedulaOriginal VARCHAR(64),
	@inCedulaNueva VARCHAR(64),
	@inNombreOriginal VARCHAR(64),
	@inNombreNuevo VARCHAR(64),
	@inPuestoNuevo VARCHAR(64),
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	-- declaracion de variables:
	DECLARE @IDPuestoNuevo INT;
	DECLARE @IDPuestoOriginal INT;
	DECLARE @IDUsername INT;
	DECLARE @outResultCodeEvento INT;
	DECLARE @descripcionEvento VARCHAR(512);
	DECLARE @descripcionError VARCHAR(128);
	DECLARE @puestoOriginal VARCHAR(64);


	-- inicializacion de variables:
	SET @outResultCode = 0;
	SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);

	-- buscar el ID del puesto con base en el nombre:
	SELECT @IDPuestoNuevo = ID FROM Puesto P WHERE P.Nombre = @inPuestoNuevo;

	-- buscar el puesto original del empleado:
	SET @puestoOriginal = (SELECT P.Nombre FROM Empleado E 
		INNER JOIN Puesto P ON E.IDPuesto = P.ID 
		WHERE E.Nombre = @inNombreOriginal);

	-- buscar el ID del puesto original:
	SELECT @IDPuestoOriginal = ID FROM Puesto P WHERE P.Nombre = @puestoOriginal;

	SET @inCedulaNueva = LTRIM(RTRIM(@inCedulaNueva));
	SET @inNombreNuevo = LTRIM(RTRIM(@inNombreNuevo));

	-- validacion de datos:
	-- nombre nuevo no contiene solo letras o espacios en blanco:
	IF (PATINDEX('%[^a-zA-Z ]%', @inNombreNuevo) != 0 AND LEN(@inNombreNuevo) > 0)
	BEGIN
		SET @outResultCode = 50009;
		SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
		SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula original: ', @inCedulaOriginal, 
			', nombre original: ', @inNombreOriginal, ', puesto original: ', @puestoOriginal, ', cedula nueva: ',
			@inCedulaNueva, ', nombre nuevo: ', @inNombreNuevo, ', puesto nuevo: ', @inPuestoNuevo));
		EXEC dbo.IngresarEvento 'Update no exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
	END

	-- cedula nueva no contiene solo numeros:
	IF LEN(@inCedulaNueva) > 0 AND ISNUMERIC(@inCedulaNueva) != 1
	BEGIN
		SET @outResultCode = 50010;
		SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
		SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula original: ', @inCedulaOriginal, 
			', nombre original: ', @inNombreOriginal, ', puesto original: ', @puestoOriginal, ', cedula nueva: ',
			@inCedulaNueva, ', nombre nuevo: ', @inNombreNuevo, ', puesto nuevo: ', @inPuestoNuevo));
		EXEC dbo.IngresarEvento 'Update no exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
	END

	-- revision de duplicados:
	-- existe algun empledo con el mismo nombre con el que se quiere actualizar:
	IF @outResultCode = 0 AND (@inNombreNuevo != @inNombreOriginal AND LEN(@inNombreNuevo) != 0)
	BEGIN
		IF EXISTS (SELECT 1 FROM Empleado E WHERE E.Nombre = @inNombreNuevo)
		BEGIN
			SET @outResultCode = 50007;
			SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
			SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula original: ', @inCedulaOriginal, 
				', nombre original: ', @inNombreOriginal, ', puesto original: ', @puestoOriginal, ', cedula nueva: ',
				@inCedulaNueva, ', nombre nuevo: ', @inNombreNuevo, ', puesto nuevo: ', @inPuestoNuevo));
			EXEC dbo.IngresarEvento 'Update no exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END
	END

	-- existe algun empleado con la misma cedula con la que se quiere actualizar:
	IF @outResultCode = 0 AND (@inCedulaNueva != @inCedulaOriginal OR LEN(@inCedulaNueva) != 0)
	BEGIN
		IF EXISTS (SELECT 1 FROM Empleado E WHERE E.ValorDocumentoIdentidad = @inCedulaNueva)
		BEGIN
			SET @outResultCode = 50006;
			SELECT @descripcionError = Descripcion FROM Error E WHERE E.Codigo = @outResultCode;
			SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula original: ', @inCedulaOriginal, 
				', nombre original: ', @inNombreOriginal, ', puesto original: ', @puestoOriginal, ', cedula nueva: ',
				@inCedulaNueva, ', nombre nuevo: ', @inNombreNuevo, ', puesto nuevo: ', @inPuestoNuevo));
			EXEC dbo.IngresarEvento 'Update no exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END
	END

	-- actualizacion del empleado:
	-- (en caso de que no existan duplicados)
	IF @outResultCode = 0
	BEGIN
		IF LEN(@inNombreNuevo) = 0
		BEGIN
			SET @inNombreNuevo = @inNombreOriginal;
		END

		IF LEN(@inCedulaNueva) = 0
		BEGIN
			SET @inCedulaNueva = @inCedulaOriginal;
		END
		UPDATE Empleado
		SET Nombre = @inNombreNuevo, ValorDocumentoIdentidad = @inCedulaNueva, IDPuesto = @IDPuestoNuevo
		WHERE Nombre = @inNombreOriginal AND ValorDocumentoIdentidad = @inCedulaOriginal AND IDPuesto = @IDPuestoOriginal;
		SET @descripcionEvento = (SELECT CONCAT('cedula original: ', @inCedulaOriginal, ', nombre original: '
			, @inNombreOriginal, ', puesto original: ', @puestoOriginal, ', cedula nueva: ', @inCedulaNueva,
			', nombre nuevo: ', @inNombreNuevo, ', puesto nuevo: ', @inPuestoNuevo));
		EXEC dbo.IngresarEvento 'Update exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
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