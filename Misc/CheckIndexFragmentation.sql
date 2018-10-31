--SELECT [name],[dbid] FROM [master].[dbo].[sysdatabases] ORDER BY [name] 

declare @databaseID int
select @databaseID = 6 

SELECT 
	dbschemas.[name] as 'Schema', 
	dbtables.[name] as 'Table', 
	dbindexes.[name] as 'Index',
	indexstats.avg_fragmentation_in_percent,
	indexstats.page_count
FROM sys.dm_db_index_physical_stats (@databaseID, NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = @databaseID
ORDER BY indexstats.avg_fragmentation_in_percent desc

