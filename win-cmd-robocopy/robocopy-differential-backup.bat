@echo off
REM (c) nachtschicht@kommespaeter.de 2021 under MIT license
REM a script for differential backups using robocopy and archive bits
REM set backupsource and backuptarget before first use below

REM change debug mode true/false, debug true does not copy anything (robocopy /L) and additional info is send to console
set debug=true

REM set backupsource and backuptarget before first use
set backupsource=X:\test1
set backuptarget=F:\test2

REM whatever it does, it gets current date-time stamp independent from localization settings, you can replace with simpler code for localized  date retrieval
REM probably first published on: https://stackoverflow.com/questions/3472631/how-do-i-get-the-day-month-and-year-from-a-windows-cmd-exe-script
for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set CurrDay=0%%L
        set CurrMonth=0%%M
        set CurrYear=%%N
    )
)
REM end of stackoverflow code
REM add leading zero for one digit hours (known bug in DOS)
set mytime=%time: =0%

set rightnow=%CurrYear%-%CurrMonth:~-2%-%CurrDay:~-2%_%mytime:~0,2%-%mytime:~3,2%-%mytime:~6,2%
if %debug% EQU true echo Date (format YYYY-MM-DD_hh-mm-ss): %rightnow%

REM backuptarget folder does not exists, so we will stop here and write an ERROR log
if not exist "%backuptarget%\" echo ERROR: WTF, backup target folder %backuptarget% does not exist ....>>_ERROR_%rightnow%.txt & exit

REM this should never happen that the backup folder already exists, but if we stop here and write an ERROR log
if exist "%backuptarget%\%rightnow%\" echo ERROR: WTF, backup folder %backuptarget%\%rightnow% already exists ....>>%backuptarget%\_ERROR_%rightnow%.txt & exit

if %debug% EQU true echo %backuptarget%\%rightnow%
if %debug% NEQ true mkdir "%backuptarget%\%rightnow%"

REM backupsource folder does not exists, so we will stop here and write an ERROR log
if not exist "%backupsource%\" echo ERROR: WTF, backup source folder %backupsource% does not exist ....>>%backuptarget%\_ERROR_%rightnow%.txt & exit


REM for some strange reason robocopying only files with archive attribute and resetting the same only works with option /E which copies all  folders too, these have to be removed in a second step
if %debug% EQU true robocopy %backupsource% "%backuptarget%\%rightnow%"  /L /M /E /COPY:DT /DCOPY:DT /R:1 /W:1 /NP /TEE /LOG:%backuptarget%\%rightnow%.txt
if %debug% NEQ true robocopy %backupsource% "%backuptarget%\%rightnow%"   /M /E /COPY:DT /DCOPY:DT /R:1 /W:1 /NP /TEE /LOG:%backuptarget%\%rightnow%.txt

echo "##################################">>%backuptarget%\%rightnow%.txt
echo "##################################">>%backuptarget%\%rightnow%.txt
echo "###  Delete empty directories  ###">>%backuptarget%\%rightnow%.txt
echo "##################################">>%backuptarget%\%rightnow%.txt
echo "##################################">>%backuptarget%\%rightnow%.txt

REM remove empty directories from first robocopy command
if %debug% EQU true robocopy "%backuptarget%\%rightnow%" "%backuptarget%\%rightnow%" /L /S /MOVE /LOG+:%backuptarget%\%rightnow%.txt
if %debug% NEQ true robocopy "%backuptarget%\%rightnow%" "%backuptarget%\%rightnow%" /S /MOVE /LOG+:%backuptarget%\%rightnow%.txt


