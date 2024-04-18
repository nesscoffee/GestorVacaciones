-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Borra un empleado de la base (borrado logico)

-- Descripion de parametros:
	-- @inCedula: valor del documento de identificacion del empleado que se desea borrar
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

ALTER PROCEDURE dbo.BorrarEmpleado
	@inCedula INT,
	@inConfirmado BIT,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		DECLARE @nombre VARCHAR(64);
		DECLARE @puesto VARCHAR(64);
		DECLARE @saldo MONEY;
		DECLARE @IDUsername INT;
		DECLARE @outResultCodeEvento INT;
		DECLARE @descripcionEvento VARCHAR(512);

		-- --------------------------------------------------------------- --

		-- INICIALIZAR VARIABLES:
		SET @outResultCode = 0;

		-- buscar el id usuario que esta activo:
		SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);

		-- buscar el nombre del empleado que se desea borrar:
		SELECT @nombre = E.Nombre 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedula;
		
		-- buscar el puesto del empleado que se desea borrar:
		SET @puesto = (SELECT P.Nombre 
			FROM Empleado E
			INNER JOIN Puesto P ON E.IDPuesto = P.ID
			WHERE E.Nombre = @nombre);

		-- buscar el saldo de vacaciones actual del empleado:
		SELECT @saldo = SaldoVacaciones 
			FROM Empleado E 
			WHERE E.Nombre = @nombre;

		-- --------------------------------------------------------------- --
		
		-- BORRAR EMPLEADO:
		-- cuando el borrado se confirma:
		IF @inConfirmado = 1
		BEGIN
			UPDATE Empleado
			SET EsActivo = 0 
				WHERE ValorDocumentoIdentidad = @inCedula;

			SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula, ', nombre: ', @nombre, 
			', puesto: ', @puesto, ', saldo vacaciones: ', @saldo));

			EXEC dbo.IngresarEvento 'Borrado exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END
			
		-- cuando el borrado no se confirma:
		ELSE
		BEGIN
			SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula, ', nombre: ', @nombre, 
			', puesto: ', @puesto, ', saldo vacaciones: ', @saldo));

			EXEC dbo.IngresarEvento 'Intento de borrado', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END

		-- --------------------------------------------------------------- --

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

		SET @outResultCode = 50008;

	END CATCH;
	SET NOCOUNT OFF;
END;