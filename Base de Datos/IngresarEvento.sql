-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- INGRESA LOS EVENTOS A LA BITACORA

-- Descripcion de parametros:
	-- @inNombreEvento: nombre del tipo de evento a guardar
	-- @inIDUsuario: id del usuario que realizo la accion
	-- @inIP: ip desde donde se realiza la accion
	-- @inDescripcion: string descripcion del evento
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.IngresarEvento 'nombre evento', 0, 'descripcion', @outResultCode OUTPUT

-- Notas adicionales:
-- el nombre del evento se utiliza para mapear contra la tabla TipoEvento
-- el usuario se utiliza para mapear contra la tabla Usuario
-- si la llamada se ejecuta desde el login, se debe proveer usuario e ip
-- de lo contrario, en ID del usuario se coloca un 0 y no se provee ip

ALTER PROCEDURE dbo.IngresarEvento
	  @inNombreEvento VARCHAR(64)
	, @inIDUsuario INT
	, @inIP VARCHAR(64)
	, @inDescripcion VARCHAR(512)
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @IDTipoEvento INT = NULL;
		DECLARE @postTime DATETIME;

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- revisar si existe el tipo de evento para obtener su id:
		IF EXISTS (SELECT 1 FROM TipoEvento TE WHERE TE.Nombre = @inNombreEvento)
			BEGIN
				SELECT @IDTipoEvento = ID
					FROM TipoEvento TE
					WHERE TE.Nombre = @inNombreEvento;
			END

		SET @postTime = GETDATE();
		
		-- ------------------------------------------------------------- --
		-- VERIFICAR SI SE INGRESO USUARIO E IP:

		-- revisar si el usuario es cero:
		IF @inIDUsuario = 0
		BEGIN
			SET @inIDUsuario = (SELECT TOP 1 BE.IDPostByUser 
				FROM BitacoraEvento BE
				INNER JOIN TipoEvento TE ON BE.IDTipoEvento = TE.ID
				WHERE TE.Nombre = 'Logout'
				ORDER BY BE.PostTime DESC);
		END;

		IF LEN(@inIP) = 0
		BEGIN
			SET @inIP = (SELECT TOP 1 BE.PostInIP
				FROM BitacoraEvento BE
				INNER JOIN TipoEvento TE ON BE.IDTipoEvento = TE.ID
				WHERE TE.Nombre = 'Logout'
				ORDER BY BE.PostTime DESC);
		END;

		-- ------------------------------------------------------------- --
		-- INGRESAR EVENTOS:

		-- insertar los valores en la bitacora de eventos:
		INSERT BitacoraEvento (IDTipoEvento
			 , Descripcion
			 , IDPostByUser
			 , PostInIP
			 , PostTime)
			VALUES (@IDTipoEvento
				, @inDescripcion
				, @inIDUsuario
				, @inIP
				, @postTime);
		
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