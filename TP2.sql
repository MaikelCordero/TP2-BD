CREATE DATABASE TPDOS;
GO

USE TPDOS;
GO

CREATE TABLE dbo.Empleadoo (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(128) NOT NULL,
    IDENTIDAD VARCHAR(128) NOT NULL,
	IdPuesto VARCHAR(128) NOT NULL,
);
GO

CREATE PROCEDURE dbo.sp_Listarr
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            e.Id, 
            e.Nombre, 
            e.IDENTIDAD,
			e.IdPuesto
        FROM 
            dbo.Empleadoo AS e;
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE dbo.sp_Obtenerr
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            e.Id, 
            e.Nombre, 
            e.IDENTIDAD,
			e.IdPuesto
        FROM 
            dbo.Empleadoo AS e
        WHERE 
            e.Id = @Id;
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE dbo.sp_Guardarr
    @Nombre VARCHAR(128),
    @IDENTIDAD VARCHAR(128),
	@IdPuesto VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.Empleadoo (Nombre, IDENTIDAD, IdPuesto) 
        VALUES (@Nombre, @IDENTIDAD, @IdPuesto);
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE dbo.sp_Editarr
	@Id INT,  
    @Nombre VARCHAR(128),
    @IDENTIDAD VARCHAR(128),
	@IdPuesto VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Empleadoo
        SET 
            Nombre = @Nombre,
            IDENTIDAD = @IDENTIDAD,
			IdPuesto = @IdPuesto
        WHERE 
            Id = @Id;
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE dbo.sp_Eliminarr
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DELETE FROM dbo.Empleadoo
        WHERE Id = @Id;
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE dbo.sp_FiltrarEmpleados
    @Nombre VARCHAR(128) = NULL,   -- Parámetro opcional para el nombre
    @IDENTIDAD VARCHAR(128) = NULL -- Parámetro opcional para la identidad
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Seleccionamos los empleados aplicando los filtros si los parámetros no son NULL
        SELECT 
            e.Id, 
            e.Nombre, 
            e.IDENTIDAD,
            e.IdPuesto
        FROM 
            dbo.Empleadoo AS e
        WHERE
            (@Nombre IS NULL OR e.Nombre LIKE '%' + @Nombre + '%') -- Filtra por nombre si está proporcionado
            AND (@IDENTIDAD IS NULL OR e.IDENTIDAD = @IDENTIDAD);  -- Filtra por identidad si está proporcionada
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

SELECT * FROM dbo.Empleadoo