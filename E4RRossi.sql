-- Pre-entrega 4: Consultas SQL de negocio - RetailPro
-- Motor: Microsoft SQL Server Management Studio
-- Base: Ventas_Tech_DB - Tabla: ventas

-- =============================================
-- Consulta 1 — Resumen ejecutivo mensual Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
-- Calculá el total como cantidad * precio_unitario. 
-- Usá alias descriptivos en español y agrupá por mes con MONTH(fecha_venta) (en PostgreSQL sería EXTRACT(MONTH FROM fecha_venta)).
-- =============================================
SELECT 
    MONTH(FechaCompra) AS mes,
    SUM(MontoTotal) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(MontoTotal) AS ticket_promedio
FROM ventas
GROUP BY MONTH(FechaCompra)
ORDER BY mes;



-- =============================================
-- Consulta 2 — Ranking de productos Top 5 de id_producto por total facturado, mostrando las unidades vendidas (SUM(cantidad)) y el
-- total generado. Usá GROUP BY id_producto, ORDER BY y TOP 5.
-- =============================================
SELECT TOP 5
    ProductID AS id_producto,
    SUM(Cantidad) AS unidades_vendidas,
    SUM(MontoTotal) AS total_facturado
FROM ventas
GROUP BY ProductID
ORDER BY total_facturado DESC;

-- =============================================
-- Consulta 3 — Clientes recurrentes id_cliente que hayan realizado más de un pedido, mostrando la cantidad de pedidos y el 
-- total gastado. Usá GROUP BY id_cliente y HAVING COUNT(*) > 1.
-- =============================================
SELECT 
    CustomerID AS id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(MontoTotal) AS total_gastado
FROM ventas
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- =============================================
-- Consulta 4 — Meses por encima/por debajo del promedio Total facturado por mes, con una columna adicional que etiquete 
-- con CASE WHEN si ese mes quedó 'Por encima' o 'Por debajo' del promedio mensual general.
-- =============================================
SELECT 
    mes,
    total_mes AS total_facturado_mes,
    (SELECT AVG(CAST(total_mes AS FLOAT)) FROM (SELECT MONTH(FechaCompra) AS mes, SUM(MontoTotal) AS total_mes FROM ventas GROUP BY MONTH(FechaCompra)) AS fm2) AS promedio_mensual,
    CASE 
        WHEN total_mes > (SELECT AVG(CAST(total_mes AS FLOAT)) FROM (SELECT MONTH(FechaCompra) AS mes, SUM(MontoTotal) AS total_mes FROM ventas GROUP BY MONTH(FechaCompra)) AS fm2) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparativa_vs_promedio
FROM (
    SELECT MONTH(FechaCompra) AS mes, SUM(MontoTotal) AS total_mes
    FROM ventas
    GROUP BY MONTH(FechaCompra)
) AS facturacion_mensual
ORDER BY mes;

-- =============================================
-- BLOQUE DE CIERRE: Hallazgos
-- =============================================
-- Hallazgo 1:  El mes 8 concentra la mayor facturación del año con $128.471,18, quedando etiquetado como 'Por encima' del promedio mensual de $104.135,34. 
--  El mes más bajo fue el 11 con $82.598,56.
-- Hallazgo 2: El producto PRD-001 es el líder con $435.496,65 facturados (330 unidades)..
-- Hallazgo 3: Cliente recurrente CLI-0083	8	2199.81 pero compro pocas unidades