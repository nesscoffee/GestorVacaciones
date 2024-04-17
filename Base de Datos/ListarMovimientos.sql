-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- Genera una lista de los movimientos de un empleado en especifico

-- Descripion de parametros:
	-- @inCedula: valor del documento de identidad del empleado
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ListarMovimientos 'cedula', @outResultCode OUTPUT

-- Notas adicionales:
-- 

ALTER PROCEDURE dbo.ListarMovimientos
	@inCedula INT,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- inicializacion de variables:
		SET @outResultCode = 0

		-- valor de retorno en forma de tabla:
		SELECT @outResultCode AS outResultCode

		-- generar la tabla:
		SELECT M.[Fecha], 
			TM.[Nombre],
			M.[Monto], 
			SUM(CASE WHEN TM.[TipoAccion] = 'Credito' THEN M.[Monto] ELSE -M.[Monto] END)
				OVER (ORDER BY M.[Fecha]) AS 'Nuevo Saldo',
			U.[Username] AS 'Usuario',
			M.[PostInIP],
			M.[PostTime]
        FROM Movimiento M
        INNER JOIN TipoMovimiento TM ON M.[IDTipoMovimiento] = TM.[ID]
        INNER JOIN Usuario U ON M.[IDPostByUser] = U.[ID]
        INNER JOIN Empleado E ON M.[IDEmpleado] = E.[ID]
        WHERE E.[ValorDocumentoIdentidad] = @inCedula
        ORDER BY M.[Fecha] DESC;

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