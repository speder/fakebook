@echo off

REM this script reads its config from .fakebook.ini (eg):
REM repo="C:\sync\public\fakebook"
REM explorer="C:\Windows\explorer.scf"
REM browser="C:\Documents and Settings\me\Local Settings\Application Data\Google\Chrome\Application\chrome.exe"

setlocal enableextensions
for /f "tokens=2 delims==" %%? in ('find /i "repo" ^< .fakebook.ini') do set repo=%%?
for /f "tokens=2 delims==" %%? in ('find /i "explorer" ^< .fakebook.ini') do set explorer=%%?
for /f "tokens=2 delims==" %%? in ('find /i "browser" ^< .fakebook.ini') do set browser=%%?
echo reverting ...
svn revert -R %repo%
echo updating ...
svn update %repo%
start %explorer% %repo%
start %browser% %repo%\.fakebook.html
endlocal
