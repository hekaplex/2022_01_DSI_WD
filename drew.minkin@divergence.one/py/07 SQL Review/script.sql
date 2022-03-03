CREATE TABLE 
	IF NOT EXISTS user 
		(
			email text
			, first_name text
			, last_name text
			, address text
			, age integer
			, PRIMARY KEY (email)
		)