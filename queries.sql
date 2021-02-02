USE urgency;

DROP TRIGGER IF EXISTS IntegridadeUrgencyEpisodesFact;
DELIMITER $
CREATE TRIGGER IntegridadeUrgencyEpisodesFact BEFORE INSERT ON Fact_Urgency_Episodes
	FOR EACH ROW
    BEGIN
		IF ( new.Urg_Episode in ( SELECT a1.Urg_Episode FROM Fact_Urgency_Episodes a1 ) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Já existe Episódio de Urgência com este id';
        END IF;
    END$
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeDiagnosisFact;
DELIMITER $
CREATE TRIGGER IntegridadeDiagnosisFact BEFORE INSERT ON Fact_Diagnosis
	FOR EACH ROW
    BEGIN
		IF ( new.Urg_Episode in ( SELECT a1.Urg_Episode FROM Fact_Diagnosis a1 ) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Já existe Diagnostico com este Episódio de Urgência';
        END IF;
    END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeTriageFact;
DELIMITER $
CREATE TRIGGER IntegridadeTriageFact BEFORE INSERT ON Fact_Triage
	FOR EACH ROW
    BEGIN
		IF ( new.Urg_Episode in ( SELECT a1.Urg_Episode FROM Fact_Triage a1 ) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Já existe triagem com este Episódio de Urgência';
        END IF;
    END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeNovaDate;
DELIMITER $
CREATE TRIGGER IntegridadeNovaDate BEFORE INSERT ON Dim_Date
	FOR EACH ROW
	BEGIN
        IF ( new.Date in ( SELECT a1.Date FROM Dim_Date a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Date já existe na base de dados';
        END IF;
	END $
DELIMITER ;

DELIMITER $$
CREATE FUNCTION getFKdata ( DataNascimento VARCHAR(100) ) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE dataConvertida DATETIME;
        DECLARE chave INT; 
        SET dataConvertida = STR_TO_DATE(DataNascimento,"%Y/%m/%d %T");
        
        IF ( dataConvertida NOT IN ( SELECT a1.Date FROM Dim_Date a1) ) THEN INSERT INTO Dim_Date (date) VALUES (dataConvertida);
        END IF;
		
        SET chave =  (SELECT a1.idDate FROM Dim_Date a1 WHERE dataConvertida = a1.Date);
        
        RETURN chave;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION getFKdistrito (Distrito VARCHAR(20)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;
    IF (distrito NOT IN ( SELECT a1.District FROM Dim_District a1 ) ) THEN INSERT INTO Dim_District (District) VALUES (Distrito);
    END IF;
    
    SET chave =  (SELECT a1.idDistrict FROM Dim_District a1 WHERE distrito = a1.District);
    
    RETURN chave;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION getFKinfor(Cod VARCHAR(45),Diag VARCHAR(250)) RETURNS INT 
DETERMINISTIC
BEGIN
	
    DECLARE chave INT;
    SET chave = (SELECT a1.idInfo FROM Dim_Info a1 WHERE Cod = a1.Cod_Diagnosis AND Diag = a1.Description );
    
    RETURN chave;
    
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InserirNovoPaciente;
DELIMITER $$
CREATE PROCEDURE InserirNovoPaciente(Sexo VARCHAR(1), DataNascimento VARCHAR(100), Distrito VARCHAR(20))
BEGIN
    
    START TRANSACTION;
    INSERT INTO Dim_Patient(Sex,FK_Date_Of_Birth,FK_District) VALUES (Sexo, (SELECT getFKdata(DataNascimento)), (SELECT getFKdistrito(Distrito)));

END $$
DELIMITER ;

DROP TRIGGER IF EXISTS TwoSexes;
DELIMITER $
CREATE TRIGGER TwoSexes BEFORE INSERT ON Dim_Patient
FOR EACH ROW
BEGIN
	IF (new.Sex <> 'F' AND new.Sex <> 'M')  THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sexo escolhido não é válido, use F ou M';
	END IF;
END $
DELIMITER ;

DROP TRIGGER IF EXISTS DataValida;
DELIMITER $
CREATE TRIGGER DataValida BEFORE INSERT ON Dim_Patient
FOR EACH ROW
BEGIN
    DECLARE novaData DATETIME; SET novaData = (SELECT a1.Date FROM Dim_Date a1 WHERE new.FK_Date_Of_Birth = a1.idDate);
	IF (novaData > CURRENT_TIMESTAMP()) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Data Invalida.';
    END IF;
END $
DELIMITER ;

DROP PROCEDURE IF EXISTS InserirNovaTriagem;
DELIMITER $$
CREATE PROCEDURE InserirNovaTriagem(UEpisode INT, TProfissional INT, PainScale INT,DataAdmissao VARCHAR(100),Cor INT)
BEGIN

	START TRANSACTION;
    INSERT INTO Fact_Triage(Urg_Episode,Prof_Triagem,Pain_Scale,FK_Date_Admission,FK_Color) VALUES (UEpisode,TProfissional,PainScale,getFKdata(DataAdmissao),Cor);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InserirNovoDiagnostico;
DELIMITER $$
CREATE PROCEDURE InserirNovoDiagnostico(UEpisode INT,DProfissional INT,DchProfissional INT,DataD VARCHAR(100),Destino INT,DataDch VARCHAR(100),Reason INT,Cod VARCHAR(45),Diag VARCHAR(250))
BEGIN
	
    START TRANSACTION;
    INSERT INTO Fact_Diagnosis(Urg_Episode,Prof_Diagnosis,Prof_Discharge,FK_Date_Diagnosis,FK_Destination,FK_Date_Discharge,FK_Reason,FK_Info)
		VALUES (Uepisode,DProfissional,DchProfissional,getFKdata(DataD),Destino,getFkdata(DataDch),Reason,getFKinfo(Cod,Diag));
    
END $$
DELIMITER ;

