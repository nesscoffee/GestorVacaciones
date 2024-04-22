-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- GENERA UNA LISTA DE LOS MOVIMIENTOS DE UN EMPLEADO EN ESPECIFICO

-- Descripcion de parametros:
	-- @inCedula: valor del documento de identidad del empleado
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ListarMovimientos 'cedula', @outResultCode OUTPUT

-- Notas adicionales:
-- la cedula viene por parte del sistema, no del usuario
-- por tanto, no hace falta hacer validacion de esta, se sabe que ya es correcta
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.ListarMovimientos
	  @inCedula INT
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @outResultCodeEvento INT;
		DECLARE @descripcionEvento VARCHAR(512);
		DECLARE @nombre VARCHAR(64);

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0

		SELECT @nombre = Nombre
			FROM Empleado E
			WHERE E.ValorDocumentoIdentidad = @inCedula;
			
		-- ------------------------------------------------------------- --
		-- GENERAR DATASETS:

		SELECT @outResultCode AS outResultCode

		-- generar la tabla de movimientos:
		SELECT M.[Fecha]
			 , TM.[Nombre] AS 'Nombre Movimiento'
			 , M.[Monto]
			 , M.[NuevoSaldo] AS 'Nuevo Saldo'
			 , U.[Username] AS 'Usuario'
			 , M.[PostInIP]
			 , M.[PostTime]
		FROM Movimiento M
		INNER JOIN TipoMovimiento TM ON M.[IDTipoMovimiento] = TM.[ID]
		INNER JOIN Usuario U ON M.[IDPostByUser] = U.[ID]
		INNER JOIN Empleado E ON M.[IDEmpleado] = E.[ID]
		WHERE E.[ValorDocumentoIdentidad] = @inCedula
		ORDER BY M.[PostTime] DESC;

		-- guardar el evento en la bitacora:
		SET @descripcionEvento = (SELECT CONCAT('cedula: ', @inCedula,
			', nombre: ', @nombre));
		EXEC dbo.IngresarEvento 'Consulta de movimientos de empleado', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
		
		-- ------------------------------------------------------------- --

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