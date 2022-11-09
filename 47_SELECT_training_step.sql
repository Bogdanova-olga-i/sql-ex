"Краткая информация о базе данных Корабли:
Рассматривается БД кораблей, участвовавших во второй мировой войне.
Имеются следующие отношения:
Classes (class, type, country, numGuns, bore, displacement)
Ships (name, class, launched)
Battles (name, date)
Outcomes (ship, battle, result)
Корабли в «классах» построены по одному и тому же проекту, и классу присваивается либо имя первого корабля, построенного по данному проекту, либо названию класса дается имя проекта, которое не совпадает ни с одним из кораблей в БД. Корабль, давший название классу, называется головным.
Отношение Classes содержит имя класса, тип (bb для боевого (линейного) корабля или bc для боевого крейсера), страну, в которой построен корабль, число главных орудий, калибр орудий (диаметр ствола орудия в дюймах) и водоизмещение ( вес в тоннах). В отношении Ships записаны название корабля, имя его класса и год спуска на воду. В отношение Battles включены название и дата битвы, в которой участвовали корабли, а в отношении Outcomes – результат участия данного корабля в битве (потоплен-sunk, поврежден - damaged или невредим - OK).
Замечания. 1) В отношение Outcomes могут входить корабли, отсутствующие в отношении Ships. 
2) Потопленный корабль в последующих битвах участия не принимает."

"Задание: 47 (Serge I: 2019-06-07)
Определить страны, которые потеряли в сражениях все свои корабли."

With pres_count1 AS (
    /*Считаем корабли из таблицы Ships*/
    SELECT c.country, COUNT(name) AS pres
    FROM Classes c INNER JOIN Ships s ON c.class=s.class
    GROUP BY country
    UNION ALL
     /*Считаем корабли из таблицы Outcomes, 
     не вошедшие в таблицу Ships*/
    SELECT c.country, COUNT(DISTINCT ship) AS pres
    FROM Classes c INNER JOIN Outcomes o ON c.class=o.ship
    WHERE ship NOT IN (SELECT name FROM Ships)
    GROUP BY country
    ),
pres_count2 AS (
    /*Подводим итог кораблей в наличии по странам*/
    SELECT country, SUM(pres) AS pres_count
    FROM pres_count1
    GROUP BY country
    ),
out_1 AS (
     /*Считаем утонувшие корабли в таблице Ships*/
    SELECT c.country, COUNT(s.name) AS sunked
    FROM Classes c INNER JOIN Ships s ON c.class=s.class JOIN Outcomes o ON o.ship=s.name
    WHERE result='sunk'
    GROUP BY country
    UNION ALL
    /*Считаем утонувшие корабли из таблицы Outcomes, 
     не вошедшие в таблицу Ships*/
    SELECT c.country, COUNT(o.ship) AS sunked
    FROM Classes c INNER JOIN Outcomes o ON c.class=o.ship
    WHERE result='sunk' AND ship NOT IN (SELECT name FROM Ships)
    GROUP BY country
    ),
out_2 AS (
    /*Подводим итог утонувших кораблей по странам*/
    SELECT country, SUM(sunked) AS out
    FROM out_1
    GROUP BY country
    )
/*Итоговый запрос*/
SELECT p.country
FROM  pres_count2  p LEFT JOIN out_2 o ON p.country=o.country
WHERE pres_count=out

