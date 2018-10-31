SELECT
	(CASE ic.key_ordinal 
		WHEN 0 THEN CAST(1 AS tinyint) 
		ELSE ic.key_ordinal 
	 END) AS [ID],
	clmns.name AS [Name],
	CAST(COLUMNPROPERTY(ic.object_id, clmns.name, N'IsComputed') AS bit) AS [IsComputed],
	ic.is_descending_key AS [Descending],
	ic.is_included_column AS [IsIncluded]
FROM sys.tables AS tbl
   INNER JOIN sys.indexes AS i 
      ON (i.index_id > 0 AND i.is_hypothetical = 0) AND (i.object_id = tbl.object_id)
   INNER JOIN sys.index_columns AS ic 
      ON (ic.column_id > 0 AND (ic.key_ordinal > 0 OR ic.partition_ordinal = 0 OR ic.is_included_column != 0)) 
         AND (ic.index_id = CAST(i.index_id AS int) AND ic.object_id = i.object_id)
   INNER JOIN sys.columns AS clmns 
   ON clmns.object_id = ic.object_id AND clmns.column_id = ic.column_id
where ic.is_included_column = 1
--AND (i.name = N'[MyIndex]') AND ((tbl.name = N'[MyTable]')
ORDER BY IsIncluded, [ID] ASC

