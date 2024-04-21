-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Ingresa un movimiento nuevo a un empleado en especifico

-- Descripcion de parametros:
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
	  @inCedula VARCHAR(64)
	, @inNombreMovimiento VARCHAR(64)
	, @inMonto MONEY
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @IDEmpleado INT;
		DECLARE @IDTipoMovimiento INT;
		DECLARE @IDUsername INT;
		DECLARE @descripcionError VARCHAR(128);
		DECLARE @descripcionEvento VARCHAR(512);
		DECLARE @nombre VARCHAR(64);
		DECLARE @outResultCodeEvento INT;
		DECLARE @postIP VARCHAR(64);
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
		SET @IDUsername = (SELECT TOP 1 BE.IDPostByUser
			FROM BitacoraEvento BE
			ORDER BY BE.PostTime DESC);

		-- buscar el ip del que accede el usuario activo:
		SET @postIP = (SELECT TOP 1 BE.PostInIP
			FROM BitacoraEvento BE
			ORDER BY BE.PostTime DESC);

		-- buscar el nombre del empleado:
		SELECT @nombre = E.Nombre 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		-- buscar el saldo actual del empleado:
		SELECT @saldo = E.SaldoVacaciones 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedula;

		-- buscar el tipo de movimiento (accion)
		SELECT @tipoMovimiento = T.TipoAccion
			FROM TipoMovimiento T
			WHERE T.Nombre = @inNombreMovimiento;

		-- ------------------------------------------------------------- --
		-- VALIDAR DATOS:
		
		-- monto no deberia ser negativo:
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

			SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError,
				', cedula: ', @inCedula,
				', nombre: ', @nombre,
				', saldo: ', @saldo,
				', movimiento: ', @inNombreMovimiento,
				', monto: ', @inMonto));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Intento de insertar movimiento', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
		END;
		
		-- ------------------------------------------------------------- --
		-- APLICAR MOVIMIENTO:

		-- aplicacion del movimiento si saldo no es muy negativo:
		IF @outResultCode = 0
		BEGIN
			UPDATE Empleado
			SET SaldoVacaciones = @saldo
			WHERE ValorDocumentoIdentidad = @inCedula;

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
				, CAST(GETDATE() AS DATE)
				, @inMonto
				, @saldo
				, @IDUsername
				, @postIP
				, GETDATE());

			SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula,
				', nombre: ', @nombre,
				', saldo: ' , @saldo,
				', movimiento: ', @inNombreMovimiento,
				', monto: ', @inMonto));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Insertar movimiento exitoso', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
		END;
		
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