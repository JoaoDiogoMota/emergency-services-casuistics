-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Urgency_Retencao
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema Urgency_Retencao
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Urgency_Retencao` DEFAULT CHARACTER SET utf8 ;
USE `Urgency_Retencao` ;

-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Color`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Color` (
  `idColor` INT NOT NULL,
  `Description` VARCHAR(8) NOT NULL,
  PRIMARY KEY (`idColor`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Reason`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Reason` (
  `idReason` INT NOT NULL,
  `Description` VARCHAR(33) NOT NULL,
  PRIMARY KEY (`idReason`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Destination`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Destination` (
  `idDestination` INT NOT NULL,
  `Description` VARCHAR(43) NOT NULL,
  PRIMARY KEY (`idDestination`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Level`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Level` (
  `idLevel` INT NOT NULL,
  `Cod_Level` VARCHAR(15) NOT NULL,
  `Description` VARCHAR(250) NOT NULL,
  PRIMARY KEY (`idLevel`, `Cod_Level`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Info` (
  `idInfo` INT NOT NULL AUTO_INCREMENT,
  `Cod_Diagnosis` VARCHAR(45) NOT NULL,
  `Description` VARCHAR(250) NOT NULL,
  `FK_LevelID` INT NOT NULL,
  `FK_LevelCod` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`idInfo`),
  INDEX `fk_Dim_Info_Dim_Level_idx` (`FK_LevelID` ASC, `FK_LevelCod` ASC) VISIBLE,
  CONSTRAINT `fk_Dim_Info_Dim_Level`
    FOREIGN KEY (`FK_LevelID` , `FK_LevelCod`)
    REFERENCES `Urgency_Retencao`.`Dim_Level` (`idLevel` , `Cod_Level`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Date`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Date` (
  `idDate` INT NOT NULL AUTO_INCREMENT,
  `Date` DATETIME NOT NULL,
  PRIMARY KEY (`idDate`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Fact_Diagnosis`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Fact_Diagnosis` (
  `Urg_Episode` INT NOT NULL,
  `Prof_Diagnosis` INT NOT NULL,
  `Prof_Discharge` INT NOT NULL,
  `FK_Date_Diagnosis` INT NOT NULL,
  `FK_Destination` INT NOT NULL,
  `FK_Date_Discharge` INT NOT NULL,
  `FK_Reason` INT NOT NULL,
  `FK_Info` INT NOT NULL,
  PRIMARY KEY (`Urg_Episode`),
  INDEX `fk_Fact_Diagnosis_Dim_Info1_idx` (`FK_Info` ASC) VISIBLE,
  INDEX `fk_Fact_Diagnosis_Dim_Reason1_idx` (`FK_Reason` ASC) VISIBLE,
  INDEX `fk_Fact_Diagnosis_Dim_Destination1_idx` (`FK_Destination` ASC) VISIBLE,
  INDEX `fk_Fact_Diagnosis_Dim_Date1_idx` (`FK_Date_Diagnosis` ASC) VISIBLE,
  INDEX `fk_Fact_Diagnosis_Dim_Date2_idx` (`FK_Date_Discharge` ASC) VISIBLE,
  CONSTRAINT `fk_Fact_Diagnosis_Dim_Info1`
    FOREIGN KEY (`FK_Info`)
    REFERENCES `Urgency_Retencao`.`Dim_Info` (`idInfo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Diagnosis_Dim_Reason1`
    FOREIGN KEY (`FK_Reason`)
    REFERENCES `Urgency_Retencao`.`Dim_Reason` (`idReason`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Diagnosis_Dim_Destination1`
    FOREIGN KEY (`FK_Destination`)
    REFERENCES `Urgency_Retencao`.`Dim_Destination` (`idDestination`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Diagnosis_Dim_Date1`
    FOREIGN KEY (`FK_Date_Diagnosis`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Diagnosis_Dim_Date2`
    FOREIGN KEY (`FK_Date_Discharge`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Fact_Triage`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Fact_Triage` (
  `Urg_Episode` INT NOT NULL,
  `Prof_Triagem` INT NOT NULL,
  `Pain_Scale` INT NOT NULL,
  `FK_Date_Admission` INT NOT NULL,
  `FK_Color` INT NOT NULL,
  PRIMARY KEY (`Urg_Episode`),
  INDEX `fk_Fact_Triage_Dim_Date1_idx` (`FK_Date_Admission` ASC) VISIBLE,
  INDEX `fk_Fact_Triage_Dim_Color1_idx` (`FK_Color` ASC) VISIBLE,
  CONSTRAINT `fk_Fact_Triage_Dim_Date1`
    FOREIGN KEY (`FK_Date_Admission`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Triage_Dim_Color1`
    FOREIGN KEY (`FK_Color`)
    REFERENCES `Urgency_Retencao`.`Dim_Color` (`idColor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Intervention`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Intervention` (
  `idIntervention` INT NOT NULL,
  `Description` VARCHAR(155) NOT NULL,
  PRIMARY KEY (`idIntervention`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_External_Cause`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_External_Cause` (
  `idExternal_Cause` INT NOT NULL,
  `Description` VARCHAR(24) NOT NULL,
  PRIMARY KEY (`idExternal_Cause`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Urgency_Exams`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Urgency_Exams` (
  `idUrgency_Exams` INT NOT NULL AUTO_INCREMENT,
  `Num_Exame` VARCHAR(23) NOT NULL,
  `Description` VARCHAR(104) NOT NULL,
  PRIMARY KEY (`idUrgency_Exams`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Procedure`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Procedure` (
  `idPrescription` INT NOT NULL,
  `Prof_Procedure` INT NOT NULL,
  `Prof_Cancel` INT NOT NULL,
  `Canceled` INT NOT NULL,
  `FK_Date_Prescription` INT NOT NULL,
  `FK_Date_Begin` INT NOT NULL,
  `FK_Intervention` INT NOT NULL,
  PRIMARY KEY (`idPrescription`),
  INDEX `fk_Dim_Procedure_Dim_Intervention1_idx` (`FK_Intervention` ASC) VISIBLE,
  INDEX `fk_Dim_Procedure_Dim_Date1_idx` (`FK_Date_Prescription` ASC) VISIBLE,
  INDEX `fk_Dim_Procedure_Dim_Date2_idx` (`FK_Date_Begin` ASC) VISIBLE,
  CONSTRAINT `fk_Dim_Procedure_Dim_Intervention1`
    FOREIGN KEY (`FK_Intervention`)
    REFERENCES `Urgency_Retencao`.`Dim_Intervention` (`idIntervention`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Dim_Procedure_Dim_Date1`
    FOREIGN KEY (`FK_Date_Prescription`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Dim_Procedure_Dim_Date2`
    FOREIGN KEY (`FK_Date_Begin`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_District`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_District` (
  `idDistrict` INT NOT NULL AUTO_INCREMENT,
  `District` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`idDistrict`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Patient` (
  `idPatient` INT NOT NULL AUTO_INCREMENT,
  `Sex` VARCHAR(1) NOT NULL,
  `FK_Date_Of_Birth` INT NOT NULL,
  `FK_District` INT NOT NULL,
  PRIMARY KEY (`idPatient`),
  INDEX `fk_Dim_Patient_Dim_Date1_idx` (`FK_Date_Of_Birth` ASC) VISIBLE,
  INDEX `fk_Dim_Patient_Dim_District1_idx` (`FK_District` ASC) VISIBLE,
  CONSTRAINT `fk_Dim_Patient_Dim_Date1`
    FOREIGN KEY (`FK_Date_Of_Birth`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Dim_Patient_Dim_District1`
    FOREIGN KEY (`FK_District`)
    REFERENCES `Urgency_Retencao`.`Dim_District` (`idDistrict`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Drug` (
  `idDrug` INT NOT NULL AUTO_INCREMENT,
  `Cod_Drug` INT NOT NULL,
  `Description` VARCHAR(227) NOT NULL,
  PRIMARY KEY (`idDrug`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Dim_Urgency_Prescription`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Dim_Urgency_Prescription` (
  `idUrgency_Prescription` INT NOT NULL AUTO_INCREMENT,
  `Cod_Prescription` INT NOT NULL,
  `Prof_Prescription` INT NOT NULL,
  `FK_Date_Prescription` INT NOT NULL,
  PRIMARY KEY (`idUrgency_Prescription`),
  INDEX `fk_Dim_Urgency_Prescription_Dim_Date1_idx` (`FK_Date_Prescription` ASC) VISIBLE,
  CONSTRAINT `fk_Dim_Urgency_Prescription_Dim_Date1`
    FOREIGN KEY (`FK_Date_Prescription`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Prescription_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Prescription_Drug` (
  `Urgency_Prescription` INT NOT NULL,
  `Drug` INT NOT NULL,
  `Quantity` INT NOT NULL,
  PRIMARY KEY (`Urgency_Prescription`, `Drug`, `Quantity`),
  INDEX `fk_Dim_Urgency_Prescription_has_Dim_Drug_Dim_Drug1_idx` (`Drug` ASC) VISIBLE,
  INDEX `fk_Dim_Urgency_Prescription_has_Dim_Drug_Dim_Urgency_Prescr_idx` (`Urgency_Prescription` ASC) VISIBLE,
  CONSTRAINT `fk_Dim_Urgency_Prescription_has_Dim_Drug_Dim_Urgency_Prescrip1`
    FOREIGN KEY (`Urgency_Prescription`)
    REFERENCES `Urgency_Retencao`.`Dim_Urgency_Prescription` (`idUrgency_Prescription`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Dim_Urgency_Prescription_has_Dim_Drug_Dim_Drug1`
    FOREIGN KEY (`Drug`)
    REFERENCES `Urgency_Retencao`.`Dim_Drug` (`idDrug`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Urgency_Retencao`.`Fact_Urgency_Episodes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Urgency_Retencao`.`Fact_Urgency_Episodes` (
  `Urg_Episode` INT NOT NULL,
  `Prof_Admission` INT NOT NULL,
  `FK_Patient` INT NOT NULL,
  `FK_Date_Admission` INT NOT NULL,
  `FK_External_Cause` INT NOT NULL,
  `FK_Urgency_Exams` INT NOT NULL,
  `FK_Procedure` INT NOT NULL,
  `FK_Urgency_Prescription` INT NOT NULL,
  PRIMARY KEY (`Urg_Episode`, `FK_Urgency_Exams`, `FK_Procedure`, `FK_Urgency_Prescription`),
  INDEX `fk_Fact_Urgency_Episodes_Dim_Patient1_idx` (`FK_Patient` ASC) VISIBLE,
  INDEX `fk_Fact_Urgency_Episodes_Dim_Date1_idx` (`FK_Date_Admission` ASC) VISIBLE,
  INDEX `fk_Fact_Urgency_Episodes_Dim_External_Cause1_idx` (`FK_External_Cause` ASC) VISIBLE,
  INDEX `fk_Fact_Urgency_Episodes_Dim_Urgency_Exams1_idx` (`FK_Urgency_Exams` ASC) VISIBLE,
  INDEX `fk_Fact_Urgency_Episodes_Dim_Procedure1_idx` (`FK_Procedure` ASC) VISIBLE,
  INDEX `fk_Fact_Urgency_Episodes_Dim_Urgency_Prescription1_idx` (`FK_Urgency_Prescription` ASC) VISIBLE,
  CONSTRAINT `fk_Fact_Urgency_Episodes_Dim_Patient1`
    FOREIGN KEY (`FK_Patient`)
    REFERENCES `Urgency_Retencao`.`Dim_Patient` (`idPatient`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Urgency_Episodes_Dim_Date1`
    FOREIGN KEY (`FK_Date_Admission`)
    REFERENCES `Urgency_Retencao`.`Dim_Date` (`idDate`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Urgency_Episodes_Dim_External_Cause1`
    FOREIGN KEY (`FK_External_Cause`)
    REFERENCES `Urgency_Retencao`.`Dim_External_Cause` (`idExternal_Cause`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Urgency_Episodes_Dim_Urgency_Exams1`
    FOREIGN KEY (`FK_Urgency_Exams`)
    REFERENCES `Urgency_Retencao`.`Dim_Urgency_Exams` (`idUrgency_Exams`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Urgency_Episodes_Dim_Procedure1`
    FOREIGN KEY (`FK_Procedure`)
    REFERENCES `Urgency_Retencao`.`Dim_Procedure` (`idPrescription`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Fact_Urgency_Episodes_Dim_Urgency_Prescription1`
    FOREIGN KEY (`FK_Urgency_Prescription`)
    REFERENCES `Urgency_Retencao`.`Dim_Urgency_Prescription` (`idUrgency_Prescription`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
