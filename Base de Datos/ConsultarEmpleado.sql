-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- DEVUELVE LA INFORMACION DE UN EMPLEADO EN ESPECIFICO

-- Descripion de parametros:
	-- @inCedula: valor del documento de identidad del empleado a consultar
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ConsultarEmpleado 'cedula', @outResultCode OUTPUT
	
-- Notas adicionales:
-- la cedula viene por parte del sistema, no del usuario
-- por tanto, no hace falta hacer validacion de esta, se sabe que ya es correcta

ALTER PROCEDURE dbo.ConsultarEmpleado
	@inCedula INT,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- ------------------------------------------------------------- --
		-- GENERAR DATASETS:
		
		SELECT @outResultCode AS outResultCode;

		-- crear la tabla con la informacion del empleado:
		SELECT E.[ValorDocumentoIdentidad] AS 'Documento Identidad'
			 , E.[Nombre]
			 , P.[Nombre] AS 'Puesto'
			 , E.[SaldoVacaciones] AS 'Saldo Vacaciones'
        FROM Empleado E
        INNER JOIN Puesto P ON E.[IDPuesto] = P.[ID]
        WHERE E.[ValorDocumentoIdentidad] = @inCedula 
			AND E.[EsActivo] = 1;
			
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
