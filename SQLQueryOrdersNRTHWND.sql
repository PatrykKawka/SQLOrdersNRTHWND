use NORTHWND

--Widok z zamówieniami z 1997
CREATE VIEW zamowienia1997
AS
  SELECT o.customerid,
         o.orderid,
         o.orderdate,
         C.contactname
  FROM   orders AS O
         LEFT JOIN customers AS C
                ON O.customerid = C.customerid
  --where o.OrderDate between '1997-01-01' and '1997-12-31'
  WHERE  Datepart(year, orderdate) = 1997 

--Miesi¹ce, w których, klienci nie z³ozyli zamówieñ
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


--TOP 3 klientow i ich TOP 3 transakcji
CREATE VIEW zamowienia AS
SELECT    o.orderid,
          o.customerid,
          o.employeeid,
          o.                                              orderdate,
          (od.unitprice * od.quantity*(1-od.discount)) AS wartosc
FROM      orders                                       AS o
LEFT JOIN [Order Details]                              AS od
ON        o.orderid=od.orderid
          (
                   select   customerid,
                            orderid,
                            sum(wartosc) AS wartosczamowienia
                   FROM     zamowienia
                   GROUP BY customerid,
                            orderid
                   ORDER BY wartosczamowienia DESC) TOP 3 klientow
SELECT TOP 3 WITH ties
                         customerid,
         sum(wartosc) AS wartosczamowienia
FROM     zamowienia
GROUP BY customerid
ORDER BY wartosczamowienia DESC
SELECT *
FROM   (
                SELECT   t1.customerid,
                         t1.orderid,
                         t1.wartosczamowienia,
                         dense_rank() OVER(partition BY t1.customerid ORDER BY t1.wartosczamowienia) AS ranking
                FROM     (
                                  SELECT   customerid,
                                           orderid,
                                           sum(wartosc) AS wartosczamowienia
                                  FROM     zamowienia
                                  GROUP BY customerid,
                                           orderid) AS t1
                JOIN
                         (
                                  SELECT TOP 3 WITH ties
                                                           customerid,
                                           sum(wartosc) AS wartosczamowienia
                                  FROM     zamowienia
                                  GROUP BY customerid
                                  ORDER BY wartosczamowienia DESC) AS t2
                ON       t1.customerid=t2.customerid ) AS t3
WHERE  t3.ranking IN (1,2,3)

