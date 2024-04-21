-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- EJECUTA EL LOGOUT DEL USUARIO

-- Descripcion de parametros:
	-- @outResultCode: resultado de ejecucion
		-- si el resultado es 0, el codigo corrio sin problemas
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.Salir @outResultCode OUTPUT

-- Notas adicionales:
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.Salir
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @outResultCodeEvento INT;

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- ------------------------------------------------------------- --
		-- EJECUTAR LOGOUT:
		
		-- registra el evento en la bitacora:
		EXEC dbo.IngresarEvento 'Logout', 0, '', ' ', @outResultCodeEvento OUTPUT;
		
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

	END CATCH;
	SET NOCOUNT OFF;
END;