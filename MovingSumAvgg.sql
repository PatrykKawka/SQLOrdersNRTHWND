SELECT O.OrderDate, O.WartoscZamowienDzien, SUM(o.WartoscZamowienDzien) OVER(ORDER BY OrderDate ROWS UNBOUNDED Preceding) as SumaRuchoma, ROUND(AVG(o.WartoscZamowienDzien) OVER(ORDER BY OrderDate ROWS UNBOUNDED Preceding),2) as SredniaRuchoma
FROM
(
SELECT OrderDate, SUM(WartoscZamowienia) as WartoscZamowienDzien
FROM ZamowieniaDane
GROUP BY OrderDate) as O