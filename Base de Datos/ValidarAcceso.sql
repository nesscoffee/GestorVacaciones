-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- VERIFICA QUE LOS DATOS DE ACCESO SEAN VALIDOS

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
	  @inUsername VARCHAR(64)
	, @inPassword VARCHAR(64)
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @ultimoPostTime DATETIME;
		DECLARE @IDUltimaEntrada VARCHAR(64);
		DECLARE @ultimaEntrada VARCHAR(64);
		DECLARE @outResultCodeEvento INT;
		DECLARE @inIDUsuario INT;
		DECLARE @intentosLogin INT;
		DECLARE @descripcion VARCHAR(512)

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- buscar la ultima fecha de estampa en bitacora:
		SET @ultimoPostTime = (SELECT TOP 1 B.[PostTime]
			FROM BitacoraEvento B
			ORDER BY B.[PostTime] DESC);

		-- buscar el id de la ultima entrada en bitacora:
		SET @IDUltimaEntrada = (SELECT TOP 1 B.[IDTipoEvento]
			FROM BitacoraEvento B
			ORDER BY B.[PostTime] DESC);

		-- buscar el tipo de evento de la ultima entrada en bitacora:
		SELECT @ultimaEntrada = T.[Nombre]
			FROM TipoEvento T
			WHERE T.ID = @IDUltimaEntrada;
			
		-- ------------------------------------------------------------- --
		-- REVISAR CANTIDAD DE INTENTOS DE LOGIN:

		-- revisar cuantas veces ha intentado entrar el usuario:
		SELECT @intentosLogin = COUNT(1)
		FROM (
			SELECT B.[IDTipoEvento], B.[PostTime], ROW_NUMBER() OVER (ORDER BY B.[PostTime] DESC) AS RowNumber
			FROM BitacoraEvento B
		) AS Subquery

		-- revisar si fueron logins no existosos en los pasados 30 minutos:
		WHERE Subquery.IDTipoEvento = (SELECT ID 
			FROM TipoEvento 
			WHERE Nombre = 'Login No Exitoso') 
		AND Subquery.PostTime >= DATEADD(MINUTE, -30, GETDATE())
		AND NOT EXISTS (
			SELECT 1
			FROM BitacoraEvento B
			WHERE B.[IDTipoEvento] = (SELECT ID 
				FROM TipoEvento 
				WHERE Nombre = 'Logout')
			AND B.[ID] > Subquery.RowNumber
		);

		-- ------------------------------------------------------------- --
		-- REVISAR ACTIVACION DEL LOGIN:
		
		-- revisar si, en caso de estar deshabilitado, ya se puede volver a hacer login:
		IF DATEDIFF(MINUTE, @ultimoPostTime, GETDATE()) < 5 AND @ultimaEntrada = 'Login deshabilitado'
		BEGIN
			SET @outResultCode = 50003;                          -- error: login deshabilitado
			EXEC dbo.IngresarEvento 'Login deshabilitado', 'UsuarioScripts', ' ', @outResultCodeEvento OUTPUT;
		END;

		-- revisar si hubieron mas de 5 logins no existosos:
		IF @outResultCode = 0 AND @intentosLogin >= 5
		BEGIN
			SET @outResultCode = 50003;                          -- error: login deshabilitado
			EXEC dbo.IngresarEvento 'Login deshabilitado', 'UsuarioScripts', ' ', @outResultCodeEvento OUTPUT;
		END;
		
		-- ------------------------------------------------------------- --
		-- VERIFICAR LOGIN:
	
		-- revisar si el usuario existe en la base de datos, tabla Usuario:
		IF @outResultCode = 0 AND NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Username = @inUsername)
		BEGIN
			SET @outResultCode = 50001;                          -- error: usuario no existe
			SET @descripcion = (SELECT CONCAT ('intentos: ', CAST(@intentosLogin AS VARCHAR(1)), ', codigo 50001'));
			EXEC dbo.IngresarEvento 'Login No Exitoso', 'UsuarioScripts', @descripcion, @outResultCodeEvento OUTPUT;
		END;

		-- revisar que, dado que el usuario existe, la contrasena tambien existe:
		IF @outResultCode = 0 AND NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE U.Password = @inPassword)
		BEGIN
			SET @outResultCode = 50002;                          -- error: contrasena no existe
			SET @descripcion = (SELECT CONCAT ('intentos: ', CAST(@intentosLogin AS VARCHAR(1)), ', codigo 50002'));
			EXEC dbo.IngresarEvento 'Login No Exitoso', 'UsuarioScripts', @descripcion, @outResultCodeEvento OUTPUT;
		END;

		-- revisar que, dado que ambos datos existen, estos coincidan:
		IF @outResultCode = 0 AND EXISTS (SELECT 1 FROM dbo.Usuario U 
			WHERE U.Username = @inUsername AND U.Password = @inPassword)
		BEGIN
			SELECT @inIDUsuario = ID 
				FROM Usuario U 
				WHERE U.Username = @inUsername;
			EXEC dbo.IngresarEvento 'Login Exitoso', @inIDUsuario, ' ', @outResultCodeEvento OUTPUT;
		END;
		
		-- ------------------------------------------------------------- --

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

		SET @outResultCode = 50008;
		SELECT @outResultCode AS outResultCode;

	END CATCH;
	SET NOCOUNT OFF;
END;