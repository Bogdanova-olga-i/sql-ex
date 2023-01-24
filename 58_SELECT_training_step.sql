"Схема БД состоит из четырех таблиц:
Product(maker, model, type)
PC(code, model, speed, ram, hd, cd, price)
Laptop(code, model, speed, ram, hd, price, screen)
Printer(code, model, color, type, price)
Таблица Product представляет производителя (maker), 
номер модели (model) и тип ('PC' - ПК, 'Laptop' - ПК-блокнот или 'Printer' - принтер). 
Предполагается, что номера моделей в таблице Product уникальны для всех производителей 
и типов продуктов. В таблице PC для каждого ПК, однозначно определяемого уникальным кодом
– code, указаны модель – model (внешний ключ к таблице Product), 
скорость - speed (процессора в мегагерцах), объем памяти - ram (в мегабайтах), 
размер диска - hd (в гигабайтах), скорость считывающего устройства - cd (например, '4x')
и цена - price (в долларах). 
Таблица Laptop аналогична таблице РС за исключением того, что вместо скорости CD 
содержит размер экрана -screen (в дюймах). 
В таблице Printer для каждой модели принтера указывается, является ли он цветным - 
color ('y', если цветной), тип принтера - type (лазерный – 'Laser', струйный – 'Jet' 
или матричный – 'Matrix') и цена - price."

"Задание: 58 (Serge I: 2009-11-13)
Для каждого типа продукции и каждого производителя из таблицы Product 
c точностью до двух десятичных знаков найти процентное отношение 
числа моделей данного типа данного производителя 
к общему числу моделей этого производителя.
Вывод: 
maker, type, 
процентное отношение числа моделей данного типа к общему числу моделей производителя"

/* Считаем общее кол-во моделей каждого производителя*/
WITH all_models AS (
    SELECT maker, COUNT(*) AS count_all 
    FROM product 
    GROUP BY maker
    ),
/* Считаем кол-во моделей каждого производителя, разбитое по типам*/
all_models_by_type AS (
    SELECT p.maker, p.type, COUNT(*) AS count_by_type
    FROM product p 
    GROUP BY  p.maker, p.type
    )
/* Проходимся по всем производителям и типам с помощью декартова произведения*/
/* Соединяем результаты произведения с данными полученными в CTE*/
SELECT m.maker, t.type, 
CAST((COALESCE(count_by_type, 0)/CAST(am.count_all AS DEC(12, 2))*100) AS DEC(12, 2)) AS ratio
FROM (SELECT maker FROM product GROUP BY maker) m 
    CROSS JOIN (SELECT type FROM product GROUP BY type) t 
    LEFT JOIN all_models am ON m.maker = am.maker 
    LEFT JOIN all_models_by_type mt ON m.maker=mt.maker AND t.type=mt.type
