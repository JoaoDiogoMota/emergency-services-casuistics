-- Atualização do Data Warehouse com os dados presentes na area de retenção
use urgency_retencao;


-- Inserção das novas datas no DW
DROP PROCEDURE IF EXISTS InserirDimDate;
DELIMITER $$
CREATE PROCEDURE InserirDimDate()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE d DATETIME;
    SET size = (SELECT COUNT(*) FROM Dim_Date);
    SET i = 0;
    DROP VIEW IF EXISTS vDatas;
    CREATE VIEW vDatas AS SELECT Date FROM `urgency-t2`.Dim_Date;
    
    WHILE(i<=size) DO
		SET d = (SELECT Date FROM Dim_Date WHERE idDate=i);
		IF(d NOT IN (SELECT * FROM vDatas)) THEN INSERT INTO `urgency-t2`.Dim_Date(Date) SELECT d; END IF;
        SET i = i+1;
	END WHILE;
    drop view vDatas;
    
END $$
DELIMITER ;

-- --------------------------------- Triage -------------------------

-- Inserção das novas Cores no DW
DROP PROCEDURE IF EXISTS InserirDim_Color;
DELIMITER $$
CREATE PROCEDURE InserirDim_Color()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE d VARCHAR(8);
    SET size = (SELECT COUNT(*) FROM Dim_Color);
    SET i = 0;
    DROP VIEW IF EXISTS vColor;
    CREATE VIEW vColor AS SELECT Description FROM `urgency-t2`.Dim_Color;
    
    WHILE(i<size) DO
        SET d = (SELECT Description d FROM Dim_Color LIMIT i,1);
        IF(d NOT IN (SELECT * FROM vColor)) THEN INSERT INTO `urgency-t2`.Dim_Color SELECT * FROM Dim_Color WHERE Dim_Color.Description=d; END IF;
        SET i = i+1;
	END WHILE;
    drop view vColor;
END $$
DELIMITER ;

-- Inserção de novas triagens no DW
DROP PROCEDURE IF EXISTS InserirFact_Triage;
DELIMITER $$
CREATE PROCEDURE InserirFact_Triage()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE u INT;
    DECLARE d DATETIME;
    DECLARE c VARCHAR(8);
    SET size = (SELECT COUNT(*) FROM Fact_Triage);
    SET i = 0;
    DROP VIEW IF EXISTS vTriage;
    CREATE VIEW vTriage AS SELECT Urg_Episode FROM `urgency-t2`.Fact_Triage;
    
    WHILE(i<size) DO
        SET u = (SELECT Urg_Episode FROM Fact_Triage LIMIT i,1);
        SET d = (SELECT Date FROM Dim_Date dD JOIN Fact_Triage fT ON dD.idDate=FT.FK_Date_Admission WHERE fT.Urg_Episode=u);
        SET c = (SELECT Description FROM Dim_Color dC JOIN Fact_Triage fT ON dC.idColor=FT.FK_Color WHERE fT.Urg_Episode=u);
        IF(u NOT IN (SELECT * FROM vTriage)) THEN INSERT INTO `urgency-t2`.Fact_Triage VALUES (u,(SELECT Prof_Triagem FROM Fact_Triage LIMIT i,1),(SELECT Pain_Scale FROM Fact_Triage LIMIT i,1),
        getFKdata2(d),getFKcor2(c)); END IF;
        SET i = i+1;
	END WHILE;
    drop view vTriage;
END $$
DELIMITER ;


-- ---------------------------------------- DIAGNOSIS ----------------------

-- Inserir no DW Dim_Reason
DROP PROCEDURE IF EXISTS InserirDimReason;
DELIMITER $$
CREATE PROCEDURE InserirDimReason()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE r VARCHAR(33);
    SET size = (SELECT COUNT(*) FROM Dim_Reason);
    SET i = 0;
    DROP VIEW IF EXISTS vReason;
    CREATE VIEW vReason AS SELECT Description FROM `urgency-t2`.Dim_Reason;
    
    WHILE(i<size) DO
		SET r = (SELECT Description FROM Dim_Reason LIMIT i,1);
		IF(r NOT IN (SELECT * FROM vReason)) THEN INSERT INTO `urgency-t2`.Dim_Reason SELECT * FROM Dim_Reason WHERE Dim_Reason.Description=r; END IF;
        SET i = i+1;
	END WHILE;
    drop view vReason;
    
END $$
DELIMITER ;

-- Inserir no DW Dim_Reason
DROP PROCEDURE IF EXISTS InserirDimDestination;
DELIMITER $$
CREATE PROCEDURE InserirDimDestination()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE d VARCHAR(43);
    SET size = (SELECT COUNT(*) FROM Dim_Destination);
    SET i = 0;
    DROP VIEW IF EXISTS vReason;
    CREATE VIEW vDestination AS SELECT Description FROM `urgency-t2`.Dim_Destination;
    
    WHILE(i<size) DO
		SET d = (SELECT Description FROM Dim_Destination LIMIT i,1);
		IF(d NOT IN (SELECT * FROM vDestination)) THEN INSERT INTO `urgency-t2`.Dim_Destination SELECT * FROM Dim_Destination WHERE Dim_Destination.Description=d; END IF;
        SET i = i+1;
	END WHILE;
    drop view vDestination;
    
END $$
DELIMITER ;

-- Inserção de novos Infos no DW
DROP PROCEDURE IF EXISTS InserirDim_Info;
DELIMITER $$
CREATE PROCEDURE InserirDim_Info()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE cod VARCHAR(45);
    DECLARE idL INT;
    DECLARE levC VARCHAR(15);
    DECLARE descrip VARCHAR(250);
    SET size = (SELECT COUNT(*) FROM Dim_Info);
    SET i = 0;
    DROP VIEW IF EXISTS vInfo;
    CREATE VIEW vInfo AS SELECT Cod_Diagnosis,Description FROM `urgency-t2`.Dim_Info;
    
    WHILE(i<size) DO
        SET cod = (SELECT Cod_Diagnosis FROM Dim_Info LIMIT i,1);
        SET descrip = (SELECT Description FROM Dim_Info LIMIT i,1);
        SET idL = (SELECT FK_LevelID FROM Dim_Info LIMIT i,1);
        SET levC = (SELECT FK_LevelCod FROM Dim_Info LIMIT i,1);
        IF(cod NOT IN (SELECT Cod_Diagnosis FROM vInfo) AND descrip NOT IN (SELECT Description FROM vInfo)) THEN INSERT INTO `urgency-t2`.Dim_Info (Cod_Diagnosis,Description,FK_LevelID,FK_LevelCod) VALUES
        (cod,descrip,idL,levC); END IF;
        SET i = i+1;
	END WHILE;
    drop view vInfo;
END $$
DELIMITER ;

SELECT * FROM `urgency-t2`.Dim_Info;

-- Inserção de novos Diagnosticos no DW
DROP PROCEDURE IF EXISTS InserirFact_Diagnosis;
DELIMITER $$
CREATE PROCEDURE InserirFact_Diagnosis()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE u INT;
    DECLARE d DATETIME;
    DECLARE d2 DATETIME;
    DECLARE dest VARCHAR(43);
    DECLARE reason VARCHAR(33);
    DECLARE codInfo VARCHAR(45);
    DECLARE descInfo VARCHAR(250);
    DECLARE c VARCHAR(8);
    SET size = (SELECT COUNT(*) FROM Fact_Triage);
    SET i = 0;
    DROP VIEW IF EXISTS vDiagnosis;
    CREATE VIEW vDiagnosis AS SELECT Urg_Episode FROM `urgency-t2`.Fact_Diagnosis;
    
    WHILE(i<size) DO
        SET u = (SELECT Urg_Episode FROM Fact_Diagnosis LIMIT i,1);
        SET d = (SELECT Date FROM Dim_Date dD JOIN Fact_Diagnosis fD ON dD.idDate=FD.FK_Date_Diagnosis WHERE fD.Urg_Episode=u);
        SET d2 = (SELECT Date FROM Dim_Date dD JOIN Fact_Diagnosis fD ON dD.idDate=FD.FK_Date_Discharge WHERE fD.Urg_Episode=u);
        SET dest = (SELECT Description FROM Dim_Destination dD JOIN Fact_Diagnosis fD ON dD.idDestination=FD.FK_Destination WHERE fD.Urg_Episode=u);
        SET reason = (SELECT Description FROM Dim_Reason dR JOIN Fact_Diagnosis fD ON dR.idReason=FD.FK_Reason WHERE fD.Urg_Episode=u);
        SET codinfo = (SELECT Cod_Diagnosis FROM Dim_Info dI JOIN Fact_Diagnosis fD ON dI.idInfo=FD.FK_Info WHERE fD.Urg_Episode=u);
        SET descinfo = (SELECT Description FROM Dim_Info dI JOIN Fact_Diagnosis fD ON dI.idInfo=FD.FK_Info WHERE fD.Urg_Episode=u);
        IF(u NOT IN (SELECT * FROM vDiagnosis)) THEN INSERT INTO `urgency-t2`.Fact_Diagnosis VALUES (u,(SELECT Prof_Diagnosis FROM Fact_Diagnosis LIMIT i,1),(SELECT Prof_Discharge FROM Fact_Diagnosis LIMIT i,1),
        getFKdata2(d),getFKdestination2(dest),getFKdata2(d2),getFKreason2(reason),getFKinfo2(codinfo,descinfo)); END IF;
        SET i = i+1;
	END WHILE;
    drop view vDiagnosis;
END $$
DELIMITER ;


  





-- ------------------------------ EPISODES ------------------------------
-- inserir District no DW
DROP PROCEDURE IF EXISTS InserirDimDistrict;
DELIMITER $$
CREATE PROCEDURE InserirDimDistrict()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE d VARCHAR(20);
    SET size = (SELECT COUNT(*) FROM Dim_District);
    SET i = 1;
    DROP VIEW IF EXISTS vDistrict;
    CREATE VIEW vDistrict AS SELECT District FROM `urgency-t2`.Dim_District;
    
    WHILE(i<=size) DO
		SET d = (SELECT District FROM Dim_District WHERE idDistrict=i);
		IF(d NOT IN (SELECT * FROM vDistrict)) THEN INSERT INTO `urgency-t2`.Dim_District(District) VALUES (d); END IF;
        SET i = i+1;
	END WHILE;
    drop view vDistrict;
    
END $$
DELIMITER ;

-- inserir Patient DW
DROP PROCEDURE IF EXISTS inserirDim_Patient;
DELIMITER $$
CREATE PROCEDURE inserirDim_Patient()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE j INT;
    DECLARE dataN DATETIME;
    DECLARE dist VARCHAR(20); 
    DECLARE sexo VARCHAR(1);
    SET size = (SELECT COUNT(*) FROM Dim_Patient);
    SET i = 1;
    DROP VIEW IF EXISTS vDistrict;
    CREATE VIEW vDistrict AS SELECT District FROM `urgency-t2`.Dim_District;
    
    WHILE(i<=size) DO
		SET j = (i-1);
		SET sexo = (SELECT Sex FROM Dim_Patient WHERE idPatient=1);
        SET dataN = (SELECT Date FROM Dim_Date dD JOIN Dim_Patient dP ON dD.idDate=dP.FK_Date_Of_Birth LIMIT j,1); 
        SET dist = (SELECT District FROM Dim_District dD JOIN Dim_Patient dP ON dD.idDistrict=dP.FK_District LIMIT j,1);
		INSERT INTO `urgency-t2`.Dim_Patient(Sex,FK_Date_Of_Birth,FK_District) VALUES (sexo,getFKdata2(dataN),getFKdistrict2(dist));
        SET i = i+1;
	END WHILE;
    drop view vDistrict;
    
END $$
DELIMITER ;

-- inserção de Drugs no DW
DROP PROCEDURE IF EXISTS InserirDimDrug;
DELIMITER $$
CREATE PROCEDURE InserirDimDrug()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE cD INT;
    DECLARE d VARCHAR(227);
    SET size = (SELECT COUNT(*) FROM Dim_Drug);
    SET i = 0;
    DROP VIEW IF EXISTS vDrug;
CREATE VIEW vDrug AS SELECT  Cod_Drug,Description FROM `urgency-t2`.Dim_Drug;
    
    WHILE(i<=size) DO
		SET cD = (SELECT Cod_Drug FROM Dim_Drug WHERE idDrug=i);
        SET d = (SELECT Description FROM Dim_Drug WHERE idDrug=i);
		IF(cD NOT IN (SELECT Cod_Drug FROM vDrug) AND d NOT IN (SELECT Description FROM vDrug)) THEN INSERT INTO `urgency-t2`.Dim_Drug(Cod_Drug, Description) VALUES (cD,d); END IF;
        SET i = i+1;
	END WHILE;
    drop view vDrug;
    
END $$
DELIMITER ;

-- Inserscao de Exams
DROP PROCEDURE IF EXISTS InserirDim_Urgency_Exams;
DELIMITER $$
CREATE PROCEDURE InserirDim_Urgency_Exams()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE nE VARCHAR(23);
    DECLARE d VARCHAR(104);
    SET size = (SELECT COUNT(*) FROM Dim_Urgency_Exams);
    SET i = 0;
    DROP VIEW IF EXISTS vUrgency_Exams;
    CREATE VIEW vUrgency_Exams AS SELECT Num_Exame,Description FROM `urgency-t2`.Dim_Urgency_Exams;
    
    WHILE(i<=size) DO
		SET nE = (SELECT Num_Exame FROM Dim_Urgency_Exams WHERE idUrgency_Exams=i);
        SET d = (SELECT Description FROM Dim_Urgency_Exams WHERE idUrgency_Exams=i);
		IF(nE NOT IN (SELECT Num_Exame FROM vUrgency_Exams) AND d NOT IN (SELECT Description FROM vUrgency_Exams)) THEN INSERT INTO `urgency-t2`.Dim_Urgency_Exams(Num_Exame, Description) VALUES (nE,d); END IF;
        SET i = i+1;
	END WHILE;
    drop view vUrgency_Exams;
    
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS InserirDimExternal_Cause;
DELIMITER $$
CREATE PROCEDURE InserirDimExternal_Cause()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE d INT;
    SET size = (SELECT COUNT(*) FROM Dim_External_Cause);
    SET i = 0;
    DROP VIEW IF EXISTS vExternalCause;
    CREATE VIEW vExternalCause AS SELECT idExternal_Cause FROM `urgency-t2`.Dim_External_Cause;
    
    WHILE(i<size) DO
		SET d = (SELECT idExternal_Cause FROM Dim_External_Cause LIMIT i,1);
		IF(d NOT IN (SELECT * FROM vExternalCause)) THEN INSERT INTO `urgency-t2`.Dim_External_Cause SELECT * FROM Dim_External_Cause WHERE Dim_External_Cause.idExternal_Cause=d; END IF;
        SET i = i+1;
	END WHILE;
    drop view vExternalCause;
    
END $$
DELIMITER ;



-- Inserir no DW Dim_Intervention
DROP PROCEDURE IF EXISTS InserirDimIntervention;
DELIMITER $$
CREATE PROCEDURE InserirDimIntervention()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE d INT;
    SET size = (SELECT COUNT(*) FROM Dim_Intervention);
    SET i = 0;
    DROP VIEW IF EXISTS vIntervention;
    CREATE VIEW vIntervention AS SELECT idIntervention FROM `urgency-t2`.Dim_Intervention;
    
    WHILE(i<size) DO
		SET d = (SELECT idIntervention FROM Dim_Intervention LIMIT i,1);
		IF(d NOT IN (SELECT * FROM vIntervention)) THEN INSERT INTO `urgency-t2`.Dim_Intervention SELECT * FROM Dim_Intervention WHERE Dim_Intervention.idIntervention=d; END IF;
        SET i = i+1;
	END WHILE;
    drop view vIntervention;
    
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InserirDim_Procedures;
DELIMITER $$
CREATE PROCEDURE InserirDim_Procedures()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
	DECLARE idP INT;
	DECLARE pP INT;
    DECLARE pC INT;
    DECLARE c INT;
    DECLARE d DATETIME;
    DECLARE d2 DATETIME;
    DECLARE interv INT;
    SET size = (SELECT COUNT(*) FROM Dim_Procedure);
    SET i = 0;
    DROP VIEW IF EXISTS vProcedure;
    CREATE VIEW vProcedure AS SELECT idPrescription FROM `urgency-t2`.Dim_Procedure;
    
    WHILE(i<size) DO
        SET idP = (SELECT idPrescription FROM Dim_Procedure LIMIT i,1);
        SET pP = (SELECT Prof_Procedure FROM Dim_Procedure  LIMIT i,1 );
        SET pC= (SELECT Prof_Cancel FROM Dim_Procedure  LIMIT i,1 );
        SET c = (SELECT Canceled FROM Dim_Procedure  LIMIT i,1 );
        SET d = (SELECT Date FROM Dim_Date dD JOIN Dim_Procedure dP ON dD.idDate=dP.FK_Date_Prescription LIMIT i,1);
        SET d2 = (SELECT Date FROM Dim_Date dD JOIN Dim_Procedure dP ON dD.idDate=dP.FK_Date_Begin LIMIT i,1);
        SET interv  = (SELECT idIntervention FROM Dim_Intervention dI JOIN Dim_Procedure dP ON dI.idIntervention=dP.FK_Intervention LIMIT i,1);
        IF(idP NOT IN (SELECT * FROM vProcedure)) THEN INSERT INTO `urgency-t2`.Dim_Procedures VALUES (idP,pP,pC,c,getFKdata2(d),getFKdata2(d2),idIntervention); END IF;
        SET i = i+1;
	END WHILE;
    drop view vProcedure;
END $$
DELIMITER ;

-- Inserção de ugency prescriptions no DW
DROP PROCEDURE IF EXISTS InserirUrency_Prescriptions;
DELIMITER $$
CREATE PROCEDURE InserirUrency_Prescriptions()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE cP int;
    DECLARE pP int;
    DECLARE d DATETIME;
    SET size = (SELECT COUNT(*) FROM Dim_Urgency_Prescription);
    SET i = 0;
    DROP VIEW IF EXISTS vUP;
    CREATE VIEW vUP AS SELECT Cod_Prescription,Prof_Prescription FROM `urgency-t2`.Dim_Urgency_Prescription;
    
    WHILE(i<=size) DO
		SET cP = (SELECT Cod_Prescription FROM Dim_Urgency_Prescription WHERE idUrgency_Prescription=i);
		SET pP= (SELECT Prof_Prescription FROM Dim_Urgency_Prescription WHERE idUrgency_Prescription=i);
        SET d = (SELECT Date FROM Dim_Date dD JOIN Dim_Urgency_Prescription duP ON dD.idDate=duP.FK_Date_Prescription WHERE idUrgency_Prescription=i);
		IF(cP NOT IN (SELECT Cod_Prescription FROM vUP) AND pP NOT IN (SELECT Prof_Prescription FROM vUP)) THEN INSERT INTO `urgency-t2`.Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
        VALUES(cP,pP,getFKdata2(d)); END IF;
        SET i = i+1;
	END WHILE;
    drop view vUP;
    
END $$
DELIMITER ;

-- Inserção de Prescription_Drug no DW ----------- 
DROP PROCEDURE IF EXISTS inserirPrescription_Drug;
DELIMITER $$
CREATE PROCEDURE inserirPrescription_Drug()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE uP INT;
    DECLARE d INT;
    DECLARE QT INT;
    SET size = (SELECT COUNT(*) FROM Prescription_Drug);
    SET i = 0;
    DROP VIEW IF EXISTS vPD;
    CREATE VIEW vPD AS SELECT * FROM `urgency-t2`.Prescription_Drug;
    WHILE(i<=size) DO
		SET d = (SELECT(getFKPrescrptionDrugDrug((SELECT Cod_Drug FROM Dim_Drug dD JOIN Prescription_Drug pD ON dD.idDrug=pD.Drug LIMIT i,1),(SELECT Description FROM Dim_Drug dD JOIN Prescription_Drug pD ON dD.idDrug=pD.Drug LIMIT i,1))));
		SET uP = (SELECT(getFKPrescrptionDrugPrescription((SELECT Cod_Prescription FROM Dim_Urgency_Prescription dUP JOIN Prescription_Drug pD ON dUP.idUrgency_Prescription=pD.Urgency_Prescription LIMIT i,1),(SELECT Prof_Prescription FROM Dim_Urgency_Prescription dUP JOIN Prescription_Drug pD ON dUP.idUrgency_Prescription=pD.Urgency_Prescription LIMIT i,1))));
        SET QT = (SELECT Quantity FROM Prescription_Drug LIMIT i,1);
		IF((uP,d,QT)NOT IN (SELECT a1.Urgency_Prescription,a1.Drug,a1.Quantity FROM Prescription_Drug a1)) THEN INSERT INTO `urgency-t2`.Prescription_Drug VALUES (uP,d,QT); END IF;
        SET i = i+1;
	END WHILE;
    drop view vPD;
    
END $$
DELIMITER ;

-- Inserção de novos Diagnosticos no DW
DROP PROCEDURE IF EXISTS InserirFact_Episodes;
DELIMITER $$
CREATE PROCEDURE InserirFact_Episodes()
BEGIN
	
	DECLARE size INT;
    DECLARE i INT;
    DECLARE u INT;
    DECLARE d DATETIME;
	DECLARE profA INT;
    DECLARE pac INT;
    DECLARE eC VARCHAR(24);
    DECLARE uENum VARCHAR(23);
    DECLARE uED VARCHAR(104);
    DECLARE c VARCHAR(8);
    DECLARE pacDate DATETIME;
    DECLARE pacDist VARCHAR(20);
    DECLARE pacSex VARCHAR(1);
    DECLARE pId INT;
    DECLARE uPCod INT;
    SET size = (SELECT COUNT(*) FROM Fact_Triage);
    SET i = 0;
    DROP VIEW IF EXISTS vFactEpisodes;
    CREATE VIEW vFactEpisodes AS SELECT Urg_Episode FROM `urgency-t2`.Fact_Urgency_Episodes;
    
    WHILE(i<size) DO
        SET u = (SELECT Urg_Episode FROM Fact_Urgency_Episodes LIMIT i,1);
        SET profA = (SELECT Prof_Admission FROM Fact_Urgency_Episodes LIMIT i,1);
        SET pacSex = (SELECT Sex FROM Dim_Patient dP JOIN Fact_Urgency_Episodes fUE ON dP.idPatient=fUE.FK_Patient WHERE fUE.Urg_Episode=u);
	    SET pacDate = (SELECT Date FROM Dim_Patient dP JOIN Fact_Urgency_Episodes fUE ON dP.idPatient=fUE.FK_Patient JOIN Dim_Date dD ON dD.idDate=dP.FK_Date_Of_Birth WHERE fUE.Urg_Episode=u);
        SET pacDist = (SELECT District FROM Dim_Patient dP JOIN Fact_Urgency_Episodes fUE ON dP.idPatient=fUE.FK_Patient JOIN Dim_District dD ON dD.idDistrict=dP.FK_District WHERE fUE.Urg_Episode=u);
        SET d = (SELECT Date FROM Dim_Date dD JOIN Fact_Urgency_Episodes fUE ON dD.idDate=fUE.FK_Date_Admission WHERE fUE.Urg_Episode=u);
        SET eC = (SELECT Description FROM Dim_External_Cause dE JOIN Fact_Urgency_Episodes fUE ON dE.idExternal_Cause=fUE.FK_External_Cause WHERE fUE.Urg_Episode=u);
        SET uENum = (SELECT Num_Exame FROM Dim_Urgency_Exams dUE JOIN Fact_Urgency_Episodes fUE ON dUE.idUrgency_Exams=fUE.FK_Urgency_Exams WHERE fUE.Urg_Episode=u);
        SET uED = (SELECT Description FROM Dim_Urgency_Exams dUE JOIN Fact_Urgency_Episodes fUE ON dUE.idUrgency_Exams=fUE.FK_Urgency_Exams WHERE fUE.Urg_Episode=u);
        SET pId = (SELECT idPrescription FROM Dim_Procedure dP JOIN Fact_Urgency_Episodes fUE ON dP.idPrescription=fUE.FK_Procedure WHERE fUE.Urg_Episode=u);
        SET uPCod = (SELECT Cod_Prescription FROM Dim_Urgency_Prescription dUP JOIN Fact_Urgency_Episodes fUE ON dUP.idUrgency_Prescription=fUE.FK_Urgency_Prescription WHERE fUE.Urg_Episode=u);
        
        
        IF(u NOT IN (SELECT * FROM vFactEpisodes)) THEN INSERT INTO `urgency-t2`.Fact_Urgency_Episodes VALUES (u,profA,getFKPatient(pacSex,pacDate,pacDist),getFKdata2(d),getFKExternalCause(eC),
        getFKUrgency_Exams2(uENum,uED),pID,getFKUrgency_Prescription2(uPCod)); END IF;
        SET i = i+1;
	END WHILE;
    drop view vFactEpisodes;
END $$
DELIMITER ;


-- funcao para obter a primary key da data
DROP FUNCTION IF EXISTS getFKdata2;
DELIMITER $$
CREATE FUNCTION getFKdata2 ( DataNascimento DATETIME ) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
        
        IF ( DataNascimento NOT IN ( SELECT a1.Date FROM `urgency-t2`.Dim_Date a1) ) THEN INSERT INTO `urgency-t2`.Dim_Date (date) VALUES (DataNascimento);
        END IF;
		
        SET chave =  (SELECT a1.idDate FROM `urgency-t2`.Dim_Date a1 WHERE DataNascimento = a1.Date);
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKcor2;
DELIMITER $$
CREATE FUNCTION getFKcor2 (Cor VARCHAR(8) ) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idColor FROM `urgency-t2`.Dim_Color d WHERE d.Description=Cor );
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKdestination2;
DELIMITER $$
CREATE FUNCTION getFKdestination2 (dest VARCHAR(43) ) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idDestination FROM `urgency-t2`.Dim_Destination d WHERE d.Description=dest );
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKreason2;
DELIMITER $$
CREATE FUNCTION getFKreason2 (reason VARCHAR(33) ) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idReason FROM `urgency-t2`.Dim_Reason d WHERE d.Description=reason );
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKinfo2;
DELIMITER $$
CREATE FUNCTION getFKinfo2 (codinfo VARCHAR(45),descinfo VARCHAR(250)) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idInfo FROM `urgency-t2`.Dim_Info d WHERE d.Cod_Diagnosis=codInfo AND d.Description=descInfo);
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKdistrict2;
DELIMITER $$
CREATE FUNCTION getFKdistrict2 (dist VARCHAR(20)) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idDim_District FROM `urgency-t2`.Dim_District d WHERE d.District=dist);
        
        RETURN chave;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS getFKPrescrptionDrugDrug;
DELIMITER $$
CREATE FUNCTION getFKPrescrptionDrugDrug (cod INT,descrip VARCHAR(227)) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idDrug FROM `urgency-t2`.Dim_Drug d WHERE d.Cod_Drug=cod AND d.Description=descrip);
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKPrescrptionDrugPrescription;
DELIMITER $$
CREATE FUNCTION getFKPrescrptionDrugPrescription (cod INT,prof INT) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idUrgency_Prescription FROM `urgency-t2`.Dim_Urgency_Prescription d WHERE d.Cod_Prescription=cod AND d.Prof_Prescription=prof);
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKPatient;
DELIMITER $$
CREATE FUNCTION getFKPatient (sex VARCHAR(1),data DATETIME, dist VARCHAR(20)) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idPatient FROM `urgency-t2`.Dim_Patient d WHERE Sex=sex AND getFKdata2(data)=FK_Date_Of_Birth AND getFKdistrict2(dist)=FK_District LIMIT 1);
        
        RETURN chave;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getFKExternalCause;
DELIMITER $$
CREATE FUNCTION getFKExternalCause (descrip VARCHAR(24)) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idExternal_Cause FROM `urgency-t2`.Dim_External_Cause d WHERE d.Description=descrip);
        
        RETURN chave;
END $$
DELIMITER ;

select * from `urgency-t2`.Dim_External_Cause;
select * FROM Dim_External_Cause;
insert into `urgency-t2`.Dim_External_Cause VALUES (23,'Desconhecida');


DROP FUNCTION IF EXISTS getFKUrgency_Exams2;
DELIMITER $$
CREATE FUNCTION getFKUrgency_Exams2 (num VARCHAR(23),descrip VARCHAR(24)) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idUrgency_Exams FROM `urgency-t2`.Dim_Urgency_Exams d WHERE d.Num_Exame=num AND d.Description=descrip);
        
        RETURN chave;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS getFKUrgency_Prescription2;
DELIMITER $$
CREATE FUNCTION getFKUrgency_Prescription2 (cod INT) RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE chave INT; 
		
        SET chave = (SELECT idUrgency_Prescription FROM `urgency-t2`.Dim_Urgency_Prescription d WHERE d.Cod_Prescription=cod);
        
        RETURN chave;
END $$
DELIMITER ;











