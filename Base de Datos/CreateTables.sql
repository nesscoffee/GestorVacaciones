-- Armando Castro, Stephanie Sandoval | Abr 17. 24
-- Tarea Programada 02 | Base de Datos I

-- Crear las tablas de la base de datos

-- Nota: al final de este script hay un codigo comentado
-- Este, sirve para eliminar las tablas en caso de necesidad

USE Vacaciones
GO

-- Tabla de puestos:
CREATE TABLE Puesto (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(64) NOT NULL,
	SalarioxHora MONEY NOT NULL
);

-- Tabla de empleados:
CREATE TABLE Empleado (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDPuesto INT NOT NULL,
	ValorDocumentoIdentidad VARCHAR(64) NOT NULL,
	Nombre VARCHAR(64) NOT NULL,
	FechaContratacion DATE NOT NULL,
	SaldoVacaciones MONEY NOT NULL,
	EsActivo BIT NOT NULL,
	FOREIGN KEY (IDPuesto) REFERENCES Puesto(ID)                   -- FK a Puesto
);

-- Tabla de tipos de movimiento:
CREATE TABLE TipoMovimiento (
	ID INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(64) NOT NULL,
	TipoAccion VARCHAR(64) NOT NULL
);

-- Tabla de usuarios:
CREATE TABLE Usuario (
	ID INT NOT NULL PRIMARY KEY,
	Username VARCHAR(64) NOT NULL,
	Password VARCHAR(64) NOT NULL
);

-- Tabla de movimientos:
CREATE TABLE Movimiento (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDEmpleado INT NOT NULL,
	IDTipoMovimiento INT NOT NULL,
	Fecha DATE NOT NULL,
	Monto INT NOT NULL,
	NuevoSaldo MONEY NOT NULL,
	IDPostByUser INT NOT NULL,
	PostInIP VARCHAR(64) NOT NULL,
	PostTime DATETIME NOT NULL,
	FOREIGN KEY (IDEmpleado) REFERENCES Empleado(ID),              -- FK a Empleado
	FOREIGN KEY (IDTipoMovimiento) REFERENCES TipoMovimiento(ID),  -- FK a Tipo Movimiento
	FOREIGN KEY (IDPostByUser) REFERENCES Usuario(ID)              -- FK a Usuario
);

-- Tabla de tipos de evento:
CREATE TABLE TipoEvento (
	ID INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(64) NOT NULL
);

-- Tabla de tipos de errores:
CREATE TABLE Error (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Codigo INT NOT NULL,
	Descripcion VARCHAR(128) NOT NULL
);

-- Tabla de errores:
CREATE TABLE DBError (
	ErrorID INT IDENTITY(1,1) NOT NULL,
	Username VARCHAR(64) NULL,
	ErrorNumber INT NULL,
	ErrorState INT NULL,
	ErrorSeverity INT NULL,
	ErrorLine INT NULL,
	ErrorProcedure VARCHAR(max) NULL,
	ErrorMessage VARCHAR(max) NULL,
	ErrorDateTime DATETIME NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

-- Tabla de la bitacora de eventos:
CREATE TABLE BitacoraEvento (
	ID INT NOT NULL IDENTITY(1,1),
	IDTipoEvento INT NOT NULL,
	Descripcion VARCHAR(64),
	IDPostByUser INT NOT NULL,
	PostInIP VARCHAR(64) NOT NULL,
	PostTime DATETIME NOT NULL,
	FOREIGN KEY (IDPostByUser) REFERENCES Usuario(ID),             -- FK a Usuario
	FOREIGN KEY (IDTipoEvento) REFERENCES TipoEvento(ID)           -- FK a Tipo Evento
);

-- Codigo para eliminar las tablas en caso de necesidad

-- DROP TABLE BitacoraEvento;
-- DROP TABLE DBError;
-- DROP TABLE Error;
-- DROP TABLE TipoEvento;
-- DROP TABLE Movimiento;
-- DROP TABLE Empleado;
-- DROP TABLE Puesto;
-- DROP TABLE TipoMovimiento;
-- DROP TABLE Usuario;