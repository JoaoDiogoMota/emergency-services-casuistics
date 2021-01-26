USE urgency;
-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DAS DATAS
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Povoar Dim_Date 
CREATE TEMPORARY TABLE Dates (`data` DATETIME) ENGINE=MEMORY; -- Tabela que aglomera todas as datas
INSERT INTO Dates SELECT STR_TO_DATE(DT_PRESCRIPTION,"%Y/%m/%d %T") FROM `dados`.`urgency_prescriptions`;
INSERT INTO Dates SELECT STR_TO_DATE(DATE_OF_BIRTH,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_ADMITION_URG,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_ADMITION_TRAIGE,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_DIAGNOSIS,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_DISCHARGE,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_PRESCRIPTION,"%Y/%m/%d %T") FROM `dados`.`urgency_procedures`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_BEGIN,"%Y/%m/%d %T") FROM `dados`.`urgency_procedures`;

INSERT INTO Dim_Date(Date)
SELECT DISTINCT data FROM Dates;

DROP TEMPORARY TABLE IF EXISTS Dates;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_INFO
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Povoar Dim_Level
-- Povoar todos os niveis 1
INSERT INTO dim_level (idLevel,Cod_Level,Description)
SELECT DISTINCT 1 AS idd,level_1_code,level_1_desc from `dados`.`icd9_hierarchy`;
-- Povoar todos os niveis 2
INSERT INTO dim_level (idLevel,Cod_Level,Description)
SELECT DISTINCT 2 AS idd,level_2_code,level_2_desc from `dados`.`icd9_hierarchy`;
-- Povoar todos os niveis 3
INSERT INTO dim_level (idLevel,Cod_Level,Description)
SELECT DISTINCT 3 AS idd,level_3_code,level_3_desc from `dados`.`icd9_hierarchy`;
-- Povoar todos os niveis 4
INSERT INTO dim_level (idLevel,Cod_Level,Description)
SELECT DISTINCT 4 AS idd,level_4_code,level_4_desc from `dados`.`icd9_hierarchy`;
-- Povoar todos os niveis 5
INSERT INTO dim_level (idLevel,Cod_Level,Description)
SELECT DISTINCT 5 AS idd,level_5_code,level_5_desc from `dados`.`icd9_hierarchy`;

-- Povoar Dim_Info ONDE o Código contêm "E"
INSERT INTO dim_info (cod_diagnosis,description,FK_LevelID,FK_LevelCod)
SELECT DISTINCT a1.COD_DIAGNOSIS, a1.DIAGNOSIS, a2.idLevel, a2.Cod_Level
FROM `dados`.`urgency_episodes` a1
INNER JOIN 	dim_level a2 ON a2.Cod_Level = 'E'
WHERE INSTR(a1.COD_DIAGNOSIS,'E') > 0;

-- Povoar DIM_Info ONDE o Código contêm "V"
INSERT INTO dim_info (cod_diagnosis,description,FK_LevelID,FK_LevelCod)
SELECT DISTINCT a1.COD_DIAGNOSIS, a1.DIAGNOSIS, a2.idLevel, a2.Cod_Level
FROM `dados`.`urgency_episodes` a1
INNER JOIN 	dim_level a2 ON a2.Cod_Level = 'V'
WHERE INSTR(a1.COD_DIAGNOSIS,'V') > 0;

-- Povoar DIM_Info ONDE o Código é uma Range de valores, aka contêm "-"
INSERT INTO dim_info (cod_diagnosis,description,FK_LevelID,FK_LevelCod)
SELECT DISTINCT a1.COD_DIAGNOSIS, a1.DIAGNOSIS, a2.idLevel, a2.Cod_Level
FROM `dados`.`urgency_episodes` a1
INNER JOIN 	dim_level a2 ON ( (SUBSTRING_INDEX(a2.cod_level,'-',1) <= a1.COD_DIAGNOSIS) AND (SUBSTRING_INDEX(a2.cod_level,'-',-1) >= a1.COD_DIAGNOSIS) AND a2.idLevel = 1)
WHERE ( (INSTR(a1.COD_DIAGNOSIS,'V') = 0) AND (INSTR(a1.COD_DIAGNOSIS,'E') = 0) );

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DA TABELA DE FACTOS - FACT_DIAGNOSIS 
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Povoar Dim_Reason 
INSERT INTO Dim_Reason 
SELECT DISTINCT ID_REASON,DESC_REASON FROM `dados`.`urgency_episodes`;
-- Povoar Dim_Destination
INSERT INTO Dim_Destination
SELECT DISTINCT ID_DESTINATION,DESC_DESTINATION FROM `dados`.`urgency_episodes`;

-- Povoar Fact_Diagnosis
INSERT INTO Fact_Diagnosis (Urg_Episode,Prof_Diagnosis,Prof_Discharge,FK_Date_Diagnosis,FK_Destination,FK_Date_Discharge,FK_Reason,FK_Info)
SELECT DISTINCT a1.URG_EPISODE, a1.ID_PROF_DIAGNOSIS, a1.ID_PROF_DISCHARGE, a2.idDate,a3.idDestination,a4.idDate,a5.idReason,a6.idInfo
FROM `dados`.`urgency_episodes` a1
INNER JOIN Dim_Date a2 ON STR_TO_DATE(a1.DT_DIAGNOSIS,"%Y/%m/%d %T") = a2.Date
INNER JOIN Dim_Destination a3 ON a1.DESC_DESTINATION = a3.Description
INNER JOIN Dim_Date a4 ON STR_TO_DATE(a1.DT_DISCHARGE,"%Y/%m/%d %T") = a4.Date
INNER JOIN Dim_Reason a5 ON a1.DESC_REASON = a5.Description
INNER JOIN Dim_Info a6 ON a1.COD_DIAGNOSIS = a6.Cod_Diagnosis;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_PATIENT
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Povoar Dim_District
INSERT INTO Dim_District (District)
SELECT DISTINCT DISTRICT FROM `dados`.`urgency_episodes`;

-- Povoar Dim_Patient 
INSERT INTO Dim_Patient (Sex,FK_Date_Of_Birth,FK_District)
SELECT a1.SEX, a2.idDate, a3.idDistrict 
FROM `dados`.`urgency_episodes` a1
INNER JOIN Dim_Date a2 ON STR_TO_DATE(a1.DATE_OF_BIRTH,"%Y/%m/%d %T") = a2.Date
INNER JOIN Dim_District a3 ON a1.DISTRICT = a3.District;
-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_PROCEDURE
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Povoar Dim_Intervention
INSERT INTO Dim_Intervention 
SELECT DISTINCT ID_INTERVENTION, DESC_INTERVENTION FROM `dados`.`urgency_procedures`;

-- Povoar Dim_Procedure
INSERT INTO Dim_Procedure (idPrescription, Prof_Procedure, Prof_Cancel, Canceled, FK_Date_Prescription, FK_Date_Begin, FK_Intervention)
SELECT a1.ID_PRESCRIPTION, a1.ID_PROFESSIONAL, a1.ID_PROFESSIONAL_CANCEL, a1.DT_CANCEL, a2.idDate, a3.idDate, a4.idIntervention
FROM `dados`.`urgency_procedures` a1
INNER JOIN Dim_Date a2 ON STR_TO_DATE(a1.DT_PRESCRIPTION,"%Y/%m/%d %T") = a2.Date
INNER JOIN Dim_Date a3 ON STR_TO_DATE(a1.DT_BEGIN,"%Y/%m/%d %T") = a3.Date
INNER JOIN Dim_Intervention a4 ON a1.ID_INTERVENTION = a4.idIntervention;