@echo off

REM  This script reads from a file in this directory named:
REM
REM      .fakebook.ini
REM
REM  Create and edit .fakebook.ini to contain the following:
REM
REM  1. the location of the Subversion repository, eg:
REM
REM      repo="C:\sync\public\fakebook"
REM
REM  2. the location of Windows Explorer, eg:
REM
REM      explorer="C:\Windows\explorer.scf"
REM
REM  3. the location of a browser, eg:
REM
REM      browser="C:\Documents and Settings\me\Local Settings\Application Data\Google\Chrome\Application\chrome.exe"

setlocal enableextensions

for /f "tokens=2 delims==" %%? in ('find /i     "repo" ^< .fakebook.ini') do set repo=%%?
for /f "tokens=2 delims==" %%? in ('find /i "explorer" ^< .fakebook.ini') do set explorer=%%?
for /f "tokens=2 delims==" %%? in ('find /i  "browser" ^< .fakebook.ini') do set browser=%%?

echo reverting ...
svn revert -R %repo%

echo updating ...
svn update %repo%

start %explorer% %repo%
start %browser% %repo%\.fakebook.html

endlocal
