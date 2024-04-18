-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Verifica que los datos de acceso sean validos

-- Descripcion de parametros:
	-- @inUsername: usuario de ingreso
	-- @inPassword: contrasena del usuario
	-- @outResultCode: resultado de ejecucion
		-- si el resultado es 0, el codigo corrio sin problemas
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ValidarAcceso 'usuario', 'password', @outResultCode OUTPUT

-- Notas adicionales:
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.Salir
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- declaracion de variables:
		DECLARE @IDUsername INT; 
		DECLARE @outResultCodeEvento INT;

		-- inicializacion de variables:
		SET @outResultCode = 0;
		SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);

		-- guardar dato en la bitacora:
		EXEC dbo.IngresarEvento 'Logout', @IDUsername, ' ', @outResultCodeEvento OUTPUT;

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