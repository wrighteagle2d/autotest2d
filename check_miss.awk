BEGIN{
	#file = $0
	current = ""
	while (getline)	
	{
		if ($1 ~ /^0,/)
		{
			if ($2 != "(referee")
			{
				player[$3]
			}
			else
			{
				current = $1	
				for (p in player)
				{
					player[p] = 1
				}
			}
		}
		else if (($1 !~ /^3000,/) && ($1 !~ /^6000,/))
		{
			new = $1 
			#print current
			if (current == new)
			{		
				if ($2 != "(referee")
				{
					 player[$3] = 1
				}
			}
			else
			{
				for (p in player)
				{
					if (player[p] == 0 && p !~ /Coach/)
					{
						print current " " p " missed!"
					}
					else 
					{
						player[p] = 0
					}
				}
				current = new
				if ($2 != "(referee")
				{
					 player[$3] = 1
				}
			}
		}
	}	
}
END{
	print "end"
}

