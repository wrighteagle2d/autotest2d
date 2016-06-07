# autotest2d
## Auto test scripts for RoboCup soccer simulation 2d games 

* test.sh -- run auto test
* kill.sh -- stop test
* result.sh -- show result
* analyze.sh -- show more information
* start\_left -- script to start left team
* start\_right -- script to start right team
* start.tmpl -- templates of start scripts
* scripts/automonitor -- start monitors

## Example outputs:

![output](http://github.com/aijunbai/autotest2d/blob/master/examples/output.png)
![curve](http://github.com/aijunbai/autotest2d/blob/master/examples/curve.png)
![score](http://github.com/aijunbai/autotest2d/blob/master/examples/score.png)

### Left Team Goals Distribution:
*   0:   162 \[#####                            \] 18.00%
*   1:   276 \[##########                       \] 30.67%
*   2:   249 \[#########                        \] 27.67%
*   3:   127 \[####                             \] 14.11%
*   4:    68 \[##                               \]  7.56%
*   5:    12 \[                                 \]  1.33%
*   6:     6 \[                                 \]  0.67%

### Right Team Goals Distribution:
*   0:   245 \[########                         \] 27.22%
*   1:   354 \[############                     \] 39.33%
*   2:   190 \[######                           \] 21.11%
*   3:    81 \[##                               \]  9.00%
*   4:    24 \[                                 \]  2.67%
*   5:     5 \[                                 \]  0.56%
*   6:     1 \[                                 \]  0.11%

### Diff Goals Distribution:
*  -6:     1 \[                                 \]  0.11%
*  -5:     3 \[                                 \]  0.33%
*  -4:     6 \[                                 \]  0.67%
*  -3:    18 \[                                 \]  2.00%
*  -2:    56 \[##                               \]  6.22%
*  -1:   152 \[#####                            \] 16.89%
*   0:   223 \[########                         \] 24.78%
*   1:   222 \[########                         \] 24.67%
*   2:   133 \[####                             \] 14.78%
*   3:    58 \[##                               \]  6.44%
*   4:    21 \[                                 \]  2.33%
*   5:     6 \[                                 \]  0.67%
*   6:     1 \[                                 \]  0.11%

### Game Count: 900
* Goals: 1523 : 1104 (diff: 419)
* Points: 1546 : 931 (diff: 615)
* Avg Goals: 1.69 : 1.23 (diff: 0.47)
* Avg Points: 1.72 : 1.03 (diff: 0.68)
* Left Team: Win 441, Draw 223, Lost 236
* Left Team: WinRate 49.00%, ExpectedWinRate 65.14%
* Left Team: 95% Confidence Interval \[45.73%, 52.27%\]
* Left Team: Shoot Success Rate 54.78%, (1523/2780, 3.09 shoots per match)
* Non Valid Game Count: 9 (1.00%)
* Total Miss Count: 8 (in 8 matches, 0.89%)

