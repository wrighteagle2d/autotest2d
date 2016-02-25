#!/usr/bin/python

import sys
import math
from collections import defaultdict
from optparse import OptionParser

class Color:
    (NONE, RED, ORANGE, GREEN, BLUE, PURPLE, GRAY) = range(7)

class Face:
    (NORMAL, MONOSPACE) = range(2)

class Context:
    class Line:
        def __init__(self, string, color=Color.NONE, face=Face.NORMAL):
            self.color = color
            self.face = face
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
    elif line.color == Color.GREEN:
        string += "\033[01;32m"
    elif line.color == Color.ORANGE:
        string += "\033[01;33m"
    elif line.color == Color.BLUE:
        string += "\033[01;34m"
    elif line.color == Color.PURPLE:
        string += "\033[01;35m"
    elif line.color == Color.GRAY:
        string += "\033[01;30m"

    string += line.string

    if line.color != Color.NONE:
        string += "\033[0m"

    return string

def no_color(line):
    return line.string

def discuz(line):
    string = ""

    if line.color == Color.RED:
        string += "[color=Red]"
    elif line.color == Color.ORANGE:
        string += "[color=Orange]"
    elif line.color == Color.GREEN:
        string += "[color=Green]"
    elif line.color == Color.BLUE:
        string += "[color=Blue]"
    elif line.color == Color.PURPLE:
        string += "[color=Purple]"
    elif line.color == Color.GRAY:
        string += "[color=Gray]"

    if line.face == Face.MONOSPACE:
        string += "[font=Monospace]"

    string += line.string

    if line.face != Face.NORMAL:
        string += "[/font]"
    if line.color != Color.NONE:
        string += "[/color]"

    return string

def html(line):
    string = ""
    line.face = Face.MONOSPACE #special case for html output

    if line.color == Color.RED:
        string += "<font color=Red>"
    elif line.color == Color.ORANGE:
        string += "<font color=Orange>"
    elif line.color == Color.GREEN:
        string += "<font color=Green>"
    elif line.color == Color.BLUE:
        string += "<font color=Blue>"
    elif line.color == Color.PURPLE:
        string += "<font color=Purple>"
    elif line.color == Color.GRAY:
        string += "<font color=Gray>"

    if line.face == Face.MONOSPACE:
        string += "<font face=Monospace>"

    string += line.string.replace(" ", "&nbsp;")

    if line.face != Face.NORMAL:
        string += "</font>"
    if line.color != Color.NONE:
        string += "</font>"

    return string + "<br />"

class GameData:
    class Result:
        def __init__(self, index, filename, left_score, right_score, left_points, right_points, left_shoot_count, valid, miss):
            self.index = index
            self.filename = filename
            self.left_score = left_score
            self.right_score = right_score
            self.left_points = left_points
            self.right_points = right_points
            self.left_shoot_count = left_shoot_count
            self.valid = valid
            self.miss = miss

    def __init__(self, verbose, curve, map):
        self.count = 0
        self.filename = 'null'
        self.result_list = []

        self.remaining_count = -1

        self.attention = 4.0

        self.left_goals = 0
        self.right_goals = 0

        self.left_points = 0
        self.right_points = 0

        self.left_total_shoot_count = 0

        self.win_count = 0
        self.draw_count = 0
        self.lost_count = 0

        self.left_score_distri = {}
        self.right_score_distri = {}
        self.diff_score_distri = {}

        self.score_map = defaultdict(dict)
        self.left_min_score = 6000
        self.left_max_score = -1
        self.right_min_score = 6000
        self.right_max_score = -1

        self.verbose = verbose
        self.curve = curve
        self.map = map
        self.context = Context()

        self.avg_left_goals = 0.0
        self.avg_right_goals = 0.0

        self.avg_left_points = 0.0
        self.avg_right_points = 0.0

        self.win_rate = 0.0
        self.lost_rate = 0.0
        self.expected_win_rate = 1.0

        self.max_win_rate = 1.0
        self.min_win_rate = 0.0

        self.win_rate_standard_deviation = 0.0
        self.confidence_intervel_left = 0.0
        self.confidence_intervel_right = 0.0

    def add_line(self, string, color=Color.PURPLE, face=Face.NORMAL):
        self.context.add_line(Context.Line(string, color, face))

    def add_newline(self):
        self.context.add_line(Context.Line(""))

    def update(self, left_score, right_score, left_shoot_count, valid, miss, filename):
        self.count += 1

        self.left_score_distri[left_score] = self.left_score_distri.get(left_score, 0) + 1
        self.right_score_distri[right_score] = self.right_score_distri.get(right_score, 0) + 1
        self.diff_score_distri[left_score - right_score] = self.diff_score_distri.get(left_score - right_score, 0) + 1

        if self.score_map.has_key(left_score) and self.score_map[left_score].has_key(right_score):
            self.score_map[left_score][right_score] += 1
        else:
            self.score_map[left_score][right_score] = 1

        self.left_min_score = min(self.left_min_score, left_score)
        self.left_max_score = max(self.left_max_score, left_score)
        self.right_min_score = min(self.right_min_score, right_score)
        self.right_max_score = max(self.right_max_score, right_score)

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

        self.result_list.append(self.Result(self.count, filename, left_score, right_score, left_points, right_points, left_shoot_count, valid, miss))

        self.left_goals += left_score
        self.right_goals += right_score
        self.left_points += left_points
        self.right_points += right_points

        self.left_total_shoot_count += left_shoot_count

        if self.curve:
            game_count = float(self.count)
            self.win_rate = self.win_count / game_count
            self.compute_confidence_interval()

            print self.count, self.win_rate, self.confidence_intervel_left, self.confidence_intervel_right

    def gen_score_distri(self, score_distri):
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

        lines = []
        scores = sorted(score_distri.keys())
        for score in range(scores[0], scores[-1] + 1):
            count = 0
            percentage = 0.0
            if score_distri.has_key(score):
                count = score_distri[score]
                percentage = score_distri[score] / float(self.count)

            lines.append(Context.Line("`%4d:%6d " % (score, count) + bar(percentage), Color.BLUE, Face.MONOSPACE))

        return lines

    def compute_confidence_interval(self):
        game_count = float(self.count)

        self.win_rate_standard_deviation = math.sqrt(self.win_rate * (1.0  - self.win_rate));
        self.confidence_intervel_left = self.win_rate - 1.96 * self.win_rate_standard_deviation / math.sqrt(game_count)
        self.confidence_intervel_right = self.win_rate + 1.96 * self.win_rate_standard_deviation / math.sqrt(game_count)

        if self.confidence_intervel_left < 0.0:
            self.confidence_intervel_left = 0.0
        if self.confidence_intervel_right > 1.0:
            self.confidence_intervel_right = 1.0


    def compute(self):
        game_count = float(self.count)

        try:
            file = open("total_rounds", "r")
            self.remaining_count = int(file.read().strip()) - self.count
            file.close()
        except:
            pass

        self.avg_left_goals = self.left_goals / game_count
        self.avg_right_goals = self.right_goals / game_count

        self.avg_left_points = self.left_points / game_count
        self.avg_right_points = self.right_points / game_count

        self.win_rate = self.win_count / game_count
        self.lost_rate = self.lost_count / game_count

        self.compute_confidence_interval()

        try:
            self.expected_win_rate = self.win_rate / (self.win_rate + self.lost_rate)
        except:
            pass

        if self.remaining_count > 0:
            self.max_win_rate = (self.win_count + self.remaining_count) / (game_count + self.remaining_count)
            self.min_win_rate = self.win_count / (game_count + self.remaining_count)

    def format(self):
        def summary():
            self.add_line(self.title, color=Color.BLUE)

            non_valid = sum(1 for e in self.result_list if not e.valid)
            miss_count = sum(e.miss for e in self.result_list if e.miss)
            miss_matches = sum(1 for e in self.result_list if e.miss)

            self.add_newline()
            self.add_line("Left Team Goals Distribution:")
            map(lambda line: self.context.add_line(line), self.gen_score_distri(self.left_score_distri))

            self.add_newline()
            self.add_line("Right Team Goals Distribution:")
            map(lambda line: self.context.add_line(line), self.gen_score_distri(self.right_score_distri))

            self.add_newline()
            self.add_line("Diff Goals Distribution:")
            map(lambda line: self.context.add_line(line), self.gen_score_distri(self.diff_score_distri))

            self.add_newline()
            if self.remaining_count > 0:
                self.add_line("Game Count: %d (%d left)" % (self.count, self.remaining_count))
            else:
                self.add_line("Game Count: %d" % (self.count))

            self.add_line("Goals: %d : %d (diff: %d)" % (self.left_goals, self.right_goals, self.left_goals - self.right_goals))
            self.add_line("Points: %d : %d (diff: %d)" % (self.left_points, self.right_points, self.left_points - self.right_points))
            self.add_line("Avg Goals: %.2f : %.2f (diff: %.2f)" % (self.avg_left_goals, self.avg_right_goals, self.avg_left_goals - self.avg_right_goals))
            self.add_line("Avg Points: %.2f : %.2f (diff: %.2f)" % (self.avg_left_points, self.avg_right_points, self.avg_left_points - self.avg_right_points))
            self.add_line("Left Team: Win %d, Draw %d, Lost %d" % (self.win_count, self.draw_count, self.lost_count))
            self.add_line("Left Team: WinRate %.2f%%, ExpectedWinRate %.2f%%" % (self.win_rate * 100, self.expected_win_rate * 100))
            self.add_line("Left Team: 95%% Confidence Interval [%.2f%%, %.2f%%]" % (self.confidence_intervel_left * 100, self.confidence_intervel_right * 100))

            if self.left_total_shoot_count > 0:
                self.add_line("Left Team: Shoot Success Rate %.2f%%, (%d/%d, %.2f shoots per match)" % (self.left_goals / float(self.left_total_shoot_count) * 100, self.left_goals, self.left_total_shoot_count, self.left_total_shoot_count / float(self.count)))

            if self.remaining_count > 0:
                self.add_line("Left Team: MaxWinRate %.2f%%, MinWinRate %.2f%%" % (self.max_win_rate * 100, self.min_win_rate * 100), Color.GRAY)

            if non_valid:
                self.add_line("Non Valid Game Count: %d (%.2f%%)" % (non_valid, non_valid / float(self.count) * 100), Color.RED)
            if miss_count:
                self.add_line("Total Miss Count: %d (in %d matches, %.2f%%)" % (miss_count, miss_matches, miss_matches / float(self.count) * 100), Color.RED)

        def details():
            left_attention = self.avg_left_goals - self.avg_right_goals - self.attention
            right_attention = self.avg_left_goals - self.avg_right_goals + self.attention
            min_diff = left_attention
            max_diff = right_attention

            self.add_newline()
            self.add_line("Game Details:")
            self.add_newline()
            for result in self.result_list:
                line = Context.Line("%3d%6d:%d%6d:%d      [%s]" % (result.index, result.left_score, result.right_score, result.left_points, result.right_points, result.filename))
                if result.valid:
                    diff = result.left_score - result.right_score
                    if diff <= min_diff:
                        min_diff = diff
                        line.color = Color.ORANGE
                    elif diff >= max_diff:
                        max_diff = diff
                        line.color = Color.ORANGE
                    elif diff <= left_attention or diff >= right_attention:
                        line.color = Color.GREEN
                else:
                    line.color = Color.RED

                if self.verbose or line.color != Color.NONE:
                    self.context.add_line(line)

        if options.html:
            summary()
            details()
        else:
            details()
            summary()

    def generate_context(self, lines):
        self.title = lines.pop(0)

        for line in lines:
            parts = line.split()
            parts = map(int, parts[:-1]) + parts[-1:]
            self.update(*parts)

        if not self.curve and not self.map:
            self.compute()
            self.format()

        if self.map:
            self.gen_score_map()

    def run(self, lines, method):
        self.generate_context(lines)
        self.context.dump(method)

    def gen_score_map(self):
        print "# (%d, %d) * (%d, %d)" % (self.left_min_score, self.left_max_score, self.right_min_score, self.right_max_score)

        for i in range(self.left_min_score, self.left_max_score + 1):
            for j in range(self.right_min_score, self.right_max_score + 1):
                share = 0.0

                if self.score_map.has_key(i) and self.score_map[i].has_key(j):
                    share = self.score_map[i][j] / float(self.count)

                print i, j, share

            print


usage = "Usage: %prog [options]"

parser = OptionParser(usage=usage)
parser.add_option("-C", "--console", action="store_true", dest="console", default=True, help="print with color to console [default]")
parser.add_option("-N", "--no-color", action="store_true", dest="no_color", default=False, help="print without color to console")
parser.add_option("-D", "--discuz", action="store_true", dest="discuz", default=False, help="print as discuz code format")
parser.add_option("-H", "--html", action="store_true", dest="html", default=False, help="print as html format")
parser.add_option("-S", "--simplify", action="store_true", dest="simplify", default=False, help="output simplify")
parser.add_option("-A", "--curve", action="store_true", dest="curve", default=False, help="output winrate curve data")
parser.add_option("-M", "--map", action="store_true", dest="map", default=False, help="output score map data")
parser.add_option("-T", "--temp", action="store_true", dest="temp", default=False, help="can be killed any time")

(options, args) = parser.parse_args()

lines = []
for line in sys.stdin:
    line = line.strip()
    if len(line) > 0:
        lines.append(line)

if len(lines) <= 1: #at least two lines: title + result
    print "No results found, exit"
    sys.exit(1)

game_data = GameData(not options.simplify, options.curve, options.map)

if options.discuz:
    game_data.run(lines, discuz)
elif options.html:
    print """
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="refresh" content="60">
<title>Test Results</title>
</head>
<body>
"""
    if options.temp:
        print "<h1>Test Results<font color=Red> (Can be killed any time!)</font></h1>"
    else:
        print "<h1>Test Results</h1>"
    print """
<hr>
<img src="result.d/curve.png" alt="Winning Rate" style="width:640px;height:400px;">
<img src="result.d/map.png" alt="Score Map" style="width:640px;height:400px;">
<hr>
<p>
"""
    game_data.run(lines, html)
    print """
</body>
"""
elif options.no_color:
    game_data.run(lines, no_color)
else:
    game_data.run(lines, console)

