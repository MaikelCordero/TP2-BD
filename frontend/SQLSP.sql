USE [PROYECT2JF]
GO

/****** Object:  StoredProcedure [dbo].[consultEmpleado]    Script Date: 22/4/2024 22:58:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[consultEmpleado]
	@InvalorDocIdent int,
	@InNamePostbyUser nvarchar(50),
	@InPostInIP nvarchar(50),
	@OutResult int OUTPUT
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent)
	BEGIN
		BEGIN TRANSACTION
			SELECT @Nombre = Nombre FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent;

			SET @Descripcion = 'Consulta del empleado, '+
						CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' +
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
				E.ValorDocumentoIdentidad = @InvalorDocIdent

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @Descripcion, @IdUser, @InPostInIP, GETDATE());
		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (11, 'Se intento consultar el empleado, ' + CONVERT(VARCHAR(100), @InvalorDocIdent), @IdUser, @InPostInIP, GETDATE());

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
@InvalorDocIdent int,
@InNamePostbyUser nvarchar(50),
@InPostInIP nvarchar(50),
@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent)
	BEGIN
		BEGIN TRANSACTION
			SELECT @Nombre = Nombre FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent;

			SET @Descripcion = 'Consulta moviminetos del empleado, '+
						CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' +
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
				M.IdEmpleado = @InvalorDocIdent
			ORDER BY M.Fecha DESC

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @Descripcion, @IdUser, @InPostInIP, GETDATE());

		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (15, 'Se intento consultar los moviminetos del empleado, ' + CONVERT(VARCHAR(100), @InvalorDocIdent), @IdUser, @InPostInIP, GETDATE());

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
	@InvalorDocIdent int,
	@InNamePostbyUser nvarchar(50),
	@InPostInIP nvarchar(50),
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
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent AND (SELECT Activo FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent) = 1)
	BEGIN
		BEGIN TRANSACTION
			SELECT @Nombre = Nombre FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent;
			SELECT @IdPuesto = IdPuesto FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent;
			SELECT @NombrePuesto = Nombre FROM Puesto WHERE Id = @IdPuesto;
			SELECT @SaldoVac = SaldoVacaciones FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent;

			SET @Descripcion = CONVERT(VARCHAR(100), @InvalorDocIdent) + ', ' +
					  @Nombre + ', ' +
					  @NombrePuesto + ', ' + 
					  CONVERT(VARCHAR(100), @SaldoVac);
                

			--update
			UPDATE  Empleado 
			SET 
				Activo = 0
			WHERE 
				ValorDocumentoIdentidad = @InvalorDocIdent

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (10, @Descripcion, @IdUser, @InPostInIP, GETDATE());
		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (9, CONVERT(NVARCHAR(100),@InvalorDocIdent), @IdUser, @InPostInIP,GETDATE());

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
    @IndocumIdentidad int,
	@Innombre nvarchar(50),
	@InIdPuesto int,
	@InNamePostbyUser nvarchar(50),
	@InPostInIP nvarchar(50),
	@OutResult int OUTPUT
AS
BEGIN
	
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @Descripcion nvarchar(150);
	DECLARE @IdUser int;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	
	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @IndocumIdentidad)
	BEGIN
		SET @OutResult = 50004;
		SELECT @Descripcion = Descripcion FROM Error WHERE Codigo = @OutResult;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (5, CONVERT(NVARCHAR(250),@Descripcion + ', ' + CONVERT(NVARCHAR(50), @IndocumIdentidad) + ', ' + @Innombre + ', ' + (SELECT nombre FROM Puesto WHERE Puesto.Id = @InIdPuesto)), @IdUser, @InPostInIP, GETDATE());


		PRINT 'El valorDocumentoIdentidad ya existe en la base de datos.';
		RETURN;
	END;

	ELSE IF EXISTS (SELECT 1 FROM Empleado WHERE Nombre = @Innombre)
	BEGIN
		SET @OutResult = 50005;
		SELECT @Descripcion = Descripcion FROM Error WHERE Codigo = @OutResult;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (5, CONVERT(NVARCHAR(250),@Descripcion + ', ' + CONVERT(NVARCHAR(50), @IndocumIdentidad) + ', ' + @Innombre + ', ' + (SELECT nombre FROM Puesto WHERE Puesto.Id = @InIdPuesto)), @IdUser, @InPostInIP,GETDATE());

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
				(@InIdPuesto, @IndocumIdentidad, @Innombre, GETDATE(), 0, 1); 

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (6, (CONVERT(NVARCHAR(250), @IndocumIdentidad) + ', ' + @Innombre + ', ' + (select nombre from Puesto where Puesto.Id = @InIdPuesto)), @IdUser, @InPostInIP, GETDATE());
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
    @InnombreEmpl nvarchar(50),
	@InnombreMov nvarchar(50),
	@InFecha DATE,
	@InMonto int,
	@InNamePostbyUser nvarchar(50),
	@InPostInIp nvarchar(50),
	@InOutResult int OUTPUT

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

	SELECT @IdEmpleado = ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @InnombreEmpl;
	SELECT @IdTipoMov = Id FROM TipoMovimiento WHERE Nombre = @InnombreMov;
	SELECT @SaldoActual = SaldoVacaciones FROM Empleado WHERE Nombre = @InnombreEmpl;
	SELECT @TipoAccion = TipoAccion FROM TipoMovimiento WHERE Nombre = @InnombreMov;
	SELECT @Nombre = Nombre FROM Empleado WHERE Nombre = @InnombreEmpl;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	--verifica el tipo de movimiento
	IF (@TipoAccion = 'Credito')
	BEGIN
		SET @NuevoSaldo = @SaldoActual + @InMonto;
	END;
	ELSE
	BEGIN
		SET @NuevoSaldo = @SaldoActual - @InMonto;
		SET @InMonto = -(@InMonto);
	END;
	

	--verifica si el nuevo saldo es menor a negativo
	IF (@NuevoSaldo >= 0)
	BEGIN
		BEGIN TRANSACTION

			SET @Descripcion = CONVERT(VARCHAR(100), (SELECT ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @InnombreEmpl)) + ', ' +
						@Nombre+', '+
						CONVERT(VARCHAR(50),@NuevoSaldo)+', '+
						@InnombreMov+', '+
						CONVERT(VARCHAR(50),@InMonto)

			--insercion
			INSERT 
			INTO 
				Movimiento(IdEmpleado, IdTipoMovimiento, Fecha, Monto, NuevoSaldo, IdPostByUser, PostInIP, PostTime) 
			VALUES 
				(@IdEmpleado, @IdTipoMov, @InFecha, @InMonto, @NuevoSaldo, @IdUser, @InPostInIp, CONVERT(VARCHAR(10), GETDATE(), 101)); 

			UPDATE  Empleado 
			SET 
				SaldoVacaciones = @NuevoSaldo
			WHERE 
				Nombre = @InnombreEmpl

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (14, @Descripcion, @IdUser, @InPostInIP,GETDATE());

		COMMIT TRANSACTION 
	END;

	ELSE
	BEGIN
		SET @OutResult = 50011;

		SET @Descripcion = (SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+
					CONVERT(VARCHAR(100), (SELECT ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @InnombreEmpl)) + ', ' +
					@Nombre+', '+
					CONVERT(VARCHAR(100),@SaldoActual)+', '+
					@InnombreMov+', '+
					CONVERT(VARCHAR(50),@InMonto)

		--trazabilidad 

		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (13, @Descripcion, @IdUser, @InPostInIP, GETDATE());

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
    @InnombreEmpl nvarchar(50),
	@InnombreMov nvarchar(50),
	@InMonto int,
	@InNamePostbyUser nvarchar(50),
	@InPostInIp nvarchar(50),
	@OutResult int OUTPUT

AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY
	DECLARE @Descripcion NVARCHAR(2000);
	DECLARE @IdUser INT;
	DECLARE @Nombre NVARCHAR(50);

	DECLARE @SaldoActual int;

	SELECT @SaldoActual = SaldoVacaciones FROM Empleado WHERE Nombre = @InnombreEmpl;
	SELECT @Nombre = Nombre FROM Empleado WHERE Nombre = @InnombreEmpl;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	
	BEGIN TRANSACTION
		SET @Descripcion = 'El usuario cancel� la inserci�n, '+
					CONVERT(VARCHAR(100), (SELECT ValorDocumentoIdentidad FROM Empleado WHERE Nombre = @InnombreEmpl)) + ', ' +
					@Nombre+', '+
					CONVERT(VARCHAR(100),@SaldoActual)+', '+
					@InnombreMov+', '+
					CONVERT(VARCHAR(50),@InMonto)

		--trazabilidad Descripci�n del error, Valor de documento identidad del empleado, nombre, Saldo actual, Nombre de tipo de movimiento, y monto. 

		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (13, @Descripcion, @IdUser, @InPostInIP, GETDATE());
			
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
    @InvarBuscar nvarchar(50),
	@InNamePostbyUser nvarchar(50),
	@InPostInIP nvarchar(50),
	@OutResult INT OUTPUT
AS
BEGIN
	
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @IdUser int;

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	BEGIN TRANSACTION 
		IF @InvarBuscar is null or @InvarBuscar = ''
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
			VALUES (11, @InvarBuscar, @IdUser, @InPostInIP, GETDATE());
		END;

		ELSE IF @InvarBuscar LIKE '%[^0-9]%'
		BEGIN
			--consulta
			SELECT 
				ValorDocumentoIdentidad,
				Nombre
			FROM 
				Empleado
			WHERE 
				Nombre LIKE '%' + @InvarBuscar + '%'
				AND
				Activo = 1
			ORDER BY 
				Nombre DESC;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (11, @InvarBuscar, @IdUser, @InPostInIP, GETDATE());
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
				CAST(ValorDocumentoIdentidad AS VARCHAR(20)) LIKE '%' + @InvarBuscar + '%'
				AND Activo = 1
			ORDER BY 
				Nombre DESC;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (12, @InvarBuscar, @IdUser, @InPostInIP, GETDATE());
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
@InuserName nvarchar(50),
@InuserPassword nvarchar(50),
@InNamePostbyUser nvarchar(50),
@InPostInIP nvarchar(50),
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

	IF EXISTS (SELECT 1 FROM Usuario WHERE UserName = @InuserName)
	BEGIN
		SELECT @idUser = Id FROM Usuario WHERE UserName = @InuserName;
		SELECT @countIntent = COUNT(*) FROM BitacoraEvento WHERE (IdPostByUser = @idUser) and (idTipoEvento = 2) and (PostTime >= @fechaAnterior);

		IF ((SELECT U.Password FROM Usuario U WHERE U.UserName = @InuserName) = @InuserPassword)
		BEGIN
			IF (@countIntent <= 5)
			BEGIN
				BEGIN TRANSACTION
				
					--trazabilidad
					INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
					VALUES (1, '', @IdUser, @InPostInIP, GETDATE());

				COMMIT TRANSACTION 
			END;
			ELSE
			BEGIN
				SET @OutResult = 50003;

				--trazabilidad
				INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
				VALUES (3, 
						(SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+', '+CONVERT(NVARCHAR(50),@countIntent), 
						(SELECT ID FROM Usuario WHERE UserName = @InuserName), 
						@InPostInIP, 
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
					(SELECT ID FROM Usuario WHERE UserName = @InuserName), 
					@InPostInIP, 
					GETDATE());

			PRINT 'contrasena no es correcta.';
		END;
	END;

	ELSE
	BEGIN
		SET @OutResult = 50001;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (2, (SELECT Descripcion FROM Error WHERE Codigo = @OutResult)+', '+@InuserName, 1, @InPostInIP, GETDATE());

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
	@InvalorDocIdent int,
	@InNuevoDocIdent int,
	@Innombre nvarchar(50),
	@InidPuesto int,
	@InNamePostbyUser nvarchar(50),
	@InPostInIP nvarchar(50),
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
	WHERE E.ValorDocumentoIdentidad = @InvalorDocIdent;

	SELECT @IdPuestoAnt = E.IdPuesto
	FROM dbo.Empleado E
	WHERE E.ValorDocumentoIdentidad = @InvalorDocIdent;

	SELECT @SaldoActual = E.SaldoVacaciones
	FROM dbo.Empleado E
	WHERE E.ValorDocumentoIdentidad = @InvalorDocIdent;

	SET @Descripcion = COALESCE(CONVERT(VARCHAR(100), @InvalorDocIdent), '') + ', ' +
                  COALESCE(@NombreAnt, '') + ', ' + 
                  COALESCE(CONVERT(VARCHAR(100), @IdPuestoAnt), '') + ', ' + 
                  COALESCE(CONVERT(VARCHAR(100), @InNuevoDocIdent), '') + ', ' +
                  COALESCE(@nombre, '') + ', ' +
                  COALESCE(CONVERT(VARCHAR(100), @InidPuesto), '') + ', ' + 
                  COALESCE(CONVERT(VARCHAR(100), @SaldoActual), '');

	SET @OutResult = 0;
	SELECT @IdUser = Id FROM Usuario WHERE UserName = @InNamePostbyUser;

	IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @InvalorDocIdent)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @InNuevoDocIdent)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Empleado WHERE Nombre = @Innombre)
			BEGIN
				BEGIN TRANSACTION
					--update
					UPDATE  Empleado 
					SET 
						Nombre = @Innombre,
						ValorDocumentoIdentidad = @InNuevoDocIdent,
						IdPuesto = @InidPuesto
					WHERE 
						ValorDocumentoIdentidad = @InvalorDocIdent

					--trazabildad
					INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
					VALUES (8, @Descripcion , @IdUser, @InPostInIP, GETDATE());
				COMMIT TRANSACTION 
			END;

			ElSE
			BEGIN
				SET @OutResult = 50007;
				SELECT @Descripcion2 = Descripcion FROM Error WHERE Codigo = @OutResult;

				--trazabilidad
				INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
				VALUES (5, @Descripcion2 +', '+ @Descripcion , @IdUser, @InPostInIP, GETDATE());

				PRINT 'Empleado con mismo nombre ya existe en actualizaci�n.';
			END;
		END;

		ELSE
		BEGIN
			SET @OutResult = 50006;
			SELECT @Descripcion2 = Descripcion FROM Error WHERE Codigo = @OutResult;

			--trazabilidad
			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
			VALUES (5,@Descripcion2 +', '+ @Descripcion , @IdUser, @InPostInIP, GETDATE());

			PRINT 'Empleado con ValorDocumentoIdentidad ya existe en actualizacion.';
		END;
	END;

	ELSE
	BEGIN
		SET @OutResult = 50012;
		SELECT @Descripcion2 = Descripcion FROM Error WHERE Codigo = @OutResult;

		--trazabilidad
		INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, IdPostByUser, PostInIP, PostTime)
		VALUES (5, @Descripcion2 +', '+ @Descripcion, @IdUser, @InPostInIP, GETDATE());

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



