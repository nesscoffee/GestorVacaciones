-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Genera una lista de los empleados ordenados por nombre ascendente

-- Descripion de parametros:
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ListarEmpleados @outResultCode OUTPUT

-- Notas adicionales:
-- se devuelve tambien el documento de identidad para hacer mas clara la busqueda con filtros

ALTER PROCEDURE dbo.ListarEmpleados
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		-- inicializacion de variables:
		SET @outResultCode = 0;

		-- valor de retorno en forma de tabla:
		SELECT @outResultCode AS outResultCode

		-- generar la tabla:
		SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad', 
			E.[Nombre]
		FROM Empleado E
		WHERE E.[EsActivo] = 1
		ORDER BY E.[Nombre]
		-- para ordenar ascendentemente segun apellido:
		-- ORDER BY SUBSTRING(E.[Nombre], CHARINDEX(' ', E.[Nombre]) + 1, LEN(E.[Nombre]) - CHARINDEX(' ', E.[Nombre]));

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