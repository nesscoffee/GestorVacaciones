-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Genera una lista de los empleados ordenados por nombre ascendente

-- Descripion de parametros:
	-- @inCedula: valor del documento de identificacion del empleado que se desea borrar
	-- @inNombre: nombre del empleado que se desea borrar
	-- @inConfirmado: 'booleano' indicando si el usuario confirmo el borrado
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.BorrarEmpleado 'cedula', @outResultCode OUTPUT

-- Notas adicionales:
-- la cedula viene por parte del sistema, no del usuario
-- por tanto, no hace falta hacer validacion de esta, se sabe que ya es correcta
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

CREATE PROCEDURE dbo.BorrarEmpleado
	@inCedula INT,
	@inNombre VARCHAR(64),
	@inConfirmado BIT,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- declaracion de variables:
		DECLARE @puesto VARCHAR(64);
		DECLARE @saldo MONEY;
		DECLARE @IDUsername INT;
		DECLARE @outResultCodeEvento INT;
		DECLARE @descripcionEvento VARCHAR(512);

		-- inicializacion de variables:
		SET @outResultCode = 0;
		SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);
		
		SET @puesto = (SELECT P.Nombre FROM Empleado E
			INNER JOIN Puesto P ON E.IDPuesto = P.ID
			WHERE E.Nombre = @inNombre);

		SELECT @saldo = SaldoVacaciones FROM Empleado E WHERE E.Nombre = @inNombre;
		
		-- borrar el empleado (borrado logico):
		IF @inConfirmado = 1
		BEGIN
			UPDATE Empleado
			SET EsActivo = 0 WHERE ValorDocumentoIdentidad = @inCedula;
			SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula, ', nombre: ', @inNombre, 
			', puesto: ', @puesto, ', saldo vacaciones: ', @saldo));
			EXEC dbo.IngresarEvento 'Borrado exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END
			
		ELSE
		BEGIN
			SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula, ', nombre: ', @inNombre, 
			', puesto: ', @puesto, ', saldo vacaciones: ', @saldo));
			EXEC dbo.IngresarEvento 'Intento de borrado', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
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