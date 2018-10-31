use msdb
go
if exists (select 1 from sys.objects where type = 'P' and name = 'DBM_Trace_Create' and schema_id = 1)
	drop procedure dbo.DBM_Trace_Create
go

create procedure [dbo].[DBM_Trace_Create](
	@TraceDirectory nvarchar(245),	-- chemin complet du répertoire LOG
	@MaxFileSize bigint,			-- taille maxi d'un fichier
	@FileCount int,					-- nb max de fichier conservés par le rollover
	@MinDuration bigint,				-- filtre de la trace : Duration > @MinDuration (en micro-secondes)
	@TraceID int OUTPUT
)
as

declare
	@rc int,
	@TraceFile nvarchar(245)

-- Construction du nom du fichier de trace.
-- Il est prefixé par le nom de l'instance
set @TraceFile = @TraceDirectory + convert(nvarchar(128), isnull(serverproperty('InstanceName'), '')) + '$DBM_Queries_And_Locks'

exec @rc = sp_trace_create
 @traceid		= @TraceID output,
 @options		= 2,				-- active le rollover
 @tracefile		= @TraceFile,		-- nom du fichier de trace
 @maxfilesize	= @MaxFileSize,		-- taille maxi d'un fichier
 @stoptime		= NULL,
 @filecount		= @FileCount		-- nb max de fichier conservés par le rollover
if @rc <> 0 return

-- Definitions des évènements et des colonnes qui vont composer la trace
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
		e.name in (	'SQL:StmtCompleted', 'Lock:Acquired', 'SP:StmtCompleted', 'SQL:BatchCompleted', 'RPC:Completed')
		--e.name in (	'Audit Login')
	and
		c.name in (	'EventSequence', 'TextData', 'DatabaseID', 'TransactionID', 'LineNumber', 'HostName',
					'ApplicationName', 'LoginName', 'SPID', 'Duration', 'StartTime', 'EndTime',
					'Reads', 'Writes', 'CPU', 'ObjectID', 'EventClass', 'NestLevel', 'Mode',
					'ObjectName', 'RowCounts', 'ObjectID2', 'Type', 'IsSystem', 'SessionLoginName')
					--'ObjectName', 'RowCounts', 'ObjectID2', 'Type', 'IsSystem', 'SessionLoginName', 'DatabaseName')

open c_trace_detail

fetch c_trace_detail into @eventid, @columnid

while (@@fetch_status = 0)  
begin
	exec sp_trace_setevent @TraceID, @eventid, @columnid, @on
	fetch c_trace_detail into @eventid, @columnid
end

close c_trace_detail
deallocate c_trace_detail


-- Mise en place du filtre sur la colonne Duration : Duration >= @MinDuration
exec sp_trace_setfilter
	@TraceID,
	13,				-- Colonne		:	Duration
	0,
	4,				-- Opérateur	:	>=
	@MinDuration	-- Valeur		:	@MinDuration
GO
