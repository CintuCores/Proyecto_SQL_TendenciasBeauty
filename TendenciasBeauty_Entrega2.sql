-- ========================
-- VISTAS
-- ========================

-- Vista: Ventas por Producto
CREATE OR REPLACE VIEW vw_ventas_por_producto AS
SELECT
    v.ID_Producto,
    p.EAN,
    p.Nombre_Producto,
    SUM(v.Unidades) AS Total_Unidades,
    SUM(v.Venta) AS Total_Vendido
FROM ventas v
JOIN productos p ON v.ID_Producto = p.ID_Producto
GROUP BY v.ID_Producto, p.EAN, p.Nombre_Producto;

-- Vista: Ventas por Ciudad
CREATE OR REPLACE VIEW vw_ventas_por_ciudad AS
SELECT
    v.ID_Ciudad,
    c.Ciudad,
    c.Pais,
    SUM(v.Unidades) AS Total_Unidades,
    SUM(v.Venta) AS Total_Vendido
FROM ventas v
JOIN ciudad c ON v.ID_Ciudad = c.ID_Ciudad
GROUP BY v.ID_Ciudad, c.Ciudad, c.Pais;

-- Vista: Ventas por Retailer
CREATE OR REPLACE VIEW vw_ventas_por_retailer AS
SELECT
    v.ID_Retailer,
    r.RETAILER,
    r.ID_TipoPlayer,
    SUM(v.Unidades) AS Total_Unidades,
    SUM(v.Venta) AS Total_Vendido
FROM ventas v
JOIN retailer r ON v.ID_Retailer = r.ID_Retailer
GROUP BY v.ID_Retailer, r.RETAILER, r.ID_TipoPlayer;

-- Vista: Ventas por Marca
CREATE OR REPLACE VIEW vw_ventas_por_marca AS
SELECT
    p.ID_Marca,
    m.Marca,
    SUM(v.Unidades) AS Total_Unidades,
    SUM(v.Venta) AS Total_Vendido
FROM ventas v
JOIN productos p ON v.ID_Producto = p.ID_Producto
JOIN marcas m ON p.ID_Marca = m.ID_Marca
GROUP BY p.ID_Marca, m.Marca;

-- Vista: Ventas por Categoría
CREATE OR REPLACE VIEW vw_ventas_por_categoria AS
SELECT
    p.ID_Categoria,
    c.Categoria,
    SUM(v.Unidades) AS Total_Unidades,
    SUM(v.Venta) AS Total_Vendido
FROM ventas v
JOIN productos p ON v.ID_Producto = p.ID_Producto
JOIN categorias c ON p.ID_Categoria = c.ID_Categoria
GROUP BY p.ID_Categoria, c.Categoria;

-- ========================
-- FUNCIONES
-- ========================

-- Función: Obtener nombre de producto por EAN
DELIMITER //
CREATE FUNCTION fn_nombre_producto(ean VARCHAR(13))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE nombre VARCHAR(255);
    SELECT Nombre_Producto INTO nombre FROM Productos WHERE EAN = ean LIMIT 1;
    RETURN nombre;
END;
//
DELIMITER ;

-- Función: Total ventas por producto
DELIMITER //
CREATE FUNCTION fn_total_ventas_producto(p_ID_Producto VARCHAR(10))
RETURNS DECIMAL(18,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(18,2);
    SELECT SUM(Venta) INTO total FROM ventas WHERE ID_Producto = p_ID_Producto;
    RETURN IFNULL(total, 0);
END;
//
DELIMITER ;

-- Función: Total de unidades por ciudad
DELIMITER //
CREATE FUNCTION fn_unidades_por_ciudad(p_ID_Ciudad VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cantidad INT;
    SELECT SUM(Unidades) INTO cantidad FROM ventas WHERE ID_Ciudad = p_ID_Ciudad;
    RETURN IFNULL(cantidad, 0);
END;
//
DELIMITER ;

-- ========================
-- STORED PROCEDURES
-- ========================

-- SP: Ventas por fecha
DELIMITER //
CREATE PROCEDURE sp_ventas_por_fecha(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    SELECT 
        v.Fecha,
        v.EAN,
        p.Nombre_Producto,
        v.Cantidad,
        v.Total_Venta
    FROM Ventas v
    JOIN Productos p ON v.EAN = p.EAN
    WHERE v.Fecha BETWEEN fecha_inicio AND fecha_fin;
END;
//
DELIMITER ;

-- SP: Top productos más vendidos
DELIMITER //
CREATE PROCEDURE sp_top_productos(IN limite INT)
BEGIN
    SELECT 
        v.EAN,
        p.Nombre_Producto,
        SUM(v.Cantidad) AS Total_Vendido
    FROM Ventas v
    JOIN Productos p ON v.EAN = p.EAN
    GROUP BY v.EAN, p.Nombre_Producto
    ORDER BY Total_Vendido DESC
    LIMIT limite;
END;
//
DELIMITER ;

-- SP: Insertar venta
DELIMITER //
CREATE PROCEDURE sp_insertar_venta (
    IN p_ID_Venta VARCHAR(10),
    IN p_ID_Producto VARCHAR(10),
    IN p_ID_Ciudad VARCHAR(10),
    IN p_ID_Retailer VARCHAR(10),
    IN p_Fecha DATETIME,
    IN p_Ordenes INT,
    IN p_Usuarios INT,
    IN p_Unidades INT,
    IN p_Venta DECIMAL(18,2)
)
BEGIN
    INSERT INTO ventas (
        ID_Venta, ID_Producto, ID_Ciudad, ID_Retailer, Fecha,
        Ordenes, Usuarios, Unidades, Venta
    )
    VALUES (
        p_ID_Venta, p_ID_Producto, p_ID_Ciudad, p_ID_Retailer, p_Fecha,
        p_Ordenes, p_Usuarios, p_Unidades, p_Venta
    );
END;
//
DELIMITER ;

-- SP: Ventas por rango de fecha
DELIMITER //
CREATE PROCEDURE sp_ventas_por_rango_fecha (
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT * FROM ventas WHERE Fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
END;
//
DELIMITER ;

-- ========================
-- TRIGGERS
-- ========================

-- Trigger: Insertar auditoría de venta
CREATE TABLE auditoria_ventas (
    ID_Auditoria INT AUTO_INCREMENT PRIMARY KEY,
    ID_Venta VARCHAR(10),
    Fecha DATETIME,
    ID_Producto VARCHAR(10),
    ID_Ciudad VARCHAR(10),
    ID_Retailer VARCHAR(10),
    Venta DECIMAL(18,2),
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER trg_insertar_auditoria_venta
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_ventas (
        ID_Venta, Fecha, ID_Producto, ID_Ciudad, ID_Retailer, Venta
    )
    VALUES (
        NEW.ID_Venta, NEW.Fecha, NEW.ID_Producto, NEW.ID_Ciudad, NEW.ID_Retailer, NEW.Venta
    );
END;
//
DELIMITER ;

-- Trigger: Auditoría por actualización de ventas
CREATE TABLE auditoria_actualizaciones (
    ID_Auditoria INT AUTO_INCREMENT PRIMARY KEY,
    ID_Venta VARCHAR(10),
    Campo_Modificado VARCHAR(50),
    Valor_Anterior VARCHAR(255),
    Valor_Nuevo VARCHAR(255),
    Fecha_Cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER trg_actualizar_auditoria_venta
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    IF OLD.Venta <> NEW.Venta THEN
        INSERT INTO auditoria_actualizaciones (ID_Venta, Campo_Modificado, Valor_Anterior, Valor_Nuevo)
        VALUES (OLD.ID_Venta, 'Venta', OLD.Venta, NEW.Venta);
    END IF;

    IF OLD.Unidades <> NEW.Unidades THEN
        INSERT INTO auditoria_actualizaciones (ID_Venta, Campo_Modificado, Valor_Anterior, Valor_Nuevo)
        VALUES (OLD.ID_Venta, 'Unidades', OLD.Unidades, NEW.Unidades);
    END IF;
END;
//
DELIMITER ;
