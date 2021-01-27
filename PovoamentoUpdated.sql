-- SCHEMA Urgency
use Urgency;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_DRUG
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_Drug(Cod_Drug,Description)
SELECT DISTINCT COD_DRUG, DESC_DRUG FROM `dados`.`urgency_prescriptions`;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_DATE
-- ---------------------------------------------------------------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS Dates;
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
SELECT DISTINCT data from Dates;

-- Eliminar Temporary Table
DROP TEMPORARY TABLE Dates;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_URGENCY_PRESCRIPTION
-- Dividido em vários slots para conseguir correr
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription) 
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION,d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=STR_TO_DATE(uP.DT_PRESCRIPTION,"%Y/%m/%d %T")
WHERE `COD_PRESCRIPTION`>= 16369810 AND `COD_PRESCRIPTION` <16420000;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
INNER JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16420000 AND `COD_PRESCRIPTION` <16507000;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16507000 AND `COD_PRESCRIPTION` <16545000;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16545000 AND `COD_PRESCRIPTION` <16584700;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16584700 AND `COD_PRESCRIPTION` <16624000;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription) 
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16624000 AND `COD_PRESCRIPTION` <16655000;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16655000 AND `COD_PRESCRIPTION` <16694000;

INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,FK_Date_Prescription)
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, d.idDate
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION
WHERE `COD_PRESCRIPTION`>=16694000 AND `COD_PRESCRIPTION` <=17235985;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE PRESCRIPTION_DRUG
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Prescription_Drug(Urgency_Prescription,Drug,Quantity)
SELECT DISTINCT uP.idUrgency_Prescription,D.idDrug,dUP.QT
FROM `dados`.`urgency_prescriptions` dUP
INNER JOIN Dim_Urgency_Prescription uP ON uP.Cod_Prescription=dUP.COD_PRESCRIPTION AND dUP.ID_PROF_PRESCRIPTION=uP.Prof_Prescription
INNER JOIN Dim_Drug D ON D.Cod_Drug=dUP.COD_DRUG AND D.Description=dUP.DESC_DRUG;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_DISTRICT
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_District (District)
SELECT DISTINCT DISTRICT FROM `dados`.`urgency_episodes`;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_PATIENT
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_Patient(Sex,FK_Date_Of_Birth,FK_District)
SELECT uE.SEX,d.idDate,di.idDistrict 
FROM `dados`.`urgency_episodes`uE
LEFT JOIN Dim_Date d ON d.Date=uE.DATE_OF_BIRTH
LEFT JOIN Dim_District di ON di.District=uE.DISTRICT;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_URGENCY_EXAMS
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_Urgency_Exams(Num_Exame,Description)
SELECT DISTINCT NUM_EXAM,DESC_EXAM FROM `dados`.`urgency_exams`;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_EXTERNAL_CAUSE
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_External_Cause
SELECT DISTINCT ID_EXT_CAUSE,DESC_EXTERNAL_CAUSE FROM `dados`.`urgency_episodes`;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_COLOR
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Dim_Color
SELECT DISTINCT ID_COLOR, DESC_COLOR FROM `dados`.`urgency_episodes`;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_LEVEL
-- ---------------------------------------------------------------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DE DIM_INFO
-- ---------------------------------------------------------------------------------------------------------------------------------

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

-- Povoar Fact_Diagnosis - TALEND
-- INSERT INTO Fact_Diagnosis (Urg_Episode,Prof_Diagnosis,Prof_Discharge,FK_Date_Diagnosis,FK_Destination,FK_Date_Discharge,FK_Reason,FK_Info)
-- SELECT DISTINCT a1.URG_EPISODE, a1.ID_PROF_DIAGNOSIS, a1.ID_PROF_DISCHARGE, a2.idDate,a3.idDestination,a4.idDate,a5.idReason,a6.idInfo
-- FROM `dados`.`urgency_episodes` a1
-- INNER JOIN Dim_Date a2 ON STR_TO_DATE(a1.DT_DIAGNOSIS,"%Y/%m/%d %T") = a2.Date
-- INNER JOIN Dim_Destination a3 ON a1.DESC_DESTINATION = a3.Description
-- INNER JOIN Dim_Date a4 ON STR_TO_DATE(a1.DT_DISCHARGE,"%Y/%m/%d %T") = a4.Date
-- INNER JOIN Dim_Reason a5 ON a1.DESC_REASON = a5.Description
-- INNER JOIN Dim_Info a6 ON a1.COD_DIAGNOSIS = a6.Cod_Diagnosis;

-- ---------------------------------------------------------------------------------------------------------------------------------
-- POVOAMENTO DA TABELA DE FACTOS - FACT_TRIAGE
-- Dividido em vários slots para conseguir correr
-- ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE <= 1789698;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1789698 AND uE.URG_EPISODE <= 1797718;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1797718 AND uE.URG_EPISODE <= 1805634;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1805634 AND uE.URG_EPISODE <= 1813337;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1813337 AND uE.URG_EPISODE <= 1821197;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1821197 AND uE.URG_EPISODE <= 1829098;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1829098 AND uE.URG_EPISODE <= 1836948;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1836948 AND uE.URG_EPISODE <= 1844779;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1844779 AND uE.URG_EPISODE <= 1860174;

INSERT INTO Fact_Triage(Urg_Episode, Prof_Triagem, Pain_Scale, FK_Date_Admission, FK_Color) 
SELECT DISTINCT uE.URG_EPISODE, uE.ID_PROF_TRIAGE, uE.PAIN_SCALE, d.idDate, c.idColor
FROM dados.`urgency_episodes` uE
LEFT JOIN Dim_Date d ON d.Date=uE.DT_ADMITION_TRAIGE
LEFT JOIN Dim_Color c ON c.idColor = uE.ID_COLOR
WHERE uE.URG_EPISODE > 1860174 AND uE.URG_EPISODE <= 1883820;


/* SOLUÇAO COM DIM_HOUR

DROP TEMPORARY TABLE IF EXISTS Hours;
CREATE TEMPORARY TABLE Hours (`hora` INT, `minuto` INT) ENGINE=MEMORY; -- Tabela que aglomera todas as horas
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_PRESCRIPTION,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_PRESCRIPTION,' ',-1),':',-1)) FROM `dados`.`urgency_prescriptions`;
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DATE_OF_BIRTH,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DATE_OF_BIRTH,' ',-1),':',-1)) FROM `dados`.`urgency_episodes`; 
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_ADMITION_URG,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_ADMITION_URG,' ',-1),':',-1)) FROM `dados`.`urgency_episodes`; 
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_ADMITION_TRAIGE,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_ADMITION_TRAIGE,' ',-1),':',-1)) FROM `dados`.`urgency_episodes`;
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_DIAGNOSIS,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_DIAGNOSIS,' ',-1),':',-1)) FROM `dados`.`urgency_episodes`;
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_DISCHARGE,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_DISCHARGE,' ',-1),':',-1)) FROM `dados`.`urgency_episodes`;
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_PRESCRIPTION,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_PRESCRIPTION,' ',-1),':',-1)) FROM `dados`.`urgency_procedures`;
INSERT INTO Hours(hora,minuto) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_BEGIN,' ',-1),':',1) ,(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(DT_BEGIN,' ',-1),':',-1))  FROM `dados`.`urgency_procedures`;

INSERT INTO Dim_Hour (Hour,Minute)
SELECT DISTINCT hora,minuto FROM Hours;

DROP TEMPORARY TABLE IF EXISTS Hours;

DROP TEMPORARY TABLE IF EXISTS Dates;
CREATE TEMPORARY TABLE Dates (`data` VARCHAR(11)); --  ENGINE=MEMORY; Se puser o engine memory dá table full Tabela que aglomera todas as datas
-- ALTER TABLE Dates MAX_ROWS=1000000000;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_PRESCRIPTION,' ',1) FROM `dados`.`urgency_prescriptions`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DATE_OF_BIRTH,' ',1) FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_ADMITION_URG,' ',1) FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_ADMITION_TRAIGE,' ',1) FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_DIAGNOSIS,' ',1) FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_DISCHARGE,' ',1) FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_PRESCRIPTION,' ',1) FROM `dados`.`urgency_procedures`;
INSERT INTO Dates SELECT SUBSTRING_INDEX(DT_BEGIN,' ',1) FROM `dados`.`urgency_procedures`;

ALTER TABLE Dim_Date AUTO_INCREMENT = 1;

-- Povoar Dim_Date_has_Dim_Hour -> Tabela resultante do relacionamento N:N
INSERT INTO Dim_Date_has_Dim_Hour 
SELECT idHour,idDate FROM 


*/
