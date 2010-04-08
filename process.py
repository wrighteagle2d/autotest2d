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
            header = "\033[01;33m"
        elif sub > 4:
            header = "\033[01;32m"

        return "%s%d\t%d:%d\t%d:%d\t%d\033[0m" % (header, index, left_score, rigt_score, left_points, right_points, valid)

    def dump(self, header):
        print "%sCount: %d" % (header, self.count)
        print "%sGoals: %d : %d" % (header, self.left_goals, self.right_goals)
        print


total_game = GameData()
valid_game = GameData()

print "No.\tScore\tPoint\tValid";

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

print
print "Total Game:"
total_game.dump("    ")

print "Only Valid Game"
valid_game.dump("    ")
