-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Ingresa un movimiento nuevo durante carga del XML

-- Descripion de parametros:
	-- @inCedula: valor del documento de identidad del empleado
	-- @inNombreMovimiento: nombre del nuevo movimiento

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.IngresarMovimiento 'cedula', 'tipo', 0, @outResultCode OUTPUT

-- Notas adicionales:
-- si es debito se resta, si es credito se suma
-- dado que la cedula la provee el sistema, se asume que esta correcta
-- por tanto, no se hace revision de su formato
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

CREATE PROCEDURE dbo.IngresarMovimientoXML
	@inCedula VARCHAR(64),
	@inNombreMovimiento VARCHAR(64),
	@inFecha DATE,
	@inMonto MONEY,
	@inUsername VARCHAR(64),
	@inIP VARCHAR(64),
	@inTime DATETIME,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- declaracion de variables:
		DECLARE @IDEmpleado INT;
		DECLARE @IDTipoMovimiento INT;
		DECLARE @IDUsuario INT;
		DECLARE @saldo MONEY;
		DECLARE @tipoMovimiento VARCHAR(16);

		-- inicializacion de variables:
		SET @outResultCode = 0;

		SELECT @IDEmpleado = E.ID FROM Empleado E WHERE E.ValorDocumentoIdentidad = @inCedula;
		SELECT @IDTipoMovimiento = T.ID FROM TipoMovimiento T WHERE T.Nombre = @inNombreMovimiento;
		SELECT @IDUsuario = U.ID FROM Usuario U WHERE U.Username = @inUsername;

		SELECT @saldo = E.SaldoVacaciones FROM Empleado E WHERE E.ValorDocumentoIdentidad = @inCedula;
		SELECT @tipoMovimiento = T.TipoAccion FROM TipoMovimiento T WHERE T.Nombre = @inNombreMovimiento;

		SET @saldo = CASE
			WHEN @tipoMovimiento = 'Credito' THEN @saldo + @inMonto
			WHEN @tipoMovimiento = 'Debito' THEN @saldo - @inMonto
			END;

		UPDATE Empleado
			SET SaldoVacaciones = @saldo
			WHERE ValorDocumentoIdentidad = @inCedula;
			INSERT Movimiento (IDEmpleado, IDTipoMovimiento, Fecha, Monto, NuevoSaldo, IDPostByUser, PostInIP, PostTime)
			VALUES (@IDEmpleado, @IDTipoMovimiento, @inFecha, @inMonto, @saldo, @IDUsuario, @inIP, @inTime)

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