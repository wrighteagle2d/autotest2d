#!/usr/bin/python

import sys

g_max_sub = 0

class GameData:
    count = 0
    left_goals = 0
    right_goals = 0
    left_points = 0
    right_points = 0
    win_count = 0
    draw_count = 0
    lost_count = 0

    def update(self, index, left_score, rigt_score, valid):
        global g_max_sub

        self.count += 1

        left_points = 0
        right_points = 0
        if left_score > rigt_score:
            left_points += 3
            self.win_count += 1
        elif left_score < rigt_score:
            right_points += 3
            self.lost_count += 1
        else:
            left_points += 1
            right_points += 1
            self.draw_count += 1

        self.left_goals += left_score
        self.right_goals += rigt_score
        self.left_points += left_points
        self.right_points += right_points

        header = ""
        sub = abs(left_score - rigt_score)
        if sub >= g_max_sub:
            g_max_sub = sub
            header = "\033[01;33m\n"
        elif sub > 4:
            header = "\033[01;32m\n"

        return "%s%d\t%d:%d\t%d:%d\t%d\033[0m" % (header, index, left_score, rigt_score, left_points, right_points, valid)

    def dump(self, header):
        game_count = float(self.count)

        if header:
            print "%sCount: %d" % (header, self.count)
        if self.count <= 0:
            print
            return

        print "%sGoals: %d : %d (diff: %d)" % (header, self.left_goals, self.right_goals, self.left_goals - self.right_goals)
        print "%sPoints: %d : %d (diff: %d)" % (header, self.left_points, self.right_points, self.left_points - self.right_points)

        avg_left_goals = self.left_goals / game_count
        avg_right_goals = self.right_goals / game_count
        print "%sAvg Goals: %f : %f (diff: %f)" % (header, avg_left_goals, avg_right_goals, avg_left_goals - avg_right_goals)

        avg_left_points = self.left_points / game_count
        avg_right_points = self.right_points / game_count
        print "%sAvg Points: %f : %f (diff: %f)" % (header, avg_left_points, avg_right_points, avg_left_points - avg_right_points)

        win_rate = self.win_count / game_count
        lost_rate = self.lost_count / game_count
        expected_win_rate = win_rate / (win_rate + lost_rate)
        print "%sLeft Team: Win %d, Draw %d, Lost %d" % (header, self.win_count, self.draw_count, self.lost_count)
        print "%sLeft Team: WinRate %f%%, ExpectedWinRate %f%%" % (header, win_rate * 100, expected_win_rate * 100)


total_game = GameData()
valid_game = GameData()

index = 0
for line in sys.stdin:
    index += 1
    parts = line.split()
    for i in range(len(parts)):
        parts[i] = int(parts[i])

    (left_score, right_score, valid) = parts
    print total_game.update(index, left_score, right_score, valid)
    if valid:
        valid_game.update(index, left_score, right_score, valid)

if total_game.count <= 0:
    print "No results found, exit"
    sys.exit(1)

header = ""
if total_game.count > 0 and valid_game.count < total_game.count:
    header = "    "

print "No.\tScore\tPoint\tValid";
print

if header:
    print
    print "Total Game:"
    total_game.dump(header)

    print
    print "Only Valid Game:"
    valid_game.dump(header)

    print
    print "Non Valid Game Count: %d" % (total_game.count - valid_game.count)
    print "Non Valid Game Rate: %f%%" % ((total_game.count - valid_game.count) / float(total_game.count) * 100)
else :
    print
    total_game.dump(header)
