use msdb
go
if exists (select 1 from sys.objects where type = 'FN' and name = 'DBM_GetInstanceLabel' and schema_id = 1)
	drop function dbo.DBM_GetInstanceLabel
go
/*
	Nom			: DBM_GetInstanceLabel
	Fonction	: Cette UDF permet de récupérer le label (MSSQL.1, MSSQL.2, MSSQL.3...)
	 			  correspondant à un type d'instance donné (SQL, OLAP ou RS)

	Historique des modifications :
		Date		Intervenant	Version		Detail des modifications
		----------	-----------	-------		------------------------
		2008/07/31	GCO			1			Creation
*/
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
