#!/usr/bin/python

import sys
from optparse import OptionParser

g_max_sub = 0
class Color:
    (NONE, RED, YELLOW, GREEN) = range(4)

class Font:
    (NORMAL, MONOSPACE) = range(2)

class Formatter:
    class Line:
        def __init__(self, string, color=Color.NONE, font=Font.NORMAL):
            self.color = color
            self.font = font
            self.string = string

    def __init__(self):
        self.lines = []

    def add_line(self, line):
        self.lines.append(line)

    def dump(self, method):
        for line in self.lines:
            print method(line)


#dump methods
def console(line):
    string = ""

    if line.color == Color.RED:
        string += "\033[01;31m"
    elif line.color == Color.YELLOW:
        string += "\033[01;33m"
    elif line.color == Color.GREEN:
        string += "\033[01;32m"

    string += line.string

    if line.color != Color.NONE:
        string += "\033[0m"

    return string

def discuz(line):
    string = ""

    if line.color == Color.RED:
        string += "[b][color=Red]"
    elif line.color == Color.YELLOW:
        string += "[b][color=Yellow]"
    elif line.color == Color.GREEN:
        string += "[b][color=Green]"

    if line.font == Font.MONOSPACE:
        string += "[font=Monospace]"

    string += line.string

    if line.font != Font.NORMAL:
        string += "[/font]"
    
    if line.color != Color.NONE:
        string += "[/color][/b]"

    return string



def gen_indent(indent) :
    header = ""
    for i in range(indent):
        header += "    "
    return header

class GameData:
    def __init__(self):
        self.count = 0

        self.left_goals = 0
        self.right_goals = 0

        self.left_points = 0
        self.right_points = 0

        self.win_count = 0
        self.draw_count = 0
        self.lost_count = 0

        self.left_score_map = {}
        self.right_score_map = {}
        self.diff_score_map = {}

        self.formatter = Formatter()

    def add_line(self, string, color=Color.NONE, font=Font.NORMAL):
        self.formatter.add_line(Formatter.Line(string, color, font))

    def update(self, index, left_score, right_score, valid):
        global g_max_sub

        self.count += 1

        self.left_score_map[left_score] = self.left_score_map.get(left_score, 0) + 1
        self.right_score_map[right_score] = self.right_score_map.get(right_score, 0) + 1
        self.diff_score_map[left_score - right_score] = self.diff_score_map.get(left_score - right_score, 0) + 1

        left_points = 0
        right_points = 0
        if left_score > right_score:
            left_points += 3
            self.win_count += 1
        elif left_score < right_score:
            right_points += 3
            self.lost_count += 1
        else:
            left_points += 1
            right_points += 1
            self.draw_count += 1

        self.left_goals += left_score
        self.right_goals += right_score
        self.left_points += left_points
        self.right_points += right_points

        line = Formatter.Line("%d\t%d:%d\t%d:%d" % (index, left_score, right_score, left_points, right_points))
        if valid:
            sub = abs(left_score - right_score)
            if sub >= g_max_sub:
                g_max_sub = sub
                line.color = Color.YELLOW
            elif sub >= 5:
                line.color = Color.GREEN
        else:
            line.color = Color.RED

        return line

    def gen_score_map(self, indent, score_map):
        def bar(percentage):
            length = 33
            bar_length = int(length * percentage)

            percentage_string = "%.2f%%" % (percentage * 100)
            while len(percentage_string) < 6:
                percentage_string = " " + percentage_string

            line = "["
            for i in range(bar_length):
                line += "#"
            for i in range(length - bar_length):
                line += " "
            line += "] %s" % (percentage_string)
            
            return line

        header = gen_indent(indent)
        lines = []
        scores = sorted(score_map.keys())
        for score in range(scores[0], scores[-1] + 1):
            count = 0
            percentage = 0.0
            if score_map.has_key(score):
                count = score_map[score]
                percentage = score_map[score] / float(self.count)

            lines.append(Formatter.Line("%s%3d:%s%3d " % (header, score, gen_indent(1), count) + bar(percentage),font=Font.MONOSPACE))

        return lines

    def format(self, indent):
        if self.count <= 0:
            self.add_line("%sGame Count: %d" % (header, self.count))
            return

        game_count = float(self.count)
        header = gen_indent(indent)

        self.add_line("%sLeft Team Goals Distribution:" % (header))
        for line in self.gen_score_map(indent, self.left_score_map) :
            self.formatter.add_line(line)

        self.add_line("\n%sRight Team Goals Distribution:" % (header))
        for line in self.gen_score_map(indent, self.right_score_map) :
            self.formatter.add_line(line)

        self.add_line("\n%sDiff Goals Distribution:" % (header))
        for line in self.gen_score_map(indent, self.diff_score_map) :
            self.formatter.add_line(line)

        self.add_line("\n\n")
        self.add_line("%sGame Count: %d" % (header, self.count))

        self.add_line("%sGoals: %d : %d (diff: %d)" % (header, self.left_goals, self.right_goals, self.left_goals - self.right_goals))
        self.add_line("%sPoints: %d : %d (diff: %d)" % (header, self.left_points, self.right_points, self.left_points - self.right_points))

        avg_left_goals = self.left_goals / game_count
        avg_right_goals = self.right_goals / game_count
        self.add_line("%sAvg Goals: %.2f : %.2f (diff: %.2f)" % (header, avg_left_goals, avg_right_goals, avg_left_goals - avg_right_goals))

        avg_left_points = self.left_points / game_count
        avg_right_points = self.right_points / game_count
        self.add_line("%sAvg Points: %.2f : %.2f (diff: %.2f)" % (header, avg_left_points, avg_right_points, avg_left_points - avg_right_points))

        win_rate = self.win_count / game_count
        lost_rate = self.lost_count / game_count
        expected_win_rate = win_rate / (win_rate + lost_rate)
        self.add_line("%sLeft Team: Win %d, Draw %d, Lost %d" % (header, self.win_count, self.draw_count, self.lost_count))
        self.add_line("%sLeft Team: WinRate %.2f%%, ExpectedWinRate %.2f%%" % (header, win_rate * 100, expected_win_rate * 100))

    def generate(self):
        self.add_line("No.\tScore\tPoint")

        index = 0
        non_valid_game_count = 0
        for line in sys.stdin:
            index += 1
            parts = line.split()
            for i in range(len(parts)):
                parts[i] = int(parts[i])

            (left_score, right_score, valid) = parts
            self.formatter.add_line(self.update(index, left_score, right_score, valid))
            if not valid:
                non_valid_game_count += 1

        if self.count <= 0:
            self.add_line("No results found, exit")
            sys.exit(1)

        self.add_line("\n")
        self.format(0)

        if non_valid_game_count:
            self.add_line("\n")
            self.add_line("Non Valid Game Count: %d" % (non_valid_game_count))
            self.add_line("Non Valid Game Rate: %.2f%%" % (non_valid_game_count / float(self.count) * 100))

    def dump(self, method):
        self.formatter.dump(method)

    def run(self, method):
        self.generate()
        self.dump(method)

usage = "Usage: %prog [options]"

parser = OptionParser(usage=usage)
parser.add_option("-C", "--console", action="store_true", dest="console", default=True, help="print to stdout [default]")
parser.add_option("-D", "--discuz", action="store_true", dest="discuz", default=False, help="print to stdout using discuz code")

(options, args) = parser.parse_args()

if options.discuz:
    GameData().run(discuz)
else:
    GameData().run(console)

