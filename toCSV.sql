USE urgency_retencao;

SELECT DISTINCT a1.Urg_Episode, a2.Num_Exame, a2.Description 
FROM Fact_Urgency_Episodes a1
INNER JOIN Dim_Urgency_Exams a2
	ON a1.FK_Urgency_Exams = a2.idUrgency_Exams
INTO OUTFILE 'exams.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ';'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT DISTINCT a1.Urg_Episode, a4.Quantity, a2.Prof_Prescription, a3.Date , a5.Description, a2.Cod_Prescription, a5.Cod_Drug
FROM Fact_Urgency_Episodes a1
INNER JOIN Dim_Urgency_Prescription a2
	ON a1.FK_Urgency_Prescription = a2.idUrgency_Prescription
INNER JOIN Dim_Date a3
	ON a2.FK_Date_Prescription = a3.idDate
INNER JOIN Prescription_Drug a4
	ON a2.idUrgency_Prescription = a4.Urgency_Prescription
INNER JOIN Dim_Drug a5
	ON a4.Drug = a5.idDrug
INTO OUTFILE 'prescriptions.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ';'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT DISTINCT a1.Urg_Episode, a2.Prof_Cancel, a2.Prof_Procedure, a2.idPrescription, a3.idIntervention, a4.Date, a2.Canceled, a5.Date, a3.Description
FROM Fact_Urgency_Episodes a1
INNER JOIN Dim_Procedure a2
	ON a1.FK_Procedure = a2.idPrescription
INNER JOIN Dim_Intervention a3
	ON a2.FK_Intervention = a3.idIntervention
INNER JOIN Dim_Date a4 
	ON a2.FK_Date_Prescription = a4.idDate
INNER JOIN Dim_Date a5
	ON a2.FK_Date_Begin = a5.idDate
INTO OUTFILE 'procedures.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ';'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT DISTINCT a1.Urg_Episode, a3.Date, a2.Sex, a4.District, a5.Date, a6.idExternal_Cause, a6.Description, a1.Prof_Admission, t2.Date, t1.Prof_Triagem, t1.Pain_Scale,
				t3.idColor, t3.Description, d2.Cod_Diagnosis, d2.Description, d3.Date, d1.Prof_Diagnosis, d4.idDestination, d4.Description, d1.Prof_Discharge,
                d5.Date, d6.idReason, d6.Description
FROM Fact_Urgency_Episodes a1
INNER JOIN Dim_Patient a2
	ON a1.FK_Patient = a2.idPatient
INNER JOIN Dim_Date a3
	ON a2.FK_Date_Of_Birth = a3.idDate
INNER JOIN Dim_District a4
	ON a2.FK_District = a4.idDistrict
INNER JOIN Dim_Date a5
	ON a1.FK_Date_Admission = a5.idDate
INNER JOIN Dim_External_Cause a6
	ON a1.FK_External_Cause = a6.idExternal_Cause
INNER JOIN Fact_Triage t1
	ON a1.Urg_Episode = t1.Urg_Episode
INNER JOIN Dim_Date t2 
	ON t1.FK_Date_Admission = t2.idDate
INNER JOIN Dim_Color t3
	ON t1.FK_Color = t3.idColor
INNER JOIN Fact_Diagnosis d1
	ON a1.Urg_Episode = d1.Urg_Episode
INNER JOIN Dim_Info d2
	ON d1.FK_Info = d2.idInfo
INNER JOIN Dim_Date d3
	ON d1.FK_Date_Diagnosis = d3.idDate
INNER JOIN Dim_Destination d4
	ON d1.FK_Destination = d4.idDestination
INNER JOIN Dim_Date d5
	ON d1.FK_Date_Discharge = d5.idDate
INNER JOIN Dim_Reason d6
	ON d1.FK_Reason = d6.idReason
INTO OUTFILE 'episodes.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ';'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';