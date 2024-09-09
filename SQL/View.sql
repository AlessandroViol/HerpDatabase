-- A simple example view
CREATE VIEW StoreSerpenti AS (
  SELECT
    se.ID,
    se.Nome,
    se.Sesso,
    se.DataNascita,
    se.Stato,
    se.Cites,
    se.Foto,
    se.Prezzo,
    a.Nome AS 'Nome Allevamento',
    sp.NomeComune AS 'Specie'
  FROM
    Serpente se
    INNER JOIN Allevamento a ON se.IVAAllevamento = a.IVA
    INNER JOIN Specie sp ON se.NomeSpecie = sp.NomeScientifico
  WHERE
    Stato IN ('In vendita', 'In adozione')
);