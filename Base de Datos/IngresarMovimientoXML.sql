-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- INGRESA UN NUEVO MOVIMIENTO DURANTE LA CARGA DEL XML

-- Descripcion de parametros:
	-- @inCedula: valor del documento de identidad del empleado
	-- @inNombreMovimiento: nombre del nuevo movimiento
	-- @inFecha: fecha en que se realizar el movimiento
	-- @inMonto: monto del movimiento
	-- @inUsername: usuario de la persona que registro el movimiento
	-- @inIP: IP en el que se registro el movimiento
	-- @inTime: estampa de tiempo del registro del movimiento

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.IngresarMovimientoXML 'cedula', 'nombre', 'fecha', 0, 'usuario', 'ip', 'estampa', @outResultCode OUTPUT

-- Notas adicionales:
-- mapea los valores necesarios con las tablas correspondientes

CREATE PROCEDURE dbo.IngresarMovimientoXML
	  @inCedula VARCHAR(64)
	, @inNombreMovimiento VARCHAR(64)
	, @inFecha DATE
	, @inMonto MONEY
	, @inUsername VARCHAR(64)
	, @inIP VARCHAR(64)
	, @inTime DATETIME
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		-- DECLARAR VARIABLES:

		DECLARE @IDEmpleado INT;
		DECLARE @IDTipoMovimiento INT;
		DECLARE @IDUsuario INT;
		DECLARE @saldo MONEY;
		DECLARE @tipoMovimiento VARCHAR(16);

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- buscar el id del empleado al que pertenece el movimiento:
		SELECT @IDEmpleado = E.ID 
			FROM Empleado E
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		-- buscar el id del tipo de movimiento:
		SELECT @IDTipoMovimiento = T.ID
			FROM TipoMovimiento T
			WHERE T.Nombre = @inNombreMovimiento;

		-- buscar el id usuario que esta activo:
		SELECT @IDUsuario = U.ID
			FROM Usuario U
			WHERE U.Username = @inUsername;

		-- buscar el saldo actual del empleado:
		SELECT @saldo = E.SaldoVacaciones
			FROM Empleado E
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		-- buscar el tipo de movimiento (accion)
		SELECT @tipoMovimiento = T.TipoAccion
			FROM TipoMovimiento T
			WHERE T.Nombre = @inNombreMovimiento;

		-- establecer nuevo saldo (en base al monto nuevo)
		SET @saldo = CASE
			WHEN @tipoMovimiento = 'Credito' 
				THEN @saldo + @inMonto
			WHEN @tipoMovimiento = 'Debito'
				THEN @saldo - @inMonto
			END;

		-- ------------------------------------------------------------- --
		-- ACTUALIZAR DATOS:
		
		UPDATE Empleado
			SET SaldoVacaciones = @saldo
			WHERE ValorDocumentoIdentidad = @inCedula;
			
		-- ------------------------------------------------------------- --
		-- INGRESAR MOVIMIENTO:

		INSERT Movimiento (IDEmpleado
			, IDTipoMovimiento
			, Fecha
			, Monto
			, NuevoSaldo
			, IDPostByUser
			, PostInIP
			, PostTime)
		VALUES (@IDEmpleado
			, @IDTipoMovimiento
			, @inFecha
			, @inMonto
			, @saldo
			, @IDUsuario
			, @inIP
			, @inTime);
		
		-- ------------------------------------------------------------- --

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
		SELECT @outResultCode AS outResultCode;

	END CATCH;
	SET NOCOUNT OFF;
END;