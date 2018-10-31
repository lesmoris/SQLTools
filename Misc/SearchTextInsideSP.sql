SELECT DISTINCT
	o.name AS Object_Name,
	o.type_desc
	, m.definition
FROM sys.sql_modules m 
INNER JOIN sys.objects o 
ON m.object_id=o.object_id
WHERE (m.definition Like '%THD_CONTACT%'
or m.definition Like '%PRV_EXECUTIVE_PROVIDER%'
OR m.definition Like '%ADR_ADRESS%')
and o.name in (SELECT
					s.name AS name
					--s.create_date,
					--s.modify_date,
					--OBJECTPROPERTY(s.object_id,'ExecIsQuotedIdentOn') AS IsQuotedIdentOn
				FROM sys.objects s
				WHERE
					s.type IN ('P','TR','V','IF','FN','TF')
					AND OBJECTPROPERTY(s.object_id,'ExecIsQuotedIdentOn') = 0
					OR OBJECTPROPERTY(s.object_id,'ExecIsAnsiNullOn') = 0
					--order by name
					)