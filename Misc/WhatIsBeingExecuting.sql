SELECT 
	sql_handle, 
	(select text from sys.dm_exec_sql_text(sql_handle))
	,* 
FROM sys.dm_exec_requests 
where sql_handle is not null

select
	r.status,
	r.blocking_session_id,
	r.wait_type,
	r.wait_time,
	r.wait_resource,
	r.total_elapsed_time/1000 as 'total_elapsed_time (s)',
	(r.total_elapsed_time/1000)/60 as 'total_elapsed_time (m)',
	substring(t.text, r.statement_start_offset/2, case when r.statement_end_offset = -1 then datalength(t.text) else r.statement_end_offset/2  - r.statement_start_offset/2 + 1 end) as 'Current running statement'
	--,t.text
from sys.dm_exec_requests r
cross apply sys.dm_exec_sql_text(r.sql_handle) t
where r.session_id = 55

-- OPEN TRXs

SELECT * 
	FROM sys.dm_tran_session_transactions tst INNER JOIN sys.dm_exec_connections ec ON tst.session_id = ec.session_id
	CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle)