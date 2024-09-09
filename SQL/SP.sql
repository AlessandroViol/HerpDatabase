-- Stored procedure per l’aggiunta di nuovi serpenti:
DROP PROCEDURE IF EXISTS AggiungiSerpente;

DELIMITER $$
CREATE PROCEDURE AggiungiSerpente (
  IN nome VARCHAR(70),
  IN sesso CHAR(1),
  IN dataNascita DATE,
  IN stato ENUM(
    'In vendita',
    'Venduto',
    'In adozione',
    'Adottato',
    'Non in vendita',
    'Morto',
    'Riproduttore'
  ),
  IN cites VARCHAR(150),
  IN foto VARCHAR(150),
  IN ivaAllevamento BIGINT UNSIGNED,
  IN nomeSpecie VARCHAR(100)
) BEGIN DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

IF Stato IN (
  'Venduto',
  'Adottato',
  'In vendita',
  'In adozione'
) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato scelto uno stato non valido. Non è possibile inserire un nuovo serpente in vendita';

END IF;

INSERT INTO
  Serpente
VALUES
  (
    NULL,
    nome,
    sesso,
    dataNascita,
    stato,
    cites,
    NULL,
    foto,
    ivaAllevamento,
    NULL,
    NULL,
    nomeSpecie
  );

END $$ DELIMITER;

-- Stored Procedure per l’aggiunta di pasti. Implementa anche l’eliminazione automatica dei record più vecchi di un anno e impedisce di
-- inserire record multipli per lo stesso serpente nell’arco della giornata.
DROP PROCEDURE IF EXISTS AggiungiPasto;

DELIMITER $$
CREATE PROCEDURE AggiungiPasto (
  IN dataPasto DATE,
  IN idSerpente INT UNSIGNED,
  IN risultato ENUM('Consumato', 'Rifiutato', 'Rigurgitato'),
  IN tipo ENUM('Scongelato', 'Pre-ucciso', 'Vivo'),
  IN nomeCibo VARCHAR(60)
) BEGIN DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

IF(
  SELECT
    COUNT(ID)
  FROM
    Serpente
  WHERE
    ID = idSerpente
) = 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Serpente selezionato non esistente.';

END IF;

IF(
  SELECT
    COUNT(dataPasto)
  FROM
    Pasti p
  WHERE
    p.IDSerpente = idSerpente
    AND p.Data = dataPasto
) = 0 THEN
INSERT INTO
  Pasti
VALUES
  (dataPasto, idSerpente, risultato, tipo, nomeCibo);

ELSE SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Questo serpente ha già consumato un pasto oggi';

END IF;

DELETE FROM Pasti
WHERE
  ((DATEDIFF(NOW(), Data)) / 365) >= 1;

END $$ DELIMITER;

-- Il resto delle stored procedures implementare per l’inserimento dei dati sono banali. Se ne riporta solo alcune:
DROP PROCEDURE IF EXISTS AggiungiTerrario;

DELIMITER $$
CREATE PROCEDURE AggiungiTerrario (
  riscaldatore enum('Tappetino', 'Lampada', 'Entrambe'),
  altaTemp tinyint,
  bassaTemp tinyint,
  tipologia enum('Opaco', 'Trasparente', 'Entrambi'),
  acquatico tinyint(1),
  arrampicabile tinyint(1),
  scavabile tinyint(1),
  umidita tinyint
) BEGIN DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

INSERT INTO
  Terrario
VALUES
  (
    NULL,
    riscaldatore,
    altaTemp,
    bassaTemp,
    tipologia,
    acquatico,
    arrampicabile,
    scavabile,
    umidità
  );

END $$ DELIMITER;

DROP PROCEDURE IF EXISTS AggiungiAllevamento;

DELIMITER $$
CREATE PROCEDURE AggiungiAllevamento (
  iva BIGINT UNSIGNED,
  nome VARCHAR(150),
  sitoWeb VARCHAR(63),
  indirizzo VARCHAR(200),
  email VARCHAR(150)
) BEGIN
INSERT INTO
  Allevamento
VALUES
  (iva, nome, sitoWeb, indirizzo, email);

END $$ DELIMITER;

DROP PROCEDURE IF EXISTS AggiungiSpecie;

DELIMITER $$
CREATE PROCEDURE AggiungiSpecie (
  nomeScientifico varchar(100),
  nomeComune varchar(100),
  etaMax tinyint unsigned,
  aspettativa tinyint unsigned,
  alimentazione enum(
    'Roditori',
    'Piccoli Mammiferi',
    'Pesci',
    'Uova',
    'Vermi'
  ),
  attivita enum('Diurno', 'Notturno', 'Crepuscolare'),
  difesa enum(
    'Morso',
    'Veleno',
    'Tanatosi',
    'Intimidazione',
    'Musk',
    'Avviluppamento'
  ),
  temperamento enum('Schivo', 'Aggressivo', 'Calmo', 'Attivo'),
  difficolta enum('Principiante', 'Intermedio', 'Esperto'),
  coabitazione tinyint(1),
  tempoIncubaz tinyint,
  progenieMax tinyint,
  progenieMin tinyint,
  ovoviviparo tinyint,
  idTerrario int
) BEGIN
INSERT INTO
  Specie
VALUES
  (
    nomeScientifico,
    nomeComune,
    etaMax,
    aspettativa,
    alimentazione,
    attivita,
    difesa,
    temperamento,
    difficolta,
    coabitazione,
    tempoIncubaz,
    progenieMax,
    progenieMin,
    ovoviviparo,
    idTerrario
  );

END $$ DELIMITER;

DROP PROCEDURE IF EXISTS AggiungiCliente;

DELIMITER $$
CREATE PROCEDURE AggiungiCliente (
  cf CHAR(16),
  nome VARCHAR(100),
  cognome VARCHAR(100),
  email VARCHAR(150),
  telefono BIGINT UNSIGNED
) BEGIN
INSERT INTO
  Cliente
VALUES
  (cf, nome, cognome, email, telefono);

END $$ DELIMITER;

DROP PROCEDURE IF EXISTS AggiungiCibo;

DELIMITER $$
CREATE PROCEDURE AggiungiCibo (
  IN nome VARCHAR(60),
  IN dimensione TINYINT UNSIGNED,
  IN peso TINYINT UNSIGNED
) BEGIN
INSERT INTO
  Cibo
VALUES
  (nome, dimensione, peso);

END $$ DELIMITER;

-- Questa stored procedure viene utilizzata per mettere in vendita un serpente effettuando prima dei controlli sulla legittimità dell’operazione.
DROP PROCEDURE IF EXISTS MettiInVenditaSerpente;

DELIMITER $$
CREATE PROCEDURE MettiInVenditaSerpente (
  IN idSerpente INT UNSIGNED,
  IN nuovoStato ENUM(
    'In vendita',
    'Venduto',
    'In adozione',
    'Adottato',
    'Non in vendita',
    'Morto',
    'Riproduttore'
  ),
  IN cites VARCHAR(150),
  IN prezzo SMALLINT UNSIGNED,
  IN foto VARCHAR(150)
) BEGIN DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

IF(
  SELECT
    COUNT(ID)
  FROM
    Serpente
  WHERE
    ID = idSerpente
) = 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Serpente selezionato non esistente.';

END IF;

IF nuovoStato IN (
  'Venduto',
  'Adottato',
  'Non in vendita',
  'Morto',
  'Riproduttore'
) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato scelto uno stato non valido.';

ELSEIF (
  SELECT
    COUNT(*)
  FROM
    Pasti p
  WHERE
    p.IDSerpente = idSerpente
    AND Risultato = 'Consumato'
) < 2 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato scelto un serpente che non ha consumato abbastanza pasti.';

ELSEIF idSerpente IS NULL
OR nuovoStato IS NULL
OR prezzo IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato omesso almeno uno dei parametri. Tutti i parametri sono obbligatori';

END IF;

UPDATE serpente
SET
  Stato = nuovoStato,
  Cites = cites,
  Prezzo = prezzo,
  Foto = foto
WHERE
  ID = idSerpente;

END $$ DELIMITER;

-- Questa stored procedure viene usata per finalizzare la vendita di un animale. 
-- Oltre a un controllo sulla correttezza dell’operazione, elimina anche i dati che a questo punto non saranno più di interesse per l’associazione.
DROP PROCEDURE IF EXISTS VenditaSerpente;

DELIMITER $$
CREATE PROCEDURE VenditaSerpente (
  IN idSerpente INT UNSIGNED,
  IN nuovoStato ENUM(
    'In vendita',
    'Venduto',
    'In adozione',
    'Adottato',
    'Non in vendita',
    'Morto',
    'Riproduttore'
  ),
  IN cfCliente CHAR(16),
  IN dataAcquisto DATE
) BEGIN DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

DECLARE CONTINUE
HANDLER FOR 1175 IF(
  SELECT
    COUNT(ID)
  FROM
    Serpente
  WHERE
    ID = idSerpente
) = 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Serpente selezionato non esistente.';

END IF;

IF nuovoStato IN (
  'In Vendita',
  'In adozione',
  'Non in vendita',
  'Morto',
  'Riproduttore'
) THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato scelto uno stato non valido.';

ELSEIF idSerpente IS NULL
OR nuovoStato IS NULL
OR cfCliente IS NULL
OR dataAcquisto IS NULL THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'E'' stato omesso almeno uno dei parametri. Tutti i parametri sono obbligatori';

END IF;

UPDATE serpente
SET
  Stato = nuovoStato,
  CFCliente = cfCliente,
  DataAcquisto = dataAcquisto
WHERE
  ID = idSerpente;

DELETE FROM Pasti
WHERE
  IDSerpente = idSerpente;

DELETE FROM BrumazioneIndotta
WHERE
  IDSerpente = idSerpente;

DELETE FROM Progenie
WHERE
  IDSerpente = idSerpente;

DELETE FROM Incubazione
WHERE
  IDSerpente = idSerpente;

END $$ DELIMITER;

-- Similmente alla stored procedure precedente, questa SP permette di registrare la morte di uno dei serpenti dell’allevamento, occupandosi anche di registrare un’ultima visita.
DROP PROCEDURE IF EXISTS RegistraMorte;

DELIMITER $$
CREATE PROCEDURE RegistraMorte (
  IN idSerpente INT UNSIGNED,
  IN dimensione SMALLINT UNSIGNED,
  IN peso TINYINT UNSIGNED,
  IN causaMorte VARCHAR(4000),
  IN dataMorte DATE,
  IN ivaClinica BIGINT UNSIGNED
) BEGIN DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

DECLARE CONTINUE
HANDLER FOR 1175 IF(
  SELECT
    COUNT(ID)
  FROM
    Serpente
  WHERE
    ID = idSerpente
) = 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Serpente selezionato non esistente.';

END IF;

UPDATE serpente
SET
  Stato = 'Morto'
WHERE
  ID = idSerpente;

IF dataMorte IS NULL THEN
SET
  dataMorte = NOW();

END IF;

INSERT INTO
  Visita
VALUES
  (
    NULL,
    dimensione,
    peso,
    causaMorte,
    NULL,
    'Morte',
    dataMorte,
    idSerpente,
    ivaClinica
  );

DELETE FROM Pasti
WHERE
  IDSerpente = idSerpente;

DELETE FROM BrumazioneIndotta
WHERE
  IDSerpente = idSerpente;

DELETE FROM Progenie
WHERE
  IDSerpente = idSerpente;

DELETE FROM Incubazione
WHERE
  IDSerpente = idSerpente;

END $$ DELIMITER;

-- Questa stored procedure si occupa invece di identificare quali serpenti venduti hanno ormai superato l’aspettativa di vita della loro specie e ne modifica lo stato. 
DROP PROCEDURE IF EXISTS MorteAutomaticaSerpentiVenduti;

DELIMITER $$
CREATE PROCEDURE MorteAutomaticaSerpentiVenduti () BEGIN DECLARE fine INTEGER DEFAULT 0;

DECLARE idSerpenti INT UNSIGNED;

DECLARE aspettativaSerpente TINYINT UNSIGNED;

DECLARE dataNascitaSerpente DATE;

DECLARE listaSerpenti CURSOR FOR
SELECT
  ID
FROM
  Serpente s
WHERE
  s.CFCliente IS NOT NULL
  AND Stato <> 'Morto';

DECLARE CONTINUE
HANDLER FOR NOT FOUND
SET
  fine = 1;

DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

OPEN listaSerpenti;

WHILE (fine = 0) DO FETCH listaSerpenti INTO idSerpenti;

IF fine = 0 THEN
SELECT
  sp.Aspettativa,
  se.DataNascita INTO aspettativaSerpente,
  dataNascitaSerpente
FROM
  Specie sp
  INNER JOIN Serpente se ON sp.NomeScientifico = se.NomeSpecie
WHERE
  se.ID = idSerpenti
  AND Stato <> 'Morto';

IF(DATEDIFF(NOW(), dataNascitaSerpente)) / 365 >= aspettativaSerpente THEN
UPDATE Serpente
SET
  Stato = 'Morto'
WHERE
  ID = idSerpenti;

END IF;

END IF;

END
WHILE;

CLOSE listaSerpenti;

END $$ DELIMITER;

-- Questa procedure si occupa di eliminare dal database i serpenti morti e che non hanno figli, ossia che non sono più di interesse all’associazione.
DROP PROCEDURE IF EXISTS CancellazioneAutomaticaClienti;

DELIMITER $$
CREATE PROCEDURE CancellazioneAutomaticaSerpenti () BEGIN DECLARE fine INTEGER DEFAULT 0;

DECLARE idSerpente INT UNSIGNED;

DECLARE totaleLegami TINYINT;

DECLARE listaSerpenti CURSOR FOR
SELECT
  ID
FROM
  Serpente
WHERE
  Stato = 'Morto';

DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

DECLARE CONTINUE
HANDLER FOR NOT FOUND
SET
  fine = 1;

OPEN listaSerpenti;

WHILE (fine = 0) DO FETCH listaSerpenti INTO idSerpente;

IF fine = 0 THEN
SET
  totaleLegami = (
    SELECT
      COUNT(*)
    FROM
      Parentela p
    WHERE
      p.IDGenitore = idSerpente
  );

IF totaleLegami = 0 THEN
DELETE FROM Serpente
WHERE
  ID = idSerpente;

END IF;

END IF;

END
WHILE;

CLOSE listaSerpenti;

END $$ DELIMITER;

-- Questa SP cancella i clienti i quali non hanno più serpenti in vita. 
-- All’inizio dell’esecuzione utilizza una delle stored procedure riportate in precedenza per aggiornare gli stati dei serpenti. 
-- A fine esecuzione, se il parametro specificato in input è TRUE, viene chiamata anche la SP precedente. 
DROP PROCEDURE IF EXISTS CancellazioneAutomaticaClienti;

DELIMITER $$
CREATE PROCEDURE CancellazioneAutomaticaClienti (IN cancellaSerpenti BOOL) BEGIN DECLARE fine INTEGER DEFAULT 0;

DECLARE cfClienti VARCHAR(16);

DECLARE totaleVivi TINYINT;

DECLARE listaClienti CURSOR FOR
SELECT
  CF
FROM
  Cliente;

DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

DECLARE CONTINUE
HANDLER FOR NOT FOUND
SET
  fine = 1;

CALL MorteAutomaticaSerpentiVenduti ();

OPEN listaClienti;

WHILE (fine = 0) DO FETCH listaClienti INTO cfClienti;

IF fine = 0 THEN
SET
  totaleVivi = (
    SELECT
      COUNT(*)
    FROM
      serpente s
    WHERE
      s.CFCliente = cfClienti
      AND Stato <> 'Morto'
  );

IF totaleVivi = 0 THEN
DELETE FROM Cliente
WHERE
  CF = cfClienti;

END IF;

END IF;

END
WHILE;

CLOSE listaClienti;

IF cancellaSerpenti THEN
CALL CancellazioneAutomaticaSerpenti ();

END IF;

END $$ DELIMITER;

-- Questa stored procedure ritorna in due campi VARCHAR l’elenco dei morph e dei possible het posseduti dal serpente specificato
DROP PROCEDURE IF EXISTS OttenimentoMorphEPH;

DELIMITER $$
CREATE PROCEDURE OttenimentoMorphEPH (
  IN idSerpenteRicerca INT UNSIGNED,
  INOUT morphSerpente VARCHAR(1500),
  INOUT phSerpente VARCHAR(1600)
) BEGIN DECLARE fine INTEGER DEFAULT 0;

DECLARE temporaryId INT UNSIGNED;

DECLARE temporaryName VARCHAR(100) DEFAULT '';

DECLARE temporaryPercent TINYINT;

DECLARE listaMorph CURSOR FOR
SELECT
  IDMorph
FROM
  Aspetto
WHERE
  IDSerpente = idSerpenteRicerca;

DECLARE listaPH CURSOR FOR
SELECT
  IDMorph,
  Percentuale
FROM
  PH
WHERE
  IDSerpente = idSerpenteRicerca;

DECLARE EXIT
HANDLER FOR SQLSTATE '45001'
SHOW ERRORS;

DECLARE CONTINUE
HANDLER FOR NOT FOUND
SET
  fine = 1;

OPEN listaMorph;

OPEN listaPH;

WHILE (fine = 0) DO FETCH listaMorph INTO temporaryID;

IF fine = 0 THEN
SELECT
  Nome INTO temporaryName
FROM
  Morph
WHERE
  ID = temporaryID;

SET
  morphSerpente = CONCAT(temporaryName, ', ', morphSerpente);

END IF;

END
WHILE;

SET
  fine = 0;

SET
  temporaryName = '';

CLOSE listaMorph;

WHILE (fine = 0) DO FETCH listaPH INTO temporaryID,
temporaryPercent;

IF fine = 0 THEN
SELECT
  Nome INTO temporaryName
FROM
  Morph
WHERE
  ID = temporaryID;

SET
  phSerpente = CONCAT(
    temporaryPercent,
    '% ',
    temporaryName,
    ', ',
    phSerpente
  );

END IF;

END
WHILE;

CLOSE listaPH;

END $$ DELIMITER;

-- EXTRAS
DROP PROCEDURE IF EXISTS Utilizzatore;

DELIMITER $$
CREATE PROCEDURE Utilizzatore (IN idSerpenteRicerca INT UNSIGNED) BEGIN DECLARE morphSerpente VARCHAR(1500) DEFAULT '';

DECLARE phSerpente VARCHAR(1600) DEFAULT '';

CALL OttenimentoMorphEPH (idSerpenteRicerca, morphSerpente, phSerpente);

SELECT
  morphSerpente,
  phSerpente;

END $$ DELIMITER;

DROP PROCEDURE IF EXISTS SelezionaSerpentePerStato;

DELIMITER $$
CREATE PROCEDURE SelezionaSerpentePerStato (
  IN stato ENUM(
    'In vendita',
    'Venduto',
    'In adozione',
    'Adottato',
    'Non in vendita',
    'Morto',
    'Riproduttore'
  )
) BEGIN
SELECT
  *
FROM
  serpente s
WHERE
  s.Stato = stato;

END $$ DELIMITER;

DROP PROCEDURE IF EXISTS VisualizzaSpecieSerpente;

DELIMITER $$
CREATE PROCEDURE VisualizzaSpecieSerpente (IN id INT UNSIGNED) BEGIN IF(
  SELECT
    COUNT(ID)
  FROM
    Serpente
  WHERE
    ID = idSerpente
) = 0 THEN SIGNAL SQLSTATE '45001'
SET
  MESSAGE_TEXT = 'Serpente selezionato non esistente.';

END IF;

SELECT
  *
FROM
  serpente se
  INNER JOIN specie sp ON se.NomeSpecie = sp.NomeScientifico
WHERE
  se.ID = id;

END $$ DELIMITER;