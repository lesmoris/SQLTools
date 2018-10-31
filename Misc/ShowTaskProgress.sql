select 
	percent_complete,
	( (estimated_completion_time/1000) / 60 ) as estimated_completion_minutes_full,
	convert(varchar(5), Round((( (estimated_completion_time/1000) / 60 ) / 60 ), 1)) + ' hour ' + convert(varchar(5), (( (estimated_completion_time/1000) / 60 ) - (Round((( (estimated_completion_time/1000) / 60 ) / 60 ), 1) * 60))) + ' mins ' as estimated_completion_hours_mins,
	DATEADD(MI, ( (estimated_completion_time/1000) / 60 ), CURRENT_TIMESTAMP) as estimated_completion_clocktime
from sys.dm_exec_requests 
where session_id = 91