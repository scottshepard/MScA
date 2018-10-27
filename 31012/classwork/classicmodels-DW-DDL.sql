/***********************************************
** DATA ENGINEERING PLATFORMS (MSCA 31012)
** File: classicmodels-DW-DDL
** Desc: Creation of the dimensional Model
** Auth: Shreenidhi Bharadwaj
** Date: 10/08/2018
************************************************/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ALLOW_INVALID_DATES';
SET SQL_SAFE_UPDATES=0; 

-- -----------------------------------------------------
-- Schema classicmodelsdw
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `classicmodelsdw` DEFAULT CHARACTER SET utf8 ;
USE `classicmodelsdw` ;

-- -----------------------------------------------------
-- Table `classicmodelsdw`.`dimCustomers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`dimCustomers` (
  `customerNumber` INT(11) NOT NULL,
  `customerName` VARCHAR(50) NOT NULL,
  `contactLastName` VARCHAR(50) NOT NULL,
  `contactFirstName` VARCHAR(50) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `addressLine1` VARCHAR(50) NOT NULL,
  `addressLine2` VARCHAR(50) NULL DEFAULT NULL,
  `city` VARCHAR(50) NOT NULL,
  `state` VARCHAR(50) NULL DEFAULT NULL,
  `postalCode` VARCHAR(15) NULL DEFAULT NULL,
  `country` VARCHAR(50) NOT NULL,
  `salesRepEmployeeNumber` INT(11) NULL DEFAULT NULL,
  `creditLimit` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`customerNumber`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `classicmodelsdw`.`dimEmployees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`dimEmployees` (
  `employeeNumber` INT(11) NOT NULL,
  `lastName` VARCHAR(50) NOT NULL,
  `firstName` VARCHAR(50) NOT NULL,
  `extension` VARCHAR(10) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `officeCode` VARCHAR(10) NOT NULL,
  `jobTitle` VARCHAR(50) NOT NULL,
  `reportsTo` int(11) DEFAULT NULL,
  PRIMARY KEY (`employeeNumber`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `classicmodelsdw`.`dimProducts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`dimProducts` (
  `productCode` VARCHAR(15) NOT NULL,
  `productName` VARCHAR(70) NOT NULL,
  `productLine` VARCHAR(50) NOT NULL,
  `productScale` VARCHAR(10) NOT NULL,
  `productVendor` VARCHAR(50) NOT NULL,
  `productDescription` TEXT NOT NULL,
  `quantityInStock` SMALLINT(6) NOT NULL,
  `buyPrice` DECIMAL(10,2) NOT NULL,
  `MSRP` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`productCode`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `classicmodelsdw`.`dimtime`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`dimtime` (
  `dateId` BIGINT(20) NOT NULL,
  `date` DATE NOT NULL,
  `timestamp` BIGINT(20) NULL DEFAULT NULL,
  `weekend` CHAR(10) NOT NULL DEFAULT 'Weekday',
  `day_of_week` CHAR(10) NULL DEFAULT NULL,
  `month` CHAR(10) NULL DEFAULT NULL,
  `month_day` INT(11) NULL DEFAULT NULL,
  `year` INT(11) NULL DEFAULT NULL,
  `week_starting_monday` CHAR(2) NULL DEFAULT NULL,
  PRIMARY KEY (`dateId`),
  UNIQUE INDEX `date` (`date` ASC),
  INDEX `year_week` (`year` ASC, `week_starting_monday` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `classicmodelsdw`.`numbers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`numbers` (
  `number` BIGINT(20) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `classicmodelsdw`.`numbers_small`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`numbers_small` (
  `number` INT(11) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `classicmodelsdw`.`factOrderDetails`
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS `classicmodelsdw`.`factOrderDetails` (
  `orderNumber` INT(11) NOT NULL,
  `productCode` VARCHAR(15) NOT NULL,
  `customerNumber` INT(11) NOT NULL,
  `employeeNumber` INT(11) NOT NULL,
  `dateId` BIGINT(20) NOT NULL,
  `quantityOrdered` INT(11) NULL,
  `priceEach` DOUBLE NULL,
  `status` VARCHAR(15) NULL,
  `orderDate` DATETIME NULL,
  `requiredDate` DATETIME NULL,
  `shippedDate` DATETIME NULL,
  PRIMARY KEY (`orderNumber`, `productCode`),
  INDEX `fk_factOrderDetails_dimProducts_idx` (`productCode` ASC),
  INDEX `fk_factOrderDetails_dimCustomers_idx` (`customerNumber` ASC),
  INDEX `fk_factOrderDetails_dimEmployees_idx` (`employeeNumber` ASC),
  INDEX `fk_factOrderDetails_dimTime_idx` (`dateId` ASC),
  CONSTRAINT `fk_factOrderDetails_dimProducts`
    FOREIGN KEY (`productCode`)
    REFERENCES `classicmodelsdw`.`dimProducts` (`productCode`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_factOrderDetails_dimCustomers`
    FOREIGN KEY (`customerNumber`)
    REFERENCES `classicmodelsdw`.`dimCustomers` (`customerNumber`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_factOrderDetails_dimEmployees`
    FOREIGN KEY (`employeeNumber`)
    REFERENCES `classicmodelsdw`.`dimEmployees` (`employeeNumber`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,    
  CONSTRAINT `fk_factOrderDetails_dimTime`
    FOREIGN KEY (`dateId`)
    REFERENCES `classicmodelsdw`.`dimTime` (`dateId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- END--