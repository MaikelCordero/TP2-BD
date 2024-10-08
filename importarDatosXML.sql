USE sistemaEmpleadosTP2
GO

ALTER PROCEDURE [dbo].[InsertarDatosXML]
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @doc XML;
        DECLARE @Contador INT;
        DECLARE @LargoEmpleado INT;
        DECLARE @LargoMovimiento INT;
        DECLARE @PuestoActual VARCHAR(64);
        DECLARE @IdPuestoActual INT;
        DECLARE @UsuarioActual VARCHAR(64);
        DECLARE @IdUsuarioActual INT;
        DECLARE @DocumentoEmpleadoActual INT;
        DECLARE @IdEmpleadoActual INT;
        DECLARE @TipoMovimientoActual VARCHAR(64);
        DECLARE @IdTipoMovimientoActual INT;
        DECLARE @SaldoVacacionesActual INT;
        DECLARE @MontoMovimientoActual INT;
        DECLARE @NuevoSaldo INT;
        DECLARE @TipoAccion VARCHAR(16);

        -- Inicialización
        SELECT @doc = BulkColumn
        FROM OPENROWSET(
                 BULK 'C:\TEC\BasesDatos1\TP2-BD\datos.xml', SINGLE_CLOB
             ) AS Data;

        SELECT @LargoEmpleado = (SELECT COUNT(*) FROM @doc.nodes('/Datos/Empleados/empleado') AS x1(Datos));
        SELECT @LargoMovimiento = (SELECT COUNT(*) FROM @doc.nodes('/Datos/Movimientos/movimiento') AS x1(Datos));

        SET @Contador = 1;
        SET @OutResultCode = 0;

        BEGIN TRANSACTION;
            -- Inserción de datos en las tablas principales
            INSERT INTO Puesto(Nombre, SalarioPorHora)
            SELECT Datos.value('@Nombre', 'VARCHAR(64)') AS Puesto,
                   Datos.value('@SalarioxHora', 'INT') AS 'Salario por Hora'
            FROM @doc.nodes('/Datos/Puestos/Puesto') AS x1(Datos);

            INSERT INTO TipoEvento(Nombre)
            SELECT Datos.value('@Nombre', 'VARCHAR(64)') AS Descripcion
            FROM @doc.nodes('/Datos/TiposEvento/TipoEvento') AS x1(Datos);

            INSERT INTO TipoMovimiento(Nombre, TipoAccion)
            SELECT Datos.value('@Nombre', 'VARCHAR(64)') AS Descripcion,
                   Datos.value('@TipoAccion', 'VARCHAR(16)') AS 'Tipo accion'
            FROM @doc.nodes('/Datos/TiposMovimientos/TipoMovimiento') AS x1(Datos);

            INSERT INTO Usuario(Username, Password)
            SELECT Datos.value('@Nombre', 'VARCHAR(64)') AS Nombre,
                   Datos.value('@Pass', 'VARCHAR(64)') AS Password
            FROM @doc.nodes('/Datos/Usuarios/usuario') AS x1(Datos);

            INSERT INTO Error(Codigo, Descripcion)
            SELECT Datos.value('@Codigo', 'INT') AS 'Codigo de error',
                   Datos.value('@Descripcion', 'VARCHAR(64)') AS Descripcion
            FROM @doc.nodes('/Datos/Error/error') AS x1(Datos);

            -- Inserción de Empleados
            DECLARE @TempEmpleados TABLE (
                id INT IDENTITY(1,1),
                Puesto VARCHAR(64),
                ValorDocumentoIdentidad INT,
                Nombre VARCHAR(64),
                FechaContratacion DATE
            );

            INSERT @TempEmpleados(Puesto, ValorDocumentoIdentidad, Nombre, FechaContratacion)
            SELECT Datos.value('@Puesto', 'VARCHAR(64)') AS Puesto,
                   Datos.value('@ValorDocumentoIdentidad', 'INT') AS 'Documento de identificacion',
                   Datos.value('@Nombre', 'VARCHAR(64)') AS Nombre,
                   Datos.value('@FechaContratacion', 'DATE') AS 'Fecha de contratacion'
            FROM @doc.nodes('/Datos/Empleados/empleado') AS x1(Datos);

            WHILE @Contador <= @LargoEmpleado
            BEGIN
                SELECT @PuestoActual = Puesto FROM @TempEmpleados WHERE id = @Contador;

                IF EXISTS(SELECT 1 FROM Puesto AS P WHERE P.Nombre = @PuestoActual)
                BEGIN
                    SELECT @IdPuestoActual = P.Id 
                    FROM Puesto AS P 
                    WHERE P.Nombre = @PuestoActual;

                    INSERT INTO Empleado(IdPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, Activo)
                    SELECT @IdPuestoActual, T.ValorDocumentoIdentidad, T.Nombre, T.FechaContratacion, 0, 1
                    FROM @TempEmpleados AS T
                    WHERE T.id = @Contador;
                END
                SET @Contador = @Contador + 1;
            END

            SET @Contador = 1;

            -- Inserción de Movimientos
            DECLARE @TempMovimientos TABLE (
                id INT IDENTITY(1,1),
                ValorDocId INT,
                IdTipoMovimiento VARCHAR(64),
                Fecha DATE,
                Monto INT,
                PostByUser VARCHAR(64),
                PostInIP VARCHAR(64),
                PostTime DATETIME
            );

            INSERT @TempMovimientos(ValorDocId, IdTipoMovimiento, Fecha, Monto, PostByUser, PostInIP, PostTime)
            SELECT Datos.value('@ValorDocId', 'INT') AS 'Valor Doc Id',
                   Datos.value('@IdTipoMovimiento', 'VARCHAR(64)') AS 'Tipo de movimiento',
                   Datos.value('@Fecha', 'DATE') AS Fecha,
                   Datos.value('@Monto', 'INT') AS Monto,
                   Datos.value('@PostByUser', 'VARCHAR(64)') AS 'User',
                   Datos.value('@PostInIP', 'VARCHAR(64)') AS 'IP',
                   Datos.value('@PostTime', 'DATETIME') AS 'Post Time'
            FROM @doc.nodes('/Datos/Movimientos/movimiento') AS x1(Datos);

            WHILE @Contador <= @LargoMovimiento
            BEGIN
                SELECT @UsuarioActual = T.PostByUser, 
                       @DocumentoEmpleadoActual = T.ValorDocId, 
                       @TipoMovimientoActual = T.IdTipoMovimiento,
                       @MontoMovimientoActual = T.Monto
                FROM @TempMovimientos AS T 
                WHERE id = @Contador;

                IF EXISTS(SELECT 1 FROM Usuario AS U WHERE U.Username = @UsuarioActual)
                    IF EXISTS(SELECT 1 FROM Empleado AS E WHERE E.ValorDocumentoIdentidad = @DocumentoEmpleadoActual)
                        IF EXISTS(SELECT 1 FROM TipoMovimiento AS TM WHERE TM.Nombre = @TipoMovimientoActual)
                        BEGIN
                            SELECT @IdUsuarioActual = U.Id 
                            FROM Usuario AS U 
                            WHERE U.Username = @UsuarioActual;

                            SELECT @IdEmpleadoActual = E.Id, 
                                   @SaldoVacacionesActual = E.SaldoVacaciones
                            FROM Empleado AS E 
                            WHERE E.ValorDocumentoIdentidad = @DocumentoEmpleadoActual;

                            SELECT @IdTipoMovimientoActual = TM.Id, 
                                   @TipoAccion = TM.TipoAccion
                            FROM TipoMovimiento AS TM 
                            WHERE TM.Nombre = @TipoMovimientoActual;

                            -- Calculamos el nuevo saldo de vacaciones y verificamos que no sea negativo
                            IF @TipoAccion = 'Debito'
                            BEGIN
                                SET @NuevoSaldo = @SaldoVacacionesActual - @MontoMovimientoActual;
                            END
                            ELSE
                            BEGIN
                                SET @NuevoSaldo = @SaldoVacacionesActual + @MontoMovimientoActual;
                            END

                            -- Solo insertamos y actualizamos si el saldo no es negativo
                            IF @NuevoSaldo >= 0
                            BEGIN
                                -- Insertamos el movimiento
                                INSERT INTO Movimiento(IdEmpleado, IdTipoMovimiento, Fecha, Monto, NuevoSaldo, IdPostByUser, PostInIP, PostTime)
                                SELECT @IdEmpleadoActual,
                                       @IdTipoMovimientoActual,
                                       T.Fecha,
                                       CASE WHEN @TipoAccion = 'Debito' THEN -@MontoMovimientoActual ELSE @MontoMovimientoActual END,
                                       @NuevoSaldo,
                                       @IdUsuarioActual,
                                       T.PostInIP,
                                       T.PostTime
                                FROM @TempMovimientos AS T
                                WHERE T.id = @Contador;

                                -- Actualizamos el saldo de vacaciones del empleado
                                UPDATE Empleado
                                SET SaldoVacaciones = @NuevoSaldo
                                WHERE Id = @IdEmpleadoActual;
                            END
                            ELSE
                            BEGIN
                                -- Si el saldo es negativo, puedes establecer un código de error o un mensaje
                                SET @OutResultCode = 50006; -- Código de error personalizado
                                -- Aquí podrías incluir un manejo adicional, como registrar el intento fallido
                            END
                        END

                SET @Contador = @Contador + 1;
            END
        COMMIT TRANSACTION;
    END TRY 
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;    
        SET @OutResultCode = 50005;
    END CATCH;

    SET NOCOUNT OFF;
END


DECLARE @OutResultCode INT
EXECUTE [dbo].[InsertarDatosXML] @OutResultCode OUTPUT
SELECT @OutResultCode

-- Borrar todo el contenido de las tablas

USE [sistemaEmpleadosTP2];
GO

-- Desactivar restricciones de claves foráneas
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Eliminar todos los registros de cada tabla
EXEC sp_MSforeachtable 'DELETE FROM ?';

-- Activar nuevamente las restricciones de claves foráneas
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';


SELECT * FROM [dbo].[Empleado]
SELECT * FROM [dbo].[Error]
SELECT * FROM [dbo].[Movimiento]
SELECT * FROM [dbo].[Puesto]
SELECT * FROM [dbo].[TipoEvento]
SELECT * FROM [dbo].[TipoMovimiento]
SELECT * FROM [dbo].[Usuario]