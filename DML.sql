-- 1. ¿Cuáles son las 5 cartas más caras actualmente en el mercado (holofoil)?
SELECT c.name, p.precio
FROM cartas c
JOIN precios p ON c.id = p.carta_id
WHERE p.tipo_precio = 'Holofoil'
  AND p.fecha = (SELECT MAX(fecha) FROM precios)
ORDER BY p.precio DESC
LIMIT 5;

-- 2. ¿Cuántas cartas tienen un precio de mercado en holofoil mayor a $100?
SELECT COUNT(DISTINCT c.id)
FROM cartas c
JOIN precios p ON c.id = p.carta_id
WHERE p.tipo_precio = 'Holofoil'
  AND p.fecha = (SELECT MAX(fecha) FROM precios)
  AND p.precio > 100;

-- 3. ¿Cuál es el precio promedio de una carta en holofoil en la última actualización?
SELECT AVG(p.precio) AS precio_promedio_holofoil
FROM precios p
WHERE p.tipo_precio = 'Holofoil'
  AND p.fecha = (SELECT MAX(fecha) FROM precios);

-- 4. ¿Cuáles son las cartas que han bajado de precio en la última actualización?
SELECT 
    c.name,
    prev.precio AS precio_anterior,
    curr.precio AS precio_actual,
    (prev.precio - curr.precio) AS diferencia
FROM 
    cartas c
JOIN 
    precios curr ON c.id = curr.carta_id
JOIN 
    precios prev ON c.id = prev.carta_id
WHERE 
    curr.tipo_precio = 'Holofoil'
    AND prev.tipo_precio = 'Holofoil'
    AND curr.fecha = (SELECT MAX(fecha) FROM precios)
    AND prev.fecha = (
        SELECT MAX(fecha) FROM precios 
        WHERE fecha < (SELECT MAX(fecha) FROM precios)
    )
    AND curr.precio < prev.precio
ORDER BY 
    diferencia DESC;
    
-- 5. ¿Qué tipo de Pokémon tiene el precio promedio más alto en holofoil?
SELECT c.types, AVG(p.precio) AS precio_promedio
FROM cartas c
JOIN precios p ON c.id = p.carta_id
WHERE p.tipo_precio = 'Holofoil'
  AND p.fecha = (SELECT MAX(fecha) FROM precios)
GROUP BY c.types
ORDER BY precio_promedio DESC
LIMIT 1;

-- 6. ¿Cuál es la diferencia de precio entre la carta más cara y la más barata en holofoil?
SELECT 
    MAX(p.precio) - MIN(p.precio) AS diferencia_precios
FROM precios p
WHERE p.tipo_precio = 'Holofoil'
  AND p.fecha = (SELECT MAX(fecha) FROM precios);

-- 7. ¿Cuántas cartas tienen precios disponibles en todas las condiciones (normal, reverse holofoil y holofoil)?
SELECT c.name, COUNT(DISTINCT p.tipo_precio) AS condiciones_disponibles
FROM cartas c
JOIN precios p ON c.id = p.carta_id
WHERE p.fecha = (SELECT MAX(fecha) FROM precios)
  AND p.tipo_precio IN ('Normal', 'Reverse Holofoil', 'Holofoil')
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT p.tipo_precio) = 3;

-- 8. ¿Cuál fue la fecha más reciente de actualización de precios?
SELECT MAX(fecha) AS ultima_actualizacion
FROM precios;

-- 9. ¿Cuáles son las 3 cartas con la mayor diferencia entre el precio más alto y el más bajo en holofoil?
SELECT c.name, 
       MAX(p.precio) - MIN(p.precio) AS diferencia_precios
FROM cartas c
JOIN precios p ON c.id = p.carta_id
WHERE p.tipo_precio = 'Holofoil'
GROUP BY c.id, c.name
ORDER BY diferencia_precios DESC
LIMIT 3;

-- 10. ¿Cuál es la carta más cara de cada tipo de Pokémon?
WITH ranked_prices AS (
    SELECT 
        c.types,
        c.name,
        p.precio,
        RANK() OVER (PARTITION BY c.types ORDER BY p.precio DESC) AS rank
    FROM cartas c
    JOIN precios p ON c.id = p.carta_id
    WHERE p.tipo_precio = 'Holofoil'
      AND p.fecha = (SELECT MAX(fecha) FROM precios)
)
SELECT types, name, precio
FROM ranked_prices
WHERE rank = 1
ORDER BY precio DESC;