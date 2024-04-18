-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Genera una lista de empleados despues de aplicar un filtro

-- Descripion de parametros:
	-- @inFiltro: string que se va a utilizar para filtrar resultados
		-- si contiene solo letras, se filtra por nombre
		-- si contiene solo numeros, se filtra por documento de identidad
		-- si contiene solo espacios en blanco, se retornan todos los empleados
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ListarEmpleados 'filtro', @outResultCode OUTPUT

-- Notas adicionales:
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.FiltrarEmpleados
	@inFiltro VARCHAR(64),
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- declaracion de variables:
		DECLARE @outResultCodeEvento INT;             -- para insertar eventos en la bitacora
		DECLARE @IDUsername INT;
		DECLARE @filtro VARCHAR(64);

		-- inicializacion de variables:
		SET @outResultCode = -1;
		SET @IDUsername = (SELECT TOP 1 [IDPostByUser] FROM BitacoraEvento ORDER BY [ID] DESC);

		-- identificar cual filtro se debe aplicar:
		-- el filtro contiene solo letras:
		IF PATINDEX('%[^A-Za-z]%', @inFiltro) = 0
		BEGIN
			SET @outResultCode = 0;
			SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', E.[Nombre]
			FROM Empleado E WHERE E.[Nombre] LIKE '%' + @inFiltro + '%'
				AND E.[EsActivo] = 1
			ORDER BY E.[Nombre]
			SET @filtro = (SELECT CONCAT('filtro: ', @inFiltro));
			EXEC dbo.IngresarEvento 'Consulta con filtro de nombre', @IDUsername, @filtro, @outResultCodeEvento OUTPUT
		END

		-- el filtro contiene solo numeros:
		IF ISNUMERIC(@inFiltro) = 1
		BEGIN
			SET @outResultCode = 0;
			SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', E.[Nombre]
			FROM Empleado E WHERE E.[ValorDocumentoIdentidad] LIKE '%' + @inFiltro + '%'
				AND E.[EsActivo] = 1
			ORDER BY E.[Nombre]
			SET @filtro = (SELECT CONCAT('filtro: ', @inFiltro));
			EXEC dbo.IngresarEvento 'Consulta con filtro de cedula', @IDUsername, @filtro, @outResultCodeEvento OUTPUT
		END

		-- el filtro contiene solo espacios en blanco:
		IF LTRIM(RTRIM(@inFiltro)) = ''
		BEGIN
			SET @outResultCode = 0;
			SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', E.[Nombre]
			FROM Empleado E
			ORDER BY E.[Nombre]
		END

		-- el filtro no cumple ninguno de los formatos aceptados:
		IF (@outResultCode != 0)
		BEGIN
			SET @outResultCode = 50013;
		END

		-- valor de retorno en forma de tabla:
		SELECT @outResultCode AS outResultCode

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