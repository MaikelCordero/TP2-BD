USE [sistemaEmpleadosTP2]
GO

DECLARE @XMLData XML;

SELECT @XMLData = BulkColumn
FROM OPENROWSET(BULK 'C:\TEC\BasesDatos1\TP2-BD\datos.xml', SINGLE_BLOB) AS x; -- Cambiar la ruta segun donde este el XML


--insertar Puestos
INSERT INTO Puesto(Nombre, SalarioPorHora)
SELECT 
    Puesto.value('@Nombre', 'NVARCHAR(50)'),
    Puesto.value('@SalarioxHora', 'MONEY')
FROM 
    @XMLData.nodes('/Datos/Puestos/Puesto') AS T(Puesto);



--insertar TipoEvento
INSERT INTO TipoEvento(Nombre)
SELECT 
    TipoEvento.value('@Nombre', 'NVARCHAR(50)')
FROM 
    @XMLData.nodes('/Datos/TiposEvento/TipoEvento') AS T(TipoEvento);



--insert TipoMovimiento
INSERT INTO TipoMovimiento ( Nombre, TipoAccion)
SELECT 
    --TipoMovimiento.value('@Id', 'INT'),
    TipoMovimiento.value('@Nombre', 'NVARCHAR(50)'),
    TipoMovimiento.value('@TipoAccion', 'NVARCHAR(50)')
FROM 
    @XMLData.nodes('/Datos/TiposMovimientos/TipoMovimiento') AS T(TipoMovimiento);



--insertar empleados
INSERT INTO Empleado(IdPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, Activo) 
SELECT
    P.Id,
    Empleado.value('@ValorDocumentoIdentidad', 'INT'),
    Empleado.value('@Nombre', 'NVARCHAR(50)'),
    Empleado.value('@FechaContratacion', 'DATE'),
	0,
	1
FROM 
    @XMLData.nodes('/Datos/Empleados/empleado') AS T(Empleado)
INNER JOIN Puesto P ON Empleado.value('@Puesto', 'NVARCHAR(50)') = P.Nombre;



--insertar usuarios
INSERT INTO Usuario (UserName, Password)
SELECT 
    Usuario.value('@Nombre', 'NVARCHAR(50)'),
    Usuario.value('@Pass', 'NVARCHAR(50)')
FROM 
    @XMLData.nodes('/Datos/Usuarios/usuario') AS T(Usuario);



-- Insertar datos en la tabla temporal #Movimientos, incluyendo el c�lculo del nuevo saldo y actualizaci�n del saldo del empleado
INSERT INTO Movimiento(IdEmpleado, IdTipoMovimiento, Fecha, Monto, NuevoSaldo, IdPostByUser, PostInIP, PostTime)
SELECT 
    Movimiento.value('@ValorDocId', 'NVARCHAR(50)'),
	tm.Id,
    Movimiento.value('@Fecha', 'DATE'),
    Movimiento.value('@Monto', 'INT'),
	0,
    u.Id,
    Movimiento.value('@PostInIP', 'NVARCHAR(50)'),
    Movimiento.value('@PostTime', 'DATETIME')
FROM 
    @XMLData.nodes('/Datos/Movimientos/movimiento') AS T(Movimiento)
INNER JOIN TipoMovimiento tm ON Movimiento.value('@IdTipoMovimiento', 'NVARCHAR(50)') = tm.Nombre
INNER JOIN Empleado e ON Movimiento.value('@ValorDocId', 'NVARCHAR(50)') = e.ValorDocumentoIdentidad
INNER JOIN Usuario u ON Movimiento.value('@PostByUser', 'NVARCHAR(50)') = u.UserName;



--insertar errores
INSERT INTO Error(Codigo, Descripcion)
SELECT 
    Error.value('@Codigo', 'INT'),
    Error.value('@Descripcion', 'NVARCHAR(150)')
FROM 
    @XMLData.nodes('/Datos/Error/error') AS T(Error);

--insert into Error (Codigo,Descripcion) values (50012, 'Empleado no encontrado')



--INSERT INTO dbo.DBError (Username, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
--VALUES ((SELECT SUSER_NAME()), (SELECT ERROR_NUMBER()), (SELECT ERROR_STATE()), (SELECT ERROR_SEVERITY()),
--(SELECT ERROR_LINE()), (SELECT ERROR_PROCEDURE()), (SELECT ERROR_MESSAGE()), (SELECT GETDATE()));