-- Allevamento (IVA, Nome, SitoWeb, Indirizzo, Email)
CREATE TABLE Allevamento (
  IVA BIGINT(11) UNSIGNED,
  Nome VARCHAR(150) NOT NULL,
  SitoWeb VARCHAR(63) DEFAULT NULL,
  Indirizzo VARCHAR(200) NOT NULL,
  Email VARCHAR(150) NOT NULL,
  PRIMARY KEY (IVA)
);


-- Cliente (CF, Nome, Cognome, Email, Telefono)
CREATE TABLE Cliente (
  CF CHAR(16),
  Nome VARCHAR(100) NOT NULL,
  Cognome VARCHAR(100) NOT NULL,
  Email VARCHAR(150) NOT NULL,
  Telefono BIGINT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (CF)
);


-- Serpente (ID, Nome, Sesso, DataNascita, Stato, Cites, Prezzo, Foto, IVAAllevamento, CFCliente, DataAcquisto, NomeSpecie)
CREATE TABLE Serpente (
  ID INT UNSIGNED AUTO_INCREMENT,
  Nome VARCHAR(70) NOT NULL,
  Sesso CHAR(1) NOT NULL,
  DataNascita DATE NOT NULL,
  Stato ENUM (
    'In vendita',
    'Venduto',
    'In adozione',
    'Adottato',
    'Non in vendita',
    'Morto',
    'Riproduttore'
  ) DEFAULT 'Non in vendita' NOT NULL,
  Cites VARCHAR(150) UNIQUE DEFAULT NULL,
  Prezzo SMALLINT UNSIGNED DEFAULT NULL,
  Foto VARCHAR(150) UNIQUE DEFAULT NULL,
  IVAAllevamento BIGINT(11) UNSIGNED NOT NULL,
  CFCliente CHAR(16) DEFAULT NULL,
  DataAcquisto DATE DEFAULT NULL,
  NomeSpecie VARCHAR(100) NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FKSerpente_IVAAllevamento FOREIGN KEY (IVAAllevamento) REFERENCES Allevamento (IVA) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKSerpente_CFCliente FOREIGN KEY (CFCliente) REFERENCES Cliente (CF) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT FKSerpente_NomeSpecie FOREIGN KEY (NomeSpecie) REFERENCES Specie (NomeScientifico) ON DELETE CASCADE ON UPDATE CASCADE
);


-- BrumazioneIndotta (DataInizioPre, IDSerpente, DataInizio, DataFine, DataFinePost)
CREATE TABLE BrumazioneIndotta (
  DataInizioPre DATE NOT NULL,
  IDSerpente INT UNSIGNED NOT NULL,
  DataInizio DATE DEFAULT NULL,
  DataFine DATE DEFAULT NULL,
  DataFinePost DATE DEFAULT NULL,
  PRIMARY KEY (DataInizioPre, IDSerpente),
  CONSTRAINT FKBrumazioneIndotta_IDSerpente FOREIGN KEY (IDSerpente) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Clinica (IVA, Nome, Indirizzo)
CREATE TABLE Clinica (
  IVA BIGINT(11) UNSIGNED,
  Nome VARCHAR(150) NOT NULL,
  Indirizzo VARCHAR(200) NOT NULL,
  PRIMARY KEY (IVA)
);


-- Telefono (Numero, IVAAllevamento, IVAClinica)
CREATE TABLE Telefono (
  Numero BIGINT(11) UNSIGNED,
  IVAAllevamento BIGINT(11) UNSIGNED DEFAULT NULL,
  IVAClinica BIGINT(11) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (Numero),
  CONSTRAINT FKTelefono_IVAAllevamento FOREIGN KEY (IVAAllevamento) REFERENCES Allevamento (IVA) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKTelefono_IVAClinica FOREIGN KEY (IVAClinica) REFERENCES Clinica (IVA) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Visita (Numero, Dimensione, Peso, Prescrizione, DurataPrescrizione, Motivazione, Data, IDSerpente, IVAClinica)
CREATE TABLE Visita (
  Numero INT UNSIGNED AUTO_INCREMENT,
  Dimensione SMALLINT UNSIGNED NOT NULL,
  Peso TINYINT UNSIGNED NOT NULL,
  Prescrizione VARCHAR(4000) DEFAULT NULL,
  DurataPrescrizione VARCHAR(20) DEFAULT NULL,
  Motivazione VARCHAR(300) NOT NULL,
  Data DATE NOT NULL,
  IDSerpente INT UNSIGNED NOT NULL,
  IVAClinica BIGINT(11) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (Numero),
  CONSTRAINT FKVisita_IDSerpente FOREIGN KEY (IDSerpente) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKVisita_IVAClinica FOREIGN KEY (IVAClinica) REFERENCES Clinica (IVA) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Cibo (Nome, Dimensione, Peso)
CREATE TABLE Cibo (
  Nome VARCHAR(60),
  Dimensione TINYINT UNSIGNED NOT NULL,
  Peso TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (Nome)
);


-- Pasti (Data, IDSerpente, Risultato, NomeCibo, Tipo)
CREATE TABLE Pasti (
  Data DATE NOT NULL,
  IDSerpente INT UNSIGNED NOT NULL,
  Risultato ENUM ('Consumato', 'Rifiutato', 'Rigurgitato') DEFAULT 'Consumato' NOT NULL,
  Tipo ENUM ('Scongelato', 'Pre-ucciso', 'Vivo') DEFAULT 'Scongelato' NOT NULL,
  NomeCibo VARCHAR(60) NOT NULL,
  PRIMARY KEY (Data, IDSerpente),
  CONSTRAINT FKPasti_IDSerpente FOREIGN KEY (IDSerpente) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKPasti_NomeCibo FOREIGN KEY (NomeCibo) REFERENCES Cibo (Nome) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Progenie (Data, IDSerpente, tipo, totale, morti, slugs)
CREATE TABLE Progenie (
  Data DATE NOT NULL,
  IDSerpente INT UNSIGNED NOT NULL,
  Tipo ENUM ('Covata', 'Nidiata') DEFAULT 'Covata' NOT NULL,
  Totale TINYINT UNSIGNED NOT NULL,
  Morti TINYINT UNSIGNED NOT NULL,
  Slugs TINYINT UNSIGNED DEFAULT 0,
  PRIMARY KEY (Data, IDSerpente),
  CONSTRAINT FKProgenie_IDSerpente FOREIGN KEY (IDSerpente) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Incubazione (DataParto, IDSerpente, DataInizio, DataFine, Temperatura, Umidita)
CREATE TABLE Incubazione (
  DataParto DATE NOT NULL,
  IDSerpente INT UNSIGNED NOT NULL,
  DataInizio DATE NOT NULL,
  DataFine DATE DEFAULT NULL,
  Temperatura TINYINT UNSIGNED NOT NULL,
  Umidita TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (DataParto, IDSerpente),
  CONSTRAINT FKIncubazione_Progenie FOREIGN KEY (DataParto, IDSerpente) REFERENCES Progenie (Data, IDSerpente) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Morph (ID, Nome, Descrizione)
CREATE TABLE Morph (
  ID INT UNSIGNED AUTO_INCREMENT,
  Nome VARCHAR(100) NOT NULL,
  Descrizione VARCHAR(1000) NOT NULL,
  PRIMARY KEY (ID)
);


-- Allele (Nome, Locus, Tipo)
CREATE TABLE Allele (
  Nome VARCHAR(100) NOT NULL,
  Locus VARCHAR(100) NOT NULL,
  Tipo ENUM ('Dominante', 'Codominante', 'Recessivo') NOT NULL,
  PRIMARY KEY (Nome, Locus)
);


-- Terrario (ID, Riscaldatore, BassaTemp, AltaTemp, Tipologia, Acquatico, Arrampicabile, Scavabile, Umidita)
CREATE TABLE Terrario (
  ID INT UNSIGNED AUTO_INCREMENT,
  Riscaldatore ENUM ('Tappetino', 'Lampada', 'Entrambe') DEFAULT 'Tappetino' NOT NULL,
  AltaTemp TINYINT NOT NULL,
  BassaTemp TINYINT NOT NULL,
  Tipologia ENUM ('Opaco', 'Trasparente', 'Entrambi') DEFAULT 'Entrambi' NOT NULL,
  Acquatico BOOL DEFAULT FALSE NOT NULL,
  Arrampicabile BOOL DEFAULT FALSE NOT NULL,
  Scavabile BOOL DEFAULT FALSE NOT NULL,
  Umidita TINYINT NOT NULL,
  PRIMARY KEY (ID)
);


-- Specie (NomeScientifico, NomeComune, EtaMax, Aspettativa, Alimentazione, Attivita, Difesa, Temperamento, Difficolta, Coabitazione, TempoIncubaz, ProgenieMax, ProgenieMin, Ovoviviparo, IDTerrario)
CREATE TABLE Specie (
  NomeScientifico VARCHAR(100),
  NomeComune VARCHAR(100) NOT NULL UNIQUE,
  EtaMax TINYINT UNSIGNED NOT NULL,
  Aspettativa TINYINT UNSIGNED NOT NULL,
  Alimentazione ENUM (
    'Roditori',
    'Piccoli Mammiferi',
    'Pesci',
    'Uova',
    'Vermi'
  ) DEFAULT 'Roditori' NOT NULL,
  Attivita ENUM ('Diurno', 'Notturno', 'Crepuscolare') DEFAULT 'Crepuscolare' NOT NULL,
  Difesa ENUM (
    'Morso',
    'Veleno',
    'Tanatosi',
    'Intimidazione',
    'Musk',
    'Avviluppamento'
  ) DEFAULT 'Morso' NOT NULL,
  Temperamento ENUM ('Schivo', 'Aggressivo', 'Calmo', 'Attivo') DEFAULT 'Calmo' NOT NULL,
  Difficolta ENUM ('Principiante', 'Intermedio', 'Esperto') DEFAULT 'Intermedio' NOT NULL,
  Coabitazione BOOL DEFAULT FALSE NOT NULL,
  TempoIncubaz TINYINT UNSIGNED DEFAULT NULL,
  ProgenieMax TINYINT UNSIGNED NOT NULL,
  ProgenieMin TINYINT UNSIGNED NOT NULL,
  Ovoviviparo BOOL DEFAULT FALSE NOT NULL,
  IDTerrario INT UNSIGNED NOT NULL,
  PRIMARY KEY (NomeScientifico),
  CONSTRAINT FKSpecie_IDTerrario FOREIGN KEY (IDTerrario) REFERENCES Terrario (ID) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Brumazione (NomeSpecie, SettPreBrum, MeseInizio, MeseFine, TempMedia)
CREATE TABLE Brumazione (
  NomeSpecie VARCHAR(100),
  SettPreBrum TINYINT UNSIGNED NOT NULL,
  MeseInizio ENUM (
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic'
  ) NOT NULL,
  MeseFine ENUM (
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic'
  ) NOT NULL,
  TempMedia TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (NomeSpecie),
  CONSTRAINT FKBrumazione_NomeSpecie FOREIGN KEY (NomeSpecie) REFERENCES Specie (NomeScientifico) ON DELETE CASCADE ON UPDATE CASCADE
);


-- SubStrato (NomeSub, Proprietà)
CREATE TABLE Substrato (
  NomeSub VARCHAR(100),
  Proprietà VARCHAR(400) NOT NULL,
  PRIMARY KEY (NomeSub)
);


-- Eta (FaseEta, NomeSpecie, Lunghezza, Peso, EtaLimite, IDTerrario, DimMinTerrario, DimConsTerrario, DimTana)
CREATE TABLE Eta (
  FaseEta ENUM ('Baby', 'Sub-adulto', 'Adulto') NOT NULL,
  NomeSpecie VARCHAR(100) NOT NULL,
  Lunghezza TINYINT UNSIGNED NOT NULL,
  Peso TINYINT UNSIGNED NOT NULL,
  EtaLimite TINYINT UNSIGNED,
  IDTerrario INT UNSIGNED NOT NULL,
  DimMinTerrario VARCHAR(7) NOT NULL,
  DimConsTerrario VARCHAR(7) NOT NULL,
  DimTana VARCHAR(7) NOT NULL,
  PRIMARY KEY (FaseEta, NomeSpecie),
  CONSTRAINT FKEta_NomeSpecie FOREIGN KEY (NomeSpecie) REFERENCES Specie (NomeScientifico) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKEta_IDTerrario FOREIGN KEY (IDTerrario) REFERENCES Terrario (ID) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Accoppiamento (IDSerpenteM, IDSerpenteF, Data)
CREATE TABLE Accoppiamento (
  IDSerpenteM INT UNSIGNED NOT NULL,
  IDSerpenteF INT UNSIGNED NOT NULL,
  Data DATE,
  PRIMARY KEY (IDSerpenteM, IDSerpenteF),
  CONSTRAINT FKAccoppiamento_IDSerpenteM FOREIGN KEY (IDSerpenteM) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKAccoppiamento_IDSerpenteF FOREIGN KEY (IDSerpenteF) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Parentela (IDGenitore, IDFiglio)
CREATE TABLE Parentela (
  IDGenitore INT UNSIGNED NOT NULL,
  IDFiglio INT UNSIGNED NOT NULL,
  PRIMARY KEY (IDGenitore, IDFiglio),
  CONSTRAINT FKParentela_IDGenitore FOREIGN KEY (IDGenitore) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKParentela_IDFiglio FOREIGN KEY (IDFiglio) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- PH (IDSerpente, IDMorph, Percentuale)
CREATE TABLE PH (
  IDSerpente INT UNSIGNED NOT NULL,
  IDMorph INT UNSIGNED NOT NULL,
  Percentuale TINYINT NOT NULL,
  PRIMARY KEY (IDSerpente, IDMorph),
  CONSTRAINT FKPH_IDSerpente FOREIGN KEY (IDSerpente) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKPH_IDMorph FOREIGN KEY (IDMorph) REFERENCES Morph (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Aspetto (IDSerpente, IDMorph)
CREATE TABLE Aspetto (
  IDSerpente INT UNSIGNED NOT NULL,
  IDMorph INT UNSIGNED NOT NULL,
  PRIMARY KEY (IDSerpente, IDMorph),
  CONSTRAINT FKAspetto_IDSerpente FOREIGN KEY (IDSerpente) REFERENCES Serpente (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKAspetto_IDMorph FOREIGN KEY (IDMorph) REFERENCES Morph (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Composto (IDComponente, IDRisultato)
CREATE TABLE Composto (
  IDComponente INT UNSIGNED NOT NULL,
  IDRisultato INT UNSIGNED NOT NULL,
  PRIMARY KEY (IDComponente, IDRisultato),
  CONSTRAINT FKComposto_IDComponente FOREIGN KEY (IDComponente) REFERENCES Morph (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKComposto_IDRisultato FOREIGN KEY (IDRisultato) REFERENCES Morph (ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Causa (IDMorph, NomeAllele, LocusAllele)
CREATE TABLE Causa (
  IDMorph INT UNSIGNED NOT NULL,
  NomeAllele VARCHAR(100) NOT NULL,
  LocusAllele VARCHAR(100) NOT NULL,
  PRIMARY KEY (IDMorph, NomeAllele, LocusAllele),
  CONSTRAINT FKCausa_IDMorph FOREIGN KEY (IDMorph) REFERENCES Morph (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKCausa_Allele FOREIGN KEY (NomeAllele, LocusAllele) REFERENCES Allele (Nome, Locus) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Genetica (IDMorph, NomeSpecie, Problematiche)
CREATE TABLE Genetica (
  IDMorph INT UNSIGNED NOT NULL,
  NomeSpecie VARCHAR(100) NOT NULL,
  Problematiche VARCHAR(1000),
  PRIMARY KEY (IDMorph, NomeSpecie),
  CONSTRAINT FKGenetica_IDMorph FOREIGN KEY (IDMorph) REFERENCES Morph (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKGenetica_NomeSpecie FOREIGN KEY (NomeSpecie) REFERENCES Specie (NomeScientifico) ON DELETE CASCADE ON UPDATE CASCADE
);


-- TerrenoBrum (NomeSpecie, NomeSubstrato)
CREATE TABLE TerrenoBrum (
  NomeSpecie VARCHAR(100) NOT NULL,
  NomeSubstrato VARCHAR(100) NOT NULL,
  PRIMARY KEY (NomeSpecie, NomeSubstrato),
  CONSTRAINT FKTerrenoBrum_NomeSpecie FOREIGN KEY (NomeSpecie) REFERENCES Specie (NomeScientifico) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKTerrenoBrum_NomeSubstrato FOREIGN KEY (NomeSubstrato) REFERENCES Substrato (NomeSub) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Terreno (IDTerrario, NomeSubstrato)
CREATE TABLE Terreno (
  IDTerrario INT UNSIGNED NOT NULL,
  NomeSubstrato VARCHAR(100) NOT NULL,
  PRIMARY KEY (IDTerrario, NomeSubstrato),
  CONSTRAINT FKTerreno_IDTerrario FOREIGN KEY (IDTerrario) REFERENCES Terrario (ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FKTerreno_NomeSubstrato FOREIGN KEY (NomeSubstrato) REFERENCES Substrato (NomeSub) ON DELETE CASCADE ON UPDATE CASCADE
);