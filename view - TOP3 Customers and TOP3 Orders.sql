Create VIEW TOP3Customers_TOP3Orders as
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

