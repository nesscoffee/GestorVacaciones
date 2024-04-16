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
		DECLARE @outResultCodeEvento INT;                        -- para insertar eventos en la bitacora
		DECLARE @inIDUsuario INT;                                -- para insertar eventos en la bitacora
		DECLARE @intentosLogin INT;                              -- para verificar cuantas veces ha intentado ingresar
		DECLARE @descripcion VARCHAR(512)                        -- para las descripciones de los eventos

		-- inicializacion de variables:
		SET @outResultCode = 0;

		-- revisar cuantas veces ha intentado entrar el usuario:
		SELECT @intentosLogin = COUNT(*)
		FROM (
			SELECT TOP 5 B.[IDTipoEvento], B.[PostTime]          -- seleccionar cinco filas de bitacora
			FROM BitacoraEvento B
			ORDER BY B.PostTime DESC                             -- ordenadas por tiempo
		) AS Subquery
		-- revisar si fueron logins no existosos en los pasados 20 minutos:
		WHERE Subquery.IDTipoEvento = (SELECT ID FROM TipoEvento WHERE Nombre = 'Login No Exitoso') 
		AND Subquery.PostTime >= DATEADD(MINUTE, -30, GETDATE());

		-- revisar si hubieron mas de 5 logins no existosos:
		IF @intentosLogin >= 5
		BEGIN
			SET @outResultCode = 50003;                          -- error: login deshabilitado
			EXEC dbo.IngresarEvento 'Login deshabilitado', NULL, ' ', @outResultCodeEvento OUTPUT;
		END;

		-- FALTA REVISAR QUE YA SE PUEDE VOLVER A ACTIVAR EL LOGIN
	
		-- revisar si el usuario existe en la base de datos, tabla Usuario:
		IF @outResultCode = 0 AND NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Username = @inUsername)
		BEGIN
			SET @outResultCode = 50001;                          -- error: usuario no existe
			SET @descripcion = (SELECT CONCAT ('intentos: ', CAST(@intentosLogin AS VARCHAR(1)), ', codigo 50001'));
			EXEC dbo.IngresarEvento 'Login No Exitoso', NULL, @descripcion, @outResultCodeEvento OUTPUT;
		END;

		-- revisar que, dado que el usuario existe, la contrasena tambien existe:
		IF @outResultCode = 0 AND NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Password = @inPassword)
		BEGIN
			SET @outResultCode = 50002;                          -- error: contrasena no existe
			SET @descripcion = (SELECT CONCAT ('intentos: ', CAST(@intentosLogin AS VARCHAR(1)), ', codigo 50002'));
			EXEC dbo.IngresarEvento 'Login No Exitoso', NULL, @descripcion, @outResultCodeEvento OUTPUT;
		END;

		-- revisar que, dado que ambos datos existen, estos coincidan:
		IF @outResultCode = 0 AND EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Username = @inUsername AND U.Password = @inPassword)
		BEGIN
			SELECT @inIDUsuario = ID FROM Usuario U WHERE U.Username = @inUsername;
			EXEC dbo.IngresarEvento 'Login Exitoso', @inIDUsuario, ' ', @outResultCodeEvento OUTPUT;
		END;

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

		SET @outResultCode = 50008;                              -- error: problema base de datos

	END CATCH;
	SET NOCOUNT OFF;
END;