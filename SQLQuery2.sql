DECLARE @outEmpleado INT
EXECUTE dbo.ValidarAcceso 'UsuarioScripts', 'UsuarioScripts', @outEmpleado OUTPUT
SELECT * FROM BitacoraEvento

DECLARE @outEmp INT
EXECUTE dbo.IngresarEmpleado '1206827', 'Andres Venegas', 'Recepcionista', @outEmp OUTPUT
SELECT * FROM Empleado
SELECT * FROM BitacoraEvento

DECLARE @outUpdate INT
EXECUTE dbo.ActualizarEmpleado '1068710', '1068711', ' ', 'Niñera', @outUpdate OUTPUT
SELECT * FROM Empleado
SELECT * FROM BitacoraEvento

DECLARE @outBorrar INT
EXECUTE dbo.BorrarEmpleado '4001120', 1, @outBorrar OUTPUT
SELECT * FROM Empleado
SELECT * FROM BitacoraEvento

DECLARE @outLista INT
EXECUTE dbo.ListarEmpleados @outLista OUTPUT

DECLARE @outFiltroN INT
EXECUTE dbo.FiltrarEmpleados 'Gaby', @outFiltroN;
SELECT * FROM BitacoraEvento

DECLARE @outFiltroC INT
EXECUTE dbo.FiltrarEmpleados '5', @outFiltroC;
SELECT * FROM BitacoraEvento

DECLARE @outConsulta INT;
EXECUTE dbo.ConsultarEmpleado '8030861', @outConsulta

DECLARE @outInMov INT;
EXECUTE dbo.IngresarMovimiento '1123258', 'Venta de vacaciones', 30, @outInMov;
SELECT * FROM Empleado
SELECT * FROM Movimiento

DECLARE @outMov INT;
EXECUTE dbo.ListarMovimientos '1039590', @outMov
SELECT * FROM BitacoraEvento

DECLARE @out INT;
EXECUTE dbo.Salir @out OUTPUT;