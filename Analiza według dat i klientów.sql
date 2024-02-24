CREATE VIEW ZamowieniaDane as

WITH CTE AS
(SELECT OrderID, ROUND(SUM(UnitPrice*Quantity*(1-Discount)),2) as WartoscZamowienia 
FROM [Order Details]
GROUP BY OrderID)

SELECT O.OrderID, O.CustomerID, O.OrderDate, C.WartoscZamowienia, ROUND(SUM(WartoscZamowienia) OVER(),2) as SumaWszystkichZamowien, ROUND(AVG(WartoscZamowienia) OVER(),2) as SredniaWartoscZamowien
FROM Orders as O
LEFT JOIN CTE as C on o.OrderID = C.OrderID


 --Zam�wienia wed�ug daty

SELECT OrderDate, SUM(WartoscZamowienia) as WartoscZamowienDzien, LAG(SUM(WartoscZamowienia)) OVER(ORDER BY OrderDate) as WartoscZamowienDzienPoprzedni, SUM(WartoscZamowienia) - LAG(SUM(WartoscZamowienia)) OVER(ORDER BY OrderDate) as RoznicaWartosciZamowienDTD,
CASE
WHEN SUM(WartoscZamowienia) - LAG(SUM(WartoscZamowienia)) OVER(ORDER BY OrderDate)> 0 THEN 'Wartosc zam�wie� wy�sza ni� dzie� wcze�niej' ELSE 'Warto�� zam�wie� ni�sza ni� dzie� wcze�niej'
END as R�nica,
LAG(SUM(WartoscZamowienia),2) OVER(ORDER BY OrderDate) as WartoscZamowienDwaDniWczesniej
FROM ZamowieniaDane
GROUP BY OrderDate


-- Funkcja zwracaj�ca TOP 3 Zamowien w danym miesi�cu
CREATE FUNCTION Top3ZamowieniaMiesiac(@Rok INT, @Miesiac INT)
RETURNS TABLE AS
RETURN
SELECT TOP 3 WITH TIES OrderDate, SUM(WartoscZamowienia) as WartoscZamowienDzien FROM ZamowieniaDane
WHERE YEAR(OrderDate) = @Rok AND MONTH(OrderDate) = @Miesiac
GROUP BY OrderDate
ORDER BY WartoscZamowienDzien DESC

--Wywo�anie funkcji
SELECT * FROM Top3ZamowieniaMiesiac(1997,1)

 --Wszystkie zam�wienia klient�w
SELECT CustomerID, OrderDate, WartoscZamowienia, SUM(WartoscZamowienia) OVER(Partition by CustomerID Order By CustomerID) as WartoscZamowienKlient, WartoscZamowienia - LAG(WartoscZamowienia) OVER(Partition by CustomerID Order By OrderDate) as RoznicaWartosciZamowien,
COALESCE(
DATEPART(DAYOFYEAR, OrderDate - LAG(OrderDate) OVER(Partition By CustomerID Order By OrderDate)),0)
as CzasOdPoprzedniegoZamowienia
FROM ZamowieniaDane
ORDER BY CustomerID, OrderDate

 --Klienci, kt�rzy z�o�yli tylko 1 zam�wienie
SELECT T.CustomerID
FROM
(
SELECT CustomerID, COUNT(OrderID) as IloscZamowien
FROM ZamowieniaDane
GROUP BY CustomerID
) as T
WHERE T.IloscZamowien = 1

