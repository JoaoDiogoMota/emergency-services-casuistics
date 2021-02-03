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

DROP TRIGGER IF EXISTS IntegridadeNovaCausa;
DELIMITER $
CREATE TRIGGER IntegridadeNovaCausa BEFORE INSERT ON Dim_External_Cause
	FOR EACH ROW
	BEGIN
        IF ( new.Description in ( SELECT a1.Description FROM Dim_External_Cause a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Causa já existe na base de dados';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeIntervenção;
DELIMITER $
CREATE TRIGGER IntegridadeIntervenção BEFORE INSERT ON Dim_Intervention
	FOR EACH ROW
	BEGIN
        IF ( new.idIntervention in ( SELECT a1.idIntervention FROM Dim_Intervention a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Intervenção já existe na base de dados';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeDistricto;
DELIMITER $
CREATE TRIGGER IntegridadeDistricto BEFORE INSERT ON Dim_District
	FOR EACH ROW
	BEGIN
        IF ( new.District in ( SELECT a1.District FROM Dim_District a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Districto já existe na base de dados';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeDrug;
DELIMITER $
CREATE TRIGGER IntegridadeDrug BEFORE INSERT ON Dim_Drug
	FOR EACH ROW
	BEGIN
        IF ( new.Cod_Drug in ( SELECT a1.Cod_Drug FROM Dim_Drug a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Medicamento já existe na base de dados';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadePrescription;
DELIMITER $
CREATE TRIGGER IntegridadePrescription BEFORE INSERT ON Dim_Urgency_Prescription
	FOR EACH ROW
	BEGIN
        IF ( new.Cod_Prescription in ( SELECT a1.Cod_Prescription FROM Dim_Urgency_Prescription a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT= 'Cod_Prescription já existe na base de dados';
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

DROP FUNCTION IF EXISTS getFKpatient;
DELIMITER $$
CREATE FUNCTION getFKpatient(Sexo VARCHAR(1), DataNascimento VARCHAR(100), Distrito VARCHAR(20)) RETURNS INT
DETERMINISTIC
BEGIN

DECLARE chave INT;	
 CALL InserirNovoPaciente(Sexo, DataNascimento, Distrito);
 SET chave = last_insert_id();

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

DROP PROCEDURE IF EXISTS insertExternalCause;
DELIMITER $$
CREATE PROCEDURE insertExternalCause(idExternal_Cause INT, Description VARCHAR(24))
BEGIN

 DECLARE Erro BOOLEAN DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;

 START TRANSACTION;

 INSERT INTO dim_external_cause(idExternal_Cause,Description) VALUES(idExternal_Cause,Description);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertDistrict;
DELIMITER $$
CREATE PROCEDURE insertDistrict(District VARCHAR(20))
BEGIN

 DECLARE Erro BOOLEAN DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;
 START TRANSACTION;
 INSERT INTO Dim_District(District) VALUES (District);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertIntervention;
DELIMITER $$
CREATE PROCEDURE insertIntervention(idIntervention INT, Description VARCHAR(155))
BEGIN

 DECLARE Erro BOOLEAN DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;

 START TRANSACTION;

 INSERT INTO dim_intervention(idIntervention,Description) VALUES(idIntervention,Description);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertPrescriptionDrug;
DELIMITER $$
CREATE PROCEDURE insertPrescriptionDrug(Quantity INT, Drug INT, Urgency_Prescription INT)
BEGIN

 DECLARE Erro BOOLEAN DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;
 INSERT INTO prescription_drug(Quantity, Drug, Urgency_Prescription) VALUES (Quantity, Drug, Urgency_Prescription);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertUrgencyExam;
DELIMITER $$
CREATE PROCEDURE insertUrgencyExam(Num_Exame VARCHAR(23), Description VARCHAR(104))
BEGIN

 INSERT INTO Dim_Urgency_Exams(Num_Exame, Description) VALUES (Num_Exame, Description);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertUrgencyPrescription;
DELIMITER $$
CREATE PROCEDURE insertUrgencyPrescription(Cod_Prescription INT, Prof_Prescription INT, Date_Prescription VARCHAR(100))
BEGIN

 DECLARE chave INT;
 DECLARE Erro BOOLEAN DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;
 START TRANSACTION;
 INSERT INTO Dim_Urgency_Prescription(Cod_Prescription, Prof_Prescription, FK_Date_Prescription) VALUES (Cod_Prescription, Prof_Prescription, getFKdata(Date_Prescription));
 IF erro = 1
     THEN 
		BEGIN
		ROLLBACK;
		SELECT 'Id pode não ser válido';
		END;
     ELSE COMMIT;
     END IF;
     
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKprescription;
DELIMITER $$

CREATE FUNCTION getFKprescription(Cod_Prescription INT) RETURNS INT
DETERMINISTIC
BEGIN

 DECLARE chave INT;
 SET chave = (SELECT idUrgency_Prescription FROM Dim_Urgency_Prescription AS dup WHERE dup.Cod_Prescription = Cod_Prescription);
 RETURN chave;

END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKexame;
DELIMITER $$
CREATE FUNCTION getFKexame ( Num_Exame VARCHAR(23), Description VARCHAR(104)) RETURNS INT
DETERMINISTIC
BEGIN

 DECLARE chave INT; 
 IF (SELECT idUrgency_Exams FROM Dim_Urgency_Exams AS due WHERE due.Num_Exame = Num_Exame AND due.Description = Description)
 IS NULL
 THEN INSERT INTO Dim_Urgency_Exams(Num_Exame, Description) VALUES (Num_Exame, Description);
 END IF;
 SET chave = (SELECT idUrgency_Exams FROM Dim_Urgency_Exams AS due WHERE due.Num_Exame = Num_Exame AND due.Description = Description);
 RETURN chave;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertDimProcedure;
DELIMITER $$
CREATE PROCEDURE insertDimProcedure(id_prescription INT, prof_procedure VARCHAR(45), prof_cancel VARCHAR(45), canceled INT, 
date_prescription VARCHAR(100), date_begin VARCHAR(100), intervention INT)
BEGIN
 
 START TRANSACTION;
 INSERT INTO Dim_Procedure(idPrescription, Prof_Procedure, Prof_Cancel, Canceled, FK_Date_Prescription, FK_Date_Begin, FK_Intervention) VALUES(
 id_prescription, prof_procedure, prof_cancel, canceled, getFKdata(date_prescription), getFKdata(date_begin), intervention);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertUrgencyEpisodes;
DELIMITER $$
CREATE PROCEDURE InsertUrgencyEpisodes(Urg_Episode INT, Prof_Admission INT, Sex VARCHAR(1), Date_Of_Birth VARCHAR(100), District VARCHAR(20),
Date_Admission VARCHAR(100), External_Cause INT, Num_Exame VARCHAR(23), Urgency_Exam_Description VARCHAR(104), Cod_Prescription INT,
idProcedure INT)
BEGIN

 DECLARE Erro BOOLEAN DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;
 START TRANSACTION;
 INSERT INTO Fact_Urgency_Episodes(Urg_Episode,Prof_Admission,FK_Patient,FK_Date_Admission,FK_External_Cause,FK_Urgency_Exams,FK_Urgency_Prescription,FK_Procedure)
	VALUES (Urg_Episode, Prof_Admission, getFKpacient(Sex,Date_Of_Birth,District), getFKdata(Date_Admission), External_Cause, getFKexame(Num_Exame,Urgency_Exam_Description),getFKprescription(Cod_Prescription),idProcedure);
	
END $$
DELIMITER ;