use msdb
go

declare
	@TraceDirectory nvarchar(245),	
	@key nvarchar(500)

set @key = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + dbo.DBM_GetInstanceLabel('SQL') + '\CPE'

exec master..xp_regread
	@rootkey	= 'HKEY_LOCAL_MACHINE',
	@key		= @key,
	@value_name	= 'ErrorDumpDir',
	@value		= @TraceDirectory OUTPUT

declare
	@TraceFile nvarchar(245),
	@TraceId int,
	@TraceStatus int

set @TraceFile = @TraceDirectory + convert(nvarchar(128), isnull(serverproperty('InstanceName'), '')) + '$DBM_Logins%.trc'

select @TraceId = id, @TraceStatus = status
from sys.traces
where path like @TraceFile

if @TraceId is not null
begin
	exec sp_trace_setstatus @TraceId, 0
	exec sp_trace_setstatus @TraceId, 2
end
go

if exists (select 1 from sys.objects where type = 'FN' and name = 'DBM_GetInstanceLabel' and schema_id = 1)
	drop function dbo.DBM_GetInstanceLabel
go
