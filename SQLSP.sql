USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[consultEmpleado]    Script Date: 22/4/2024 22:58:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[consultEmpleado]
	@valorDocIdent int,
	@NamePostbyUser nvarchar(50),
	@PostInIP nvarchar(50),
	@OutResult int OUTPUT
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent)
	BEGIN
		BEGIN TRANSACTION
			SELECT @Nombre = Nombre FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent;

			SET @Descripcion = 'Consulta del empleado, '+
						CONVERT(VARCHAR(100), @valorDocIdent) + ', ' +
						@Nombre;
            --consulta    
			SELECT 
				E.ValorDocumentoIdentidad,
				E.Nombre,
				P.Nombre 'Puesto',
				E.SaldoVacaciones
			FROM Empleado E
				inner join Puesto P on P.Id = E.IdPuesto
			WHERE 
				E.ValorDocumentoIdentidad = @valorDocIdent

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @Descripcion, @IdUser, @PostInIP, GETDATE());
		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (11, 'Se intento consultar el empleado, ' + CONVERT(VARCHAR(100), @valorDocIdent), @IdUser, @PostInIP, GETDATE());

		PRINT 'No existe el empleado.';
	END;
END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[consultMovim]    Script Date: 22/4/2024 22:58:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[consultMovim]
@valorDocIdent int,
@NamePostbyUser nvarchar(50),
@PostInIP nvarchar(50),
@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent)
	BEGIN
		BEGIN TRANSACTION
			SELECT @Nombre = Nombre FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent;

			SET @Descripcion = 'Consulta moviminetos del empleado, '+
						CONVERT(VARCHAR(100), @valorDocIdent) + ', ' +
						@Nombre;
			--consulta
			SELECT 
				M.Fecha,
				T.Nombre,
				M.Monto,
				M.NuevoSaldo,
				M.IdPostByUser,
				M.PostInIP,
				M.PostTime
			FROM Movimiento M
				inner join TipoMovimiento T on M.IdTipoMovimiento = T.Id 
				inner join Empleado E on M.IdEmpleado = E.ValorDocumentoIdentidad
			WHERE 
				M.IdEmpleado = @valorDocIdent
			ORDER BY M.Fecha DESC

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @Descripcion, @IdUser, @PostInIP, GETDATE());

		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (15, 'Se intento consultar los moviminetos del empleado, ' + CONVERT(VARCHAR(100), @valorDocIdent), @IdUser, @PostInIP, GETDATE());

		PRINT 'No existe el empleado.';
	END;
END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[deletEmpleado]    Script Date: 22/4/2024 22:58:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deletEmpleado]
	@valorDocIdent int,
	@NamePostbyUser nvarchar(50),
	@PostInIP nvarchar(50),
	@OutResult int OUTPUT
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

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent AND (SELECT Activo FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent) = 1)
	BEGIN
		BEGIN TRANSACTION
			SELECT @Nombre = Nombre FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent;
			SELECT @IdPuesto = IdPuesto FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent;
			SELECT @NombrePuesto = Nombre FROM Puesto WHERE Id = @IdPuesto;
			SELECT @SaldoVac = SaldoVacaciones FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent;

			SET @Descripcion = CONVERT(VARCHAR(100), @valorDocIdent) + ', ' +
					  @Nombre + ', ' +
					  @NombrePuesto + ', ' + 
					  CONVERT(VARCHAR(100), @SaldoVac);
                

			--update
			UPDATE  Empleado 
			SET 
				Activo = 0
			WHERE 
				ValorDocumentoIdentidad = @valorDocIdent

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (10, @Descripcion, @IdUser, @PostInIP, GETDATE());
		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (9, CONVERT(NVARCHAR(100),@valorDocIdent), @IdUser, @PostInIP,GETDATE());

		PRINT 'No existe el empleado o ya fue eliminado.';
	END;
END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[insertEmpleado]    Script Date: 22/4/2024 22:59:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[insertEmpleado]
    @documIdentidad int,
	@nombre nvarchar(50),
	@IdPuesto int,
	@NamePostbyUser nvarchar(50),
	@PostInIP nvarchar(50),
	@OutResult int OUTPUT
AS
BEGIN
	
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @Descripcion nvarchar(150);
	DECLARE @IdUser int;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	
	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @documIdentidad)
	BEGIN
		SET @OutResult = 50004;
		SELECT @Descripcion = Descripcion FROM Error WHERE Codigo = @OutResult;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (5, CONVERT(NVARCHAR(250),@Descripcion + ', ' + CONVERT(NVARCHAR(50), @documIdentidad) + ', ' + @nombre + ', ' + (SELECT nombre FROM Puesto WHERE Puesto.Id = @IdPuesto)), @IdUser, @PostInIP, GETDATE());


		PRINT 'El valorDocumentoIdentidad ya existe en la base de datos.';
		RETURN;
	END;

	ELSE IF EXISTS (SELECT 1 FROM Empleado WHERE Nombre = @nombre)
	BEGIN
		SET @OutResult = 50005;
		SELECT @Descripcion = Descripcion FROM Error WHERE Codigo = @OutResult;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (5, CONVERT(NVARCHAR(250),@Descripcion + ', ' + CONVERT(NVARCHAR(50), @documIdentidad) + ', ' + @nombre + ', ' + (SELECT nombre FROM Puesto WHERE Puesto.Id = @IdPuesto)), @IdUser, @PostInIP,GETDATE());

		PRINT 'El nombre del empleado ya existe en la base de datos.';
		RETURN;
	END;

	ELSE
	BEGIN
		BEGIN TRANSACTION 
			--incersion
			INSERT 
			INTO 
				Empleado (IdPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, Activo) 
			VALUES 
				(@IdPuesto, @documIdentidad, @nombre, GETDATE(), 0, 1); 

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (6, (CONVERT(NVARCHAR(250), @documIdentidad) + ', ' + @nombre + ', ' + (select nombre from Puesto where Puesto.Id = @IdPuesto)), @IdUser, @PostInIP, GETDATE());
		COMMIT TRANSACTION 
	END;

END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[insertMovimiento]    Script Date: 22/4/2024 22:59:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[insertMovimiento]
    @nombreEmpl nvarchar(50),
	@nombreMov nvarchar(50),
	@Fecha DATE,
	@Monto int,
	@NamePostbyUser nvarchar(50),
	@PostInIp nvarchar(50),
	@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	DECLARE @IdEmpleado int;
	DECLARE @IdTipoMov int;
	DECLARE @SaldoActual int;
	DECLARE @NuevoSaldo int;
	DECLARE @TipoAccion NVARCHAR(50);

	SELECT @IdEmpleado = ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @nombreEmpl;
	SELECT @IdTipoMov = Id FROM TipoMovimiento WHERE Nombre = @nombreMov;
	SELECT @SaldoActual = SaldoVacaciones FROM Empleado WHERE Nombre = @nombreEmpl;
	SELECT @TipoAccion = TipoAccion FROM TipoMovimiento WHERE Nombre = @nombreMov;
	SELECT @Nombre = Nombre FROM Empleado WHERE Nombre = @nombreEmpl;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	--verifica el tipo de movimiento
	IF (@TipoAccion = 'Credito')
	BEGIN
		SET @NuevoSaldo = @SaldoActual + @monto;
	END;
	ELSE
	BEGIN
		SET @NuevoSaldo = @SaldoActual - @monto;
		SET @Monto = -(@Monto);
	END;
	

	--verifica si el nuevo saldo es menor a negativo
	IF (@NuevoSaldo >= 0)
	BEGIN
		BEGIN TRANSACTION

			SET @Descripcion = CONVERT(VARCHAR(100), (SELECT ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @nombreEmpl)) + ', ' +
						@Nombre+', '+
						CONVERT(VARCHAR(50),@NuevoSaldo)+', '+
						@nombreMov+', '+
						CONVERT(VARCHAR(50),@Monto)

			--insercion
			INSERT 
			INTO 
				Movimiento(IdEmpleado, IdTipoMovimiento, Fecha, Monto, NuevoSaldo, IdPostByUser, PostInIP, PostTime) 
			VALUES 
				(@IdEmpleado, @IdTipoMov, @Fecha, @Monto, @NuevoSaldo, @IdUser, @PostInIp, CONVERT(VARCHAR(10), GETDATE(), 101)); 

			UPDATE  Empleado 
			SET 
				SaldoVacaciones = @NuevoSaldo
			WHERE 
				Nombre = @nombreEmpl

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (14, @Descripcion, @IdUser, @PostInIP,GETDATE());

		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50011;

		SET @Descripcion = (SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+
					CONVERT(VARCHAR(100), (SELECT ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @nombreEmpl)) + ', ' +
					@Nombre+', '+
					CONVERT(VARCHAR(100),@SaldoActual)+', '+
					@nombreMov+', '+
					CONVERT(VARCHAR(50),@Monto)

		--trazabilidad 

		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (13, @Descripcion, @IdUser, @PostInIP, GETDATE());

		PRINT 'EL monto es mayor al saldo de vacaciones.';
	END;

END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[IntentoInsertMovimiento]    Script Date: 22/4/2024 22:59:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IntentoInsertMovimiento]
    @nombreEmpl nvarchar(50),
	@nombreMov nvarchar(50),
	@Monto int,
	@NamePostbyUser nvarchar(50),
	@PostInIp nvarchar(50),
	@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	DECLARE @SaldoActual int;

	SELECT @SaldoActual = SaldoVacaciones FROM Empleado WHERE Nombre = @nombreEmpl;
	SELECT @Nombre = Nombre FROM Empleado WHERE Nombre = @nombreEmpl;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	
	BEGIN TRANSACTION
		SET @Descripcion = 'El usuario canceló la inserción, '+
					CONVERT(VARCHAR(100), (SELECT ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @nombreEmpl)) + ', ' +
					@Nombre+', '+
					CONVERT(VARCHAR(100),@SaldoActual)+', '+
					@nombreMov+', '+
					CONVERT(VARCHAR(50),@Monto)

		--trazabilidad Descripción del error, Valor de documento identidad del empleado, nombre, Saldo actual, Nombre de tipo de movimiento, y monto. 

		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (13, @Descripcion, @IdUser, @PostInIP, GETDATE());
			
	COMMIT TRANSACTION 

END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[listarEmpleados]    Script Date: 22/4/2024 23:00:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[listarEmpleados]
    @varBuscar nvarchar(50),
	@NamePostbyUser nvarchar(50),
	@PostInIP nvarchar(50),
	@OutResult INT OUTPUT
AS
BEGIN
	
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @IdUser int;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	BEGIN TRANSACTION 
		IF @varBuscar is null or @varBuscar = ''
		BEGIN
			--consulta
			SELECT  
				ValorDocumentoIdentidad,
				Nombre
			FROM 
				Empleado
			WHERE
				Activo = 1
			ORDER BY 
				Nombre DESC;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @varBuscar, @IdUser, @PostInIP, GETDATE());
		END;

		ELSE IF @varBuscar LIKE '%[^0-9]%'
		BEGIN
			--consulta
			SELECT 
				ValorDocumentoIdentidad,
				Nombre
			FROM 
				Empleado
			WHERE 
				Nombre LIKE '%' + @varBuscar + '%'
				AND
				Activo = 1
			ORDER BY 
				Nombre DESC;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @varBuscar, @IdUser, @PostInIP, GETDATE());
		END;

		ELSE
		BEGIN
			--consulta
			SELECT 
				ValorDocumentoIdentidad,
				Nombre
			FROM 
				Empleado
			WHERE 
				CAST(ValorDocumentoIdentidad AS VARCHAR(20)) LIKE '%' + @varBuscar + '%'
				AND Activo = 1
			ORDER BY 
				Nombre DESC;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (12, @varBuscar, @IdUser, @PostInIP, GETDATE());
		END;
	COMMIT TRANSACTION 

END TRY
BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH

SET NOCOUNT OFF;

END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[listarTiposMov]    Script Date: 22/4/2024 23:00:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[listarTiposMov]
	@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	SET @OutResult = 0;
	BEGIN TRANSACTION
		SELECT 
			Nombre,
			TipoAccion
		FROM 
			TipoMovimiento
			
	COMMIT TRANSACTION 

END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[loginUser]    Script Date: 22/4/2024 23:00:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[loginUser]
@userName nvarchar(50),
@userPassword nvarchar(50),
@NamePostbyUser nvarchar(50),
@PostInIP nvarchar(50),
@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @countIntent int;
	DECLARE @idUser int;
	DECLARE @fechaActual DATETIME = GETDATE();
	DECLARE @fechaAnterior DATETIME = DATEADD(MINUTE, -30, @fechaActual);

	SET @OutResult = 0;

	IF EXISTS (SELECT 1 FROM Usuario WHERE UserName = @userName)
	BEGIN
		SELECT @idUser = Id FROM Usuario WHERE UserName = @userName;
		SELECT @countIntent = COUNT(*) FROM BitacoraEvento WHERE (IdPostByUser = @idUser) and (idTipoEvento = 2) and (PostTime >= @fechaAnterior);

		IF ((SELECT U.Password FROM Usuario U WHERE U.UserName = @userName) = @userPassword)
		BEGIN
			IF (@countIntent <= 5)
			BEGIN
				BEGIN TRANSACTION
				
					--trazabilidad
					INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
					VALUES (1, '', @IdUser, @PostInIP, GETDATE());

				COMMIT TRANSACTION 
			END;
			ELSE
			BEGIN
				SET @OutResult = 50003;

				--trazabilidad
				INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
				VALUES (3, 
						(SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+', '+CONVERT(NVARCHAR(50),@countIntent), 
						(SELECT ID FROM Usuario WHERE UserName = @userName), 
						@PostInIP, 
						GETDATE());

				PRINT 'login deshabilitado.';
			END;
		END;

		ELSE
		BEGIN
			SET @OutResult = 50002;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (2, 
					(SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+', '+CONVERT(NVARCHAR(50),@countIntent), 
					(SELECT ID FROM Usuario WHERE UserName = @userName), 
					@PostInIP, 
					GETDATE());

			PRINT 'contrasena no es correcta.';
		END;
	END;

	ELSE
	BEGIN
		SET @OutResult = 50001;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (2, (SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+', '+@userName, 1, @PostInIP, GETDATE());

		PRINT 'nombre no existe.';
	END;
END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO

USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[updateEmpleado]    Script Date: 22/4/2024 23:01:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[updateEmpleado]
	@valorDocIdent int,
	@NuevoDocIdent int,
	@nombre nvarchar(50),
	@idPuesto int,
	@NamePostbyUser nvarchar(50),
	@PostInIP nvarchar(50),
	@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @Descripcion2 NVARCHAR(500);
	DECLARE @IdUser INT;

	DECLARE @NombreAnt NVARCHAR(50);
	DECLARE @IdPuestoAnt INT;
	DECLARE @SaldoActual INT;

	SELECT @NombreAnt = E.Nombre
	FROM dbo.Empleado E
	WHERE E.ValorDocumentoIdentidad = @valorDocIdent;

	SELECT @IdPuestoAnt = E.IdPuesto
	FROM dbo.Empleado E
	WHERE E.ValorDocumentoIdentidad = @valorDocIdent;

	SELECT @SaldoActual = E.SaldoVacaciones
	FROM dbo.Empleado E
	WHERE E.ValorDocumentoIdentidad = @valorDocIdent;

	SET @Descripcion = COALESCE(CONVERT(VARCHAR(100), @valorDocIdent), '') + ', ' +
                  COALESCE(@NombreAnt, '') + ', ' + 
                  COALESCE(CONVERT(VARCHAR(100), @IdPuestoAnt), '') + ', ' + 
                  COALESCE(CONVERT(VARCHAR(100), @NuevoDocIdent), '') + ', ' +
                  COALESCE(@nombre, '') + ', ' +
                  COALESCE(CONVERT(VARCHAR(100), @idPuesto), '') + ', ' + 
                  COALESCE(CONVERT(VARCHAR(100), @SaldoActual), '');

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @NamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @valorDocIdent)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @NuevoDocIdent)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Empleado WHERE Nombre = @nombre)
			BEGIN
				BEGIN TRANSACTION
					--update
					UPDATE  Empleado 
					SET 
						Nombre = @nombre,
						ValorDocumentoIdentidad = @NuevoDocIdent,
						IdPuesto = @idPuesto
					WHERE 
						ValorDocumentoIdentidad = @valorDocIdent

					--trazabildad
					INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
					VALUES (8, @Descripcion , @IdUser, @PostInIP, GETDATE());
				COMMIT TRANSACTION 
			END;

			ElSE
			BEGIN
				SET @OutResult = 50007;
				SELECT @Descripcion2 = Descripcion FROM Error WHERE Codigo = @OutResult;

				--trazabilidad
				INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
				VALUES (5, @Descripcion2 +', '+ @Descripcion , @IdUser, @PostInIP, GETDATE());

				PRINT 'Empleado con mismo nombre ya existe en actualización.';
			END;
		END;

		ELSE
		BEGIN
			SET @OutResult = 50006;
			SELECT @Descripcion2 = Descripcion FROM Error WHERE Codigo = @OutResult;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (5,@Descripcion2 +', '+ @Descripcion , @IdUser, @PostInIP, GETDATE());

			PRINT 'Empleado con ValorDocumentoIdentidad ya existe en actualizacion.';
		END;
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;
		SELECT @Descripcion2 = Descripcion FROM Error WHERE Codigo = @OutResult;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (5, @Descripcion2 +', '+ @Descripcion, @IdUser, @PostInIP, GETDATE());

		PRINT 'No existe el empleado.';
	END;

END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0 
	BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	INSERT INTO dbo.DBError (DBError.ErrorUsername, DBError.ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage, ErrorDateTime)
	VALUES (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
	
	
	SET @OutResult = 50008;   -- error en BD

END CATCH
SET NOCOUNT OFF;
END;
GO



