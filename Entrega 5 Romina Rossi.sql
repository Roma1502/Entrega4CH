-- =====================================================
-- Proyecto: RetailPro / Ventas_Tech_DB
-- Pre-entrega 5: Consultas con JOINs
-- Motor: Microsoft SQL Server (SSMS)
-- =====================================================

USE Ventas_Tech_DB;
GO

-- =====================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Propósito: enriquecer las ventas con información
-- de clientes, productos y categorías para Power BI.
-- =====================================================

SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS region,
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

-- Hallazgo: la vista integra las ventas con los datos
-- descriptivos para analizar ingresos por cliente,
-- ciudad, producto y categoría en Power BI.


-- =====================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: identificar clientes registrados que
-- nunca realizaron una compra para el área de CRM.
-- =====================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgo: con los datos actuales, no hay clientes
-- registrados sin compras. CRM no identifica clientes
-- sin ventas dentro de esta muestra.


-- =====================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Propósito: encontrar artículos del catálogo que
-- nunca se vendieron para el área de Producto.
-- =====================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM dbo.productos AS p
INNER JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN dbo.ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgo: con los datos actuales, todos los productos
-- del catálogo registran ventas. No se detectan artículos
-- sin movimiento que requieran revisión del área de Producto.


-- =====================================================
-- CONSULTA 4: Consolidado por período (UNION ALL)
-- Propósito: comparar el total vendido en dos períodos.
-- El canal se genera como una etiqueta para cada grupo.
-- =====================================================

SELECT
    canal,
    SUM(total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Periodo 1' AS canal
    FROM dbo.ventas
    WHERE fecha_venta < '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Periodo 2' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '2024-03-10'
) AS consolidado
GROUP BY canal;

-- Hallazgo: el Periodo 1 registra $3.230,00 y el
-- Periodo 2 registra $3.214,00. El Periodo 1 supera
-- al segundo por $16,00 en ventas totales.