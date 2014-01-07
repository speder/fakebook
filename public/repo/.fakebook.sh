#!/bin/sh

# This script reads from ./.fakebook.cfg containing the following:
#
# 1. path to SVN repo, eg:
#
#     repo=/home/me/fakebook
#
# 2. path to browser, eg:
#
#     browser=/opt/google/chrome/google-chrome

dir=`dirname $0`

. ${dir}/.fakebook.cfg

echo reverting ...
svn revert -R $repo

echo updating ...
svn update $repo

nohup $browser "${dir}/.fakebook.html" >/dev/null 2>&1 &

exit 0
