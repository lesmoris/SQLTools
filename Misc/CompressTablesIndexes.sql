-- EXEC sp_estimate_data_compression_savings 'dbo', 'CAS_CASE', NULL, NULL, 'PAGE' ;
-- SCRIPT TO COMPRESS ALL TABLES AND INDEXES FROM A DB

-- TABLES
declare 
	@schema nvarchar(50),
	@table  nvarchar(250)
    
declare tables_cursor cursor for 
select ss.name, st.name from sys.tables st
inner join sys.schemas ss on ss.schema_id = st.schema_id

open tables_cursor

fetch next from tables_cursor 
into @schema, @table

while @@fetch_status = 0
begin

	print 'Compressing table ' + @schema + '.' + @table + '...'
	exec ('ALTER TABLE [' + @schema + ']'+ '.' + '[' + @table + ']' + ' REBUILD WITH (DATA_COMPRESSION=PAGE);')
	
	fetch next from tables_cursor 
    into @schema, @table
end 
close tables_cursor;
deallocate tables_cursor;

print 'Done Compressing Tables!'

go

-- INDEXES
declare 
	@schema nvarchar(50),
	@table  nvarchar(250),
	@index  nvarchar(250)
    
declare indexes_cursor cursor for 
select ss.name, st.name, si.name from sys.indexes si
inner join sys.tables st on st.object_id = si.object_id
inner join sys.schemas ss on ss.schema_id = st.schema_id
where si.type != 0 -- Exclude HEAPs

open indexes_cursor

fetch next from indexes_cursor 
into @schema, @table, @index

while @@fetch_status = 0
begin

	print 'Compressing index ' + @table + '.' + @index + '...'
	exec ('ALTER INDEX ' + @index + ' ON ' + @schema + '.' + @table + ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);')
		
	fetch next from indexes_cursor 
	into @schema, @table, @index
end 
close indexes_cursor;
deallocate indexes_cursor;

print 'Done Compressing Indexes!'
go

