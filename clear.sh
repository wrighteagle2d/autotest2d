#!/bin/bash - 
#===============================================================================
#
#          FILE: clear.sh
# 
#         USAGE: ./clear.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/24/2016 17:36
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
rm -fr log.d/ result.d/ log.d_* result.d_*


