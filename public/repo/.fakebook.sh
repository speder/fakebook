#!/bin/sh
# this script reads its config from .fakebook.cfg (eg)
# repo=/media/common/sync/public/fakebook
# browser=/opt/google/chrome/google-chrome

dir=`dirname $0`
. ${dir}/.fakebook.cfg
echo reverting ... 
svn revert -R $repo
echo updating ...
svn update $repo
nohup $browser "${dir}/.fakebook.html" >/dev/null 2>&1 &
exit 0
