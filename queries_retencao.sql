-- -----------------------------------------------------
-- Schema Urgency_Retencao
-- -----------------------------------------------------
USE urgency_retencao;
-- -----------------------------------------------------
-- Inserir Valores de tabelas estáticas
-- -----------------------------------------------------
INSERT INTO dim_level SELECT * FROM urgency.dim_level;
-- -----------------------------------------------------
-- PROCEDURES PARA INSERÇÃO
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Procedure para inserir uma nova triagem, aceita valores nulls
-- em todas as posições exceto código de urgência.
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InserirNovaTriagem;
DELIMITER $$
CREATE PROCEDURE InserirNovaTriagem(UEpisode INT, TProfissional INT, PainScale INT,DataAdmissao VARCHAR(100),idCor INT,Cor VARCHAR(8))
BEGIN
	DECLARE Erro BOOLEAN DEFAULT 0;
    DECLARE nn_TProfissional INT; DECLARE nn_PainScale INT; 
    DECLARE nn_DataAdmissao VARCHAR(100);
    DECLARE nn_idCor INT; DECLARE nn_Cor VARCHAR(8);
    
	-- DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET Erro = 1;
    
    SET nn_TProfissional = IFNULL(TProfissional,-1); 
    SET nn_PainScale = IFNULL(PainScale,-1);
    SET nn_DataAdmissao = IFNULL(DataAdmissao,'1111/11/11 00:00:00');
    SET nn_idCor = IFNULL(idCor,-1); 
    SET nn_Cor = IFNULL(Cor,'Unknown');
    
    IF UEpisode IS NULL THEN SET Erro = 1; 
    END IF;
    IF Erro = 1 THEN SELECT 'Número de Episódio de Urgência não pode ser nulo.'; 
    END IF;
    
	START TRANSACTION;
    INSERT INTO Fact_Triage(Urg_Episode,Prof_Triagem,Pain_Scale,FK_Date_Admission,FK_Color) VALUES (UEpisode,nn_TProfissional,nn_PainScale,getFKdata(nn_DataAdmissao),getFKcor(nn_idCor,nn_Cor));
	
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Procedure para inserir uma nova diagnostico, aceita valores nulls
-- em todas as posições exceto código de urgência, código de nivel
-- e descrição de nivel.
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InserirNovoDiagnostico;
DELIMITER $$
CREATE PROCEDURE InserirNovoDiagnostico(UEpisode INT,DProfissional INT,DchProfissional INT,DataD VARCHAR(100),Destino INT,DestinoDesc VARCHAR(43),DataDch VARCHAR(100),Reason INT, ReasonDesc VARCHAR(33), Cod VARCHAR(45), Cod_Desc VARCHAR(250))
BEGIN
	DECLARE Erro BOOLEAN DEFAULT 0;
    DECLARE nn_DProfissional INT; DECLARE nn_DchProfissional INT; DECLARE nn_DataD VARCHAR(100); DECLARE nn_Destino INT;
    DECLARE nn_DestinoDesc VARCHAR(43); DECLARE nn_DataDch VARCHAR(100); DECLARE nn_Reason INT; DECLARE nn_ReasonDesc VARCHAR(33);
    
    IF UEpisode IS NULL THEN SET Erro = 1; 
    END IF;
    IF Erro = 1 THEN SELECT 'Número de Episódio de Urgência não pode ser nulo.'; 
    END IF;
    
    IF (Cod IS NULL OR Cod_Desc IS NULL) THEN SET Erro = 1; 
    END IF;
    IF Erro = 1 THEN SELECT 'Valor de Código ou Descrição não pode ser nulo.'; 
    END IF;
    
    SET nn_DProfissional = IFNULL(DProfissional,-1);
    SET nn_DchProfissional = IFNULL(DchProfissional,-1);
    SET nn_DataD = IFNULL(DataD,'1111/11/11 00:00:00');
    SET nn_Destino = IFNULL(Destino,-1);
    SET nn_DestinoDesc = IFNULL(DestinoDesc,"Sem destino indicado.");
    SET nn_DataDch = IFNULL(DataDch,'1111/11/11 00:00:00');
    SET nn_Reason = IFNULL(Reason,-1);
    SET nn_ReasonDesc = IFNULL(ReasonDesc,"Destino de Alta não fornecido.");
    
    START TRANSACTION;
    INSERT INTO Fact_Diagnosis(Urg_Episode,Prof_Diagnosis,Prof_Discharge,FK_Date_Diagnosis,FK_Destination,FK_Date_Discharge,FK_Reason,FK_Info)
		VALUES (Uepisode,nn_DProfissional,nn_DchProfissional,getFKdata(nn_DataD),getFKdestino(nn_Destino,nn_DestinoDesc),getFkdata(nn_DataDch),getFKreason(nn_Reason,nn_ReasonDesc),getFKinfo(Cod,Cod_Desc));
    
END $$
DELIMITER ;
-- -----------------------------------------------------
-- Procedure para inserir um novo nivel de diagnóstico + a
-- a sua descrição. Valores nulos não tolerados
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InserirNovoDimInfo;
DELIMITER $$
CREATE PROCEDURE InserirNovoDimInfo(Codigo VARCHAR(45), Descricao VARCHAR(250))
BEGIN
	DECLARE Id INT; 
    DECLARE Cod VARCHAR(15);
    
    SET Id = 1;
    SET Cod = (SELECT l1.Cod_Level FROM Dim_Level l1 
				WHERE (l1.idLevel = 1) AND (
					(CONVERT(SUBSTRING_INDEX(l1.cod_level,'-',1),DOUBLE) <= CONVERT('98',DOUBLE)) AND 
				   ((CONVERT(SUBSTRING_INDEX(l1.cod_level,'-',-1),DOUBLE)+1) > CONVERT('98',DOUBLE) ) ) );
	
    INSERT INTO Dim_Info(Cod_Diagnosis,Description,FK_LevelID,FK_LevelCod) VALUES (Codigo,Descricao,Id,Cod);
    
END $$
DELIMITER ;
-- -----------------------------------------------------
-- Procedure para inserir uma nova Urgency Prescription
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InsereUrgencyPrescription;
DELIMITER $$
CREATE PROCEDURE InsereUrgencyPrescription(Cod_Prescription INT, Prof_Prescription INT, Date_Prescription VARCHAR(100))
BEGIN
	DECLARE Erro BOOLEAN DEFAULT 0;
    DECLARE nn_ProfPrescription INT; DECLARE nn_DatePrescription VARCHAR(100);DECLARE nn_CodPrescription INT;
    
    SET nn_CodPrescription = IFNULL(Cod_Prescription,-1);
    SET nn_ProfPrescription = IFNULL(Prof_Prescription,-1);
    SET nn_DatePrescription = IFNULL(Date_Prescription,'1111/11/11 00:00:00');

	START TRANSACTION;
	INSERT INTO Dim_Urgency_Prescription(Cod_Prescription, Prof_Prescription, FK_Date_Prescription) VALUES (nn_CodPrescription, nn_ProfPrescription, getFKdata(nn_DatePrescription));
END $$
DELIMITER ;
CALL InsereUrgencyPrescription(null,null,null);
-- -----------------------------------------------------
-- Procedure para inserir novas entradas na tabela N to N
-- Não permite a existência de valores nulos
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InsereRelacaoPrescriptionDrug;
DELIMITER $$
CREATE PROCEDURE InsereRelacaoPrescriptionDrug(Cod_Prescription INT,Cod_Drug INT,Drug_Description VARCHAR(227),Quantity INT)
BEGIN
	DECLARE Erro BOOLEAN DEFAULT 0;
    DECLARE nn_CodDrug INT;
    DECLARE nn_DrugDescription VARCHAR(227);
    DECLARE nn_Quantity INT;
    DECLARE fk_DUP INT;
    
    SET nn_CodDrug = IFNULL(Cod_Drug,-1);
    SET nn_DrugDescription = IFNULL(Drug_Description,"Sem Medicação");
    SET nn_Quantity = IFNULL(Quantity,0);
    
    IF Cod_Prescription IS NULL THEN SET Erro = 1; 
	END IF;
	IF Erro = 1 THEN SELECT 'Código de Prescrição não pode ser nulo.'; 
	END IF;
    
    IF Cod_Prescription NOT IN (SELECT a1.Cod_Prescription FROM Dim_Urgency_Prescription a1) THEN SET Erro = 1;
    END IF;
    IF Erro = 1 THEN SELECT 'Não existe Episódio de Urgência com o código de prescrição fornecido. Inválido.'; 
	END IF;
    
    SET fk_DUP = (SELECT a1.idUrgency_Prescription FROM Dim_Urgency_Prescription a1 WHERE a1.Cod_Prescription = Cod_Prescription);
    
    START TRANSACTION;
    INSERT INTO Prescription_Drug(Urgency_Prescription,Drug,Quantity) VALUES (fk_DUP,getFKdrug(nn_CodDrug,nn_DrugDescription),nn_Quantity);
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InserirProcedimento;
DELIMITER $$
CREATE PROCEDURE InserirProcedimento(idPrescription INT,profP INT,profC INT,canceled INT,dateP VARCHAR(100),dateB VARCHAR(100),idIntervention INT,Intervention VARCHAR(155))
BEGIN
	DECLARE Erro BOOLEAN DEFAULT 0;
    DECLARE nn_idPrescription INT;
	DECLARE nn_profP INT;   
    DECLARE nn_profC INT;
    DECLARE nn_canceled INT;
    DECLARE nn_dateP VARCHAR(100);
    DECLARE nn_dateB VARCHAR(100);
    DECLARE nn_idIntervention INT;
    DECLARE nn_Intervention VARCHAR(155);
    
    SET nn_idPrescription = IFNULL(idPrescription,-1);
    SET nn_profP = IFNULL(profP,-1);
    SET nn_profC = IFNULL(profC,-1);
    SET nn_canceled = IFNULL(canceled,0);
    SET nn_dateP = IFNULL(dateP,'1111/11/11 00:00:00');
    SET nn_dateB = IFNULL(dateB,'1111/11/11 00:00:00');
    SET nn_idIntervention = IFNULL(idIntervention,'-1');
    SET nn_Intervention = IFNULL(Intervention,'Sem Intervenção');
    
    START TRANSACTION;
    INSERT INTO Dim_Procedure(idPrescription,Prof_Procedure,Prof_Cancel,Canceled,FK_Date_Prescription,FK_Date_Begin,FK_Intervention)
		VALUES (nn_idPrescription,nn_profP,nn_profC,nn_canceled,getFKdata(nn_dateP),getFKdata(nn_dateB),getFKintervention(nn_idIntervention,nn_Intervention));
END $$
DELIMITER ; 
call urgency_retencao.InserirProcedimento(null, null, null, null, null, null, null, null);
-- -----------------------------------------------------
-- Insere pacientes , 1 Urgencia = 1 Paciente
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InserirNovoPaciente;
DELIMITER $$
CREATE PROCEDURE InserirNovoPaciente(Sexo VARCHAR(1), DataNascimento VARCHAR(100), Distrito VARCHAR(20))
BEGIN
    
    START TRANSACTION;
    INSERT INTO Dim_Patient(Sex,FK_Date_Of_Birth,FK_District) VALUES (Sexo, (SELECT getFKdata(DataNascimento)), (SELECT getFKdistrito(Distrito)));

END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS InserirEpisodioUrgencia;
DELIMITER $$
CREATE PROCEDURE InserirEpisodioUrgencia(Urg_Episode INT, Prof_Admission INT, Sex VARCHAR(1), Date_Of_Birth VARCHAR(100), District VARCHAR(20),
Date_Admission VARCHAR(100), idExtC INT,ExtC VARCHAR(24), Num_Exame VARCHAR(23), Exam_Description VARCHAR(104), idPrescription INT, idProcedure INT)
BEGIN
	DECLARE Erro BOOLEAN DEFAULT 0;
	DECLARE nn_ProfA INT;
    DECLARE nn_Sex VARCHAR(1); DECLARE nn_DoB VARCHAR(100) ;DECLARE nn_District VARCHAR(20);
    DECLARE nn_DateAdd VARCHAR(100); 
    DECLARE nn_idExtC INT; DECLARE ExtC VARCHAR(24);
    DECLARE nn_NumExame VARCHAR(23); DECLARE nn_ExamDescription VARCHAR(104);
    DECLARE nn_Prescription INT; DECLARE nn_Procedure INT;
    DECLARE pp INT;
	
    IF Urg_Episode IS NULL THEN SET Erro = 1; 
    END IF;
    IF Erro = 1 THEN SELECT 'Número de Episódio de Emergência não pode ser nulo.'; 
    END IF;
    
    SET nn_ProfA = IFNULL(Prof_Admission,-1);
    SET nn_Sex = IFNULL(Sex,'N');SET nn_DoB = IFNULL(Date_Of_Birth,'1111/11/11 00:00:00');SET nn_District = IFNULL(District,'Não Indicado');
    SET nn_DateAdd = IFNULL(Date_Admission,'1111/11/11 00:00:00');
    SET nn_idExtC = IFNULL(idExtC,-1);SET ExtC = IFNULL(ExtC,'Desconhecida');
    SET nn_NumExame = IFNULL(Num_Exame,'Sem Exame');SET nn_ExamDescription = IFNULL(Exam_Description,'Sem Exame');
    SET nn_Prescription = IFNULL(idPrescription,-1);SET nn_Procedure = IFNULL(idProcedure,-1);
    
    IF nn_Prescription NOT IN (SELECT a1.Cod_Prescription FROM Dim_Urgency_Prescription a1) THEN SET Erro = 1;
    END IF;
    IF Erro = 1 THEN SELECT 'Não existe Episódio de Urgência com o código de prescrição fornecido. Inválido.'; 
	END IF;
    
    IF nn_Procedure NOT IN (SELECT a1.idPrescription FROM Dim_Procedure a1) THEN SET Erro = 1;
    END IF;
    IF Erro = 1 THEN SELECT 'Não existe Episódio de Urgência com o código fornecido. Inválido.'; 
	END IF;
    
    SET pp = (SELECT a1.idUrgency_Prescription FROM Dim_Urgency_Prescription a1 WHERE a1.Cod_Prescription = nn_Prescription); 
    
    START TRANSACTION;
    INSERT INTO Fact_Urgency_Episodes(Urg_Episode,Prof_Admission,FK_Patient,FK_Date_Admission,FK_External_Cause,FK_Urgency_Exams,FK_Urgency_Prescription,FK_Procedure)
		VALUES (Urg_Episode, nn_ProfA, getFKpatient(nn_Sex,nn_DoB,nn_District), getFKdata(nn_DateAdd), getFKextCause(nn_idExtC,ExtC), getFKexame(nn_NumExame,nn_ExamDescription),pp,nn_Procedure);
END $$
DELIMITER ;
-- -----------------------------------------------------
-- FUNÇÕES PARA INSERIR TABELAS DE DIMENSÃO E OBTER AS FK
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKdata;
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
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKcor;
DELIMITER $$
CREATE FUNCTION getFKcor ( idCor INT,Cor VARCHAR(8) ) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        IF (idCor NOT IN ( SELECT a1.idColor FROM Dim_Color a1) AND Cor NOT IN ( SELECT a2.Description FROM Dim_Color a2)) 
			THEN INSERT INTO Dim_Color(idColor,Description) VALUES (idCor,Cor);
		END IF;
        
        IF (Cor IN ( SELECT a1.Description FROM Dim_Color a1) ) THEN SET chave = (SELECT a1.idColor FROM Dim_Color a1 WHERE a1.Description = Cor);
        END IF;
        IF (idCor IN ( SELECT a1.idColor FROM Dim_Color a1) AND (idCor <> -1) ) THEN SET chave = idCor;
        END IF;
        
        RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKdestino;
DELIMITER $$
CREATE FUNCTION getFKdestino (Id INT,Destino VARCHAR(43)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;
    
    IF (Id NOT IN ( SELECT a1.idDestination FROM Dim_Destination a1) AND Destino NOT IN ( SELECT a2.Description FROM Dim_Destination a2)) 
			THEN INSERT INTO Dim_Destination(idDestination,Description) VALUES (Id,Destino);
		END IF;
    
    IF (Destino IN ( SELECT a1.Description FROM Dim_Destination a1) ) THEN SET chave = (SELECT a1.idDestination FROM Dim_Destination a1 WHERE a1.Description = Destino);
        END IF;
	IF (Id IN ( SELECT a1.idDestination FROM Dim_Destination a1) AND (Id <> -1) ) THEN SET chave = Id;
        END IF;
    
    RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKreason;
DELIMITER $$
CREATE FUNCTION getFKreason (Id INT,Reason VARCHAR(33)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;
    
    IF (Id NOT IN ( SELECT a1.idReason FROM Dim_Reason a1) AND Reason NOT IN ( SELECT a2.Description FROM Dim_Reason a2)) 
			THEN INSERT INTO Dim_Reason(idReason,Description) VALUES (Id,Reason);
		END IF;
    
    IF (Reason IN ( SELECT a1.Description FROM Dim_Reason a1) ) THEN SET chave = (SELECT a1.idReason FROM Dim_Reason a1 WHERE a1.Description = Reason);
        END IF;
	IF (Id IN ( SELECT a1.idReason FROM Dim_Reason a1) AND (Id <> -1) ) THEN SET chave = Id;
        END IF;
    
    RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKinfo;
DELIMITER $$
CREATE FUNCTION getFKinfo(Cod VARCHAR(45),Diag VARCHAR(250)) RETURNS INT 
DETERMINISTIC
BEGIN
    DECLARE chave INT;
    
    IF ( (Cod,Diag) NOT IN ( SELECT a1.Cod_Diagnosis, a1.Description FROM Dim_Info a1 ) ) THEN CALL InsereNovoDimInfo(Cod,Diag);
    END IF;
    
    SET chave = (SELECT a1.idInfo FROM Dim_Info a1 WHERE Cod = a1.Cod_Diagnosis AND Diag = a1.Description );
    
    RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKdrug;
DELIMITER $$
CREATE FUNCTION getFKdrug (Id INT,Description VARCHAR(227)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;
    
	IF ( (Id,Description) NOT IN ( SELECT a1.Cod_Drug, a1.Description FROM Dim_Drug a1 ) ) THEN INSERT INTO Dim_Drug(Cod_Drug,Description) VALUES (Id,Description);
    END IF;
    
    SET chave = (SELECT a1.idDrug FROM Dim_Drug a1 WHERE Id = a1.Cod_Drug AND Description = a1.Description );
    
    RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKintervention;
DELIMITER $$
CREATE FUNCTION getFKintervention (Id INT,Intervention VARCHAR(155)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;
    
    IF (Id NOT IN ( SELECT a1.idIntervention FROM Dim_Intervention a1) AND Intervention NOT IN ( SELECT a2.Description FROM Dim_Intervention a2)) 
			THEN INSERT INTO Dim_Intervention(idIntervention,Description) VALUES (Id,Intervention);
		END IF;
    
    IF (Intervention IN ( SELECT a1.Description FROM Dim_Intervention a1) ) THEN SET chave = (SELECT a1.idIntervention FROM Dim_Intervention a1 WHERE a1.Description = Intervention);
        END IF;
	IF (Id IN ( SELECT a1.idIntervention FROM Dim_Intervention a1) AND (Id <> -1) ) THEN SET chave = Id;
        END IF;
    
    RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKdistrito;
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
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKpatient;
DELIMITER $$
CREATE FUNCTION getFKpatient(Sexo VARCHAR(1), DataNascimento VARCHAR(100), Distrito VARCHAR(20)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;	
	INSERT INTO Dim_Patient(Sex,FK_Date_Of_Birth,FK_District) VALUES (Sexo, (SELECT getFKdata(DataNascimento)), (SELECT getFKdistrito(Distrito)));
	SET chave = last_insert_id();

	RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
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
-- -----------------------------------------------------
-- 
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS getFKextCause;
DELIMITER $$
CREATE FUNCTION getFKextCause (Id INT,Cause VARCHAR(24)) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE chave INT;
    
    IF (Id NOT IN ( SELECT a1.idExternal_Cause FROM Dim_External_Cause a1) AND Cause NOT IN ( SELECT a2.Description FROM Dim_External_Cause a2)) 
			THEN INSERT INTO Dim_External_Cause(idExternal_Cause,Description) VALUES (Id,Cause);
		END IF;
    
    IF (Cause IN ( SELECT a1.Description FROM Dim_External_Cause a1) ) THEN SET chave = (SELECT a1.idExternal_Cause FROM Dim_External_Cause a1 WHERE a1.Description = Cause);
        END IF;
	IF (Id IN ( SELECT a1.idExternal_Cause FROM Dim_External_Cause a1) AND (Id <> -1) ) THEN SET chave = Id;
        END IF;
    
    RETURN chave;
END $$
DELIMITER ;
-- -----------------------------------------------------
-- TRIGGERS PARA IMPEDIR INFO REPETIDA
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS IntegridadeTriageFact;
DELIMITER $
CREATE TRIGGER IntegridadeTriageFact BEFORE INSERT ON Fact_Triage
	FOR EACH ROW
    BEGIN
		IF ( new.Urg_Episode in ( SELECT a1.Urg_Episode FROM Fact_Triage a1 ) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Este Episódio de Urgência já se encontra associado a uma triagem.';
        END IF;
    END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeNovaDate;
DELIMITER $
CREATE TRIGGER IntegridadeNovaDate BEFORE INSERT ON Dim_Date
	FOR EACH ROW
	BEGIN
        IF ( new.Date in ( SELECT a1.Date FROM Dim_Date a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Esta data já se encontra na Base de Dados.';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeNovaCor;
DELIMITER $
CREATE TRIGGER IntegridadeNovaCor BEFORE INSERT ON Dim_Color
	FOR EACH ROW
    BEGIN
		IF ( new.idColor in (SELECT a1.idColor FROM Dim_Color a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Esta cor já se encontra na Base de Dados';
        END IF;
    END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeDiagnosisFact;
DELIMITER $
CREATE TRIGGER IntegridadeDiagnosisFact BEFORE INSERT ON Fact_Diagnosis
	FOR EACH ROW
    BEGIN
		IF ( new.Urg_Episode in ( SELECT a1.Urg_Episode FROM Fact_Diagnosis a1 ) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Já existe um diagnóstico com este Episódio de Urgência';
        END IF;
    END $
DELIMITER ;

DROP TRIGGER IF EXISTS TwoSexes;
DELIMITER $
CREATE TRIGGER TwoSexes BEFORE INSERT ON Dim_Patient
FOR EACH ROW
BEGIN
	IF (new.Sex <> 'F' AND new.Sex <> 'M'AND new.Sex <> 'N')  THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sexo escolhido não é válido, use F ou M';
	END IF;
END $
DELIMITER ;

DROP TRIGGER IF EXISTS DataValida;
DELIMITER $
CREATE TRIGGER DataValida BEFORE INSERT ON Dim_Date
FOR EACH ROW
BEGIN
    DECLARE novaData DATETIME; SET novaData = new.Date;
	IF (novaData > CURRENT_TIMESTAMP()) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Data Inválida.';
    END IF;
END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeUrgencyEpisodesFact;
DELIMITER $
CREATE TRIGGER IntegridadeUrgencyEpisodesFact BEFORE INSERT ON Fact_Urgency_Episodes
	FOR EACH ROW
    BEGIN
		IF ( new.Urg_Episode in ( SELECT a1.Urg_Episode FROM Fact_Urgency_Episodes a1 ) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Já existe Episódio de Urgência com este identificador.';
        END IF;
    END$
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeNovaCausa;
DELIMITER $
CREATE TRIGGER IntegridadeNovaCausa BEFORE INSERT ON Dim_External_Cause
	FOR EACH ROW
	BEGIN
        IF ( new.Description in ( SELECT a1.Description FROM Dim_External_Cause a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Esta causa já se encontra na Base de Dados.';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeIntervenção;
DELIMITER $
CREATE TRIGGER IntegridadeIntervenção BEFORE INSERT ON Dim_Intervention
	FOR EACH ROW
	BEGIN
        IF ( new.idIntervention in ( SELECT a1.idIntervention FROM Dim_Intervention a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Esta intervenção já se encontra na Base de Dados';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeDistricto;
DELIMITER $
CREATE TRIGGER IntegridadeDistricto BEFORE INSERT ON Dim_District
	FOR EACH ROW
	BEGIN
        IF ( new.District in ( SELECT a1.District FROM Dim_District a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Este distrito já se encontra na Base de Dados.';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadeDrug;
DELIMITER $
CREATE TRIGGER IntegridadeDrug BEFORE INSERT ON Dim_Drug
	FOR EACH ROW
	BEGIN
        IF ( new.Cod_Drug in ( SELECT a1.Cod_Drug FROM Dim_Drug a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Este fármaco já se encontra na Base de Dados';
        END IF;
	END $
DELIMITER ;

DROP TRIGGER IF EXISTS IntegridadePrescription;
DELIMITER $
CREATE TRIGGER IntegridadePrescription BEFORE INSERT ON Dim_Urgency_Prescription
	FOR EACH ROW
	BEGIN
        IF ( new.Cod_Prescription in ( SELECT a1.Cod_Prescription FROM Dim_Urgency_Prescription a1) ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT= 'Este código de prescrição já se encontra na Base de Dados';
        END IF;
	END $
DELIMITER ;
