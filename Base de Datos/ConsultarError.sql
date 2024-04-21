-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- INDICA EL SIGNIFICADO DE LOS ERRORES QUE PRODUCEN LOS SPs

-- Descripcion de parametros:
	-- @inCodigo: valor numerico del codigo producido
	-- @outDescripcion: significado del codigo de error dado
	-- @outResultCode: resultado de la consulta
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar (y no retorna descripcion)

-- Ejemplo de ejecucion:
	-- DECLARE @outDescripcion VARCHAR(128);
	-- DECLARE @outResultCode INT;
	-- EXECUTE dbo.ConsultarError 50001, @outDescripcion OUTPUT, @outResultCode OUTPUT

ALTER PROCEDURE dbo.ConsultarError
	  @inCodigo INT
	, @outDescripcion VARCHAR(128) OUTPUT
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- ------------------------------------------------------------- --
		-- ENCONTRAR ERROR:
		
		-- revisar si existe el codigo de error para obtener su descripcion:
		IF EXISTS (SELECT 1 FROM Error E WHERE E.Codigo = @inCodigo)
			BEGIN
				SELECT @outDescripcion = Descripcion 
					FROM Error E 
					WHERE E.Codigo = @inCodigo;
			END;
			
		-- el codigo solicitado no esta registrado:
		ELSE
			BEGIN
				SET @outResultCode = 50012;
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
