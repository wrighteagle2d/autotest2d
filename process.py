#!/usr/bin/python

import sys
from optparse import OptionParser

class Color:
    (NONE, RED, ORANGE, GREEN, BLUE, PURPLE) = range(6)

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

    string += line.string

    if line.color != Color.NONE:
        string += "\033[0m"

    return string

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
    line.face = Face.MONOSPACE

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

    if line.face == Face.MONOSPACE:
        string += "<font face=Monospace>"

    string += line.string.replace(" ", "&nbsp;")

    if line.face != Face.NORMAL:
        string += "</font>"
    
    if line.color != Color.NONE:
        string += "</font>"

    return string + "<br />"

class GameData:
    def __init__(self):
        self.count = 0

        self.max_sub = 0

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

        self.context = Context()

    def add_line(self, string, color=Color.PURPLE, face=Face.NORMAL):
        self.context.add_line(Context.Line(string, color, face))

    def add_newline(self):
        self.context.add_line(Context.Line(""))

    def update(self, index, left_score, right_score, valid):
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

        line = Context.Line("%3d%6d:%d%6d:%d" % (index, left_score, right_score, left_points, right_points))
        if valid:
            sub = abs(left_score - right_score)
            if sub >= self.max_sub:
                self.max_sub = sub
                line.color = Color.ORANGE
            elif sub >= 5:
                line.color = Color.GREEN
        else:
            line.color = Color.RED

        return line

    def gen_score_map(self, score_map):
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
        scores = sorted(score_map.keys())
        for score in range(scores[0], scores[-1] + 1):
            count = 0
            percentage = 0.0
            if score_map.has_key(score):
                count = score_map[score]
                percentage = score_map[score] / float(self.count)

            lines.append(Context.Line("`%4d:%6d " % (score, count) + bar(percentage), Color.BLUE, Face.MONOSPACE))

        return lines

    def do_some_calc(self):
        if self.count <= 0:
            self.add_line("Game Count: %d" % (self.count))
            return

        game_count = float(self.count)

        self.add_line("Left Team Goals Distribution:")
        for line in self.gen_score_map(self.left_score_map) :
            self.context.add_line(line)

        self.add_newline()
        self.add_line("Right Team Goals Distribution:")
        for line in self.gen_score_map(self.right_score_map) :
            self.context.add_line(line)

        self.add_newline()
        self.add_line("Diff Goals Distribution:")
        for line in self.gen_score_map(self.diff_score_map) :
            self.context.add_line(line)

        self.add_newline()
        self.add_line("Game Count: %d" % (self.count))

        self.add_line("Goals: %d : %d (diff: %d)" % (self.left_goals, self.right_goals, self.left_goals - self.right_goals))
        self.add_line("Points: %d : %d (diff: %d)" % (self.left_points, self.right_points, self.left_points - self.right_points))

        avg_left_goals = self.left_goals / game_count
        avg_right_goals = self.right_goals / game_count
        self.add_line("Avg Goals: %.2f : %.2f (diff: %.2f)" % (avg_left_goals, avg_right_goals, avg_left_goals - avg_right_goals))

        avg_left_points = self.left_points / game_count
        avg_right_points = self.right_points / game_count
        self.add_line("Avg Points: %.2f : %.2f (diff: %.2f)" % (avg_left_points, avg_right_points, avg_left_points - avg_right_points))

        win_rate = self.win_count / game_count
        lost_rate = self.lost_count / game_count
        expected_win_rate = win_rate / (win_rate + lost_rate)
        self.add_line("Left Team: Win %d, Draw %d, Lost %d" % (self.win_count, self.draw_count, self.lost_count))
        self.add_line("Left Team: WinRate %.2f%%, ExpectedWinRate %.2f%%" % (win_rate * 100, expected_win_rate * 100))

    def generate_context(self, lines):
        index = -1
        non_valid = 0
        for line in lines:
            index += 1
            if index <= 0:
                self.add_line(line, color=Color.BLUE) #title
                self.add_newline()
                self.add_line(" No.    Score   Point") #head
                continue
            parts = line.split()
            for i in range(len(parts)):
                parts[i] = int(parts[i])

            (left_score, right_score, valid) = parts
            self.context.add_line(self.update(index, left_score, right_score, valid))
            if not valid:
                non_valid += 1

        self.add_newline()
        if self.count <= 0:
            self.add_line("No results found, exit")
        else:
            self.do_some_calc()

        if non_valid:
            self.add_line("Non Valid Game Count: %d (%.2f%%)" % (non_valid, non_valid / float(self.count) * 100), Color.RED)

    def run(self, lines, method):
        self.generate_context(lines)
        self.context.dump(method)

usage = "Usage: %prog [options]"

parser = OptionParser(usage=usage)
parser.add_option("-C", "--console", action="store_true", dest="console", default=True, help="print console format [default]")
parser.add_option("-D", "--discuz", action="store_true", dest="discuz", default=False, help="print as discuz code format")
parser.add_option("-H", "--html", action="store_true", dest="html", default=False, help="print as html format")

(options, args) = parser.parse_args()

lines = []
for line in sys.stdin:
    lines.append(line.rstrip())

if options.discuz:
    GameData().run(lines, discuz)
elif options.html:
    print "<head> "
    print '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
    print "<title>Test Results</title> "
    print "</head>"
    print "<body>"
    print "<h1>Test Results</h1>"
    print "<hr>"
    GameData().run(lines, html)
    print "</body>"
elif options.console:
    GameData().run(lines, console)
