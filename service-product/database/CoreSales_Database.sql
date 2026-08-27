/* CoreSales - SQL Server - Script completo v1.0 */
USE master;
GO
IF DB_ID(N'CoreSales') IS NULL
    CREATE DATABASE CoreSales;
GO
USE CoreSales;
GO
SET NOCOUNT ON;
GO

/*==================== CATALOGOS ====================*/
IF OBJECT_ID(N'dbo.TipoDocumento',N'U') IS NULL
CREATE TABLE dbo.TipoDocumento(
 TipoDocumentoId INT IDENTITY(1,1) NOT NULL,
 Codigo VARCHAR(10) NOT NULL,
 Nombre VARCHAR(50) NOT NULL,
 LongitudMinima TINYINT NULL,
 LongitudMaxima TINYINT NULL,
 Activo BIT NOT NULL CONSTRAINT DF_TipoDocumento_Activo DEFAULT(1),
 CONSTRAINT PK_TipoDocumento PRIMARY KEY CLUSTERED(TipoDocumentoId),
 CONSTRAINT UQ_TipoDocumento_Codigo UNIQUE(Codigo),
 CONSTRAINT UQ_TipoDocumento_Nombre UNIQUE(Nombre)
);
GO

IF OBJECT_ID(N'dbo.CategoriaProducto',N'U') IS NULL
CREATE TABLE dbo.CategoriaProducto(
 CategoriaProductoId INT IDENTITY(1,1) NOT NULL,
 Nombre VARCHAR(100) NOT NULL,
 Descripcion VARCHAR(250) NULL,
 Activo BIT NOT NULL CONSTRAINT DF_CategoriaProducto_Activo DEFAULT(1),
 CONSTRAINT PK_CategoriaProducto PRIMARY KEY CLUSTERED(CategoriaProductoId),
 CONSTRAINT UQ_CategoriaProducto_Nombre UNIQUE(Nombre)
);
GO

IF OBJECT_ID(N'dbo.Marca',N'U') IS NULL
CREATE TABLE dbo.Marca(
 MarcaId INT IDENTITY(1,1) NOT NULL,
 Nombre VARCHAR(100) NOT NULL,
 Activo BIT NOT NULL CONSTRAINT DF_Marca_Activo DEFAULT(1),
 CONSTRAINT PK_Marca PRIMARY KEY CLUSTERED(MarcaId),
 CONSTRAINT UQ_Marca_Nombre UNIQUE(Nombre)
);
GO

IF OBJECT_ID(N'dbo.TipoComprobante',N'U') IS NULL
CREATE TABLE dbo.TipoComprobante(
 TipoComprobanteId INT IDENTITY(1,1) NOT NULL,
 Codigo VARCHAR(10) NOT NULL,
 Nombre VARCHAR(50) NOT NULL,
 Activo BIT NOT NULL CONSTRAINT DF_TipoComprobante_Activo DEFAULT(1),
 CONSTRAINT PK_TipoComprobante PRIMARY KEY CLUSTERED(TipoComprobanteId),
 CONSTRAINT UQ_TipoComprobante_Codigo UNIQUE(Codigo),
 CONSTRAINT UQ_TipoComprobante_Nombre UNIQUE(Nombre)
);
GO

IF OBJECT_ID(N'dbo.EstadoVenta',N'U') IS NULL
CREATE TABLE dbo.EstadoVenta(
 EstadoVentaId INT IDENTITY(1,1) NOT NULL,
 Codigo VARCHAR(20) NOT NULL,
 Nombre VARCHAR(50) NOT NULL,
 Activo BIT NOT NULL CONSTRAINT DF_EstadoVenta_Activo DEFAULT(1),
 CONSTRAINT PK_EstadoVenta PRIMARY KEY CLUSTERED(EstadoVentaId),
 CONSTRAINT UQ_EstadoVenta_Codigo UNIQUE(Codigo),
 CONSTRAINT UQ_EstadoVenta_Nombre UNIQUE(Nombre)
);
GO

IF OBJECT_ID(N'dbo.TipoMovimientoInventario',N'U') IS NULL
CREATE TABLE dbo.TipoMovimientoInventario(
 TipoMovimientoInventarioId INT IDENTITY(1,1) NOT NULL,
 Codigo VARCHAR(20) NOT NULL,
 Nombre VARCHAR(50) NOT NULL,
 Factor SMALLINT NOT NULL,
 Activo BIT NOT NULL CONSTRAINT DF_TipoMovimientoInventario_Activo DEFAULT(1),
 CONSTRAINT PK_TipoMovimientoInventario PRIMARY KEY CLUSTERED(TipoMovimientoInventarioId),
 CONSTRAINT UQ_TipoMovimientoInventario_Codigo UNIQUE(Codigo),
 CONSTRAINT UQ_TipoMovimientoInventario_Nombre UNIQUE(Nombre),
 CONSTRAINT CK_TipoMovimientoInventario_Factor CHECK(Factor IN(-1,1))
);
GO

/*==================== CLIENTE ====================*/
IF OBJECT_ID(N'dbo.Cliente',N'U') IS NULL
CREATE TABLE dbo.Cliente(
 ClienteId BIGINT IDENTITY(1,1) NOT NULL,
 TipoDocumentoId INT NOT NULL,
 NumeroDocumento VARCHAR(20) NOT NULL,
 Nombres VARCHAR(100) NULL,
 Apellidos VARCHAR(100) NULL,
 RazonSocial VARCHAR(150) NULL,
 Email VARCHAR(150) NULL,
 Telefono VARCHAR(20) NULL,
 Direccion VARCHAR(250) NULL,
 Activo BIT NOT NULL CONSTRAINT DF_Cliente_Activo DEFAULT(1),
 FechaRegistro DATETIME2(0) NOT NULL CONSTRAINT DF_Cliente_FechaRegistro DEFAULT(SYSDATETIME()),
 CONSTRAINT PK_Cliente PRIMARY KEY CLUSTERED(ClienteId),
 CONSTRAINT UQ_Cliente_NumeroDocumento UNIQUE(NumeroDocumento),
 CONSTRAINT FK_Cliente_TipoDocumento FOREIGN KEY(TipoDocumentoId) REFERENCES dbo.TipoDocumento(TipoDocumentoId),
 CONSTRAINT CK_Cliente_DatosIdentificacion CHECK(
   (RazonSocial IS NOT NULL AND LEN(LTRIM(RTRIM(RazonSocial)))>0)
   OR (Nombres IS NOT NULL AND Apellidos IS NOT NULL)
 )
);
GO

/*==================== PRODUCTO ====================*/
IF OBJECT_ID(N'dbo.Producto',N'U') IS NULL
CREATE TABLE dbo.Producto(
 ProductoId BIGINT IDENTITY(1,1) NOT NULL,
 Codigo VARCHAR(30) NOT NULL,
 Nombre VARCHAR(150) NOT NULL,
 Descripcion VARCHAR(500) NULL,
 CategoriaProductoId INT NOT NULL,
 MarcaId INT NULL,
 PrecioCompra DECIMAL(12,2) NOT NULL,
 PrecioVenta DECIMAL(12,2) NOT NULL,
 StockMinimo INT NOT NULL CONSTRAINT DF_Producto_StockMinimo DEFAULT(0),
 Activo BIT NOT NULL CONSTRAINT DF_Producto_Activo DEFAULT(1),
 FechaRegistro DATETIME2(0) NOT NULL CONSTRAINT DF_Producto_FechaRegistro DEFAULT(SYSDATETIME()),
 CONSTRAINT PK_Producto PRIMARY KEY CLUSTERED(ProductoId),
 CONSTRAINT UQ_Producto_Codigo UNIQUE(Codigo),
 CONSTRAINT FK_Producto_CategoriaProducto FOREIGN KEY(CategoriaProductoId) REFERENCES dbo.CategoriaProducto(CategoriaProductoId),
 CONSTRAINT FK_Producto_Marca FOREIGN KEY(MarcaId) REFERENCES dbo.Marca(MarcaId),
 CONSTRAINT CK_Producto_PrecioCompra CHECK(PrecioCompra>=0),
 CONSTRAINT CK_Producto_PrecioVenta CHECK(PrecioVenta>=0),
 CONSTRAINT CK_Producto_StockMinimo CHECK(StockMinimo>=0)
);
GO

/*==================== INVENTARIO ====================*/
IF OBJECT_ID(N'dbo.Inventario',N'U') IS NULL
CREATE TABLE dbo.Inventario(
 InventarioId BIGINT IDENTITY(1,1) NOT NULL,
 ProductoId BIGINT NOT NULL,
 StockActual INT NOT NULL CONSTRAINT DF_Inventario_StockActual DEFAULT(0),
 FechaActualizacion DATETIME2(0) NOT NULL CONSTRAINT DF_Inventario_FechaActualizacion DEFAULT(SYSDATETIME()),
 CONSTRAINT PK_Inventario PRIMARY KEY CLUSTERED(InventarioId),
 CONSTRAINT UQ_Inventario_Producto UNIQUE(ProductoId),
 CONSTRAINT FK_Inventario_Producto FOREIGN KEY(ProductoId) REFERENCES dbo.Producto(ProductoId),
 CONSTRAINT CK_Inventario_StockActual CHECK(StockActual>=0)
);
GO

/*==================== MOVIMIENTOS ====================*/
IF OBJECT_ID(N'dbo.MovimientoInventario',N'U') IS NULL
CREATE TABLE dbo.MovimientoInventario(
 MovimientoInventarioId BIGINT IDENTITY(1,1) NOT NULL,
 ProductoId BIGINT NOT NULL,
 TipoMovimientoInventarioId INT NOT NULL,
 Cantidad INT NOT NULL,
 StockAnterior INT NOT NULL,
 StockPosterior INT NOT NULL,
 Referencia VARCHAR(100) NULL,
 Observacion VARCHAR(250) NULL,
 FechaMovimiento DATETIME2(0) NOT NULL CONSTRAINT DF_MovimientoInventario_FechaMovimiento DEFAULT(SYSDATETIME()),
 CONSTRAINT PK_MovimientoInventario PRIMARY KEY CLUSTERED(MovimientoInventarioId),
 CONSTRAINT FK_MovimientoInventario_Producto FOREIGN KEY(ProductoId) REFERENCES dbo.Producto(ProductoId),
 CONSTRAINT FK_MovimientoInventario_Tipo FOREIGN KEY(TipoMovimientoInventarioId) REFERENCES dbo.TipoMovimientoInventario(TipoMovimientoInventarioId),
 CONSTRAINT CK_MovimientoInventario_Cantidad CHECK(Cantidad>0),
 CONSTRAINT CK_MovimientoInventario_StockAnterior CHECK(StockAnterior>=0),
 CONSTRAINT CK_MovimientoInventario_StockPosterior CHECK(StockPosterior>=0)
);
GO

/*==================== VENTA ====================*/
IF OBJECT_ID(N'dbo.Venta',N'U') IS NULL
CREATE TABLE dbo.Venta(
 VentaId BIGINT IDENTITY(1,1) NOT NULL,
 ClienteId BIGINT NOT NULL,
 TipoComprobanteId INT NOT NULL,
 EstadoVentaId INT NOT NULL,
 Serie VARCHAR(10) NOT NULL,
 Numero INT NOT NULL,
 FechaVenta DATETIME2(0) NOT NULL CONSTRAINT DF_Venta_FechaVenta DEFAULT(SYSDATETIME()),
 Subtotal DECIMAL(14,2) NOT NULL,
 Igv DECIMAL(14,2) NOT NULL,
 Total DECIMAL(14,2) NOT NULL,
 Observacion VARCHAR(250) NULL,
 CONSTRAINT PK_Venta PRIMARY KEY CLUSTERED(VentaId),
 CONSTRAINT UQ_Venta_Comprobante UNIQUE(TipoComprobanteId,Serie,Numero),
 CONSTRAINT FK_Venta_Cliente FOREIGN KEY(ClienteId) REFERENCES dbo.Cliente(ClienteId),
 CONSTRAINT FK_Venta_TipoComprobante FOREIGN KEY(TipoComprobanteId) REFERENCES dbo.TipoComprobante(TipoComprobanteId),
 CONSTRAINT FK_Venta_EstadoVenta FOREIGN KEY(EstadoVentaId) REFERENCES dbo.EstadoVenta(EstadoVentaId),
 CONSTRAINT CK_Venta_Subtotal CHECK(Subtotal>=0),
 CONSTRAINT CK_Venta_Igv CHECK(Igv>=0),
 CONSTRAINT CK_Venta_Total CHECK(Total>=0),
 CONSTRAINT CK_Venta_Numero CHECK(Numero>0)
);
GO

/*==================== DETALLE VENTA ====================*/
IF OBJECT_ID(N'dbo.DetalleVenta',N'U') IS NULL
CREATE TABLE dbo.DetalleVenta(
 DetalleVentaId BIGINT IDENTITY(1,1) NOT NULL,
 VentaId BIGINT NOT NULL,
 ProductoId BIGINT NOT NULL,
 Cantidad INT NOT NULL,
 PrecioUnitario DECIMAL(12,2) NOT NULL,
 Importe DECIMAL(14,2) NOT NULL,
 CONSTRAINT PK_DetalleVenta PRIMARY KEY CLUSTERED(DetalleVentaId),
 CONSTRAINT UQ_DetalleVenta_VentaProducto UNIQUE(VentaId,ProductoId),
 CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY(VentaId) REFERENCES dbo.Venta(VentaId),
 CONSTRAINT FK_DetalleVenta_Producto FOREIGN KEY(ProductoId) REFERENCES dbo.Producto(ProductoId),
 CONSTRAINT CK_DetalleVenta_Cantidad CHECK(Cantidad>0),
 CONSTRAINT CK_DetalleVenta_PrecioUnitario CHECK(PrecioUnitario>=0),
 CONSTRAINT CK_DetalleVenta_Importe CHECK(Importe>=0)
);
GO

/*==================== INDICES ====================*/
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_Cliente_TipoDocumentoId_NumeroDocumento' AND object_id=OBJECT_ID(N'dbo.Cliente'))
CREATE INDEX IX_Cliente_TipoDocumentoId_NumeroDocumento ON dbo.Cliente(TipoDocumentoId,NumeroDocumento);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_Producto_Nombre' AND object_id=OBJECT_ID(N'dbo.Producto'))
CREATE INDEX IX_Producto_Nombre ON dbo.Producto(Nombre);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_Producto_CategoriaProductoId' AND object_id=OBJECT_ID(N'dbo.Producto'))
CREATE INDEX IX_Producto_CategoriaProductoId ON dbo.Producto(CategoriaProductoId);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_Venta_ClienteId_FechaVenta' AND object_id=OBJECT_ID(N'dbo.Venta'))
CREATE INDEX IX_Venta_ClienteId_FechaVenta ON dbo.Venta(ClienteId,FechaVenta);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_Venta_FechaVenta' AND object_id=OBJECT_ID(N'dbo.Venta'))
CREATE INDEX IX_Venta_FechaVenta ON dbo.Venta(FechaVenta);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_DetalleVenta_ProductoId' AND object_id=OBJECT_ID(N'dbo.DetalleVenta'))
CREATE INDEX IX_DetalleVenta_ProductoId ON dbo.DetalleVenta(ProductoId);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_MovimientoInventario_ProductoId_FechaMovimiento' AND object_id=OBJECT_ID(N'dbo.MovimientoInventario'))
CREATE INDEX IX_MovimientoInventario_ProductoId_FechaMovimiento ON dbo.MovimientoInventario(ProductoId,FechaMovimiento);
GO

/*==================== DATOS DE CATALOGOS ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.TipoDocumento)
INSERT INTO dbo.TipoDocumento(Codigo,Nombre,LongitudMinima,LongitudMaxima)
VALUES
('DNI','Documento Nacional de Identidad',8,8),
('RUC','Registro Único de Contribuyentes',11,11),
('CE','Carné de Extranjería',9,12);
GO

IF NOT EXISTS(SELECT 1 FROM dbo.CategoriaProducto)
INSERT INTO dbo.CategoriaProducto(Nombre,Descripcion)
VALUES
('Computación','Equipos y componentes de computación'),
('Electrónica','Equipos electrónicos'),
('Accesorios','Accesorios y periféricos'),
('Oficina','Equipos y suministros para oficina');
GO

IF NOT EXISTS(SELECT 1 FROM dbo.Marca)
INSERT INTO dbo.Marca(Nombre)
VALUES
('Lenovo'),('LG'),('Logitech'),('HP'),('Kingston'),('Epson');
GO

IF NOT EXISTS(SELECT 1 FROM dbo.TipoComprobante)
INSERT INTO dbo.TipoComprobante(Codigo,Nombre)
VALUES
('B','Boleta'),('F','Factura');
GO

IF NOT EXISTS(SELECT 1 FROM dbo.EstadoVenta)
INSERT INTO dbo.EstadoVenta(Codigo,Nombre)
VALUES
('COMPLETADA','Completada'),
('PENDIENTE','Pendiente'),
('CANCELADA','Cancelada');
GO

IF NOT EXISTS(SELECT 1 FROM dbo.TipoMovimientoInventario)
INSERT INTO dbo.TipoMovimientoInventario(Codigo,Nombre,Factor)
VALUES
('ENTRADA','Entrada',1),
('SALIDA','Salida',-1),
('AJUSTE_POS','Ajuste positivo',1),
('AJUSTE_NEG','Ajuste negativo',-1);
GO

/*==================== DATOS CLIENTES ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.Cliente)
BEGIN
INSERT INTO dbo.Cliente(TipoDocumentoId,NumeroDocumento,Nombres,Apellidos,RazonSocial,Email,Telefono,Direccion,Activo)
SELECT td.TipoDocumentoId,v.NumeroDocumento,v.Nombres,v.Apellidos,v.RazonSocial,v.Email,v.Telefono,v.Direccion,v.Activo
FROM(VALUES
('DNI','45879632','Juan','Pérez',NULL,'juan.perez@gmail.com','987654321','Av. Javier Prado 123, Lima',1),
('DNI','42156328','María','García',NULL,'maria.garcia@gmail.com','986543210','Av. Arequipa 456, Lima',1),
('RUC','20601234567','Carlos','Torres','Comercial Andina SAC','contacto@comercialandina.com','985432109','Av. Argentina 789, Lima',1),
('DNI','47256891','Pedro','Ramírez',NULL,'pedro.ramirez@gmail.com','984321098','Jr. Los Pinos 321, Lima',1),
('RUC','20598765432','Ana','Rodríguez','Distribuciones Norte SAC','ventas@distribucionesnorte.com','983210987','Av. Colonial 654, Lima',1),
('DNI','43658972','Luis','Fernández',NULL,'luis.fernandez@gmail.com','982109876','Calle Los Olivos 147, Lima',1),
('DNI','41523698','Carla','Mendoza',NULL,'carla.mendoza@gmail.com','981098765','Av. Brasil 258, Lima',1),
('RUC','20456789123','Roberto','Castillo','Tecnología Empresarial SAC','contacto@tecnologiaempresarial.com','980987654','Av. República de Panamá 369, Lima',1),
('DNI','46789521','Sofía','Vargas',NULL,'sofia.vargas@gmail.com','979876543','Jr. Lima 741, Lima',1),
('DNI','42987653','Diego','Sánchez',NULL,'diego.sanchez@gmail.com','978765432','Av. Brasil 852, Lima',1)
)v(TipoDocumentoCodigo,NumeroDocumento,Nombres,Apellidos,RazonSocial,Email,Telefono,Direccion,Activo)
INNER JOIN dbo.TipoDocumento td ON td.Codigo=v.TipoDocumentoCodigo;
END;
GO

/*==================== DATOS PRODUCTOS ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.Producto)
BEGIN
INSERT INTO dbo.Producto(Codigo,Nombre,Descripcion,CategoriaProductoId,MarcaId,PrecioCompra,PrecioVenta,StockMinimo,Activo)
SELECT v.Codigo,v.Nombre,v.Descripcion,cp.CategoriaProductoId,m.MarcaId,v.PrecioCompra,v.PrecioVenta,v.StockMinimo,1
FROM(VALUES
('PROD-001','Laptop Lenovo ThinkPad','Laptop empresarial de alto rendimiento','Computación','Lenovo',2200.00,2850.00,5),
('PROD-002','Monitor LED 24"','Monitor LED Full HD de 24 pulgadas','Electrónica','LG',480.00,680.00,10),
('PROD-003','Teclado inalámbrico','Teclado inalámbrico empresarial','Accesorios','Logitech',90.00,145.00,10),
('PROD-004','Mouse inalámbrico','Mouse inalámbrico ergonómico','Accesorios','Logitech',50.00,85.00,8),
('PROD-005','Impresora multifuncional','Impresora multifuncional para oficina','Oficina','Epson',700.00,920.00,5),
('PROD-006','Disco SSD 1TB','Unidad SSD de estado sólido de 1TB','Computación','Kingston',280.00,390.00,5)
)v(Codigo,Nombre,Descripcion,CategoriaNombre,MarcaNombre,PrecioCompra,PrecioVenta,StockMinimo)
INNER JOIN dbo.CategoriaProducto cp ON cp.Nombre=v.CategoriaNombre
LEFT JOIN dbo.Marca m ON m.Nombre=v.MarcaNombre;
END;
GO

/*==================== INVENTARIO ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.Inventario)
INSERT INTO dbo.Inventario(ProductoId,StockActual)
SELECT p.ProductoId,v.StockActual
FROM(VALUES
('PROD-001',12),('PROD-002',25),('PROD-003',8),
('PROD-004',4),('PROD-005',2),('PROD-006',0)
)v(CodigoProducto,StockActual)
INNER JOIN dbo.Producto p ON p.Codigo=v.CodigoProducto;
GO

/*==================== MOVIMIENTOS INICIALES ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.MovimientoInventario)
INSERT INTO dbo.MovimientoInventario(ProductoId,TipoMovimientoInventarioId,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion)
SELECT p.ProductoId,tm.TipoMovimientoInventarioId,v.Cantidad,0,v.Cantidad,'CARGA-INICIAL','Carga inicial de inventario'
FROM(VALUES
('PROD-001',12),('PROD-002',25),('PROD-003',8),('PROD-004',4),('PROD-005',2)
)v(CodigoProducto,Cantidad)
INNER JOIN dbo.Producto p ON p.Codigo=v.CodigoProducto
INNER JOIN dbo.TipoMovimientoInventario tm ON tm.Codigo='ENTRADA';
GO

/*==================== VENTAS ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.Venta)
INSERT INTO dbo.Venta(ClienteId,TipoComprobanteId,EstadoVentaId,Serie,Numero,FechaVenta,Subtotal,Igv,Total,Observacion)
SELECT c.ClienteId,tc.TipoComprobanteId,ev.EstadoVentaId,v.Serie,v.Numero,v.FechaVenta,v.Subtotal,v.Igv,v.Total,v.Observacion
FROM(VALUES
('45879632','F','COMPLETADA','F001',125,CAST('2026-08-08 10:15:00' AS DATETIME2(0)),5076.27,913.73,5990.00,'Venta corporativa'),
('42156328','B','COMPLETADA','B001',458,CAST('2026-08-09 11:30:00' AS DATETIME2(0)),576.27,103.73,680.00,NULL),
('47256891','B','PENDIENTE','B001',459,CAST('2026-08-10 12:00:00' AS DATETIME2(0)),266.95,48.05,315.00,'Pago pendiente'),
('20598765432','F','COMPLETADA','F001',126,CAST('2026-08-05 09:45:00' AS DATETIME2(0)),1559.32,280.68,1840.00,'Venta corporativa'),
('43658972','B','COMPLETADA','B001',455,CAST('2026-08-03 15:20:00' AS DATETIME2(0)),216.10,38.90,255.00,NULL)
)v(NumeroDocumento,TipoComprobanteCodigo,EstadoVentaCodigo,Serie,Numero,FechaVenta,Subtotal,Igv,Total,Observacion)
INNER JOIN dbo.Cliente c ON c.NumeroDocumento=v.NumeroDocumento
INNER JOIN dbo.TipoComprobante tc ON tc.Codigo=v.TipoComprobanteCodigo
INNER JOIN dbo.EstadoVenta ev ON ev.Codigo=v.EstadoVentaCodigo;
GO

/*==================== DETALLE DE VENTAS ====================*/
IF NOT EXISTS(SELECT 1 FROM dbo.DetalleVenta)
INSERT INTO dbo.DetalleVenta(VentaId,ProductoId,Cantidad,PrecioUnitario,Importe)
SELECT ve.VentaId,p.ProductoId,d.Cantidad,d.PrecioUnitario,d.Importe
FROM(VALUES
('F001',125,'PROD-001',2,2850.00,5700.00),
('F001',125,'PROD-003',2,145.00,290.00),
('B001',458,'PROD-002',1,680.00,680.00),
('B001',459,'PROD-004',2,85.00,170.00),
('B001',459,'PROD-003',1,145.00,145.00),
('F001',126,'PROD-005',2,920.00,1840.00),
('B001',455,'PROD-004',3,85.00,255.00)
)d(Serie,Numero,CodigoProducto,Cantidad,PrecioUnitario,Importe)
INNER JOIN dbo.Venta ve ON ve.Serie=d.Serie AND ve.Numero=d.Numero
INNER JOIN dbo.Producto p ON p.Codigo=d.CodigoProducto;
GO

/*==================== CRUD CLIENTE ====================*/
CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Listar
AS
BEGIN
 SET NOCOUNT ON;
 SELECT c.ClienteId,td.Codigo AS TipoDocumentoCodigo,td.Nombre AS TipoDocumento,
 c.NumeroDocumento,c.Nombres,c.Apellidos,c.RazonSocial,c.Email,c.Telefono,c.Direccion,c.Activo,c.FechaRegistro
 FROM dbo.Cliente c INNER JOIN dbo.TipoDocumento td ON td.TipoDocumentoId=c.TipoDocumentoId
 ORDER BY c.Apellidos,c.Nombres,c.RazonSocial;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_ObtenerPorId @ClienteId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 SELECT c.ClienteId,td.Codigo AS TipoDocumentoCodigo,td.Nombre AS TipoDocumento,
 c.NumeroDocumento,c.Nombres,c.Apellidos,c.RazonSocial,c.Email,c.Telefono,c.Direccion,c.Activo,c.FechaRegistro
 FROM dbo.Cliente c INNER JOIN dbo.TipoDocumento td ON td.TipoDocumentoId=c.TipoDocumentoId
 WHERE c.ClienteId=@ClienteId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Insertar
 @TipoDocumentoId INT,@NumeroDocumento VARCHAR(20),@Nombres VARCHAR(100)=NULL,
 @Apellidos VARCHAR(100)=NULL,@RazonSocial VARCHAR(150)=NULL,@Email VARCHAR(150)=NULL,
 @Telefono VARCHAR(20)=NULL,@Direccion VARCHAR(250)=NULL,@Activo BIT=1
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM dbo.Cliente WHERE NumeroDocumento=@NumeroDocumento)
  THROW 50001,'Ya existe un cliente con el número de documento indicado.',1;
 INSERT INTO dbo.Cliente(TipoDocumentoId,NumeroDocumento,Nombres,Apellidos,RazonSocial,Email,Telefono,Direccion,Activo)
 VALUES(@TipoDocumentoId,@NumeroDocumento,@Nombres,@Apellidos,@RazonSocial,@Email,@Telefono,@Direccion,@Activo);
 DECLARE @NuevoClienteId BIGINT=CONVERT(BIGINT,SCOPE_IDENTITY());
 EXEC dbo.usp_Cliente_ObtenerPorId @ClienteId=@NuevoClienteId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Actualizar
 @ClienteId BIGINT,@TipoDocumentoId INT,@NumeroDocumento VARCHAR(20),@Nombres VARCHAR(100)=NULL,
 @Apellidos VARCHAR(100)=NULL,@RazonSocial VARCHAR(150)=NULL,@Email VARCHAR(150)=NULL,
 @Telefono VARCHAR(20)=NULL,@Direccion VARCHAR(250)=NULL,@Activo BIT=1
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Cliente WHERE ClienteId=@ClienteId)
  THROW 50002,'El cliente indicado no existe.',1;
 IF EXISTS(SELECT 1 FROM dbo.Cliente WHERE NumeroDocumento=@NumeroDocumento AND ClienteId<>@ClienteId)
  THROW 50003,'El número de documento ya pertenece a otro cliente.',1;
 UPDATE dbo.Cliente SET TipoDocumentoId=@TipoDocumentoId,NumeroDocumento=@NumeroDocumento,Nombres=@Nombres,
 Apellidos=@Apellidos,RazonSocial=@RazonSocial,Email=@Email,Telefono=@Telefono,Direccion=@Direccion,Activo=@Activo
 WHERE ClienteId=@ClienteId;
 EXEC dbo.usp_Cliente_ObtenerPorId @ClienteId=@ClienteId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Eliminar @ClienteId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Cliente WHERE ClienteId=@ClienteId)
  THROW 50004,'El cliente indicado no existe.',1;
 UPDATE dbo.Cliente SET Activo=0 WHERE ClienteId=@ClienteId;
 SELECT ClienteId,Activo FROM dbo.Cliente WHERE ClienteId=@ClienteId;
END;
GO

/*==================== CRUD PRODUCTO ====================*/
CREATE OR ALTER PROCEDURE dbo.usp_Producto_Listar
AS
BEGIN
 SET NOCOUNT ON;
 SELECT p.ProductoId,p.Codigo,p.Nombre,p.Descripcion,p.CategoriaProductoId,cp.Nombre AS Categoria,
 p.MarcaId,m.Nombre AS Marca,p.PrecioCompra,p.PrecioVenta,p.StockMinimo,ISNULL(i.StockActual,0) AS StockActual,
 p.Activo,p.FechaRegistro
 FROM dbo.Producto p INNER JOIN dbo.CategoriaProducto cp ON cp.CategoriaProductoId=p.CategoriaProductoId
 LEFT JOIN dbo.Marca m ON m.MarcaId=p.MarcaId LEFT JOIN dbo.Inventario i ON i.ProductoId=p.ProductoId
 ORDER BY p.Nombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_ObtenerPorId @ProductoId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 SELECT p.ProductoId,p.Codigo,p.Nombre,p.Descripcion,p.CategoriaProductoId,cp.Nombre AS Categoria,
 p.MarcaId,m.Nombre AS Marca,p.PrecioCompra,p.PrecioVenta,p.StockMinimo,ISNULL(i.StockActual,0) AS StockActual,
 p.Activo,p.FechaRegistro
 FROM dbo.Producto p INNER JOIN dbo.CategoriaProducto cp ON cp.CategoriaProductoId=p.CategoriaProductoId
 LEFT JOIN dbo.Marca m ON m.MarcaId=p.MarcaId LEFT JOIN dbo.Inventario i ON i.ProductoId=p.ProductoId
 WHERE p.ProductoId=@ProductoId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Insertar
 @Codigo VARCHAR(30),@Nombre VARCHAR(150),@Descripcion VARCHAR(500)=NULL,@CategoriaProductoId INT,
 @MarcaId INT=NULL,@PrecioCompra DECIMAL(12,2),@PrecioVenta DECIMAL(12,2),
 @StockMinimo INT=0,@StockInicial INT=0,@Activo BIT=1
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRANSACTION;
 IF EXISTS(SELECT 1 FROM dbo.Producto WHERE Codigo=@Codigo)
  THROW 50010,'Ya existe un producto con el código indicado.',1;
 INSERT INTO dbo.Producto(Codigo,Nombre,Descripcion,CategoriaProductoId,MarcaId,PrecioCompra,PrecioVenta,StockMinimo,Activo)
 VALUES(@Codigo,@Nombre,@Descripcion,@CategoriaProductoId,@MarcaId,@PrecioCompra,@PrecioVenta,@StockMinimo,@Activo);
 DECLARE @NuevoProductoId BIGINT=CONVERT(BIGINT,SCOPE_IDENTITY());
 INSERT INTO dbo.Inventario(ProductoId,StockActual) VALUES(@NuevoProductoId,@StockInicial);
 IF @StockInicial>0
 BEGIN
  INSERT INTO dbo.MovimientoInventario(ProductoId,TipoMovimientoInventarioId,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion)
  SELECT @NuevoProductoId,TipoMovimientoInventarioId,@StockInicial,0,@StockInicial,'ALTA-PRODUCTO','Stock inicial del producto'
  FROM dbo.TipoMovimientoInventario WHERE Codigo='ENTRADA';
 END;
 COMMIT TRANSACTION;
 EXEC dbo.usp_Producto_ObtenerPorId @ProductoId=@NuevoProductoId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Actualizar
 @ProductoId BIGINT,@Codigo VARCHAR(30),@Nombre VARCHAR(150),@Descripcion VARCHAR(500)=NULL,
 @CategoriaProductoId INT,@MarcaId INT=NULL,@PrecioCompra DECIMAL(12,2),@PrecioVenta DECIMAL(12,2),
 @StockMinimo INT,@Activo BIT=1
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Producto WHERE ProductoId=@ProductoId)
  THROW 50011,'El producto indicado no existe.',1;
 IF EXISTS(SELECT 1 FROM dbo.Producto WHERE Codigo=@Codigo AND ProductoId<>@ProductoId)
  THROW 50012,'El código ya pertenece a otro producto.',1;
 UPDATE dbo.Producto SET Codigo=@Codigo,Nombre=@Nombre,Descripcion=@Descripcion,CategoriaProductoId=@CategoriaProductoId,
 MarcaId=@MarcaId,PrecioCompra=@PrecioCompra,PrecioVenta=@PrecioVenta,StockMinimo=@StockMinimo,Activo=@Activo
 WHERE ProductoId=@ProductoId;
 EXEC dbo.usp_Producto_ObtenerPorId @ProductoId=@ProductoId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar @ProductoId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Producto WHERE ProductoId=@ProductoId)
  THROW 50013,'El producto indicado no existe.',1;
 UPDATE dbo.Producto SET Activo=0 WHERE ProductoId=@ProductoId;
 SELECT ProductoId,Activo FROM dbo.Producto WHERE ProductoId=@ProductoId;
END;
GO

/*==================== CRUD INVENTARIO ====================*/
CREATE OR ALTER PROCEDURE dbo.usp_Inventario_Listar
AS
BEGIN
 SET NOCOUNT ON;
 SELECT i.InventarioId,i.ProductoId,p.Codigo,p.Nombre,cp.Nombre AS Categoria,p.StockMinimo,i.StockActual,
 CASE WHEN i.StockActual=0 THEN 'SIN_STOCK' WHEN i.StockActual<=p.StockMinimo THEN 'CRITICO' ELSE 'NORMAL' END AS EstadoStock,
 i.FechaActualizacion
 FROM dbo.Inventario i INNER JOIN dbo.Producto p ON p.ProductoId=i.ProductoId
 INNER JOIN dbo.CategoriaProducto cp ON cp.CategoriaProductoId=p.CategoriaProductoId
 ORDER BY CASE WHEN i.StockActual=0 THEN 1 WHEN i.StockActual<=p.StockMinimo THEN 2 ELSE 3 END,p.Nombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Inventario_ObtenerPorId @ProductoId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 SELECT i.InventarioId,i.ProductoId,p.Codigo,p.Nombre,p.StockMinimo,i.StockActual,
 CASE WHEN i.StockActual=0 THEN 'SIN_STOCK' WHEN i.StockActual<=p.StockMinimo THEN 'CRITICO' ELSE 'NORMAL' END AS EstadoStock,
 i.FechaActualizacion
 FROM dbo.Inventario i INNER JOIN dbo.Producto p ON p.ProductoId=i.ProductoId
 WHERE i.ProductoId=@ProductoId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Inventario_Ajustar
 @ProductoId BIGINT,@TipoMovimientoInventarioId INT,@Cantidad INT,
 @Referencia VARCHAR(100)=NULL,@Observacion VARCHAR(250)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRANSACTION;
 DECLARE @StockAnterior INT,@StockPosterior INT,@Factor SMALLINT;
 SELECT @Factor=Factor FROM dbo.TipoMovimientoInventario
 WHERE TipoMovimientoInventarioId=@TipoMovimientoInventarioId AND Activo=1;
 IF @Factor IS NULL THROW 50030,'El tipo de movimiento no existe o está inactivo.',1;
 SELECT @StockAnterior=StockActual FROM dbo.Inventario WITH(UPDLOCK,HOLDLOCK) WHERE ProductoId=@ProductoId;
 IF @StockAnterior IS NULL THROW 50031,'El producto no tiene registro de inventario.',1;
 SET @StockPosterior=@StockAnterior+(@Cantidad*@Factor);
 IF @StockPosterior<0 THROW 50032,'El movimiento produciría stock negativo.',1;
 UPDATE dbo.Inventario SET StockActual=@StockPosterior,FechaActualizacion=SYSDATETIME() WHERE ProductoId=@ProductoId;
 INSERT INTO dbo.MovimientoInventario(ProductoId,TipoMovimientoInventarioId,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion)
 VALUES(@ProductoId,@TipoMovimientoInventarioId,@Cantidad,@StockAnterior,@StockPosterior,@Referencia,@Observacion);
 COMMIT TRANSACTION;
 EXEC dbo.usp_Inventario_ObtenerPorId @ProductoId=@ProductoId;
END;
GO

/*==================== CRUD VENTA ====================*/
CREATE OR ALTER PROCEDURE dbo.usp_Venta_Listar
AS
BEGIN
 SET NOCOUNT ON;
 SELECT v.VentaId,v.ClienteId,COALESCE(c.RazonSocial,CONCAT(c.Nombres,' ',c.Apellidos)) AS Cliente,
 tc.Codigo AS TipoComprobanteCodigo,tc.Nombre AS TipoComprobante,v.Serie,v.Numero,
 ev.Codigo AS EstadoVentaCodigo,ev.Nombre AS EstadoVenta,v.FechaVenta,v.Subtotal,v.Igv,v.Total,v.Observacion
 FROM dbo.Venta v INNER JOIN dbo.Cliente c ON c.ClienteId=v.ClienteId
 INNER JOIN dbo.TipoComprobante tc ON tc.TipoComprobanteId=v.TipoComprobanteId
 INNER JOIN dbo.EstadoVenta ev ON ev.EstadoVentaId=v.EstadoVentaId
 ORDER BY v.FechaVenta DESC,v.VentaId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Venta_ObtenerPorId @VentaId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 SELECT v.VentaId,v.ClienteId,COALESCE(c.RazonSocial,CONCAT(c.Nombres,' ',c.Apellidos)) AS Cliente,
 tc.Codigo AS TipoComprobanteCodigo,tc.Nombre AS TipoComprobante,v.Serie,v.Numero,
 ev.Codigo AS EstadoVentaCodigo,ev.Nombre AS EstadoVenta,v.FechaVenta,v.Subtotal,v.Igv,v.Total,v.Observacion
 FROM dbo.Venta v INNER JOIN dbo.Cliente c ON c.ClienteId=v.ClienteId
 INNER JOIN dbo.TipoComprobante tc ON tc.TipoComprobanteId=v.TipoComprobanteId
 INNER JOIN dbo.EstadoVenta ev ON ev.EstadoVentaId=v.EstadoVentaId
 WHERE v.VentaId=@VentaId;

 SELECT dv.DetalleVentaId,dv.VentaId,dv.ProductoId,p.Codigo AS CodigoProducto,p.Nombre AS Producto,
 dv.Cantidad,dv.PrecioUnitario,dv.Importe
 FROM dbo.DetalleVenta dv INNER JOIN dbo.Producto p ON p.ProductoId=dv.ProductoId
 WHERE dv.VentaId=@VentaId ORDER BY dv.DetalleVentaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Venta_Insertar
 @ClienteId BIGINT,@TipoComprobanteId INT,@EstadoVentaId INT,@Serie VARCHAR(10),@Numero INT,
 @FechaVenta DATETIME2(0),@Subtotal DECIMAL(14,2),@Igv DECIMAL(14,2),@Total DECIMAL(14,2),
 @Observacion VARCHAR(250)=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM dbo.Venta WHERE TipoComprobanteId=@TipoComprobanteId AND Serie=@Serie AND Numero=@Numero)
  THROW 50020,'El comprobante ya existe.',1;
 INSERT INTO dbo.Venta(ClienteId,TipoComprobanteId,EstadoVentaId,Serie,Numero,FechaVenta,Subtotal,Igv,Total,Observacion)
 VALUES(@ClienteId,@TipoComprobanteId,@EstadoVentaId,@Serie,@Numero,@FechaVenta,@Subtotal,@Igv,@Total,@Observacion);
 DECLARE @NuevaVentaId BIGINT=CONVERT(BIGINT,SCOPE_IDENTITY());
 EXEC dbo.usp_Venta_ObtenerPorId @VentaId=@NuevaVentaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Venta_Actualizar
 @VentaId BIGINT,@ClienteId BIGINT,@EstadoVentaId INT,@FechaVenta DATETIME2(0),@Observacion VARCHAR(250)=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Venta WHERE VentaId=@VentaId)
  THROW 50021,'La venta indicada no existe.',1;
 UPDATE dbo.Venta SET ClienteId=@ClienteId,EstadoVentaId=@EstadoVentaId,FechaVenta=@FechaVenta,Observacion=@Observacion
 WHERE VentaId=@VentaId;
 EXEC dbo.usp_Venta_ObtenerPorId @VentaId=@VentaId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Venta_Eliminar @VentaId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Venta WHERE VentaId=@VentaId)
  THROW 50022,'La venta indicada no existe.',1;
 UPDATE dbo.Venta SET EstadoVentaId=(SELECT EstadoVentaId FROM dbo.EstadoVenta WHERE Codigo='CANCELADA')
 WHERE VentaId=@VentaId;
 SELECT VentaId,EstadoVentaId FROM dbo.Venta WHERE VentaId=@VentaId;
END;
GO

/*==================== REPORTES ====================*/
CREATE OR ALTER PROCEDURE dbo.usp_Reporte_VentasPorPeriodo
 @FechaInicio DATE,@FechaFin DATE
AS
BEGIN
 SET NOCOUNT ON;
 SELECT CAST(v.FechaVenta AS DATE) AS Fecha,COUNT(*) AS CantidadVentas,
 SUM(v.Subtotal) AS Subtotal,SUM(v.Igv) AS Igv,SUM(v.Total) AS Total
 FROM dbo.Venta v INNER JOIN dbo.EstadoVenta ev ON ev.EstadoVentaId=v.EstadoVentaId
 WHERE v.FechaVenta>=@FechaInicio AND v.FechaVenta<DATEADD(DAY,1,@FechaFin)
 AND ev.Codigo='COMPLETADA'
 GROUP BY CAST(v.FechaVenta AS DATE)
 ORDER BY Fecha;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_ProductosMasVendidos
 @FechaInicio DATE,@FechaFin DATE
AS
BEGIN
 SET NOCOUNT ON;
 SELECT TOP 10 p.ProductoId,p.Codigo,p.Nombre,SUM(dv.Cantidad) AS UnidadesVendidas,SUM(dv.Importe) AS ImporteVendido
 FROM dbo.DetalleVenta dv INNER JOIN dbo.Venta v ON v.VentaId=dv.VentaId
 INNER JOIN dbo.EstadoVenta ev ON ev.EstadoVentaId=v.EstadoVentaId
 INNER JOIN dbo.Producto p ON p.ProductoId=dv.ProductoId
 WHERE v.FechaVenta>=@FechaInicio AND v.FechaVenta<DATEADD(DAY,1,@FechaFin)
 AND ev.Codigo='COMPLETADA'
 GROUP BY p.ProductoId,p.Codigo,p.Nombre
 ORDER BY UnidadesVendidas DESC,ImporteVendido DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_ResumenInventario
AS
BEGIN
 SET NOCOUNT ON;
 SELECT
 SUM(CASE WHEN i.StockActual=0 THEN 1 ELSE 0 END) AS ProductosSinStock,
 SUM(CASE WHEN i.StockActual>0 AND i.StockActual<=p.StockMinimo THEN 1 ELSE 0 END) AS ProductosCriticos,
 SUM(CASE WHEN i.StockActual>p.StockMinimo THEN 1 ELSE 0 END) AS ProductosDisponibles,
 SUM(i.StockActual*p.PrecioCompra) AS ValorInventarioCompra,
 SUM(i.StockActual*p.PrecioVenta) AS ValorInventarioVenta
 FROM dbo.Inventario i INNER JOIN dbo.Producto p ON p.ProductoId=i.ProductoId
 WHERE p.Activo=1;
END;
GO

/*==================== PRUEBAS ====================*/
-- EXEC dbo.usp_Cliente_Listar;
-- EXEC dbo.usp_Producto_Listar;
-- EXEC dbo.usp_Venta_Listar;
-- EXEC dbo.usp_Inventario_Listar;
-- EXEC dbo.usp_Reporte_VentasPorPeriodo '2026-08-01','2026-08-31';
-- EXEC dbo.usp_Reporte_ProductosMasVendidos '2026-08-01','2026-08-31';
-- EXEC dbo.usp_Reporte_ResumenInventario;
GO
