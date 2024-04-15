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

ALTER PROCEDURE dbo.ValidarAcceso
	@inUsername VARCHAR(64),
	@inPassword VARCHAR(64),
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		-- declaracion de variables:
		DECLARE @outResultCodeEvento INT;             -- para insertar eventos en la bitacora
		DECLARE @inIDUsuario INT;                     -- para insertar eventos en la bitacora

		-- inicializacion de variables:
		SET @outResultCode = 0;
	
		-- revisar si el usuario existe en la base de datos, tabla Usuario:
		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Username = @inUsername)
			BEGIN
				SET @outResultCode = 50001;           -- error: usuario no existe
				EXEC dbo.IngresarEvento 'Login No Exitoso', NULL, 'intentos: x, codigo: 50001', @outResultCodeEvento OUTPUT
			END

		-- revisar que, dado que el usuario existe, la contrasena tambien existe:
		IF @outResultCode = 0 AND NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Password = @inPassword)
			BEGIN
				SET @outResultCode = 50002;           -- error: contrasena no existe
				EXEC dbo.IngresarEvento 'Login No Exitoso', NULL, 'intentos: x, codigo: 50002', @outResultCodeEvento OUTPUT
			END

		-- revisar que, dado que ambos datos existen, estos coincidan:
		IF @outResultCode = 0 AND EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Username = @inUsername AND U.Password = @inPassword)
			BEGIN
				SELECT @inIDUsuario = ID FROM Usuario U WHERE U.Username = @inUsername
				EXEC dbo.IngresarEvento 'Login Exitoso', @inIDUsuario, ' ', @outResultCodeEvento OUTPUT
			END

		SELECT @outResultCode AS outResultCode;
	END TRY

	BEGIN CATCH
		INSERT INTO dbo.DBError VALUES (
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