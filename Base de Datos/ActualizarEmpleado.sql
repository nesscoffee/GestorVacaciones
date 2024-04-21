-- Armando Castro, Stephanie Sandoval | Abr 22. 24
-- Tarea Programada 02 | Base de Datos I

-- Stored Procedure:
-- ACTUALIZA UN EMPLEADO EXISTENTE

-- Descripcion de parametros:
	-- @inCedulaOriginal: valor del documento de identidad del empleado antes de la actualizacion 
	-- @inCedulaNueva: nuevo valor para el documento de identidad del empleado
	-- @inNombreNuevo: nuevo valor para el nombre del empleado
	-- @inPuestoNuevo: nuevo valor para el puesto del empleado
	-- @outResultCode: resultado del insertado en la tabla
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, se puede consultar en la tabla de errores

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ActualizarEmpleado 'cedulaOriginal', 'cedulaNueva', 'nombreNuevo', 'puestoNuevo', @outResultCode OUTPUT

-- Notas adicionales:
-- si alguno de los espacios viene en blanco, se mantiene la informacion previa
-- no se permite actualizar si el nombre nuevo o la cedula nueva ya existen en la BD
-- todas las acciones quedan documentadas en la tabla bitacora de eventos

ALTER PROCEDURE dbo.ActualizarEmpleado
	  @inCedulaOriginal VARCHAR(64)
	, @inCedulaNueva VARCHAR(64)
	, @inNombreNuevo VARCHAR(64)
	, @inPuestoNuevo VARCHAR(64)
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		
		DECLARE @IDPuestoNuevo INT;
		DECLARE @IDPuestoOriginal INT;
		DECLARE @descripcionEvento VARCHAR(512);
		DECLARE @descripcionError VARCHAR(128);
		DECLARE @nombreOriginal VARCHAR(64);
		DECLARE @outResultCodeEvento INT;
		DECLARE @puestoOriginal VARCHAR(64);

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES:
		
		SET @outResultCode = 0;

		-- buscar el nombre original del empleado que se desea actualizar:
		SELECT @nombreOriginal = E.Nombre 
			FROM Empleado E 
			WHERE E.ValorDocumentoIdentidad = @inCedulaOriginal;

		-- buscar el id del puesto nuevo para el empleado:
		SELECT @IDPuestoNuevo = ID 
			FROM Puesto P 
			WHERE P.Nombre = @inPuestoNuevo;

		-- buscar el puesto original del empleado:
		SET @puestoOriginal = (SELECT P.Nombre 
			FROM Empleado E 
			INNER JOIN Puesto P ON E.IDPuesto = P.ID 
			WHERE E.Nombre = @nombreOriginal);

		-- buscar el id del puesto original:
		SELECT @IDPuestoOriginal = ID 
			FROM Puesto P 
			WHERE P.Nombre = @puestoOriginal;

		-- ------------------------------------------------------------- --
		-- LIMPIAR VARIABLES:
		
		-- limpiar los nuevos datos para cedula y nombre:
		SET @inCedulaNueva = LTRIM(RTRIM(@inCedulaNueva));
		SET @inNombreNuevo = LTRIM(RTRIM(@inNombreNuevo));

		-- ------------------------------------------------------------- --
		-- VALIDAR DATOS:
		
		-- el nombre nuevo no contiene solo letras o espacios:
		IF PATINDEX('%[^a-zA-Z ]%', @inNombreNuevo) != 0 
			AND LEN(@inNombreNuevo) > 0
		BEGIN
			SET @outResultCode = 50009;                                      -- error: nombre no alfabetico
			SELECT @descripcionError = Descripcion 
				FROM Error E 
				WHERE E.Codigo = @outResultCode;

			SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError, 
				', cedula original: ', @inCedulaOriginal, 
				', nombre original: ', @nombreOriginal, 
				', puesto original: ', @puestoOriginal, 
				', cedula nueva: ', @inCedulaNueva, 
				', nombre nuevo: ', @inNombreNuevo, 
				', puesto nuevo: ', @inPuestoNuevo));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Update no exitoso', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
		END;

		-- la cedula nueva no contiene solo numeros:
		IF LEN(@inCedulaNueva) > 0
			AND ISNUMERIC(@inCedulaNueva) != 1
		BEGIN
			SET @outResultCode = 50010;                                      -- error: cedula no numerica
			SELECT @descripcionError = Descripcion 
				FROM Error E 
				WHERE E.Codigo = @outResultCode;

			SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError,
				', cedula original: ', @inCedulaOriginal, 
				', nombre original: ', @nombreOriginal,
				', puesto original: ', @puestoOriginal,
				', cedula nueva: ', @inCedulaNueva,
				', nombre nuevo: ', @inNombreNuevo,
				', puesto nuevo: ', @inPuestoNuevo));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Update no exitoso', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
		END;

		-- ------------------------------------------------------------- --
		-- REVISAR DUPLICADOS:
		
		-- existe algun empledo con el mismo nombre con el que se quiere actualizar:
		IF @outResultCode = 0 
			AND (@inNombreNuevo != @nombreOriginal
			AND LEN(@inNombreNuevo) != 0)
		BEGIN
			IF EXISTS (SELECT 1 FROM Empleado E WHERE E.Nombre = @inNombreNuevo)
			BEGIN
				SET @outResultCode = 50007;                                  -- error: empleado con mismo nombre ya existe
				SELECT @descripcionError = Descripcion 
					FROM Error E 
					WHERE E.Codigo = @outResultCode;

				SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError,
					', cedula original: ', @inCedulaOriginal, 
					', nombre original: ', @nombreOriginal,
					', puesto original: ', @puestoOriginal,
					', cedula nueva: ', @inCedulaNueva,
					', nombre nuevo: ', @inNombreNuevo,
					', puesto nuevo: ', @inPuestoNuevo));
				-- guardar evento en la bitacora:
				EXEC dbo.IngresarEvento 'Update no exitoso', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
			END;
		END;

		-- existe algun empleado con la misma cedula con la que se quiere actualizar:
		IF @outResultCode = 0 
			AND (@inCedulaNueva != @inCedulaOriginal 
			OR LEN(@inCedulaNueva) != 0)
		BEGIN
			IF EXISTS (SELECT 1 FROM Empleado E WHERE E.ValorDocumentoIdentidad = @inCedulaNueva)
			BEGIN
				SET @outResultCode = 50006;                                  -- error: empleado con misma cedula ya existe
				SELECT @descripcionError = Descripcion 
					FROM Error E 
					WHERE E.Codigo = @outResultCode;

				SET @descripcionEvento = (SELECT CONCAT('error: ', @descripcionError,
					', cedula original: ', @inCedulaOriginal, 
					', nombre original: ', @nombreOriginal,
					', puesto original: ', @puestoOriginal,
					', cedula nueva: ', @inCedulaNueva,
					', nombre nuevo: ', @inNombreNuevo,
					', puesto nuevo: ', @inPuestoNuevo));
				-- guardar evento en la bitacora:
				EXEC dbo.IngresarEvento 'Update no exitoso', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
			END;
		END;

		-- ------------------------------------------------------------- --
		-- ACTUALIZAR EMPLEADO:
		
		-- en caso de que no existan duplicados:
		IF @outResultCode = 0
		BEGIN
			IF LEN(@inNombreNuevo) = 0
			BEGIN
				SET @inNombreNuevo = @nombreOriginal;
			END;

			IF LEN(@inCedulaNueva) = 0
			BEGIN
				SET @inCedulaNueva = @inCedulaOriginal;
			END;

			UPDATE Empleado
			SET Nombre = @inNombreNuevo, 
				ValorDocumentoIdentidad = @inCedulaNueva, 
				IDPuesto = @IDPuestoNuevo
			WHERE Nombre = @nombreOriginal 
				AND ValorDocumentoIdentidad = @inCedulaOriginal 
				AND IDPuesto = @IDPuestoOriginal;

			SET @descripcionEvento = (SELECT CONCAT('cedula original: ', @inCedulaOriginal,
				', nombre original: ' , @nombreOriginal,
				', puesto original: ', @puestoOriginal,
				', cedula nueva: ', @inCedulaNueva,
				', nombre nuevo: ', @inNombreNuevo, 
				', puesto nuevo: ', @inPuestoNuevo));
			-- guardar evento en la bitacora:
			EXEC dbo.IngresarEvento 'Update exitoso', 0, '', @descripcionEvento, @outResultCodeEvento OUTPUT;
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