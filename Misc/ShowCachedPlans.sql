SELECT sql, cacheobjtype, usecounts
FROM master..syscacheobjects sco 
inner join sys.objects so on so.object_id = sco.objid
WHERE name = 'PROC1_TEST'

SELECT *
FROM sys.dm_exec_cached_plans
OUTER APPLY sys.dm_exec_query_plan(plan_handle)
WHERE objectid = object_id('PROC1_TEST')

SELECT *
FROM sys.dm_exec_plan_attributes(0x05000600B048170A40E1B2C3010000000000000000000000)

DECLARE @set_options_value INT = 4345
PRINT 'Set options for value 4345:'
IF @set_options_value & 1 = 1 PRINT 'ANSI_PADDING'
IF @set_options_value & 2 = 1 PRINT 'Parallel Plan'
IF @set_options_value & 4 = 4 PRINT 'FORCEPLAN'
IF @set_options_value & 8 = 8 PRINT 'CONCAT_NULL_YIELDS_NULL'
IF @set_options_value & 16 = 16 PRINT 'ANSI_WARNINGS'
IF @set_options_value & 32 = 32 PRINT 'ANSI_NULLS'
IF @set_options_value & 64 = 64 PRINT 'QUOTED_IDENTIFIER'
IF @set_options_value & 128 = 128 PRINT 'ANSI_NULL_DFLT_ON'
IF @set_options_value & 256 = 256 PRINT 'ANSI_NULL_DFLT_OFF'
IF @set_options_value & 512 = 512 PRINT 'NoBrowseTable'
IF @set_options_value & 1024 = 1024 PRINT 'TriggerOneRow'
IF @set_options_value & 2048 = 2048 PRINT 'ResyncQuery'
IF @set_options_value & 4096 = 4096 PRINT 'ARITHABORT'
IF @set_options_value & 8192 = 8192 PRINT 'NUMERIC_ROUNDABORT'
IF @set_options_value & 16384 = 16384 PRINT 'DATEFIRST'
IF @set_options_value & 32768 = 32768 PRINT 'DATEFORMAT'
IF @set_options_value & 65536 = 65536 PRINT 'LanguageId'
IF @set_options_value & 131072 = 131072 PRINT 'UPON'