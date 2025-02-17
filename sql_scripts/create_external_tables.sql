-- Ensure the correct database context
SELECT DB_NAME() AS CurrentDatabase;
GO

-- Create Master Key if it doesn’t exist (Required for encryption)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword123!';
END
GO

-- Create Database Scoped Credential for Azure Data Lake Storage (ADLS) Gen2
IF NOT EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'ADLS_credential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL ADLS_credential
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
    SECRET = 'Your_SAS_Token_Here';  -- Replace with actual SAS token
END
GO

-- Create External Data Source for ADLS Gen2
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'AzureDataLakeStore')
BEGIN
    CREATE EXTERNAL DATA SOURCE AzureDataLakeStore
    WITH 
    (
        LOCATION = 'abfss://<container-name>@<storage-account-name>.dfs.core.windows.net/', -- Replace with your storage details
        CREDENTIAL = ADLS_credential,
        TYPE = HADOOP
    );
END
GO

-- Create External File Format for Parquet
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'parquet_file_format')
BEGIN
    CREATE EXTERNAL FILE FORMAT parquet_file_format
    WITH 
    (
        FORMAT_TYPE = PARQUET,
        DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
    );
END
GO

-- Drop and create external table for Teams Data
IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'teams')
    DROP EXTERNAL TABLE teams;
GO

CREATE EXTERNAL TABLE teams
(
    TeamName      VARCHAR(200),
    Discipline    VARCHAR(200),
    Country       VARCHAR(200),
    Total_Events  INT
)
WITH 
(
    LOCATION = 'teams',
    DATA_SOURCE = AzureDataLakeStore,
    FILE_FORMAT = parquet_file_format
);
GO

-- Drop and create external table for Medals Data
IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'medals')
    DROP EXTERNAL TABLE medals;
GO

CREATE EXTERNAL TABLE medals
(
    Rank            VARCHAR(50),
    Team_Country    VARCHAR(100),
    Gold            INT,
    Silver          INT,
    Bronze          INT,
    Total           INT,
    Rank_by_Total   INT,
    Rank_By_Gold    INT,
    Rank_By_Silver  INT,
    Rank_By_Bronze  INT
)
WITH 
(
    LOCATION = 'medals',
    DATA_SOURCE = AzureDataLakeStore,
    FILE_FORMAT = parquet_file_format
);
GO

-- Drop and create external table for Athletes Data
IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'athletes')
    DROP EXTERNAL TABLE athletes;
GO

CREATE EXTERNAL TABLE athletes
(
    PersonName  VARCHAR(200),
    Country     VARCHAR(100),
    Discipline  VARCHAR(150)
)
WITH 
(
    LOCATION = 'athletes',
    DATA_SOURCE = AzureDataLakeStore,
    FILE_FORMAT = parquet_file_format
);
GO

-- Drop and create external table for Entries by Gender
IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'entries_gender')
    DROP EXTERNAL TABLE entries_gender;
GO

CREATE EXTERNAL TABLE entries_gender
(
    Discipline VARCHAR(150),
    Female     INT,
    Male       INT,
    Total      INT
)
WITH 
(
    LOCATION = 'entriesgender',
    DATA_SOURCE = AzureDataLakeStore,
    FILE_FORMAT = parquet_file_format
);
GO

-- Drop and create external table for Coaches Data
IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'coaches')
    DROP EXTERNAL TABLE coaches;
GO

CREATE EXTERNAL TABLE coaches
(
    Name       VARCHAR(150),
    Country    VARCHAR(100),
    Discipline VARCHAR(150),
    Event      VARCHAR(200)
)
WITH 
(
    LOCATION = 'coaches',
    DATA_SOURCE = AzureDataLakeStore,
    FILE_FORMAT = parquet_file_format
);
GO

-- Verify External Tables
SELECT * FROM sys.external_tables;

-- Create a schema for views if it doesn’t exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'vw')
    EXEC('CREATE SCHEMA vw');
GO

-- Create a view for the teams table
CREATE VIEW vw.teams AS
SELECT 
    TeamName, 
    Discipline, 
    Country, 
    Total_Events
FROM dbo.teams;
GO

-- Create a view for the medals table
CREATE VIEW vw.medals AS
SELECT 
    Rank, 
    Team_Country, 
    Gold,
    Silver,
    Bronze,
    Total,
    Rank_by_Total,
    Rank_By_Gold,
    Rank_By_Silver,
    Rank_By_Bronze
FROM dbo.medals;
GO

-- Create a view for the athletes table
CREATE VIEW vw.athletes AS
SELECT 
    PersonName, 
    Country, 
    Discipline
FROM dbo.athletes;
GO

-- Create a view for the entries_gender table
CREATE VIEW vw.entries_gender AS
SELECT 
    Discipline, 
    Female, 
    Male, 
    Total
FROM dbo.entries_gender;
GO

-- Create a view for the coaches table
CREATE VIEW vw.coaches AS
SELECT 
    Name, 
    Country, 
    Discipline, 
    Event
FROM dbo.coaches;
GO
