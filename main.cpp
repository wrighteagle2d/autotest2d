#include <iostream>
#include <cstdlib>

int main(int argc, char *argv[])
{
	if (argc != 4) {
		std::cerr << "Usage: " << argv[0] << " [game count] [win rate] [lost rate]" << std::endl;
		exit(1);
	}

	int game_count = atoi(argv[1]);
	double win_rate = strtod(argv[2], 0);
	double lost_rate = strtod(argv[3], 0);

	if (game_count < 0) {
		std::cerr << "Error: game_count < 0" << std::endl;
		exit(1);
	}

	if (win_rate + lost_rate > 1.0) {
		std::cerr << "Error: win_rate + lost_rate > 1.0" << std::endl;
		exit(1);
	}

	srand48(getpid());

	std::cout << "\'WE2009\' vs \'HELIOS2009\'" << std::endl;

	for (int i = 0; i < game_count; ++i) {
		double probility = drand48();
		
		int left_score, right_score;
		if (probility < win_rate) {
			left_score = 3;
			right_score = 0;
		}
		else if (probility > 1.0 - lost_rate) {
			left_score = 0;
			right_score = 3;
		}
		else {
			left_score = right_score = 1;
		}

		std::cout << "\tScore: " << left_score << " - " << right_score << std::endl;
	}

	return 0;
}
