-- =============================================
-- Script: Setup Environment for DataWarehouse
-- Description: !!Drops!! and recreates the DataWarehouse database
--              with bronze, silver, and gold schemas
-- =============================================


USE master;
GO

-- Drop and recreate the 'DataWarehoue' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
