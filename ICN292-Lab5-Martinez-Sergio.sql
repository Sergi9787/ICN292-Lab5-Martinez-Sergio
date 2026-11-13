-- ICN292 - Laboratorio 5 - Andes Bike
-- Entregable 1: creación de la base y carga oficial
-- Entregable 2: diez consultas SQL

CREATE DATABASE IF NOT EXISTS andesbike
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE andesbike;

-- Permite volver a ejecutar el archivo desde cero.
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS vendedores;
DROP TABLE IF EXISTS bicicletas;
DROP TABLE IF EXISTS tiendas;

CREATE TABLE tiendas (
    id_tienda INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    comuna VARCHAR(50) NOT NULL
);

CREATE TABLE vendedores (
    id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    id_tienda INT NULL,
    fecha_ingreso DATE NOT NULL,
    CONSTRAINT fk_vendedores_tiendas
      FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

CREATE TABLE bicicletas (
    id_bicicleta INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(60) NOT NULL,
    categoria ENUM('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana') NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_bicicletas_precio CHECK (precio >= 0)
);

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_vendedor INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha DATE NOT NULL,
    unidades INT NOT NULL,
    CONSTRAINT fk_ventas_vendedores
      FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    CONSTRAINT fk_ventas_bicicletas
      FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta),
    CONSTRAINT chk_ventas_unidades CHECK (unidades > 0)
);

INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
(1, 'Andes Providencia', 'Providencia'),
(2, 'Andes Maipú', 'Maipú'),
(3, 'Andes Concepción', 'Concepción'),
(4, 'Andes La Serena', 'La Serena');

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
(1, 'Camila Ortiz', 1, '2024-06-20'),
(2, 'Diego Fuentes', 1, '2024-01-15'),
(3, 'Javiera Soto', 2, '2023-07-24'),
(4, 'Matías Herrera', 2, '2024-01-15'),
(5, 'Paula Riquelme', 3, '2022-11-02'),
(6, 'Ignacio Vera', 3, '2024-08-19'),
(7, 'Fernanda Lillo', 1, '2025-02-03'),
(8, 'Rubén Castro', NULL, '2025-06-10');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
(1, 'Cordillera 29', 'Montaña', 549990.00),
(2, 'Ruta Austral', 'Ruta', 899990.00),
(3, 'Urbana Pro', 'Urbana', 329990.00),
(4, 'Pequeño Andes', 'Infantil', 149990.00),
(5, 'Volt City', 'Eléctrica', 1249990.00),
(6, 'Trail Master', 'Montaña', 749990.00),
(7, 'Urbana Lite', 'Urbana', 229990.00),
(8, 'Sprint R7', 'Ruta', 1099990.00);

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, '2025-03-04', 2),
(1, 3, '2025-03-18', 1),
(1, 5, '2025-04-02', 1),
(2, 2, '2025-03-04', 1),
(2, 1, '2025-04-11', 3),
(2, 7, '2025-05-06', 2),
(3, 4, '2025-03-21', 4),
(3, 3, '2025-04-15', 2),
(3, 6, '2025-05-20', 1),
(4, 1, '2025-03-27', 1),
(4, 5, '2025-05-09', 2),
(5, 2, '2025-04-08', 1),
(5, 6, '2025-04-23', 2),
(5, 4, '2025-06-02', 5),
(6, 3, '2025-05-13', 3),
(6, 7, '2025-06-17', 1),
(6, 1, '2025-06-24', 2),
(1, 6, '2025-06-30', 1);

-- Control de carga: 4 tiendas, 8 vendedores, 8 bicicletas,
-- 18 ventas, 35 unidades y monto total 16.969.650.
SELECT (SELECT COUNT(*) FROM tiendas) AS tiendas,
       (SELECT COUNT(*) FROM vendedores) AS vendedores,
       (SELECT COUNT(*) FROM bicicletas) AS bicicletas,
       COUNT(*) AS ventas,
       SUM(v.unidades) AS unidades,
       SUM(v.unidades * b.precio) AS monto_total
FROM ventas v
JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta;

-- CONSULTA 1: vendedores y número de ventas (incluye cero).
SELECT vd.nombre AS vendedor,
       COUNT(v.id_venta) AS cantidad_ventas
FROM vendedores vd
LEFT JOIN ventas v ON v.id_vendedor = vd.id_vendedor
GROUP BY vd.id_vendedor, vd.nombre
ORDER BY cantidad_ventas DESC, vd.nombre ASC;

-- CONSULTA 2: ventas y unidades por tienda (incluye tiendas vacías).
SELECT t.nombre AS tienda,
       COUNT(v.id_venta) AS cantidad_ventas,
       COALESCE(SUM(v.unidades), 0) AS unidades_vendidas
FROM tiendas t
LEFT JOIN vendedores vd ON vd.id_tienda = t.id_tienda
LEFT JOIN ventas v ON v.id_vendedor = vd.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades_vendidas DESC;

-- CONSULTA 3: tiendas sin vendedores asignados.
SELECT t.nombre AS tienda
FROM tiendas t
LEFT JOIN vendedores vd ON vd.id_tienda = t.id_tienda
WHERE vd.id_vendedor IS NULL;

-- CONSULTA 4: modelos sin ventas en junio de 2025.
-- El filtro temporal está en ON para conservar los modelos sin coincidencias.
SELECT b.modelo
FROM bicicletas b
LEFT JOIN ventas v
  ON v.id_bicicleta = b.id_bicicleta
 AND v.fecha >= '2025-06-01'
 AND v.fecha < '2025-07-01'
WHERE v.id_venta IS NULL
ORDER BY b.modelo;

-- CONSULTA 5: vendedores sin ninguna venta, con su tienda si existe.
SELECT vd.nombre AS vendedor,
       t.nombre AS tienda
FROM vendedores vd
LEFT JOIN ventas v ON v.id_vendedor = vd.id_vendedor
LEFT JOIN tiendas t ON t.id_tienda = vd.id_tienda
WHERE v.id_venta IS NULL
ORDER BY vd.nombre;

-- CONSULTA 6: cada par de vendedores de una misma tienda, una sola vez.
-- El más antiguo primero; ante empate, menor id_vendedor primero.
SELECT a.nombre AS vendedor_1,
       a.fecha_ingreso AS ingreso_1,
       b.nombre AS vendedor_2,
       b.fecha_ingreso AS ingreso_2,
       t.nombre AS tienda
FROM vendedores a
JOIN vendedores b
  ON a.id_tienda = b.id_tienda
 AND (a.fecha_ingreso < b.fecha_ingreso
      OR (a.fecha_ingreso = b.fecha_ingreso AND a.id_vendedor < b.id_vendedor))
JOIN tiendas t ON t.id_tienda = a.id_tienda
ORDER BY t.nombre, a.fecha_ingreso, b.fecha_ingreso, a.nombre, b.nombre;

-- CONSULTA 7: monto de categorías Montaña y Ruta, sobre 2.000.000.
SELECT t.nombre AS tienda,
       SUM(v.unidades * b.precio) AS monto_total
FROM tiendas t
JOIN vendedores vd ON vd.id_tienda = t.id_tienda
JOIN ventas v ON v.id_vendedor = vd.id_vendedor
JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(v.unidades * b.precio) > 2000000
ORDER BY monto_total DESC;

-- CONSULTA 8: modelos más caros que el precio promedio del catálogo.
SELECT b.modelo, b.precio
FROM bicicletas b
WHERE b.precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY b.precio DESC;
-- El promedio pedido para la explicación del informe:
SELECT AVG(precio) AS precio_promedio_catalogo FROM bicicletas;

-- CONSULTA 9: vendedores con promedio por venta superior al global.
SELECT vd.nombre AS vendedor,
       AVG(v.unidades) AS promedio_unidades
FROM vendedores vd
JOIN ventas v ON v.id_vendedor = vd.id_vendedor
GROUP BY vd.id_vendedor, vd.nombre
HAVING AVG(v.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, vd.nombre ASC;

-- CONSULTA 10: monto total por vendedor (sin COALESCE intencionalmente).
SELECT vd.nombre AS vendedor,
       SUM(v.unidades * b.precio) AS monto_total
FROM vendedores vd
LEFT JOIN ventas v ON v.id_vendedor = vd.id_vendedor
LEFT JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta
GROUP BY vd.id_vendedor, vd.nombre
ORDER BY monto_total DESC;
-- SUM sin filas no nulas devuelve NULL; COALESCE(SUM(...), 0) lo muestra como cero.
