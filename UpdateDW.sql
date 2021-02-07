use urgency_retencao;

call InserirDimDate();

call InserirDim_Color();
call InserirFact_Triage();

call InserirDimReason();
call InserirDimDestination();
call InserirDim_Info();
call InserirFact_Diagnosis();

call InserirDimDistrict();
call inserirDim_Patient();
call InserirDimDrug();
call InserirDim_Urgency_Exams();
call InserirDimExternal_Cause();
call InserirDimIntervention();
call InserirDim_Procedures();
call InserirUrency_Prescriptions();
call inserirPrescription_Drug();
call InserirFact_Episodes();

DELETE FROM fact_triage;
DELETE FROM Dim_Color;

DELETE FROM Fact_Diagnosis;
DELETE FROM Dim_Info;
DELETE FROM Dim_Destination;
DELETE FROM Dim_Reason;

DELETE FROM Fact_Urgency_Episodes;
DELETE FROM Prescription_Drug;
DELETE FROM Dim_Urgency_Prescription;
DELETE FROM Dim_Procedure; 
DELETE FROM Dim_Dim_Intervention;
DELETE FROM Dim_External_Cause;
DELETE FROM Dim_Urgency_Exams;
DELETE FROM Dim_Drug;
DELETE FROM Dim_Patient;
DELETE FROM Dim_District;
DELETE FROM Dim_Date;


