BEGIN {
	game_count = 0;
	win = 0;
	draw = 0;
	lost = 0;
}

{
	game_count += 1;
	l_score = $2;
	r_score = $4;

	if ( l_score > r_score)
	{
		win += 1;
	}
	else if ( r_score > l_score )
	{
		lost += 1;
	}
	else
	{
		draw += 1;
	}

	win_rate = win / game_count;
	lost_rate = lost / game_count;
	expected_win_rate = win_rate / (win_rate + lost_rate);

	print game_count, win_rate, expected_win_rate;
}
