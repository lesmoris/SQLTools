begin tran

	-- Initial SetUp
	create table temp_leo (
		id int primary key identity(1,1),
		description	varchar(50)
	)

	insert into temp_leo values ('Desc1'), ('Desc2'), ('Desc3')
	
	-- Insert new IDs and get the old ones
	select * from temp_leo 

	declare @temp table (id int)

	insert into @temp values (2),(3)

	declare @output table (id_old int, id_new int)

	MERGE
		temp_leo AS target
	USING (
			SELECT
				  tl.id
				, Description
			FROM
			temp_leo tl
			inner join @temp t on t.id = tl.id
	) AS source ON (1 = 0)  
	WHEN NOT MATCHED   
	THEN INSERT (Description) VALUES (Description)
	OUTPUT inserted.ID, source.ID INTO @output;
	
	select * from temp_leo 
	
	select * from @output

	drop table temp_leo

rollback