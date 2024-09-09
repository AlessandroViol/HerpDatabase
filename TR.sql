-- Trigger banali che si occupano principalmente di assicurarsi che tutti i record presenti nelle tabelle siano sensati. 
-- La maggior parte sono banali, ne riportiamo solo i seguenti come esempio.
DROP TRIGGER TR_AggiuntaTerrario;

DELIMITER $$
CREATE TRIGGER TR_AggiuntaTerrario BEFORE
UPDATE ON Terrario FOR EACH ROW BEGIN IF NEW.AltaTemp - NEW.BassaTemp < 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'La bassa temperatura è maggiore dell''alta temperatura.';

END IF;

END $$ DELIMITER;

DROP TRIGGER TR_ModificaTerrario;

DELIMITER $$
CREATE TRIGGER TR_ModificaTerrario BEFORE
UPDATE ON Terrario FOR EACH ROW BEGIN IF NEW.AltaTemp - NEW.BassaTemp < 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'La bassa temperatura è maggiore dell''alta temperatura.';

END IF;

END $$ DELIMITER;

-- I trigger di seguito sono invece più complessi poiché riguardano la relazione Serpente dove vertono la maggior parte dei vincoli di progetto.
DROP TRIGGER TR_AggiuntaSerpente;

DELIMITER $$
CREATE TRIGGER TR_AggiuntaSerpente BEFORE
INSERT
  ON Serpente FOR EACH ROW BEGIN IF NEW.Nome IN (
    SELECT
      Nome
    FROM
      Serpente
    WHERE
      IVAAllevamento = NEW.IVAAllevamento
      AND Stato NOT IN('Venduto', 'Adottato', 'Morto')
  ) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Esiste già un serpente con questo nome in questo allevamento.';

ELSEIF NEW.Sesso NOT IN('M', 'F') THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'L''input inserito per il sesso del serpente non è né M né F.';

ELSEIF NEW.Stato IN (
  'In vendita',
  'Venduto',
  'In adozione',
  'Adottato'
) THEN IF NEW.Prezzo IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Non è stato indicato il prezzo per il serpente.';

ELSEIF NEW.Cites IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'URL della certificazione Cites mancante.';

ELSEIF NEW.Foto IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'URL della foto mancante.';

ELSEIF NEW.Stato IN ('Venduto', 'Adottato') THEN IF NEW.CFCliente IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Codice fiscale acquirente mancante';

ELSEIF NEW.DataAcquisto IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Non è stata specificata la data di acquisto o adozione.';

ELSEIF NEW.DataNascita IS NOT NULL
AND NOT DateCheck (NEW.DataNascita, NEW.DataAcquisto) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'L''intervallo di date inserito non è valido.';

END IF;

END IF;

ELSEIF NEW.Stato <> 'Morto' THEN IF NEW.Prezzo IS NOT NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato inserito il prezzo per un animale non in vendita o adozione.';

ELSEIF NEW.CFCliente IS NOT NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato inserito l''acquirente per un animale non in vendita o adozione.';

ELSEIF NEW.DataAcquisto IS NOT NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stata inserita la data di acquisto per un animale non in vendita o adozione.';

END IF;

END IF;

END $$ DELIMITER;

DROP TRIGGER TR_PreModificaSerpente;

DELIMITER $$
CREATE TRIGGER TR_PreModificaSerpente BEFORE
UPDATE ON Serpente FOR EACH ROW BEGIN IF NEW.Nome IN (
  SELECT
    Nome
  FROM
    Serpente
  WHERE
    IVAAllevamento = NEW.IVAAllevamento
    AND Nome <> OLD.Nome
    AND Stato NOT IN('Venduto', 'Adottato', 'Morto')
) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Esiste già un serpente con questo nome in questo allevamento.';

ELSEIF NEW.Sesso NOT IN('M', 'F') THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'L''input inserito per il sesso del serpente non è né M né F.';

END IF;

IF NEW.Stato IN (
  'In vendita',
  'Venduto',
  'In adozione',
  'Adottato'
) THEN IF NEW.Cites IS NULL THEN IF OLD.Cites IS NOT NULL THEN
SET
  NEW.Cites = OLD.Cites;

ELSE SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'URL della certificazione Cites mancante.';

END IF;

END IF;

IF NEW.Foto IS NULL THEN IF OLD.Foto IS NOT NULL THEN
SET
  NEW.Foto = OLD.Foto;

ELSE SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'URL della foto mancante.';

END IF;

END IF;

IF NEW.Prezzo IS NULL THEN IF OLD.Prezzo IS NOT NULL THEN
SET
  NEW.Prezzo = OLD.Prezzo;

ELSE SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Non è stato indicato il prezzo per il serpente.';

END IF;

END IF;

IF NEW.Stato IN ('Venduto', 'Adottato') THEN IF OLD.Stato NOT IN('In vendita', 'In adozione') THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato venduto o dato in adozione un serpente non in vendita o in adozione.';

ELSEIF OLD.Stato = 'In vendita'
AND NEW.Stato = 'Adottato' THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato adottato un serpente previsto per la vendita';

ELSEIF OLD.Stato = 'In adozione'
AND NEW.Stato = 'Venduto' THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato venduto un serpente previsto per l''adottazione';

ELSEIF NEW.CFCliente IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Codice fiscale acquirente mancante';

ELSEIF NEW.DataAcquisto IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Non è stata specificata la data di acquisto o adozione.';

ELSEIF NEW.DataNascita IS NOT NULL
AND NOT DateCheck (NEW.DataNascita, NEW.DataAcquisto) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'L''intervallo di date inserito non è valido.';

END IF;

END IF;

ELSEIF NEW.Stato <> 'Morto' THEN IF NEW.Prezzo IS NOT NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato inserito il prezzo per un animale non in vendita o adozione.';

ELSEIF NEW.CFCliente IS NOT NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato inserito l''acquirente per un animale non in vendita o adozione.';

ELSEIF NEW.DataAcquisto IS NOT NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stata inserita la data di acquisto per un animale non in vendita o adozione.';

END IF;

END IF;

END $$ DELIMITER;