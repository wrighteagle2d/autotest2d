BEGIN {
	l_goals = 0;
	r_goals = 0;
	l_points = 0;
	r_points = 0;
	game_count = 0;
	win = 0;
	lost = 0;
	draw = 0;

	print "No.\tScore\tPoint";
}

{
	game_count += 1;
	l_score = $2;
	r_score = $4;
	l_point = 0;
	r_point = 0;

	if ( l_score > r_score)
	{
		l_point += 3;
		win += 1;
	}
	else if ( r_score > l_score )
	{
		r_point += 3;
		lost += 1;
	}
	else
	{
		l_point += 1;
		r_point += 1;
		draw += 1;
	}

	l_goals += l_score;
	r_goals += r_score;
	l_points += l_point;
	r_points += r_point;

	print game_count "\t" l_score ":" r_score "\t" l_point ":" r_point;
}

END {
	print "\n";
	print "Goals:  " l_goals " : " r_goals " (diff: " l_goals - r_goals")";
	print "Points: " l_points " : "  r_points " (diff: " l_points - r_points")";

	avg_l_goals = l_goals / game_count;
	avg_r_goals = r_goals / game_count;
	avg_l_points = l_points / game_count;
	avg_r_points = r_points / game_count;

	print "Avg Goals:  " avg_l_goals " : " avg_r_goals " (diff: " avg_l_goals - avg_r_goals")";
	print "Avg Points: " avg_l_points " : "  avg_r_points " (diff: " avg_l_points - avg_r_points")";

	win_rate = win / game_count;
	lost_rate = lost / game_count;
	draw_rate = draw / game_count;
	expected_win_rate = win_rate + draw_rate * win_rate;

	print "Left Team: Win " win, "Draw " draw, "Lost " lost;
	print "Left Team: WinRate " percentage(win_rate) "%", "ExpectedWinRate " percentage(expected_win_rate) "%";
}

function percentage(x)
{
	return (int((x * 100000 + 5) / 10)) / 100;
}

function max(a, b)
{
	if (a > b)
	{
		return a;
	}
	else
	{
		return b;
	}
}

function abs(a)
{
	if (a > 0)
	{
		return a;
	}
	else
	{
		return -a;
	}
}
