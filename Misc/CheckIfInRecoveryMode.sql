SELECT name, recovery_model_desc
   FROM sys.databases
      WHERE name = 'XXXX' ;
GO

USE master;
ALTER DATABASE XXXX SET RECOVERY SIMPLE;