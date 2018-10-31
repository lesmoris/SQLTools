--select * from sys.traces
select * from fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL10_50.INTEGRATION\MSSQL\LOG\INTEGRATION$DBM_Logins.trc', default)
