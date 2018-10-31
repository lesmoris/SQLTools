use msdb
GO

if exists (select 1 from sys.objects where type = 'P' and name = 'DBM_Trace_Stop' and schema_id = 1)
	drop procedure dbo.DBM_Trace_Stop
GO

create procedure [dbo].[DBM_Trace_Stop]
as

declare
	@TraceDirectory nvarchar(245),	-- chemin complet du répertoire LOG
	@key nvarchar(500)

-- Recuperation du chemin complet du répertoire LOG (en SQL 2005)
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

set @TraceFile = @TraceDirectory + convert(nvarchar(128), isnull(serverproperty('InstanceName'), '')) + '$DBM_Queries_And_Locks%.trc'

select @TraceId = id, @TraceStatus = status
from sys.traces
where path like @TraceFile

-- Arrêt et suppression de la trace
if @TraceId is not null
begin
	exec sp_trace_setstatus @TraceId, 0
	exec sp_trace_setstatus @TraceId, 2
end
