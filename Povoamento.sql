use Urgency;

-- Povoar Dim_Drug
INSERT INTO Dim_Drug(Cod_Drug,Description)
SELECT DISTINCT COD_DRUG, DESC_DRUG FROM `dados`.`urgency_prescriptions`;


-- Povoar Dim_Date 
DROP TEMPORARY TABLE IF EXISTS Dates;
CREATE TEMPORARY TABLE Dates (`data` DATETIME) ENGINE=MEMORY; -- Tabela que aglomera todas as datas
INSERT INTO Dates SELECT STR_TO_DATE(DT_PRESCRIPTION,"%Y-%m-%d %T") FROM `dados`.`urgency_prescriptions`;
INSERT INTO Dates SELECT STR_TO_DATE(DATE_OF_BIRTH,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_ADMITION_URG,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_ADMITION_TRAIGE,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_DIAGNOSIS,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_DISCHARGE,"%Y/%m/%d %T") FROM `dados`.`urgency_episodes`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_PRESCRIPTION,"%Y/%m/%d %T") FROM `dados`.`urgency_procedures`;
INSERT INTO Dates SELECT STR_TO_DATE(DT_BEGIN,"%Y/%m/%d %T") FROM `dados`.`urgency_procedures`;

ALTER TABLE Dim_Date AUTO_INCREMENT = 1;

INSERT INTO Dim_Date(Date)
SELECT DISTINCT data FROM Dates;

select * FROM Dim_Date;

-- Povoar Dim_Urgency_Prescription -> Não está a dar não sei porque
INSERT INTO Dim_Urgency_Prescription(Cod_Prescription,Prof_Prescription,Quantity,FK_Date_Prescription,FK_Drug) 
SELECT DISTINCT uP.COD_PRESCRIPTION, uP.ID_PROF_PRESCRIPTION, uP.QT, d.idDate, dr.idDrug
FROM `dados`.`urgency_prescriptions` uP 
LEFT JOIN Dim_Drug dr ON dr.Cod_Drug=uP.COD_DRUG AND dr.Description=uP.DESC_DRUG
LEFT JOIN Dim_Date d ON d.Date=uP.DT_PRESCRIPTION;


select * FROM `dados`.`urgency_prescriptions`;

select * FROM Dim_Urgency_Prescription;

-- Povoar Dim_District
INSERT INTO Dim_District (District)
SELECT DISTINCT DISTRICT FROM `dados`.`urgency_episodes`;

-- Povoar Dim_Patient 
INSERT INTO Dim_Patient(Sex,FK_Date_Of_Birth,FK_District)
SELECT uE.SEX,d.idDate,di.idDistrict 
FROM `dados`.`urgency_episodes`uE
LEFT JOIN Dim_Date d ON d.Date=uE.DATE_OF_BIRTH
LEFT JOIN Dim_District di ON di.District=uE.DISTRICT;


SELECT * FROM `dados`.`urgency_episodes` WHERE DISTRICT=null;

-- Povoar Dim_Urgency_Exams
INSERT INTO Dim_Urgency_Exams(Num_Exame,Description)
SELECT DISTINCT NUM_EXAM,DESC_EXAM FROM `dados`.`urgency_exams`;

-- Povoar Dim_External_Cause
INSERT INTO Dim_External_Cause
SELECT DISTINCT ID_EXT_CAUSE,DESC_EXTERNAL_CAUSE FROM `dados`.`urgency_episodes`;

-- Povoar Dim_Intervention
INSERT INTO Dim_Intervention 
SELECT DISTINCT ID_INTERVENTION, DESC_INTERVENTION FROM `dados`.`urgency_procedures`;

-- Povoar Dim_Procedure -> Não sei por causa das fks
INSERT INTO Dim_Procedure ...;

-- Povoar Fact_Urgency_Episodes -> Ainda não posso fazer
INSERT Fact_Urgency_Episodes ...;

-- Povoar Dim_Color
INSERT INTO Dim_Color
SELECT DISTINCT ID_COLOR, DESC_COLOR FROM `dados`.`urgency_episodes`;

-- Povoar Fact_Triage -> Ainda nao posso fazer
INSERT INTO Fact_Triage ... ; 

-- Povoar Dim_Reason 
INSERT INTO Dim_Reason 
SELECT DISTINCT ID_REASON,DESC_REASON FROM `dados`.`urgency_episodes`;

-- Povoar Dim_Destination
INSERT INTO Dim_Destination
SELECT DISTINCT ID_DESTINATION,DESC_DESTINATION FROM `dados`.`urgency_episodes`;

-- Povoar Fact_Diagnosis -> Ainda não dá
INSERT INTO Facto_Diagnosis....;

-- Povoar Dim_Level
INSERT INTO Dim_Level (idLevel,CodLevel,Description) VALUES
1, (SELECT 



DELIMITER //
CREATE PROCEDURE populateDim_Level(level INT)
	BEGIN 
		DECLARE n INT;
        DECLARE i INT;
		SELECT COUNT(*) FROM `dados`.`icd9_hierarchy` INTO n;
        SET i=0;
        WHILE i<n DO
		
			INSERT INTO dim_Body_Camera VALUES (i,(SELECT id FROM fatal_police_shootings_data LIMIT i,1));
                
			insert INTO Dim_Level(idLevel,Cod_Level,Description)
				   VALUES (level,SELECT)
			INSERT INTO dim_Details VALUES (i,(SELECT manner_of_death FROM fatal_police_shootings_data LIMIT i,1),(SELECT armed FROM fatal_police_shootings_data LIMIT i,1),(SELECT flee FROM fatal_police_shootings_data LIMIT i,1));
                
			INSERT INTO dim_Mental_Illness VALUES (i,(SELECT signs_of_mental_illness FROM fatal_police_shootings_data LIMIT i,1));
                
			INSERT INTO dim_Place VALUES (i,(SELECT city FROM fatal_police_shootings_data LIMIT i,1),(SELECT state FROM fatal_police_shootings_data LIMIT i,1));
              
			INSERT INTO dim_Threat_Level (id_dim_Threat_Level,Threat_Levelcol) VALUES (i,(SELECT threat_level FROM fatal_police_shootings_data LIMIT i,1));
                        
            INSERT INTO dim_Victim VALUES (i,(SELECT name FROM fatal_police_shootings_data LIMIT i,1),(SELECT age FROM fatal_police_shootings_data LIMIT i,1),(SELECT gender FROM fatal_police_shootings_data LIMIT i,1),(SELECT race FROM fatal_police_shootings_data LIMIT i,1));
            
            INSERT INTO fact_Fatal_Police_Shootings 
				VALUES((SELECT id FROM fatal_police_shootings_data LIMIT i,1),
						(SELECT newDate FROM fatal_police_shootings_data LIMIT i,1),i,i,i,i,i,i);
                        
			SET i = i+1;
    END WHILE;
	END //
DELIMITER //





