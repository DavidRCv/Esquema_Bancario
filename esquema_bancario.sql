CREATE DATABASE IF NOT EXISTS esquema_bancario;

USE esquema_bancario;

CREATE TABLE clientes ( -- tabla base
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255)
);

CREATE TABLE cuentas ( -- dependent tables
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL, -- it needs to belong to a clients
    tipo ENUM('ahorro', 'corriente') NOT NULL, -- restricts values to only valid values ()
    numero BIGINT NOT NULL UNIQUE, -- bigint 'til 9 quintillion, and because it doesn't share the same number
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00, -- not float bc only approximates the values, default 0 is nothing is added
	FOREIGN KEY (cliente_id) REFERENCES clientes(id) -- prevents accs from pointing to nonexistent clients
);

CREATE TABLE tarjetas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    tipo ENUM('debito', 'credito') NOT NULL,
    numero BIGINT NOT NULL UNIQUE,
    limite DECIMAL(12,2), -- nullable, since not all cards need it

    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE prestamos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    tasa DECIMAL(5,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('activo', 'pagado', 'default') NOT NULL,

    FOREIGN KEY (cliente_id) REFERENCES clientes(id) -- prevents accs from pointing to nonexistent clients
); 

CREATE TABLE inversiones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    tipo ENUM('acciones', 'bonos', 'fondos') NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha DATE NOT NULL,
    valor_actual DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (cliente_id) REFERENCES clientes(id) -- " "
); 
  
CREATE TABLE transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cuenta_id INT NOT NULL, -- connects transaccion to acc
    tiempo DATETIME NOT NULL,
    tipo ENUM('deposito', 'retiro', 'transferencia') NOT NULL,
    monto DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (cuenta_id) REFERENCES cuentas(id) -- " "
);

CREATE TABLE transferencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    desde INT NOT NULL, -- fk
    hacia INT NOT NULL, -- fk
    tiempo DATETIME NOT NULL,
    monto DECIMAL(12,2) NOT NULL, -- exact moneyy

    FOREIGN KEY (desde) REFERENCES cuentas(id),
    FOREIGN KEY (hacia) REFERENCES cuentas(id),

    CHECK (desde <> hacia) -- prevents self transfer of mony
);

-- clients created

INSERT INTO clientes (nombres, apellidos, telefono, direccion) VALUES
('Juan', 'Perez', '999111222', 'Lima'),
('Maria', 'Lopez', '988222333', 'Arequipa'),
('Carlos', 'Sanchez', '977333444', 'Cusco'),
('Ana', 'Torres', '966444555', 'Trujillo'),
('Luis', 'Ramirez', '955555666', 'Piura'),
('Sofia', 'Gomez', '944666777', 'Chiclayo'),
('Diego', 'Vargas', '933777888', 'Ica'),
('Elena', 'Castro', '922888999', 'Tacna');

-- cuentas created (no 7 y 8 para la pregunta 13)

INSERT INTO cuentas (cliente_id, tipo, numero, balance) VALUES
(1, 'ahorro', 100001, 15000.00),
(1, 'corriente', 100002, 5000.00),
(2, 'ahorro', 100003, 20000.00),
(3, 'corriente', 100004, 3000.00),
(4, 'ahorro', 100005, 800.00),
(5, 'corriente', 100006, 12000.00),
(6, 'ahorro', 100007, 0.00);

-- transacciones created (algunos no tiened nada, pregunta 17)

INSERT INTO transacciones (cuenta_id, tiempo, tipo, monto) VALUES
(1, '2026-03-01 10:00:00', 'deposito', 5000.00),
(1, '2026-03-05 12:00:00', 'retiro', 2000.00),
(2, '2026-03-10 09:00:00', 'deposito', 3000.00),
(3, '2026-03-15 14:00:00', 'deposito', 10000.00),
(3, '2026-03-20 16:00:00', 'retiro', 2000.00),
(5, '2026-04-01 11:00:00', 'deposito', 12000.00);

-- transferencias created

INSERT INTO transferencias (desde, hacia, tiempo, monto) VALUES
(1, 2, '2026-04-01 10:00:00', 1000.00),
(1, 3, '2026-04-01 11:00:00', 500.00),
(1, 4, '2026-04-01 12:00:00', 300.00),
(2, 1, '2026-04-02 09:00:00', 700.00);

-- prestamos

INSERT INTO prestamos (cliente_id, monto, tasa, fecha_inicio, fecha_fin, estado) VALUES
(1, 10000.00, 10.50, '2025-01-01', '2027-01-01', 'activo'),
(2, 5000.00, 8.00, '2024-06-01', '2026-06-01', 'pagado'),
(3, 20000.00, 12.00, '2025-03-01', '2028-03-01', 'activo'),
(6, 7000.00, 9.50, '2025-07-01', '2027-07-01', 'default');

-- inversiones created

INSERT INTO inversiones (cliente_id, tipo, monto, fecha, valor_actual) VALUES
(1, 'acciones', 5000.00, '2025-01-01', 7000.00),
(2, 'bonos', 3000.00, '2025-02-01', 3500.00),
(3, 'fondos', 8000.00, '2025-03-01', 7500.00),
(5, 'acciones', 10000.00, '2025-04-01', 15000.00);

-- tarjetas creadas

INSERT INTO tarjetas (cliente_id, tipo, numero, limite) VALUES
(1, 'credito', 555001, 5000.00),
(2, 'debito', 555002, NULL),
(3, 'credito', 555003, 10000.00);

-- test para cada una de las tablas creadas con datos insertados

SELECT * FROM clientes;
SELECT * FROM cuentas;
SELECT * FROM transacciones;
SELECT * FROM transferencias;
SELECT * FROM prestamos;
SELECT * FROM inversiones;

-- querys

-- Pregunta 1:Listar todos los clientes con al menos una cuenta.

SELECT DISTINCT clientes.*
FROM clientes
INNER JOIN cuentas -- combine only when they match
ON clientes.id = cuentas.cliente_id;

-- Pregunta 2:Mostrar el saldo total por cliente.

SELECT clientes.id, clientes.nombres, SUM(cuentas.balance) -- sums up the balance for the clients accs
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
GROUP BY clientes.id, clientes.nombres;

-- Pregunta 3:Obtener todas las transacciones de un cliente específico.

SELECT transacciones.*
FROM transacciones
INNER JOIN cuentas
ON transacciones.cuenta_id = cuentas.id
WHERE cuentas.cliente_id = 1; -- [1, ... ,8] acc not client

-- Pregunta 4:Listar cuentas con saldo mayor a 10,000.

SELECT *
FROM cuentas
WHERE balance > 10000;

-- Pregunta 5:Mostrar los clientes que tienen tarjetas (cards).

SELECT DISTINCT clientes.*
FROM clientes
INNER JOIN tarjetas -- clients that have a match in tarjetas
ON clientes.id = tarjetas.cliente_id; -- client ->tarjeta


-- Pregunta 6:Obtener el número de cuentas por cliente.

SELECT clientes.id, clientes.nombres, COUNT(cuentas.id)
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
GROUP BY clientes.id, clientes.nombres;

-- Pregunta 7:Listar los préstamos activos (status = 'active').

SELECT *
FROM prestamos
WHERE prestamos.estado = 'activo';

-- Pregunta 8:Mostrar el monto total transferido desde cada cuenta.

SELECT transferencias.desde, SUM(transferencias.monto)
FROM transferencias
GROUP BY transferencias.desde;

-- Pregunta 9:Obtener las transacciones del último mes.

SELECT *
FROM transacciones
WHERE transacciones.tiempo >= NOW() - INTERVAL 1 MONTH; -- ()CURRENTDATE

-- Pregunta 10:Mostrar clientes que tienen inversiones mayores a 5,000.

SELECT DISTINCT clientes.*
FROM clientes
INNER JOIN inversiones
ON clientes.id = inversiones.cliente_id
WHERE inversiones.monto > 5000;

-- Pregunta 11:Mostrar nombre del cliente + número de cuenta + saldo.

SELECT clientes.nombres, cuentas.numero, cuentas.balance
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id;

-- Pregunta 12:Obtener el total de transacciones por cuenta.

SELECT cuentas.id, COUNT(transacciones.id)
FROM cuentas
INNER JOIN transacciones
ON cuentas.id = transacciones.cuenta_id
GROUP BY cuentas.id;

-- Pregunta 13:Listar clientes sin cuentas.

SELECT clientes.*
FROM clientes
LEFT JOIN cuentas  -- give me all clients, evn if they don't have acc
ON clientes.id = cuentas.cliente_id
WHERE cuentas.id IS NULL; -- when is null, return it

-- Pregunta 14:Mostrar el cliente con más cuentas.

SELECT clientes.id, clientes.nombres, COUNT(cuentas.id) AS total_cuentas
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
GROUP BY clientes.id, clientes.nombres
ORDER BY total_cuentas DESC
LIMIT 1;

-- Pregunta 15:Obtener el total de préstamos por cliente.

SELECT clientes.id, clientes.nombres, SUM(prestamos.monto)
FROM clientes
INNER JOIN prestamos
ON clientes.id = prestamos.cliente_id
GROUP BY clientes.id, clientes.nombres;

-- Pregunta 16:Mostrar el total invertido por cliente.

SELECT clientes.id, clientes.nombres, SUM(inversiones.monto)
FROM clientes
INNER JOIN inversiones
ON clientes.id = inversiones.cliente_id
GROUP BY clientes.id, clientes.nombres;

-- Pregunta 17:Listar cuentas que nunca han tenido transacciones.

SELECT cuentas.*
FROM cuentas
LEFT JOIN transacciones
ON cuentas.id = transacciones.cuenta_id
WHERE transacciones.id IS NULL;

-- Pregunta 18:Obtener el promedio de monto por transacción.

SELECT AVG(transacciones.monto)
FROM transacciones;

-- Pregunta 19:Mostrar los 5 clientes con mayor saldo total. 

SELECT clientes.id, clientes.nombres, SUM(cuentas.balance) AS saldo_total
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
GROUP BY clientes.id, clientes.nombres
ORDER BY saldo_total DESC
LIMIT 5;

-- Pregunta 20:Listar clientes que tienen cuentas y préstamos.

SELECT DISTINCT clientes.*
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
INNER JOIN prestamos
ON clientes.id = prestamos.cliente_id;

-- Pregunta 21:Obtener el cliente con mayor actividad (más transacciones).

SELECT clientes.id, clientes.nombres, COUNT(transacciones.id) AS total_transacciones
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
INNER JOIN transacciones
ON cuentas.id = transacciones.cuenta_id
GROUP BY clientes.id, clientes.nombres
ORDER BY total_transacciones DESC
LIMIT 1;

-- Pregunta 22:Detectar cuentas con transferencias sospechosas (más de 3 transferencias enun día)

SELECT transferencias.desde, DATE(transferencias.tiempo), COUNT(transferencias.id)
FROM transferencias
GROUP BY transferencias.desde, DATE(transferencias.tiempo)
HAVING COUNT(transferencias.id) > 3;

-- Pregunta 23:Listar clientes cuyo saldo total es menor a sus préstamos.

SELECT clientes.id, clientes.nombres
FROM clientes
INNER JOIN cuentas
ON clientes.id = cuentas.cliente_id
INNER JOIN prestamos
ON clientes.id = prestamos.cliente_id
GROUP BY clientes.id, clientes.nombres
HAVING SUM(cuentas.balance) < SUM(prestamos.monto);

-- Pregunta 24:Obtener el ranking de clientes por inversiones (RANK()).

SELECT clientes.id, clientes.nombres,
SUM(inversiones.monto) AS total_invertido,
RANK() OVER (ORDER BY SUM(inversiones.monto) DESC) AS ranking
FROM clientes
INNER JOIN inversiones
ON clientes.id = inversiones.cliente_id
GROUP BY clientes.id, clientes.nombres;

-- Pregunta 25:Mostrar el crecimiento de inversiones por cliente (comparando amount vscurrent_val).

SELECT clientes.id, clientes.nombres,
SUM(inversiones.monto) AS total_inicial,
SUM(inversiones.valor_actual) AS total_actual,
SUM(inversiones.valor_actual) - SUM(inversiones.monto) AS crecimiento
FROM clientes
INNER JOIN inversiones
ON clientes.id = inversiones.cliente_id
GROUP BY clientes.id, clientes.nombres;
























