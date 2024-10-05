USE [sistemaEmpleadosTP2]
GO

/****** Object:  Table [dbo].[BitacoraEvento] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BitacoraEvento](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[idTipoEvento] [int] NOT NULL,
	[Descripcion] [nvarchar](2000) NOT NULL,
	[IdPostByUser] [int] NOT NULL,
	[PostInIP] [nvarchar](50) NOT NULL,
	[PostTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BitacoraEvento] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BitacoraEvento]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraEvento_TipoEvento] FOREIGN KEY([idTipoEvento])
REFERENCES [dbo].[TipoEvento] ([Id])
GO

ALTER TABLE [dbo].[BitacoraEvento] CHECK CONSTRAINT [FK_BitacoraEvento_TipoEvento]
GO

ALTER TABLE [dbo].[BitacoraEvento]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraEvento_Usuario] FOREIGN KEY([IdPostByUser])
REFERENCES [dbo].[Usuario] ([Id])
GO

ALTER TABLE [dbo].[BitacoraEvento] CHECK CONSTRAINT [FK_BitacoraEvento_Usuario]
GO


/****** Object:  Table [dbo].[DBError] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DBError](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ErrorUserName] [nvarchar](50) NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorState] [nvarchar](50) NOT NULL,
	[ErrorSeverity] [nvarchar](50) NOT NULL,
	[ErrorLine] [int] NOT NULL,
	[ErrorProcedure] [nvarchar](50) NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL,
	[ErrorDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DBError] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Empleado] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Empleado](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPuesto] [int] NOT NULL,
	[ValorDocumentoIdentidad] [int] NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[FechaContratacion] [date] NOT NULL,
	[SaldoVacaciones] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Puesto] FOREIGN KEY([IdPuesto])
REFERENCES [dbo].[Puesto] ([Id])
GO

ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [FK_Empleado_Puesto]
GO


/****** Object:  Table [dbo].[Error] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Error](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [nvarchar](50) NOT NULL,
	[Descripcion] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Movimiento]    Script Date: 4/10/2024 21:55:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Movimiento](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdEmpleado] [int] NOT NULL,
	[IdTipoMovimiento] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Monto] [int] NOT NULL,
	[NuevoSaldo] [int] NOT NULL,
	[IdPostByUser] [int] NOT NULL,
	[PostInIP] [nvarchar](50) NOT NULL,
	[PostTime] [varchar](10) NOT NULL,
 CONSTRAINT [PK_Movimiento] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Movimiento]  WITH CHECK ADD  CONSTRAINT [FK_Movimiento_TipoMovimiento] FOREIGN KEY([IdTipoMovimiento])
REFERENCES [dbo].[TipoMovimiento] ([Id])
GO

ALTER TABLE [dbo].[Movimiento] CHECK CONSTRAINT [FK_Movimiento_TipoMovimiento]
GO

ALTER TABLE [dbo].[Movimiento]  WITH CHECK ADD  CONSTRAINT [FK_Movimiento_Usuario] FOREIGN KEY([IdPostByUser])
REFERENCES [dbo].[Usuario] ([Id])
GO

ALTER TABLE [dbo].[Movimiento] CHECK CONSTRAINT [FK_Movimiento_Usuario]
GO

ALTER TABLE [dbo].[Movimiento]  WITH CHECK ADD  CONSTRAINT [FK_Movimiento_Empleado] FOREIGN KEY([IdEmpleado])
REFERENCES [dbo].[Empleado] ([Id])
GO

ALTER TABLE [dbo].[Movimiento] CHECK CONSTRAINT [FK_Movimiento_Empleado]
GO


/****** Object:  Table [dbo].[Puesto] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Puesto](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[SalarioPorHora] [int] NOT NULL,
 CONSTRAINT [PK_Puesto] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[TipoEvento] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TipoEvento](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TipoEvento] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[TipoMovimiento] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TipoMovimiento](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[TipoAccion] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TipoMovimiento] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Usuario] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Usuario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

