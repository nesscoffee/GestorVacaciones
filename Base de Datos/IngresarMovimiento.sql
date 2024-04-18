-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Ingresa un movimiento nuevo a un empleado en especifico

-- Descripion de parametros:
	-- @inCedula: valor del documento de identidad del empleado
	-- @inNombreMovimiento: nombre del nuevo movimiento
	-- @inMonto: monto del nuevo movimiento
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.IngresarMovimiento 'cedula', 'tipo', 0, @outResultCode OUTPUT

-- Notas adicionales:
-- si es debito se resta, si es credito se suma
-- dado que la cedula la provee el sistema, se asume que esta correcta
-- por tanto, no se hace revision de su formato
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.IngresarMovimiento
	@inCedula VARCHAR(64),
	@inNombreMovimiento VARCHAR(64),
	@inMonto MONEY,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- declaracion de variables:
		DECLARE @IDEmpleado INT;
		DECLARE @IDTipoMovimiento INT;
		DECLARE @IDUsername INT;
		DECLARE @descripcionError VARCHAR(128);
		DECLARE @descripcionEvento VARCHAR(512);
		DECLARE @nombre VARCHAR(64);
		DECLARE @outResultCodeEvento INT;
		DECLARE @saldo MONEY;
		DECLARE @tipoMovimiento VARCHAR(16);

		-- inicializacion de variables:
		SELECT @IDEmpleado = E.ID 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		SELECT @IDTipoMovimiento = T.ID
			FROM TipoMovimiento T
			WHERE T.Nombre = @inNombreMovimiento;

		SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);

		SET @outResultCode = 0;

		SELECT @nombre = E.Nombre 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		SELECT @saldo = E.SaldoVacaciones 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		SELECT @tipoMovimiento = T.TipoAccion
			FROM TipoMovimiento T
			WHERE T.Nombre = @inNombreMovimiento;

		-- validacion de datos:
		-- monto no deberia ser negativo
		-- la suma o resta se aplica segun el tipo del movimiento
		IF (@inMonto < 0)
		BEGIN
			SET @outResultCode = 50014;
		END;

		-- calculo del nuevo monto:
		SET @saldo = CASE
			WHEN @tipoMovimiento = 'Credito' 
				THEN @saldo + @inMonto
			WHEN @tipoMovimiento = 'Debito' 
				THEN @saldo - @inMonto
			END;

		-- validacion de que el monto no sea "muy" negativo:
		IF @outResultCode = 0 AND @saldo <= -30
		BEGIN
			SET @outResultCode = 50011;
			SELECT @descripcionError = Descripcion 
				FROM Error E 
				WHERE E.Codigo = @outResultCode;

			SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, ', cedula: ', @inCedula, ', nombre: ',
				@nombre, ', saldo: ', @saldo - @inMonto, ', movimiento: ', @inNombreMovimiento, ', monto: ', @inMonto));

			EXEC dbo.IngresarEvento 'Intento de insertar movimiento', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END;

		-- aplicacion del movimiento si saldo no es muy negativo:
		IF @outResultCode = 0
		BEGIN
			UPDATE Empleado
			SET SaldoVacaciones = @saldo
			WHERE ValorDocumentoIdentidad = @inCedula;

			INSERT Movimiento (IDEmpleado, IDTipoMovimiento, Fecha, Monto, NuevoSaldo, IDPostByUser, PostInIP, PostTime)
			VALUES (@IDEmpleado, @IDTipoMovimiento, CAST(GETDATE() AS DATE), @inMonto, @saldo, @IDUsername, HOST_NAME(), GETDATE())

			SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula, ', nombre: ', @nombre, ', saldo: '
				, @saldo - @inMonto, ', movimiento: ', @inNombreMovimiento, ', monto: ', @inMonto));
				
			EXEC dbo.IngresarEvento 'Insertar movimiento exitoso', @IDUsername, @descripcionEvento, @outResultCodeEvento OUTPUT;
		END;

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