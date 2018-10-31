use msdb
go

if exists (select 1 from sys.objects where type = 'FN' and name = 'DBM_GetInstanceLabel' and schema_id = 1)
	drop function dbo.DBM_GetInstanceLabel
go

create function dbo.DBM_GetInstanceLabel(
	@InstanceType varchar(4)
)
returns nvarchar(255)
as
begin
	if @InstanceType not in ('OLAP', 'RS', 'SQL')
	begin
		return null
	end

	declare @key nvarchar(255), @value_name nvarchar(255), @return nvarchar(255)

	set @key = N'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\' + @InstanceType
	set @value_name = isnull(convert(nvarchar(128), serverproperty('InstanceName')), N'MSSQLSERVER')

	exec master..xp_regread
		@rootkey	= 'HKEY_LOCAL_MACHINE',
		@key		= @key,
		@value_name	= @value_name,
		@value		= @return OUTPUT

	return @return
end
go

declare
	@rc int,

	@TraceFile		nvarchar(245),
	@TraceDirectory nvarchar(245),	
	@TraceId		int,
	@TraceStatus	int,

	@MaxFileSize	bigint,			
	@FileCount		int,			
	@key			nvarchar(500),	
	@filterValue	nvarchar(255)	
	
select
	@key = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + dbo.DBM_GetInstanceLabel('SQL') + '\CPE', 
	@filterValue = '%read committed%'
	
exec master..xp_regread
	@rootkey	= 'HKEY_LOCAL_MACHINE',
	@key		= @key,
	@value_name	= 'ErrorDumpDir',
	@value		= @TraceDirectory OUTPUT

select
	@MaxFileSize	= 50,			
	@FileCount		= 20,			
	@TraceFile = @TraceDirectory + convert(nvarchar(128), isnull(serverproperty('InstanceName'), '')) + '$DBM_Logins'

select	
	@TraceId = id, 
	@TraceStatus = status
from sys.traces
where path like @TraceFile + '%.trc'

if @TraceId is not null
begin
	exec sp_trace_setstatus @TraceId, 0
	exec sp_trace_setstatus @TraceId, 2
end

exec @rc = sp_trace_create
 @traceid		= @TraceID output,
 @options		= 2,				
 @tracefile		= @TraceFile,		
 @maxfilesize	= @MaxFileSize,		
 @stoptime		= NULL,
 @filecount		= @FileCount		

if @rc <> 0 return -- error

declare @on bit
declare @eventid int, @columnid int
set @on = 1

declare c_trace_detail cursor LOCAL STATIC READ_ONLY for
	select
			e.trace_event_id, c.trace_column_id
	from
			sys.trace_events e
			cross join sys.trace_columns c
	where
		e.name in (	'Audit Login')
	and
		c.name in (	'EventSequence', 'TextData', 'DatabaseID', 'HostName',
					'ApplicationName', 'LoginName', 'SPID', 'StartTime',
					'IsSystem', 'SessionLoginName', 'DatabaseName', 'ClientProcessId' )

open c_trace_detail

fetch c_trace_detail into @eventid, @columnid

while (@@fetch_status = 0)  
begin
	exec sp_trace_setevent @TraceID, @eventid, @columnid, @on
	fetch c_trace_detail into @eventid, @columnid
end

close c_trace_detail
deallocate c_trace_detail

exec sp_trace_setfilter
	@TraceID,
	1,					-- Column		:	TextData
	0,
	7,					-- Operator		:	NOT LIKE
	@filterValue		-- Value		:  '%read committed%'

exec sp_trace_setstatus @TraceId, 1
GO