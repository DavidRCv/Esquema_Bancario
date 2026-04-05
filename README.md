# Sistema Bancario en SQL (MySQL)

Este proyecto consiste en el diseño de una base de datos relacional para un sistema bancario, junto con la resolución de 25 consultas SQL que permiten analizar la información almacenada.

# CONSULTA 1. Clientes con al menos una cuenta

Se utilizó un INNER JOIN entre clientes y cuentas para mostrar únicamente aquellos clientes que tienen al menos una cuenta registrada.

SELECT DISTINCT clientes.*

FROM clientes
INNER JOIN cuentas -- combine only when they match

ON clientes.id = cuentas.cliente_id;


# CONSULTA 2. Saldo total por cliente

Se sumaron los balances de todas las cuentas de cada cliente usando SUM() y se agruparon los resultados con GROUP BY.

SELECT clientes.id, clientes.nombres, SUM(cuentas.balance) -- sums up the balance for the 
clients accs

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

GROUP BY clientes.id, clientes.nombres;

# CONSULTA 3. Transacciones de un cliente específico

Se conectaron las tablas transacciones → cuentas → clientes para obtener todas las transacciones asociadas a un cliente en particular.

SELECT transacciones.*

FROM transacciones

INNER JOIN cuentas

ON transacciones.cuenta_id = cuentas.id

WHERE cuentas.cliente_id = 1; -- [1, ... ,8] acc not client

# CONSULTA 4. Cuentas con saldo mayor a 10,000

Se aplicó un filtro con WHERE sobre el campo balance para mostrar únicamente las cuentas con saldo alto.

SELECT *

FROM cuentas

WHERE balance > 10000;

# CONSULTA 5. Clientes que tienen tarjetas

Se utilizó un INNER JOIN entre clientes y tarjetas para listar solo los clientes que poseen al menos una tarjeta.

SELECT DISTINCT clientes.*

FROM clientes

INNER JOIN tarjetas -- clients that have a match in tarjetas

ON clientes.id = tarjetas.cliente_id; -- client ->tarjeta

# CONSULTA 6. Número de cuentas por cliente

Se contó la cantidad de cuentas por cliente usando COUNT() junto con GROUP BY.

SELECT clientes.id, clientes.nombres, COUNT(cuentas.id)

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

GROUP BY clientes.id, clientes.nombres;

# CONSULTA 7. Préstamos activos

Se filtraron los préstamos con WHERE, mostrando únicamente aquellos cuyo estado es "activo".

SELECT *

FROM prestamos

WHERE prestamos.estado = 'activo';

# CONSULTA 8. Monto total transferido desde cada cuenta

Se agruparon las transferencias por cuenta origen (desde) y se sumaron los montos con SUM().

SELECT transferencias.desde, SUM(transferencias.monto)

FROM transferencias

GROUP BY transferencias.desde;


# CONSULTA 9. Transacciones del último mes

Se utilizó una condición de tiempo con NOW() y INTERVAL para obtener las transacciones recientes.

SELECT *

FROM transacciones

WHERE transacciones.tiempo >= NOW() - INTERVAL 1 MONTH; -- ()CURRENTDATE


# CONSULTA 10. Clientes con inversiones mayores a 5,000

Se filtraron las inversiones por monto y se relacionaron con clientes mediante JOIN.

SELECT DISTINCT clientes.*

FROM clientes

INNER JOIN inversiones

ON clientes.id = inversiones.cliente_id

WHERE inversiones.monto > 5000;

# CONSULTA 11. Nombre del cliente, número de cuenta y saldo

Se combinaron las tablas clientes y cuentas para mostrar información conjunta de cada cliente con sus cuentas.

SELECT clientes.nombres, cuentas.numero, cuentas.balance

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id;

# CONSULTA 12. Total de transacciones por cuenta

Se contó el número de transacciones por cada cuenta utilizando COUNT() y agrupación.

SELECT cuentas.id, COUNT(transacciones.id)

FROM cuentas

INNER JOIN transacciones

ON cuentas.id = transacciones.cuenta_id

GROUP BY cuentas.id;

# CONSULTA 13. Clientes sin cuentas

Se utilizó LEFT JOIN y se filtraron los valores NULL para identificar clientes que no tienen cuentas.

SELECT clientes.*

FROM clientes

LEFT JOIN cuentas  -- give me all clients, evn if they don't have acc

ON clientes.id = cuentas.cliente_id

WHERE cuentas.id IS NULL; -- when is null, return it

# CONSULTA 14. Cliente con más cuentas

Se contaron las cuentas por cliente, se ordenaron de mayor a menor (ORDER BY) y se limitó el resultado a uno (LIMIT 1).

SELECT clientes.id, clientes.nombres, COUNT(cuentas.id) AS total_cuentas

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

GROUP BY clientes.id, clientes.nombres

ORDER BY total_cuentas DESC

LIMIT 1;

# CONSULTA 15. Total de préstamos por cliente

Se sumaron los montos de los préstamos agrupados por cliente.

SELECT clientes.id, clientes.nombres, SUM(prestamos.monto)

FROM clientes

INNER JOIN prestamos

ON clientes.id = prestamos.cliente_id

GROUP BY clientes.id, clientes.nombres;

# CONSULTA 16. Total invertido por cliente

Se sumaron las inversiones de cada cliente usando SUM() y GROUP BY.

SELECT clientes.id, clientes.nombres, SUM(inversiones.monto)

FROM clientes

INNER JOIN inversiones

ON clientes.id = inversiones.cliente_id

GROUP BY clientes.id, clientes.nombres;

# CONSULTA 17. Cuentas sin transacciones

Se utilizó LEFT JOIN entre cuentas y transacciones, filtrando los casos donde no hay coincidencias (NULL).

SELECT cuentas.*

FROM cuentas

LEFT JOIN transacciones

ON cuentas.id = transacciones.cuenta_id

WHERE transacciones.id IS NULL;


# CONSULTA 18. Promedio de monto por transacción

Se calculó el promedio general utilizando la función AVG().

SELECT AVG(transacciones.monto)

FROM transacciones;

# CONSULTA 19. Top 5 clientes con mayor saldo

Se sumaron los balances por cliente, se ordenaron de mayor a menor y se limitaron los resultados a los 5 primeros.

SELECT clientes.id, clientes.nombres, SUM(cuentas.balance) AS saldo_total

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

GROUP BY clientes.id, clientes.nombres

ORDER BY saldo_total DESC

LIMIT 5;

# CONSULTA 20. Clientes con cuentas y préstamos

Se usaron múltiples INNER JOIN para mostrar clientes que cumplen ambas condiciones.

SELECT DISTINCT clientes.*

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

INNER JOIN prestamos

ON clientes.id = prestamos.cliente_id;


# CONSULTA 21. Cliente con mayor actividad

Se contaron las transacciones por cliente, se ordenaron de mayor a menor y se seleccionó el primero.

SELECT clientes.id, clientes.nombres, COUNT(transacciones.id) AS total_transacciones

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

INNER JOIN transacciones

ON cuentas.id = transacciones.cuenta_id

GROUP BY clientes.id, clientes.nombres

ORDER BY total_transacciones DESC

LIMIT 1;

# CONSULTA 22. Transferencias sospechosas

Se agruparon las transferencias por cuenta y fecha, y se filtraron aquellas con más de 3 operaciones usando HAVING. Debido a las cuentas agregadas, no muestra un resultado, pero la lógica sigue valida.

SELECT transferencias.desde, DATE(transferencias.tiempo), COUNT(transferencias.id)

FROM transferencias

GROUP BY transferencias.desde, DATE(transferencias.tiempo)

HAVING COUNT(transferencias.id) > 3;

# CONSULTA 23. Clientes con saldo menor a sus préstamos

Se compararon las sumas de balances y préstamos por cliente utilizando HAVING.

SELECT clientes.id, clientes.nombres

FROM clientes

INNER JOIN cuentas

ON clientes.id = cuentas.cliente_id

INNER JOIN prestamos

ON clientes.id = prestamos.cliente_id

GROUP BY clientes.id, clientes.nombres

HAVING SUM(cuentas.balance) < SUM(prestamos.monto);

# CONSULTA 24. Ranking de clientes por inversiones

Se utilizó la función RANK() junto con OVER para asignar una posición a cada cliente según su inversión total.

SELECT clientes.id, clientes.nombres,

SUM(inversiones.monto) AS total_invertido,

RANK() OVER (ORDER BY SUM(inversiones.monto) DESC) AS ranking

FROM clientes

INNER JOIN inversiones

ON clientes.id = inversiones.cliente_id

GROUP BY clientes.id, clientes.nombres;

# CONSULTA 25. Crecimiento de inversiones por cliente

Se calculó la diferencia entre el valor actual y el monto invertido para medir la ganancia o pérdida.

SELECT clientes.id, clientes.nombres,

SUM(inversiones.monto) AS total_inicial,

SUM(inversiones.valor_actual) AS total_actual,

SUM(inversiones.valor_actual) - SUM(inversiones.monto) AS crecimiento

FROM clientes

INNER JOIN inversiones

ON clientes.id = inversiones.cliente_id

GROUP BY clientes.id, clientes.nombres;
