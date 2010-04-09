#!/usr/bin/python

import sys

g_max_sub = 0

def gen_indent(indent) :
    header = ""
    for i in range(indent):
        header += "    "
    return header

class GameData:
    count = 0

    left_goals = 0
    right_goals = 0

    left_points = 0
    right_points = 0

    win_count = 0
    draw_count = 0
    lost_count = 0

    left_score_map = {}
    right_score_map = {}
    diff_score_map = {}

    def update(self, index, left_score, rigt_score, valid):
        global g_max_sub

        self.count += 1

        self.left_score_map[left_score] = self.left_score_map.get(left_score, 0) + 1
        self.right_score_map[right_score] = self.right_score_map.get(right_score, 0) + 1
        self.diff_score_map[left_score - right_score] = self.diff_score_map.get(left_score - right_score, 0) + 1

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
        if sub >= 5:
            header = "\033[01;32m\n"
            if sub >= g_max_sub:
                g_max_sub = sub
                header = "\033[01;33m\n"

        return "%s%d\t%d:%d\t%d:%d\t%d\033[0m" % (header, index, left_score, rigt_score, left_points, right_points, valid)

    def dump_score_map(self, indent, score_map):
        def bar(percentage):
            length = 25
            bar_length = int(length * percentage)

            percentage_string = "%.2f%%" % (percentage * 100)
            while len(percentage_string) <= 6:
                percentage_string = " " + percentage_string

            line = "%s [" % (percentage_string)
            for i in range(bar_length):
                line += "#"
            
            return line

        indent += 1
        header = gen_indent(indent)
        lines = []
        for score in sorted(score_map.keys()):
            lines.append("%s%3d:    %s" % (header, score, bar(score_map[score] / float(self.count))))

        return lines

    def dump(self, indent):
        game_count = float(self.count)

        header = gen_indent(indent)
        print "%sCount: %d" % (header, self.count)

        if self.count <= 0:
            print
            return

        print "%sGoals: %d : %d (diff: %d)" % (header, self.left_goals, self.right_goals, self.left_goals - self.right_goals)
        print "%sPoints: %d : %d (diff: %d)" % (header, self.left_points, self.right_points, self.left_points - self.right_points)

        avg_left_goals = self.left_goals / game_count
        avg_right_goals = self.right_goals / game_count
        print "%sAvg Goals: %.2f : %.2f (diff: %.2f)" % (header, avg_left_goals, avg_right_goals, avg_left_goals - avg_right_goals)

        avg_left_points = self.left_points / game_count
        avg_right_points = self.right_points / game_count
        print "%sAvg Points: %.2f : %.2f (diff: %.2f)" % (header, avg_left_points, avg_right_points, avg_left_points - avg_right_points)

        win_rate = self.win_count / game_count
        lost_rate = self.lost_count / game_count
        expected_win_rate = win_rate / (win_rate + lost_rate)
        print "%sLeft Team: Win %d, Draw %d, Lost %d" % (header, self.win_count, self.draw_count, self.lost_count)
        print "%sLeft Team: WinRate %.2f%%, ExpectedWinRate %.2f%%" % (header, win_rate * 100, expected_win_rate * 100)

        print "\n%sLeft Team Goals Distribution:" % (header)
        for line in self.dump_score_map(indent, self.left_score_map) :
            print line
        print "\n%sRight Team Goals Distribution:" % (header)
        for line in self.dump_score_map(indent, self.right_score_map) :
            print line
        print "\n%sDiff Goals Distribution:" % (header)
        for line in self.dump_score_map(indent, self.diff_score_map) :
            print line


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

if total_game.count <= 0:
    print "No results found, exit"
    sys.exit(1)

indent = 0
if total_game.count > 0 and valid_game.count < total_game.count:
    indent = 1

print

if indent:
    print
    print "Total Game:"
    total_game.dump(indent)

    print
    print "Valid Game:"
    valid_game.dump(indent)

    print
    print "Non Valid Game Count: %d" % (total_game.count - valid_game.count)
    print "Non Valid Game Rate: %.2f%%" % ((total_game.count - valid_game.count) / float(total_game.count) * 100)
else :
    print
    total_game.dump(indent)
