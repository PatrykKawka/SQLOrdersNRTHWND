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