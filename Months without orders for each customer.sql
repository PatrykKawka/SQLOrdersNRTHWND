SELECT T1.customerid,
       T2.miesiac
FROM   (SELECT DISTINCT customerid
        FROM   customers) AS T1
       CROSS JOIN (SELECT DISTINCT Month(orderdate) AS Miesiac
                   FROM   orders) AS T2
EXCEPT
SELECT DISTINCT customerid,
                Datepart(month, orderdate) AS Miesiac
FROM   zamowienia1997
ORDER  BY 1,
          2 