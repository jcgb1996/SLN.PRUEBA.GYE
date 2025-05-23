USE [MG_PRUEBA]
GO
/****** Object:  Table [dbo].[Rol]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rol](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Descripcion] [varchar](255) NULL,
	[UsuarioCreacion] [varchar](50) NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioModificacion] [varchar](50) NULL,
	[FechaModificacion] [datetime] NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Solicitudes]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Solicitudes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](500) NULL,
	[UsuarioCreacion] [varchar](50) NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioModificacion] [varchar](50) NULL,
	[FechaModificacion] [datetime] NULL,
	[EstadoSolicitud] [int] NOT NULL,
	[SupervisorId] [int] NULL,
	[FechaAprobacion] [datetime] NULL,
	[UsuarioId] [int] NOT NULL,
	[Nombre] [varchar](200) NULL,
	[DireccionSolicitante] [varchar](500) NULL,
	[TipoCompra] [int] NOT NULL,
	[FechaEsperada] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuario]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RolId] [int] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Apellido] [varchar](100) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[Contrasena] [varchar](255) NOT NULL,
	[UsuarioCreacion] [varchar](50) NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[UsuarioModificacion] [varchar](50) NULL,
	[FechaModificacion] [datetime] NULL,
	[Estado] [bit] NOT NULL,
	[NombreUsuario] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Rol] ADD  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [dbo].[Rol] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [dbo].[Solicitudes] ADD  DEFAULT ((0)) FOR [EstadoSolicitud]
GO
ALTER TABLE [dbo].[Solicitudes] ADD  DEFAULT ((0)) FOR [TipoCompra]
GO
ALTER TABLE [dbo].[Solicitudes] ADD  DEFAULT ((0)) FOR [FechaEsperada]
GO
ALTER TABLE [dbo].[Usuario] ADD  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [dbo].[Usuario] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [dbo].[Solicitudes]  WITH CHECK ADD  CONSTRAINT [FK_Solicitudes_Supervisor] FOREIGN KEY([SupervisorId])
REFERENCES [dbo].[Usuario] ([Id])
GO
ALTER TABLE [dbo].[Solicitudes] CHECK CONSTRAINT [FK_Solicitudes_Supervisor]
GO
ALTER TABLE [dbo].[Solicitudes]  WITH CHECK ADD  CONSTRAINT [FK_Solicitudes_UsuarioCreacion] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[Usuario] ([Id])
GO
ALTER TABLE [dbo].[Solicitudes] CHECK CONSTRAINT [FK_Solicitudes_UsuarioCreacion]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD FOREIGN KEY([RolId])
REFERENCES [dbo].[Rol] ([Id])
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarSolicitud]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ActualizarSolicitud]
    @IdSolicitud INT,
    @Descripcion VARCHAR(500),
    @UsuarioCreacion VARCHAR(50),
    @Nombre VARCHAR(200),
    @DireccionSolicitante VARCHAR(500),
    @EstadoSolicitud INT,
    @TipoCompra INT,
    @FechaSolicitud DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioID INT;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Usuario
        WHERE NombreUsuario = @UsuarioCreacion
    )
    BEGIN
        THROW 50001, 'El usuario no existe.', 1;
    END

    SELECT @UsuarioID = Id
    FROM dbo.Usuario
    WHERE NombreUsuario = @UsuarioCreacion;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Solicitudes
        WHERE Id = @IdSolicitud
    )
    BEGIN
        THROW 50002, 'La solicitud no existe.', 1;
    END

    UPDATE dbo.Solicitudes
    SET 
        Descripcion = @Descripcion,
        UsuarioModificacion = @UsuarioCreacion,
        FechaModificacion = GETDATE(),
        EstadoSolicitud = @EstadoSolicitud,
        UsuarioId = @UsuarioID,
        Nombre = @Nombre,
        DireccionSolicitante = @DireccionSolicitante,
        TipoCompra = @TipoCompra,
        FechaEsperada = @FechaSolicitud
    WHERE Id = @IdSolicitud;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ConsultarSolicitudesPendientes]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ConsultarSolicitudesPendientes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.Id,
        s.Descripcion,
        s.Monto,
        s.FechaEsperada,
        s.EstadoSolicitud,
        s.FechaCreacion,
        s.FechaAprobacion,
        s.SupervisorId,
        u.Nombre + ' ' + u.Apellido AS NombreUsuarioCreacion,
		u.RolId as Rol
    FROM dbo.Solicitudes s
    INNER JOIN dbo.Usuario u ON s.UsuarioId = u.Id
    WHERE s.EstadoSolicitud = 0
    ORDER BY s.FechaCreacion DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ConsultarSolicitudesPorEstado]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[sp_ConsultarSolicitudesPorEstado]
@estado int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.Id,
        s.Descripcion,
        s.Monto,
        s.FechaEsperada,
        s.EstadoSolicitud,
        s.FechaCreacion,
        s.FechaAprobacion,
        s.SupervisorId,
        u.Nombre + ' ' + u.Apellido AS Nombre
    FROM dbo.Solicitudes s
    INNER JOIN dbo.Usuario u ON s.UsuarioId = u.Id
    WHERE s.EstadoSolicitud = @estado
    ORDER BY s.FechaCreacion DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ConsultarSolicitudesPorUsuario]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ConsultarSolicitudesPorUsuario]
    @UsuarioCreacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Usuario
        WHERE NombreUsuario = @UsuarioCreacion
    )
    BEGIN
        THROW 50001, 'El usuario no existe.', 1;
    END

    SELECT 
         [Id]
		 ,Nombre
		,[Descripcion]		
		,[EstadoSolicitud]
		,[UsuarioId]
		,[Nombre]
		,[DireccionSolicitante]
		,[TipoCompra]
		,FechaEsperada
    FROM dbo.Solicitudes
    WHERE UsuarioCreacion = @UsuarioCreacion
    ORDER BY FechaCreacion DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ConsultarSolicitudPorId]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ConsultarSolicitudPorId]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        Descripcion,
        Monto,
        FechaEsperada,
        EstadoSolicitud,
        FechaCreacion,
        FechaAprobacion,
        SupervisorId,
        UsuarioId,
        UsuarioModificacion,
        FechaModificacion
    FROM dbo.Solicitudes
    WHERE Id = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarSolicitud]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[sp_EliminarSolicitud]
    @IdSolicitud INT,
    @UsuarioEliminacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioID INT;

    -- Verificar si el usuario existe
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Usuario
        WHERE NombreUsuario = @UsuarioEliminacion
    )
    BEGIN
        THROW 50001, 'El usuario no existe.', 1;
    END

    SELECT @UsuarioID = Id
    FROM dbo.Usuario
    WHERE NombreUsuario = @UsuarioEliminacion;

    -- Verificar si la solicitud existe
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Solicitudes
        WHERE Id = @IdSolicitud
    )
    BEGIN
        THROW 50002, 'La solicitud no existe.', 1;
    END

    -- Actualizar la solicitud (eliminación lógica)
    UPDATE dbo.Solicitudes
    SET 
        EstadoSolicitud = 0,
        UsuarioModificacion = @UsuarioEliminacion,
        FechaModificacion = GETDATE()
    WHERE Id = @IdSolicitud;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_LoginUsuario]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_LoginUsuario]
    @NombreUsuario VARCHAR(30),
    @Contrasena VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
		U.NombreUsuario as Usuario,
        U.Id,
        U.Nombre,
        U.Apellido,
        U.Email,
        U.RolId,
        R.Nombre AS NombreRol,
        U.Estado
    FROM dbo.Usuario U
    INNER JOIN dbo.Rol R ON U.RolId = R.Id
    WHERE U.NombreUsuario = @NombreUsuario
      AND U.Contrasena = @Contrasena
      AND U.Estado = 1; 
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_RegistrarSolicitud]    Script Date: 12/5/2025 8:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_RegistrarSolicitud]
    @Descripcion VARCHAR(500),
    @UsuarioCreacion VARCHAR(50),
    @Nombre VARCHAR(200),
    @DireccionSolicitante VARCHAR(500),
    @EstadoSolicitud INT,
    @TipoCompra INT,
    @FechaSolicitud DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioID INT;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Usuario
        WHERE NombreUsuario = @UsuarioCreacion
    )
    BEGIN
        THROW 50001, 'El usuario no existe.', 1;
    END

    SELECT @UsuarioID = Id
    FROM dbo.Usuario
    WHERE NombreUsuario = @UsuarioCreacion;

    INSERT INTO dbo.Solicitudes (
        Descripcion,
        UsuarioCreacion,
        FechaCreacion,
        UsuarioModificacion,
        FechaModificacion,
        EstadoSolicitud,
        UsuarioId,
        Nombre,
        DireccionSolicitante,
        TipoCompra,
        FechaAprobacion,
        SupervisorId,
        FechaEsperada
    )
    VALUES (
        @Descripcion,
        @UsuarioCreacion,
        GETDATE(),
        NULL,
        NULL,
        @EstadoSolicitud,
        @UsuarioID,
        @Nombre,
        @DireccionSolicitante,
        @TipoCompra,      
        NULL,
        NULL,
        @FechaSolicitud
    );
END



GO
