-- Creación del esquema/base de datos
CREATE DATABASE TendenciasBeauty;
USE TendenciasBeauty;

-- Tabla: Marcas
CREATE TABLE Marcas (
    ID_Marca VARCHAR(10) PRIMARY KEY,
    Marca VARCHAR(50) NOT NULL
);

-- Tabla: Categorías
CREATE TABLE Categorias (
    ID_Categoria VARCHAR(10) PRIMARY KEY,
    Categoria VARCHAR(50) NOT NULL
);

-- Tabla: Subcategorías
CREATE TABLE Sub_Categorias (
    ID_SubCategoria VARCHAR(10) PRIMARY KEY,
    Subcategoria VARCHAR(50) NOT NULL,
    ID_Categoria VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID_Categoria)
);

-- Tabla: Segmento
CREATE TABLE Segmento (
    ID_Segmento VARCHAR(10) PRIMARY KEY,
    Segmento VARCHAR(50) NOT NULL,
    ID_Subcategoria VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID_Subcategoria) REFERENCES Sub_Categorias(ID_SubCategoria)
);

-- Tabla: Productos
CREATE TABLE Productos (
    ID_Producto VARCHAR(10) PRIMARY KEY,
    EAN VARCHAR(13) NOT NULL,
    Nombre_Producto VARCHAR(100) NOT NULL,
    ID_Marca VARCHAR(10) NOT NULL,
    ID_Categoria VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID_Marca) REFERENCES Marcas(ID_Marca),
    FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID_Categoria)
);

-- Tabla: Ciudad
CREATE TABLE Ciudad (
    ID_Ciudad VARCHAR(10) PRIMARY KEY,
    Ciudad VARCHAR(50) NOT NULL
);

-- Tabla: Localidad
CREATE TABLE Localidad (
    ID_Localidad VARCHAR(10) PRIMARY KEY,
    Localidad VARCHAR(50) NOT NULL,
    ID_Ciudad VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID_Ciudad) REFERENCES Ciudad(ID_Ciudad)
);

-- Tabla: Tipo de Player
CREATE TABLE Tipo_Player (
    ID_TipoPlayer VARCHAR(10) PRIMARY KEY,
    Tipo_de_Player VARCHAR(50) NOT NULL
);

-- Tabla: Retailer
CREATE TABLE Retailer (
    ID_Retailer VARCHAR(10) PRIMARY KEY,
    RETAILER VARCHAR(50) NOT NULL,
    ID_TipoPlayer VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID_TipoPlayer) REFERENCES Tipo_Player(ID_TipoPlayer)
);

-- Tabla: Compañía
CREATE TABLE Compania (
    ID_Compania VARCHAR(10) PRIMARY KEY,
    Compania VARCHAR(50) NOT NULL,
    ID_Retailer VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID_Retailer) REFERENCES Retailer(ID_Retailer)
);

-- Tabla: Ventas
CREATE TABLE Ventas (
    ID_Venta VARCHAR(10) PRIMARY KEY,
    ID_Producto VARCHAR(10) NOT NULL,
    ID_Ciudad VARCHAR(10) NOT NULL,
    ID_Retailer VARCHAR(10) NOT NULL,
    Fecha DATETIME NOT NULL,
    Ordenes INT NOT NULL,
    Usuarios INT NOT NULL,
    Unidades INT NOT NULL,
    Venta DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (ID_Producto) REFERENCES Productos(ID_Producto),
    FOREIGN KEY (ID_Ciudad) REFERENCES Ciudad(ID_Ciudad),
    FOREIGN KEY (ID_Retailer) REFERENCES Retailer(ID_Retailer)
);
