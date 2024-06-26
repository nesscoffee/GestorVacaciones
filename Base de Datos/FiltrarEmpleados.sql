-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- GENERA UNA LISTA DE EMPLEADOS DESPUES DE APLICAR UN FILTRO

-- Descripcion de parametros:
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
	  @inFiltro VARCHAR(64)
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @outResultCodeEvento INT;
		DECLARE @filtro VARCHAR(64);

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- ------------------------------------------------------------- --
		-- IDENTIFICAR SI EL FILTRO ES INVALIDO:
		
		-- el filtro no contiene ninguno de los formatos aceptados:
		IF PATINDEX('%[^A-Za-z]%', @inFiltro) != 0
			AND ISNUMERIC(@inFiltro) != 1
			AND LTRIM(RTRIM(@inFiltro)) != ''
		BEGIN
			SET @outResultCode = 50013
		END;

		-- ------------------------------------------------------------- --
		-- CREAR LOS DATASETS:

		SELECT @outResultCode AS outResultCode;
	
		-- crear tabla de resultados segun filtro:
		-- el filtro contiene solo letras:
		IF PATINDEX('%[^A-Za-z]%', @inFiltro) = 0
		BEGIN
			SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', 
				E.[Nombre]
			FROM Empleado E 
				WHERE E.[Nombre] LIKE '%' + @inFiltro + '%'
				AND E.[EsActivo] = 1
			ORDER BY E.[Nombre]

			SET @filtro = (SELECT CONCAT('filtro: ', @inFiltro));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Consulta con filtro de nombre', 0, '', @filtro, @outResultCodeEvento OUTPUT;
			RETURN;
		END;

		-- el filtro contiene solo numeros:
		IF ISNUMERIC(@inFiltro) = 1
		BEGIN
			SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', 
				E.[Nombre]
			FROM Empleado E 
				WHERE E.[ValorDocumentoIdentidad] LIKE '%' + @inFiltro + '%'
				AND E.[EsActivo] = 1
			ORDER BY E.[Nombre]

			SET @filtro = (SELECT CONCAT('filtro: ', @inFiltro));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Consulta con filtro de cedula', 0, '', @filtro, @outResultCodeEvento OUTPUT;
			RETURN;
		END;

		-- el filtro contiene solo espacios en blanco:
		IF LTRIM(RTRIM(@inFiltro)) = ''
		BEGIN
			SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', E.[Nombre]
			FROM Empleado E
			ORDER BY E.[Nombre];
			RETURN;
		END;
		
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