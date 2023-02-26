##################################################################################	USER DEFINED FUNCTIONS	##################################################################################



DELIMITER $$
CREATE FUNCTION DateCheck(
firstDate DATE, lastDate DATE)
RETURNS BOOL
DETERMINISTIC
BEGIN
	IF YEAR(lastDate) - YEAR(firstDate) < 0 THEN
		RETURN FALSE;
	ELSEIF YEAR(lastDate) - YEAR(firstDate) = 0 THEN
		IF MONTH(lastDate) - MONTH(firstDate) < 0 THEN
			RETURN FALSE;
		ELSEIF MONTH(lastDate) - MONTH(firstDate) = 0 THEN
			IF DAY(lastDate) - DAY(firstDate) <= 0 THEN
				RETURN FALSE;
			END IF;
		END IF;
    END IF;
    RETURN TRUE;
END $$ DELIMITER ;



##################################################################################	STORED PROCEDURES	##################################################################################



DROP PROCEDURE IF EXISTS AggiungiSerpente;
DELIMITER $$
CREATE PROCEDURE AggiungiSerpente(
IN nome VARCHAR(70),
IN sesso CHAR(1),
IN dataNascita DATE,
IN stato ENUM('In vendita','Venduto','In adozione','Adottato','Non in vendita','Morto','Riproduttore'),
IN cites VARCHAR(150),
IN foto VARCHAR(150),
IN ivaAllevamento BIGINT UNSIGNED,
IN nomeSpecie VARCHAR(100))
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
            
	IF Stato IN ('Venduto','Adottato', 'In vendita', 'In adozione') THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato scelto uno stato non valido. Non è possibile inserire un nuovo serpente in vendita';
	END IF;
        
	INSERT INTO Serpente
		VALUES (NULL, nome, sesso, dataNascita, stato, cites, NULL, foto, ivaAllevamento, NULL, NULL, nomeSpecie);
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS AggiungiPasto;
DELIMITER $$
CREATE PROCEDURE AggiungiPasto(
IN dataPasto DATE,
IN idSerpente INT UNSIGNED,
IN risultato ENUM('Consumato','Rifiutato','Rigurgitato'),
IN tipo ENUM('Scongelato','Pre-ucciso','Vivo'),
IN nomeCibo VARCHAR(60))
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
	
	IF (SELECT COUNT(ID) FROM Serpente WHERE ID = idSerpente) = 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Serpente selezionato non esistente.';
	END IF;
    
	IF (SELECT COUNT(dataPasto) FROM Pasti p WHERE p.IDSerpente = idSerpente AND p.Data = dataPasto) = 0 THEN
		INSERT INTO Pasti
			VALUES (dataPasto, idSerpente, risultato, tipo, nomeCibo);
	ELSE
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Questo serpente ha già consumato un pasto oggi';
	END IF;
    
    DELETE FROM Pasti WHERE ((DATEDIFF(NOW(), Data)) / 365) >= 1;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS AggiungiTerrario;
DELIMITER $$
CREATE PROCEDURE AggiungiTerrario(
riscaldatore enum('Tappetino','Lampada','Entrambe'),
altaTemp tinyint,
bassaTemp tinyint,
tipologia enum('Opaco','Trasparente','Entrambi'),
acquatico tinyint(1),
arrampicabile tinyint(1),
scavabile tinyint(1),
umidita tinyint)
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
	INSERT INTO Terrario
		VALUES (NULL, riscaldatore, altaTemp, bassaTemp, tipologia, acquatico, arrampicabile, scavabile, umidità);
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS MettiInVenditaSerpente;
DELIMITER $$
CREATE PROCEDURE MettiInVenditaSerpente(
IN idSerpente INT UNSIGNED,
IN nuovoStato ENUM('In vendita','Venduto','In adozione','Adottato','Non in vendita','Morto','Riproduttore'),
IN cites VARCHAR(150),
IN prezzo SMALLINT UNSIGNED,
IN foto VARCHAR(150))
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
    
	IF (SELECT COUNT(ID) FROM Serpente WHERE ID = idSerpente) = 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Serpente selezionato non esistente.';
	END IF;
    
	IF nuovoStato IN ('Venduto','Adottato','Non in vendita','Morto','Riproduttore') THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato scelto uno stato non valido.';
	ELSEIF (SELECT COUNT(*) FROM Pasti p WHERE p.IDSerpente = idSerpente AND Risultato = 'Consumato') < 2 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato scelto un serpente che non ha consumato abbastanza pasti.';
	ELSEIF idSerpente IS NULL OR nuovoStato IS NULL OR prezzo IS NULL THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato omesso almeno uno dei parametri. Tutti i parametri sono obbligatori';
	END IF;
    
	UPDATE serpente
		SET Stato = nuovoStato,
			Cites = cites,
			Prezzo = prezzo,
			Foto = foto
		WHERE ID = idSerpente;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS VenditaSerpente;
DELIMITER $$
CREATE PROCEDURE VenditaSerpente(
IN idSerpente INT UNSIGNED,
IN nuovoStato ENUM('In vendita','Venduto','In adozione','Adottato','Non in vendita','Morto','Riproduttore'),
IN cfCliente CHAR(16),
IN dataAcquisto DATE)
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
    DECLARE CONTINUE HANDLER FOR 1175
    
	IF (SELECT COUNT(ID) FROM Serpente WHERE ID = idSerpente) = 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Serpente selezionato non esistente.';
	END IF;
    
	IF nuovoStato IN ('In Vendita','In adozione','Non in vendita','Morto','Riproduttore') THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato scelto uno stato non valido.';
	ELSEIF idSerpente IS NULL OR nuovoStato IS NULL OR cfCliente IS NULL OR dataAcquisto IS NULL THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato omesso almeno uno dei parametri. Tutti i parametri sono obbligatori';
	END IF;
    
	UPDATE serpente
	SET Stato = nuovoStato,
		CFCliente = cfCliente,
		DataAcquisto = dataAcquisto
	WHERE ID = idSerpente;
        
	DELETE FROM Pasti WHERE IDSerpente = idSerpente;
    DELETE FROM BrumazioneIndotta WHERE IDSerpente = idSerpente;
    DELETE FROM Progenie WHERE IDSerpente = idSerpente;
    DELETE FROM Incubazione WHERE IDSerpente = idSerpente;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS RegistraMorte;
DELIMITER $$
CREATE PROCEDURE RegistraMorte(
IN idSerpente INT UNSIGNED,
IN dimensione SMALLINT UNSIGNED,
IN peso TINYINT UNSIGNED,
IN causaMorte VARCHAR(4000),
IN dataMorte DATE,
IN ivaClinica BIGINT UNSIGNED)
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
	
    DECLARE CONTINUE HANDLER FOR 1175
    
    IF (SELECT COUNT(ID) FROM Serpente WHERE ID = idSerpente) = 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Serpente selezionato non esistente.';
	END IF;
    
	UPDATE serpente
	SET Stato = 'Morto'
	WHERE ID = idSerpente;
    
    IF dataMorte IS NULL THEN
		SET dataMorte = NOW();
	END IF;
    
    INSERT INTO Visita
		VALUES (NULL, dimensione, peso, causaMorte, NULL, 'Morte', dataMorte, idSerpente, ivaClinica);
        
	DELETE FROM Pasti WHERE IDSerpente = idSerpente;
    DELETE FROM BrumazioneIndotta WHERE IDSerpente = idSerpente;
    DELETE FROM Progenie WHERE IDSerpente = idSerpente;
    DELETE FROM Incubazione WHERE IDSerpente = idSerpente;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS MorteAutomaticaSerpentiVenduti;
DELIMITER $$
CREATE PROCEDURE MorteAutomaticaSerpentiVenduti()
BEGIN
	DECLARE fine INTEGER DEFAULT 0;
    DECLARE idSerpenti INT UNSIGNED;
    DECLARE aspettativaSerpente TINYINT UNSIGNED;
    DECLARE dataNascitaSerpente DATE;
    DECLARE listaSerpenti CURSOR FOR SELECT ID FROM Serpente s WHERE s.CFCliente IS NOT NULL AND Stato <> 'Morto';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET fine = 1;
    DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;

	OPEN listaSerpenti;
    
    WHILE (fine = 0) DO
		FETCH listaSerpenti INTO idSerpenti;
        IF fine = 0 THEN
			SELECT sp.Aspettativa, se.DataNascita
            INTO aspettativaSerpente, dataNascitaSerpente
            FROM Specie sp INNER JOIN Serpente se ON sp.NomeScientifico = se.NomeSpecie
            WHERE se.ID = idSerpenti AND Stato <> 'Morto';
            IF (DATEDIFF(NOW(), dataNascitaSerpente)) / 365 >= aspettativaSerpente THEN
				UPDATE Serpente SET Stato = 'Morto' WHERE ID = idSerpenti;
			END IF;
		END IF;
	END WHILE;
    
	CLOSE listaSerpenti;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS CancellazioneAutomaticaClienti;
DELIMITER $$
CREATE PROCEDURE CancellazioneAutomaticaClienti(
IN cancellaSerpenti BOOL)
BEGIN
	DECLARE fine INTEGER DEFAULT 0;
    DECLARE cfClienti VARCHAR(16);
    DECLARE totaleVivi TINYINT;
    DECLARE listaClienti CURSOR FOR SELECT CF FROM Cliente;
    
    DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET fine = 1;
	
    CALL MorteAutomaticaSerpentiVenduti();
    
    OPEN listaClienti;
    
    WHILE (fine = 0) DO
		FETCH listaClienti INTO cfClienti;
        IF fine = 0 THEN
			SET totaleVivi = (SELECT COUNT(*) FROM serpente s WHERE s.CFCliente = cfClienti AND Stato <> 'Morto');
            IF totaleVivi = 0 THEN
				DELETE FROM Cliente WHERE CF = cfClienti;
			END IF;
		END IF;
	END WHILE;
    
	CLOSE listaClienti;
    
    IF cancellaSerpenti THEN
		CALL CancellazioneAutomaticaSerpenti();
	END IF;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS CancellazioneAutomaticaSerpenti;
DELIMITER $$
CREATE PROCEDURE CancellazioneAutomaticaSerpenti()
BEGIN
	DECLARE fine INTEGER DEFAULT 0;
    DECLARE idSerpente INT UNSIGNED;
    DECLARE totaleLegami TINYINT;
    DECLARE listaSerpenti CURSOR FOR SELECT ID FROM Serpente WHERE Stato = 'Morto';
    
    DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET fine = 1;
	
    OPEN listaSerpenti;
    
    WHILE (fine = 0) DO
		FETCH listaSerpenti INTO idSerpente;
        IF fine = 0 THEN
			SET totaleLegami = (SELECT COUNT(*) FROM Parentela p WHERE p.IDGenitore = idSerpente);
            IF totaleLegami = 0 THEN
				DELETE FROM Serpente WHERE ID = idSerpente;
			END IF;
		END IF;
	END WHILE;
	CLOSE listaSerpenti;
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS OttenimentoMorphEPH;
DELIMITER $$
CREATE PROCEDURE OttenimentoMorphEPH(
IN idSerpenteRicerca INT UNSIGNED,
INOUT morphSerpente VARCHAR(1500),
INOUT phSerpente VARCHAR(1600))
BEGIN
	DECLARE fine INTEGER DEFAULT 0;
    DECLARE temporaryId INT UNSIGNED;
    DECLARE temporaryName VARCHAR(100) DEFAULT '';
    DECLARE temporaryPercent TINYINT;
    DECLARE listaMorph CURSOR FOR SELECT IDMorph FROM Aspetto WHERE IDSerpente = idSerpenteRicerca;
	DECLARE listaPH CURSOR FOR SELECT IDMorph, Percentuale FROM PH WHERE IDSerpente = idSerpenteRicerca;

    DECLARE EXIT HANDLER FOR SQLSTATE '45001'
		SHOW ERRORS;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET fine = 1;
	
    OPEN listaMorph;
    OPEN listaPH;
    
    WHILE (fine = 0) DO
		FETCH listaMorph INTO temporaryID;
        IF fine = 0 THEN
			SELECT Nome INTO temporaryName FROM Morph WHERE ID = temporaryID;
            SET morphSerpente = CONCAT(temporaryName, ', ', morphSerpente);
		END IF;
	END WHILE;
    
    SET fine = 0;
    SET temporaryName = '';
 	CLOSE listaMorph;   
    
	WHILE (fine = 0) DO
		FETCH listaPH INTO temporaryID, temporaryPercent;
        IF fine = 0 THEN
			SELECT Nome INTO temporaryName FROM Morph WHERE ID = temporaryID;
            SET phSerpente = CONCAT(temporaryPercent, '% ', temporaryName, ', ', phSerpente);
		END IF;
	END WHILE;

    CLOSE listaPH;
END $$ DELIMITER ;



##################################################################################	TRIGGERS	##################################################################################



DROP TRIGGER TR_AggiuntaTerrario;
DELIMITER $$
CREATE TRIGGER TR_AggiuntaTerrario
BEFORE UPDATE ON Terrario
FOR EACH ROW
BEGIN
	IF NEW.AltaTemp - NEW.BassaTemp < 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'La bassa temperatura è maggiore dell''alta temperatura.';
	END IF;
END	$$ DELIMITER ;

DROP TRIGGER TR_ModificaTerrario;
DELIMITER $$
CREATE TRIGGER TR_ModificaTerrario
BEFORE UPDATE ON Terrario
FOR EACH ROW
BEGIN
	IF NEW.AltaTemp - NEW.BassaTemp < 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'La bassa temperatura è maggiore dell''alta temperatura.';
	END IF;
END	$$ DELIMITER ;

DROP TRIGGER TR_AggiuntaSerpente;
DELIMITER $$
CREATE TRIGGER TR_AggiuntaSerpente
BEFORE INSERT ON Serpente
FOR EACH ROW
BEGIN
	IF NEW.Nome IN (SELECT Nome FROM Serpente WHERE IVAAllevamento = NEW.IVAAllevamento AND Stato NOT IN ('Venduto', 'Adottato', 'Morto')) THEN 
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Esiste già un serpente con questo nome in questo allevamento.';
        
    ELSEIF NEW.Sesso NOT IN ('M', 'F') THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'L''input inserito per il sesso del serpente non è né M né F.';
        
	ELSEIF NEW.Stato IN ('In vendita','Venduto','In adozione','Adottato') THEN
		IF NEW.Prezzo IS NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Non è stato indicato il prezzo per il serpente.';
		ELSEIF NEW.Cites IS NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'URL della certificazione Cites mancante.';
		ELSEIF NEW.Foto IS NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'URL della foto mancante.';
            
		ELSEIF NEW.Stato IN ('Venduto', 'Adottato') THEN
			IF NEW.CFCliente IS NULL THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Codice fiscale acquirente mancante';
			ELSEIF NEW.DataAcquisto IS NULL THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Non è stata specificata la data di acquisto o adozione.';
			ELSEIF NEW.DataNascita IS NOT NULL AND NOT DateCheck(NEW.DataNascita, NEW.DataAcquisto) THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'L''intervallo di date inserito non è valido.';
			END IF;
		END IF;
        
	ELSEIF NEW.Stato <> 'Morto' THEN
		IF NEW.Prezzo IS NOT NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato inserito il prezzo per un animale non in vendita o adozione.';
		ELSEIF NEW.CFCliente IS NOT NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato inserito l''acquirente per un animale non in vendita o adozione.';
		ELSEIF NEW.DataAcquisto IS NOT NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stata inserita la data di acquisto per un animale non in vendita o adozione.';
		END IF;
	END IF;
END	$$ DELIMITER ;


DROP TRIGGER TR_PreModificaSerpente;
DELIMITER $$
CREATE TRIGGER TR_PreModificaSerpente
BEFORE UPDATE ON Serpente
FOR EACH ROW
BEGIN
	IF NEW.Nome IN (SELECT Nome FROM Serpente WHERE IVAAllevamento = NEW.IVAAllevamento AND Nome <> OLD.Nome AND Stato NOT IN ('Venduto', 'Adottato', 'Morto')) THEN 
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Esiste già un serpente con questo nome in questo allevamento.';
        
    ELSEIF NEW.Sesso NOT IN ('M', 'F') THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'L''input inserito per il sesso del serpente non è né M né F.';
	END IF;
    
	IF NEW.Stato IN ('In vendita','Venduto','In adozione','Adottato') THEN
		IF NEW.Cites IS NULL THEN
			IF OLD.Cites IS NOT NULL THEN
				SET NEW.Cites = OLD.Cites;
			ELSE
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'URL della certificazione Cites mancante.';
			END IF;
		END IF;
            
		IF NEW.Foto IS NULL THEN
			IF OLD.Foto IS NOT NULL THEN
				SET NEW.Foto = OLD.Foto;
			ELSE
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'URL della foto mancante.';
			END IF;
		END IF;

		IF NEW.Prezzo IS NULL THEN
			IF OLD.Prezzo IS NOT NULL THEN
				SET NEW.Prezzo = OLD.Prezzo;
			ELSE
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Non è stato indicato il prezzo per il serpente.';
			END IF;
		END IF;
		
		IF NEW.Stato IN ('Venduto', 'Adottato') THEN
			IF OLD.Stato NOT IN ('In vendita', 'In adozione') THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato venduto o dato in adozione un serpente non in vendita o in adozione.';
			ELSEIF OLD.Stato = 'In vendita' AND NEW.Stato = 'Adottato' THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato adottato un serpente previsto per la vendita';
			ELSEIF OLD.Stato = 'In adozione' AND NEW.Stato = 'Venduto' THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato venduto un serpente previsto per l''adottazione';
			ELSEIF NEW.CFCliente IS NULL THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Codice fiscale acquirente mancante';
			ELSEIF NEW.DataAcquisto IS NULL THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Non è stata specificata la data di acquisto o adozione.';
			ELSEIF NEW.DataNascita IS NOT NULL AND NOT DateCheck(NEW.DataNascita, NEW.DataAcquisto) THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'L''intervallo di date inserito non è valido.';
			END IF;
		END IF;
    
    ELSEIF NEW.Stato <> 'Morto' THEN
		IF NEW.Prezzo IS NOT NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato inserito il prezzo per un animale non in vendita o adozione.';
		ELSEIF NEW.CFCliente IS NOT NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stato inserito l''acquirente per un animale non in vendita o adozione.';
		ELSEIF NEW.DataAcquisto IS NOT NULL THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'E'' stata inserita la data di acquisto per un animale non in vendita o adozione.';
		END IF;
	END IF;
END	$$ DELIMITER ;



##################################################################################	INTERROGAZIONI DATABASE	##################################################################################



DROP PROCEDURE IF EXISTS SelezionaSerpentePerStato;
DELIMITER $$
CREATE PROCEDURE SelezionaSerpentePerStato(
IN stato ENUM('In vendita','Venduto','In adozione','Adottato','Non in vendita','Morto','Riproduttore'))
BEGIN
	SELECT * FROM serpente s WHERE s.Stato = stato; 
END $$ DELIMITER ;

DROP PROCEDURE IF EXISTS VisualizzaSpecieSerpente;
DELIMITER $$
CREATE PROCEDURE VisualizzaSpecieSerpente(
IN id INT UNSIGNED)
BEGIN
    IF (SELECT COUNT(ID) FROM Serpente WHERE ID = idSerpente) = 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Serpente selezionato non esistente.';
	END IF;
    
	SELECT * 
    FROM serpente se INNER JOIN specie sp ON se.NomeSpecie = sp.NomeScientifico
    WHERE se.ID = id; 
END $$ DELIMITER ;

CREATE VIEW StoreSerpenti AS(
	SELECT se.ID, se.Nome, se.Sesso, se.DataNascita, se.Stato, se.Cites, se.Foto, se.Prezzo, a.Nome AS 'Nome Allevamento', sp.NomeComune AS 'Specie'
    FROM Serpente se INNER JOIN Allevamento a ON se.IVAAllevamento = a.IVA
		INNER JOIN Specie sp ON se.NomeSpecie = sp.NomeScientifico
	WHERE Stato IN ('In vendita', 'In adozione')
);