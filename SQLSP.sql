USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[consultEmpleado] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[consultEmpleado]
    @InvalorDocIdent int,
    @InNamePostbyUser nvarchar(50),
    @InPostInIP nvarchar(50),
    @OutResultCode int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @descripcion NVARCHAR(2000);
        DECLARE @id_usuario INT;
        DECLARE @nombre_empleado NVARCHAR(50);

        -- Inicialización del parámetro de salida
        SET @OutResultCode = 0;

        -- Obtiene el ID del usuario que realiza la consulta
        SELECT @id_usuario = u.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] u
		WHERE u.UserName = @InNamePostbyUser;

        -- Verifica si el empleado existe
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
		WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent)

        BEGIN
        BEGIN TRANSACTION

        -- Obtiene el nombre del empleado
        SELECT @nombre_empleado = e.Nombre
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
        WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent;

        -- Construye la descripción del evento
        SET @descripcion = 'Consulta del empleado, ' +
                                   CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' +
                                   @nombre_empleado;

        -- Realiza la consulta del empleado
        SELECT
            e.ValorDocumentoIdentidad,
            e.Nombre,
            p.Nombre AS Puesto,
            e.SaldoVacaciones
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
            INNER JOIN [sistemaEmpleadosTP2].[dbo].[Puesto] p ON p.Id = e.IdPuesto
        WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent;

        -- Inserta registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (11, @descripcion, @id_usuario, @InPostInIP, GETDATE());

        COMMIT TRANSACTION
    END
        ELSE
        BEGIN
        -- Si no existe el empleado, actualiza el resultado y registra el evento
        SET @OutResultCode = 50012;

        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (11, 'Intento de consulta del empleado, ' + 
                CONVERT(VARCHAR(100), @InvalorDocIdent), @id_usuario, @InPostInIP, GETDATE());

        PRINT 'No existe el empleado.';
    END;
    END TRY

    BEGIN CATCH
        -- Manejo de errores, si ocurre un error se revierte la transacción
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Inserta el error en la tabla de errores de la base de datos
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (ErrorUsername, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine,
        ErrorProcedure, ErrorMessage, ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
            ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Actualiza el parámetro de salida con un código de error
        SET @OutResultCode = 50008; -- Error en la base de datos
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[consultMovim] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[consultMovim]
    @InvalorDocIdent INT,
    @InNamePostbyUser NVARCHAR(50),
    @InPostInIP NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Descripcion NVARCHAR(2000);
        DECLARE @IdUser INT;
        DECLARE @Nombre NVARCHAR(50);
		DECLARE @IdEmpleado INT;

        -- Inicialización del parámetro de salida
        SET @OutResultCode = 0;

        -- Obtiene el ID del usuario que realiza la consulta
        SELECT @IdUser = u.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] u
		WHERE u.UserName = @InNamePostbyUser;

        -- Verifica si el empleado existe
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
		WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent)
        BEGIN
        BEGIN TRANSACTION

        -- Obtiene el nombre del empleado
        SELECT @Nombre = e.Nombre,
		       @IdEmpleado = e.Id
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
        WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent;

        -- Construye la descripción del evento
        SET @Descripcion = 'Consulta movimientos del empleado, ' + 
                                   CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' + 
                                   @Nombre;

        -- Realiza la consulta de movimientos del empleado
        SELECT
            m.Fecha,
            t.Nombre,
            m.Monto,
            m.NuevoSaldo,
            m.IdPostByUser,
            m.PostInIP,
            m.PostTime
        FROM [sistemaEmpleadosTP2].[dbo].[Movimiento] m
            INNER JOIN [sistemaEmpleadosTP2].[dbo].[TipoMovimiento] t ON m.IdTipoMovimiento = t.Id
            INNER JOIN [sistemaEmpleadosTP2].[dbo].[Empleado] e ON m.IdEmpleado = e.Id
        WHERE m.IdEmpleado = @IdEmpleado
        ORDER BY m.Fecha DESC;

        -- Inserta registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (11, @Descripcion, @IdUser, @InPostInIP, GETDATE());

        COMMIT TRANSACTION
    END
        ELSE
        BEGIN
        -- Si no existe el empleado, actualiza el resultado y registra el evento
        SET @OutResultCode = 50012;

        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (15, 'Intento de consulta de movimientos del empleado, ' + 
                CONVERT(VARCHAR(100), @InvalorDocIdent), @IdUser, @InPostInIP, GETDATE());

        PRINT 'No existe el empleado.';
    END;
    END TRY

    BEGIN CATCH
        -- Manejo de errores, si ocurre un error se revierte la transacción
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Inserta el error en la tabla de errores de la base de datos
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (ErrorUsername, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine,
        ErrorProcedure, ErrorMessage, ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
            ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Actualiza el parámetro de salida con un código de error
        SET @OutResultCode = 50008; -- Error en la base de datos
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[deletEmpleado] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deletEmpleado]
    @InvalorDocIdent INT,
    @InNamePostbyUser NVARCHAR(50),
    @InPostInIP NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Descripcion NVARCHAR(2000);
        DECLARE @IdUser INT;
        DECLARE @Nombre NVARCHAR(50);
        DECLARE @IdPuesto INT;
        DECLARE @NombrePuesto NVARCHAR(50);
        DECLARE @SaldoVac INT;

        -- Inicialización del parámetro de salida
        SET @OutResultCode = 0;

        -- Obtiene el ID del usuario que realiza la eliminación
        SELECT @IdUser = u.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] u
		WHERE u.UserName = @InNamePostbyUser;

        -- Verifica si el empleado existe y está activo
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
		WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent
        AND e.Activo = 1)
        BEGIN
        BEGIN TRANSACTION
        -- Obtiene los detalles del empleado
        SELECT
            @Nombre = e.Nombre,
            @IdPuesto = e.IdPuesto,
            @SaldoVac = e.SaldoVacaciones
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
        WHERE e.ValorDocumentoIdentidad = @InvalorDocIdent;

        -- Obtiene el nombre del puesto del empleado
        SELECT @NombrePuesto = p.Nombre
        FROM [sistemaEmpleadosTP2].[dbo].[Puesto] p
        WHERE p.Id = @IdPuesto;

        -- Construye la descripción del evento de eliminación
        SET @Descripcion = CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' + 
                                   @Nombre + ', ' + 
                                   @NombrePuesto + ', ' + 
                                   CONVERT(VARCHAR(100), @SaldoVac);

        -- Desactiva el empleado
        UPDATE Empleado 
                SET Activo = 0 
                WHERE ValorDocumentoIdentidad = @InvalorDocIdent;

        -- Inserta un registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (10, @Descripcion, @IdUser, @InPostInIP, GETDATE());

        COMMIT TRANSACTION
    END
        ELSE
        BEGIN
        -- Si el empleado no existe o ya fue eliminado, actualiza el resultado
        SET @OutResultCode = 50012;

        -- Construye la descripción del evento de eliminación
        SET @Descripcion = CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' + 
                                   @Nombre + ', ' + 
                                   @NombrePuesto + ', ' + 
                                   CONVERT(VARCHAR(100), @SaldoVac);

        -- Inserta registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (9, @Descripcion, @IdUser, @InPostInIP, GETDATE());

        PRINT 'No existe el empleado o ya fue eliminado.';
    END;
    END TRY

    BEGIN CATCH
        -- Manejo de errores: si ocurre un error, revierte la transacción
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Inserta el error en la tabla de errores de la base de datos
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (ErrorUsername, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine,
        ErrorProcedure, ErrorMessage, ErrorDateTime)
    VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
            ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Actualiza el parámetro de salida con un código de error
        SET @OutResultCode = 50008; -- Error en la base de datos
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[insertEmpleado] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[insertEmpleado]
    @IndocumIdentidad INT,
    @Innombre NVARCHAR(50),
    @InIdPuesto INT,
    @InNamePostbyUser NVARCHAR(50),
    @InPostInIP NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Descripcion NVARCHAR(150);
        DECLARE @IdUser INT;
        DECLARE @PuestoNombre NVARCHAR(50);

        -- Inicializa el parámetro de salida
        SET @OutResultCode = 0;

        -- Obtiene el ID del usuario que realiza la inserción
        SELECT @IdUser = u.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] u
		WHERE u.UserName = @InNamePostbyUser;

        -- Verifica si ya existe un empleado con el mismo documento de identidad
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
		WHERE e.ValorDocumentoIdentidad = @IndocumIdentidad)

        BEGIN
        SET @OutResultCode = 50004;

        -- Obtiene la descripción del error
        SELECT @Descripcion = err.Descripcion
        FROM [sistemaEmpleadosTP2].[dbo].[Error] err
        WHERE err.Codigo = @OutResultCode;

        -- Inserta un registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
			(5,
            @Descripcion + ', ' + 
            CONVERT(NVARCHAR(50), @IndocumIdentidad) + ', ' + 
            @Innombre + ', ' + 
            (SELECT p.Nombre
            FROM Puesto p
            WHERE p.Id = @InIdPuesto),
            @IdUser, @InPostInIP, GETDATE());

        PRINT 'El valorDocumentoIdentidad ya existe en la base de datos.';
        RETURN;
    END;

        -- Verifica si ya existe un empleado con el mismo nombre
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] e
		WHERE e.Nombre = @Innombre)
        BEGIN
        SET @OutResultCode = 50005;

        -- Obtiene la descripción del error
        SELECT @Descripcion = err.Descripcion
        FROM [sistemaEmpleadosTP2].[dbo].[Error] err
        WHERE err.Codigo = @OutResultCode;

        -- Inserta un registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (5,
                @Descripcion + ', ' + 
                CONVERT(NVARCHAR(50), @IndocumIdentidad) + ', ' + 
                @Innombre + ', ' + 
                (SELECT p.Nombre
                FROM Puesto p
                WHERE p.Id = @InIdPuesto),
                @IdUser, @InPostInIP, GETDATE());

        PRINT 'El nombre del empleado ya existe en la base de datos.';
        RETURN;
    END;

        ELSE
        BEGIN
        -- Inserción del empleado si no existen conflictos
        BEGIN TRANSACTION
        -- Inserta el empleado
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[Empleado]
            (IdPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, Activo)
        VALUES
            (@InIdPuesto, @IndocumIdentidad, @Innombre, GETDATE(), 0, 1);

        -- Obtiene el nombre del puesto para la trazabilidad
        SELECT @PuestoNombre = p.Nombre
        FROM [sistemaEmpleadosTP2].[dbo].[Puesto] p
        WHERE p.Id = @InIdPuesto;

        -- Inserta un registro en la bitácora
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (6, CONVERT(NVARCHAR(250), @IndocumIdentidad) + ', ' + @Innombre + ', ' + @PuestoNombre, @IdUser, @InPostInIP, GETDATE());
        COMMIT TRANSACTION
    END;
    END TRY

    BEGIN CATCH
        -- Revertir la transacción si ocurre un error
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Registra el error en la tabla DBError
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (ErrorUsername, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine,
        ErrorProcedure, ErrorMessage, ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
            ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Actualiza el resultado de salida en caso de error
        SET @OutResultCode = 50008; -- Error en la base de datos
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[insertMovimiento] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[insertMovimiento]
    @InNombreEmpleado NVARCHAR(50),
    @InNombreMovimiento NVARCHAR(50),
    @InFecha DATE,
    @InMonto INT,
    @InPostByUser NVARCHAR(50),
    @InPostInIp NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdUser INT, @IdEmpleado INT, @IdTipoMovimiento INT;
        DECLARE @SaldoActual INT, @NuevoSaldo INT, @TipoAccion NVARCHAR(50);
        DECLARE @Descripcion NVARCHAR(2000);

        -- Inicialización del resultado de salida
        SET @OutResultCode = 0;

        -- Obtener el usuario que realiza la operación
        SELECT @IdUser = U.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
		WHERE U.UserName = @InPostByUser;

        -- Obtener los datos del empleado y tipo de movimiento
        SELECT @IdEmpleado = E.Id,
        @SaldoActual = E.SaldoVacaciones,
        @TipoAccion = T.TipoAccion
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
        JOIN [sistemaEmpleadosTP2].[dbo].[TipoMovimiento] T ON T.Nombre = @InNombreMovimiento
		WHERE E.Nombre = @InNombreEmpleado;

        -- Determinar el nuevo saldo en función del tipo de movimiento
        SET @NuevoSaldo = CASE WHEN @TipoAccion = 'Credito' THEN @SaldoActual + @InMonto ELSE @SaldoActual - @InMonto END;

        -- Verificar si el nuevo saldo es válido
        IF @NuevoSaldo >= 0
        BEGIN
        -- Descripción para trazabilidad
        SET @Descripcion = CONCAT(CONVERT(VARCHAR(100), @IdEmpleado), ', ', 
                @InNombreEmpleado, ', ', CONVERT(VARCHAR(50), @NuevoSaldo), ', ', 
                @InNombreMovimiento, ', ', CONVERT(VARCHAR(50), @InMonto));

        BEGIN TRANSACTION
        -- Insertar el nuevo movimiento
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[Movimiento]
            (IdEmpleado, IdTipoMovimiento, Fecha, Monto, NuevoSaldo, IdPostByUser, PostInIP, PostTime)
        VALUES
            (
            @IdEmpleado,
            (SELECT Id
            FROM TipoMovimiento
            WHERE Nombre = @InNombreMovimiento),
            @InFecha,
            CASE WHEN @TipoAccion = 'Debito' THEN -(@InMonto) ELSE @InMonto END,
            @NuevoSaldo,
            @IdUser,
            @InPostInIp,
            GETDATE());

        -- Actualizar el saldo de vacaciones del empleado
        UPDATE Empleado
                SET SaldoVacaciones = @NuevoSaldo
                WHERE ValorDocumentoIdentidad = @IdEmpleado;

        -- Insertar trazabilidad
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP,
            PostTime)
        VALUES
            (14, @Descripcion, @IdUser, @InPostInIp, GETDATE());

        COMMIT TRANSACTION;
    END;

        ELSE
        BEGIN
        -- Manejo de error por saldo insuficiente
        SET @OutResultCode = 50011;

        SET @Descripcion = CONCAT((SELECT Descripcion
        FROM Error
        WHERE Codigo = @OutResultCode), ', ', 
            @IdEmpleado, ', ', @InNombreEmpleado, ', ', CONVERT(VARCHAR(100), @SaldoActual), ', ', 
            @InNombreMovimiento, ', ', CONVERT(VARCHAR(50), @InMonto));

        -- Insertar trazabilidad de error
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP,
            PostTime)
        VALUES
            (13, @Descripcion, @IdUser, @InPostInIp, GETDATE());

        PRINT 'El monto excede el saldo de vacaciones.';
    END;
    END TRY

    BEGIN CATCH
        -- Manejo de errores y rollback
        IF @@TRANCOUNT > 0
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        SET @OutResultCode = 50008; -- Error en base de datos
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[IntentoInsertMovimiento]    Script Date: 22/4/2024 22:59:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IntentoInsertMovimiento]
    @InNombreEmpleado NVARCHAR(50),
    @InNombreMovimiento NVARCHAR(50),
    @InMonto INT,
    @InPostByUser NVARCHAR(50),
    @InPostInIp NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdUser INT;
        DECLARE @SaldoActual INT;
        DECLARE @Descripcion NVARCHAR(2000);

        -- Inicialización del resultado de salida
        SET @OutResultCode = 0;

        -- Obtener el usuario que está realizando la acción
        SELECT @IdUser = U.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
		WHERE U.UserName = @InPostByUser;

        -- Obtener el saldo actual del empleado
        SELECT @SaldoActual = E.SaldoVacaciones
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
		WHERE E.Nombre = @InNombreEmpleado;

        -- Construir la descripción para trazabilidad
        SET @Descripcion = CONCAT('El usuario canceló la inserción, ', CONVERT(VARCHAR(100), 
		(SELECT E.ValorDocumentoIdentidad FROM Empleado E WHERE E.Nombre = @InNombreEmpleado)), ', ',
        @InNombreEmpleado, ', ', CONVERT(VARCHAR(100), @SaldoActual), ', ', @InNombreMovimiento, ', ',
        CONVERT(VARCHAR(50), @InMonto));

        -- Comenzar transacción
        BEGIN TRANSACTION
            -- Insertar trazabilidad del evento
            INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
			(
			idTipoEvento,
			Descripcion,
			IdPostByUser,
			PostInIP,
			PostTime)
			VALUES
			(13, @Descripcion, @IdUser, @InPostInIp, GETDATE());
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Manejo de errores y rollback
        IF @@TRANCOUNT > 0
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Loguear el error en la tabla DBError
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Asignar código de error de base de datos al resultado de salida
        SET @OutResultCode = 50008;
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[listarEmpleados] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[listarEmpleados]
    @InBuscar NVARCHAR(50),
    @InPostByUser NVARCHAR(50),
    @InPostInIP NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdUser INT;

        -- Inicialización del resultado de salida
        SET @OutResultCode = 0;

        -- Obtener ID del usuario que realiza la búsqueda
        SELECT @IdUser = U.Id
    FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
    WHERE U.UserName = @InPostByUser;

        -- Iniciar transacción
        BEGIN TRANSACTION

        -- Consulta según el valor de búsqueda
        IF @InBuscar IS NULL OR @InBuscar = ''
        BEGIN
        -- Caso sin búsqueda específica: listar todos los empleados activos
        SELECT E.ValorDocumentoIdentidad, E.Nombre
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
        WHERE E.Activo = 1
        ORDER BY E.Nombre DESC;

        -- Insertar evento de trazabilidad
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP,
            PostTime)
        VALUES
            (11, 'Listado completo de empleados', @IdUser, @InPostInIP, GETDATE());
    END
        ELSE IF @InBuscar LIKE '%[^0-9]%'
        BEGIN
        -- Caso de búsqueda por nombre
        SELECT E.ValorDocumentoIdentidad, E.Nombre
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
        WHERE E.Nombre LIKE '%' + @InBuscar + '%'
            AND E.Activo = 1
        ORDER BY E.Nombre DESC;

        -- Insertar evento de trazabilidad
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP,
            PostTime)
        VALUES
            (11, CONCAT('Búsqueda por nombre: ', @InBuscar), @IdUser, @InPostInIP, GETDATE());
    END
        ELSE
        BEGIN
        -- Caso de búsqueda por valor numérico de documento de identidad
        SELECT E.ValorDocumentoIdentidad, E.Nombre
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
        WHERE CAST(E.ValorDocumentoIdentidad AS VARCHAR(20)) LIKE '%' + @InBuscar + '%'
            AND E.Activo = 1
        ORDER BY E.Nombre DESC;

        -- Insertar evento de trazabilidad
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP,
            PostTime)
        VALUES
            (12, CONCAT('Búsqueda por documento: ', @InBuscar), @IdUser, @InPostInIP, GETDATE());
    END

        COMMIT TRANSACTION;
    
    END TRY
    BEGIN CATCH
        -- Manejo de errores y rollback
        IF @@TRANCOUNT > 0
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Loguear el error en la tabla DBError
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Asignar código de error de base de datos al resultado de salida
        SET @OutResultCode = 50008;
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[listarTiposMov] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[listarTiposMov]
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicialización del resultado de salida
        SET @OutResultCode = 0;

        -- Iniciar transacción
        BEGIN TRANSACTION

        -- Selección de los tipos de movimiento
        SELECT TM.Nombre, TM.TipoAccion
		FROM [sistemaEmpleadosTP2].[dbo].[TipoMovimiento] TM;

        -- Finalizar transacción
        COMMIT TRANSACTION;
    
    END TRY
    BEGIN CATCH
        -- Manejo de errores y rollback
        IF @@TRANCOUNT > 0
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Insertar el error en la tabla DBError
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Asignar código de error de base de datos al resultado de salida
        SET @OutResultCode = 50008; 
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[loginUser] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[loginUser]
    @InuserName NVARCHAR(50),
    @InuserPassword NVARCHAR(50),
    @InNamePostbyUser NVARCHAR(50),
    @InPostInIP NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Declaración de variables
        DECLARE @Descripcion NVARCHAR(2000);
        DECLARE @CountIntent INT;
        DECLARE @IdUser INT;
        DECLARE @FechaActual DATETIME = GETDATE();
        DECLARE @FechaAnterior DATETIME = DATEADD(MINUTE, -30, @FechaActual);

        -- Inicializar el resultado de salida
        SET @OutResultCode = 0;

        -- Validar si el usuario existe
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
		WHERE U.UserName = @InuserName)
        BEGIN
        -- Obtener el Id del usuario
        SELECT @IdUser = U.Id
        FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
        WHERE U.UserName = @InuserName;

        -- Contar los intentos fallidos recientes
        SELECT @CountIntent = COUNT(*)
        FROM [sistemaEmpleadosTP2].[dbo].[BitacoraEvento] BE
        WHERE BE.IdPostByUser = @IdUser
            AND BE.idTipoEvento = 2
            AND BE.PostTime >= @FechaAnterior;

        -- Validar contraseña
        IF (SELECT U.Password
        FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
        WHERE U.UserName = @InuserName) = @InuserPassword
            BEGIN
            -- Verificar si el usuario ha superado el límite de intentos fallidos
            IF @CountIntent <= 5
                BEGIN
                BEGIN TRANSACTION
                -- Insertar evento de trazabilidad exitoso
                INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
                    (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
                VALUES
                    (1, '', @IdUser, @InPostInIP, GETDATE());
                COMMIT TRANSACTION;
            END
                ELSE
                BEGIN
                SET @OutResultCode = 50003;

                -- Insertar evento de bloqueo por demasiados intentos
                INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
                    (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
                VALUES
                    (3,
                        (SELECT E.Descripcion
                        FROM [sistemaEmpleadosTP2].[dbo].[Error] E
                        WHERE E.Codigo = @OutResultCode) + ', ' + CONVERT(NVARCHAR(50), @CountIntent),
                        @IdUser,
                        @InPostInIP,
                        GETDATE());

                PRINT 'Login deshabilitado.';
            END;
        END
            ELSE
            BEGIN
            SET @OutResultCode = 50002;

            -- Insertar evento de contraseña incorrecta
            INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
                (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
            VALUES
                (2,
                    (SELECT E.Descripcion
                    FROM [sistemaEmpleadosTP2].[dbo].[Error] E
                    WHERE E.Codigo = @OutResultCode) + ', ' + CONVERT(NVARCHAR(50), @CountIntent),
                    @IdUser,
                    @InPostInIP,
                    GETDATE());

            PRINT 'Contraseña incorrecta.';
        END;
    END
        ELSE
        BEGIN
        SET @OutResultCode = 50001;

        -- Insertar evento de usuario no existente
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (
            2,
            (SELECT E.Descripcion
            FROM [sistemaEmpleadosTP2].[dbo].[Error] E
            WHERE E.Codigo = @OutResultCode) + ', ' + @InuserName,
            1,
            @InPostInIP,
            GETDATE());

        PRINT 'Nombre de usuario no existe.';
    END;

    END TRY
    BEGIN CATCH
        -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Registrar el error en la tabla DBError
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Asignar el código de error de la base de datos al resultado de salida
        SET @OutResultCode = 50008;
    END CATCH

    SET NOCOUNT OFF;
END;
GO

USE [sistemaEmpleadosTP2]
GO

/****** Object:  StoredProcedure [dbo].[updateEmpleado] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[updateEmpleado]
    @InvalorDocIdent INT,
    @InNuevoDocIdent INT,
    @Innombre NVARCHAR(50),
    @InidPuesto INT,
    @InNamePostbyUser NVARCHAR(50),
    @InPostInIP NVARCHAR(50),
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Declaraciones de variables
        DECLARE @Descripcion NVARCHAR(2000);
        DECLARE @DescripcionError NVARCHAR(500);
        DECLARE @IdUser INT;
        DECLARE @NombreAnt NVARCHAR(50);
        DECLARE @IdPuestoAnt INT;
        DECLARE @SaldoActual INT;

        -- Obtener valores actuales del empleado
        SELECT
        @NombreAnt = E.Nombre,
        @IdPuestoAnt = E.IdPuesto,
        @SaldoActual = E.SaldoVacaciones
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
		WHERE E.ValorDocumentoIdentidad = @InvalorDocIdent;

        -- Descripción de la actualización
        SET @Descripcion = COALESCE(CONVERT(VARCHAR(100), @InvalorDocIdent), '') + ', ' +
                           COALESCE(@NombreAnt, '') + ', ' +
                           COALESCE(CONVERT(VARCHAR(100), @IdPuestoAnt), '') + ', ' +
                           COALESCE(CONVERT(VARCHAR(100), @InNuevoDocIdent), '') + ', ' +
                           COALESCE(@Innombre, '') + ', ' +
                           COALESCE(CONVERT(VARCHAR(100), @InidPuesto), '') + ', ' +
                           COALESCE(CONVERT(VARCHAR(100), @SaldoActual), '');

        -- Inicializar resultado de salida
        SET @OutResultCode = 0;

        -- Obtener Id del usuario que ejecuta la acción
        SELECT @IdUser = U.Id
		FROM [sistemaEmpleadosTP2].[dbo].[Usuario] U
		WHERE U.UserName = @InNamePostbyUser;

        -- Validar si el empleado con el documento de identidad actual existe
        IF EXISTS (SELECT 1
		FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
		WHERE E.ValorDocumentoIdentidad = @InvalorDocIdent)
        BEGIN
        -- Validar si el nuevo documento de identidad no está duplicado
        IF NOT EXISTS (SELECT 1
        FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
        WHERE E.ValorDocumentoIdentidad = @InNuevoDocIdent)
            BEGIN
            -- Validar si el nuevo nombre no está duplicado
            IF NOT EXISTS (SELECT 1
            FROM [sistemaEmpleadosTP2].[dbo].[Empleado] E
            WHERE E.Nombre = @Innombre)
                BEGIN
                -- Iniciar transacción para la actualización
                BEGIN TRANSACTION
                -- Actualizar empleado
                UPDATE Empleado
                        SET 
                            Nombre = @Innombre,
                            ValorDocumentoIdentidad = @InNuevoDocIdent,
                            IdPuesto = @InidPuesto
                        WHERE 
                            ValorDocumentoIdentidad = @InvalorDocIdent;

                -- Insertar trazabilidad de la operación
                INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
                    (
                    idTipoEvento,
                    Descripcion,
                    IdPostByUser,
                    PostInIP,
                    PostTime)
                VALUES
                    (8, @Descripcion, @IdUser, @InPostInIP, GETDATE());
                COMMIT TRANSACTION;
            END
                ELSE
                BEGIN
                -- Manejo de error: el nombre ya existe
                SET @OutResultCode = 50007;
                SELECT @DescripcionError = E.Descripcion
                FROM [sistemaEmpleadosTP2].[dbo].[Error] E
                WHERE E.Codigo = @OutResultCode;

                -- Insertar trazabilidad del error
                INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
                    (
                    idTipoEvento,
                    Descripcion,
                    IdPostByUser,
                    PostInIP,
                    PostTime)
                VALUES
                    (5, @DescripcionError + ', ' + @Descripcion, @IdUser, @InPostInIP, GETDATE());

                PRINT 'Empleado con mismo nombre ya existe en actualización.';
            END;
        END;
            ELSE
            BEGIN
            -- Manejo de error: el documento de identidad ya existe
            SET @OutResultCode = 50006;
            SELECT @DescripcionError = E.Descripcion
            FROM [sistemaEmpleadosTP2].[dbo].[Error] E
            WHERE E.Codigo = @OutResultCode;

            -- Insertar trazabilidad del error
            INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
                (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
            VALUES
                (5, @DescripcionError + ', ' + @Descripcion, @IdUser, @InPostInIP, GETDATE());

            PRINT 'Empleado con ValorDocumentoIdentidad ya existe en actualización.';
        END;
    END
        ELSE
        BEGIN
        -- Manejo de error: el empleado no existe
        SET @OutResultCode = 50012;
        SELECT @DescripcionError = E.Descripcion
        FROM [sistemaEmpleadosTP2].[dbo].[Error] E
        WHERE E.Codigo = @OutResultCode;

        -- Insertar trazabilidad del error
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[BitacoraEvento]
            (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
        VALUES
            (5, @DescripcionError + ', ' + @Descripcion, @IdUser, @InPostInIP, GETDATE());

        PRINT 'No existe el empleado.';
    END;

    END TRY
    BEGIN CATCH
        -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
    END;

        -- Insertar el error en la tabla DBError
        INSERT INTO [sistemaEmpleadosTP2].[dbo].[DBError]
        (ErrorUsername, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
    VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        -- Asignar el código de error de la base de datos al resultado de salida
        SET @OutResultCode = 50008;
    END CATCH

    SET NOCOUNT OFF;
END;
GO
