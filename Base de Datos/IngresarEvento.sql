-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Ingresa los eventos a la bitacora

-- Descripion de parametros:
	-- @inNombreEvento: nombre del tipo de evento a guardar
	-- @inUsuario: username de la persona que realizo la accion
	-- @inDescripcion: string descripcion del evento
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.IngresarEvento 'nombre evento', 'usuario', 'descripcion', @outResultCode OUTPUT

-- Notas adicionales:
-- el nombre del evento se utiliza para mapear contra la tabla TipoEvento
-- el usuario se utiliza para mapear contra la tabla Usuario
-- si no se ingresan valores existentes, se colocan un NULL en la bitacora

ALTER PROCEDURE dbo.IngresarEvento
	@inNombreEvento VARCHAR(64),
	@inUsuario VARCHAR(64),
	@inDescripcion VARCHAR(256),
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- declaracion de variables:
		DECLARE @IDTipoEvento INT = NULL;
		DECLARE @IDUsername INT = NULL;
		DECLARE @postIP VARCHAR(64);
		DECLARE @postTime DATETIME;

		-- inicializacion de variables
		SET @outResultCode = 0;

		-- revisar si existe el tipo de evento para obtener su id
		IF EXISTS (SELECT 1 FROM TipoEvento TE WHERE TE.Nombre = @inNombreEvento)
			BEGIN
				SELECT @IDTipoEvento = ID FROM TipoEvento TE WHERE TE.Nombre = @inNombreEvento;
			END

		-- revisar si existe el usuario para obtener su id
		IF EXISTS (SELECT 1 FROM Usuario U WHERE U.Username = @inUsuario)
			BEGIN
				SELECT @IDUsername = ID FROM Usuario U WHERE U.Username = @inUsuario;
			END

		SET @postIP = HOST_NAME();            -- cambiar para ingresar IP exacto?
		SET @postTime = GETDATE();            -- obtiene la fecha y hora del sistema

		-- insertar los valores en la bitacora de eventos
		INSERT BitacoraEvento (IDTipoEvento, Descripcion, IDPostByUser, PostInIP, PostTime)
			VALUES (@IDTipoEvento, @inDescripcion, @IDUsername, @postIP, @postTime)

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