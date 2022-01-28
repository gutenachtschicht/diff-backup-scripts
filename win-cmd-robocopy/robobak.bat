@ECHO off
REM better set a local scope for variables
SETLOCAL 
REM robobak.bat v2-20220129
REM a script for differential and full backups using robocopy, maintaining the date of directories, 
REM also copying empty directories (see robocopy section for details and settings)
REM
REM (c) 2021 nachtschicht under the MIT license (see text at the end of file), portions under https://creativecommons.org/licenses/by-sa/3.0/ (see start of stackoverflow code)
IF "%~1" == "/license" GOTO :license

REM go to help text
IF "%~1" == "?"  GOTO :displayhelp
IF "%~1" == "/?" GOTO :displayhelp
IF "%~1" == "/h" GOTO :displayhelp
IF "%~1" == "-h" GOTO :displayhelp

REM better set a local scope for variables
SETLOCAL 

REM enter robobaksource and robobaktarget from console ... or call batch file with parameters (for simplicty of script order must be kept):  
REM >robobak.bat [full|diff] [debug|nodebug] [targetpath] [soucepath]
REM (when calling from batch you can leave the last entries empty, so that you can enter manually from the console)

REM paramenter "full" does a one way full copy (not a mirror), parameter diff does a differential backup to the target folder with those files only that had the archive bit set, thereafter the archive bit is cleared
IF "%~1" == "" (ECHO Backup mode, can be [diff] or [full]. & SET robobakmode=diff & SET /p robobakmode=robobakmode: ) ELSE (SET robobakmode=%~1)
REM change debug mode debug or something else, "debug" does not copy anything (robocopy /L) and additional info is send to console for log
IF "%~2" == "" (ECHO Debugmode, can be [debug] or else. & SET robobakdebug=debug & SET /p robobakdebug=robobakdebug: ) ELSE (SET robobakdebug=%~2)
REM set the target path, under which the backup folders and the log files are stored, each folder has a timestamp on a second and the source folder's name
IF "%~3" == "" (ECHO backup TARGET path, do not use blanks or brackets in path! & SET /P robobaktarget=robobaktarget: ) ELSE (SET robobaktarget=%~3)
REM give the root directory that shall be stored in backup
IF "%~4" == "" (ECHO backup SOURCE path, do not use blanks or brackets in path! & SET /P robobaksource=robobaksource: ) ELSE (SET robobaksource=%~4)
REM if set, use an OPTIONAL backup name, otherwise use last folder from source path used as name for the backup folder
IF "%~5" == "" (ECHO optional name of the backup, do not use blanks or brackets! & SET /P robobakname=robobakname: ) ELSE (SET robobakname=%~5)

REM remove trailing backslash
IF %robobaktarget:~-1%==\ SET robobaktarget=%robobaktarget:~0,-1%
IF %robobaksource:~-1%==\ SET robobaksource=%robobaksource:~0,-1%

REM use last folder from source path to be used as name for the backup folder
FOR %%f IN ("%robobaksource%") DO SET robobaksourcefolder=%%~nxf

REM if optional robobakname is set and NOT set to "!" which has to be used in batch files, use robobakname instead of the source folder as prefix for the backup folder name
REM (this line gave me a HUGE headache before the logic worked, dont try something like: if %var%=="" SET .. if the variable does not exist)
IF DEFINED robobakname (IF NOT %robobakname%==! (SET robobaksourcefolder=%robobakname%))

REM start of stackoverflow code
REM whatever it does, it gets current date-time stamp independent from localization settings.
REM probably first published on: https://stackoverflow.com/questions/3472631/how-do-i-get-the-day-month-and-year-from-a-windows-cmd-exe-script
REM as published on: https://stackoverflow.com/a/33402280 
FOR /F "skip=1 delims=" %%F IN ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') DO (
    FOR /F "tokens=1-3" %%L IN ("%%F") DO (
        SET CurrDay=0%%L
        SET CurrMonth=0%%M
        SET CurrYear=%%N
    )
)
REM You could replace with simpler code for localized date retrieval, especially if you don't like stackoverflow's licensing model - which I would understand ...
REM something like 'set mydate=%date:~10,4%-%date:~4,2%-%date:~7,2%' based on US localization
REM end of stackoverflow code

REM add leading zero for one digit hours (known bug in DOS)
SET robobakmytime=%time: =0%

SET robobakrightnow=%CurrYear%-%CurrMonth:~-2%-%CurrDay:~-2%_%robobakmytime:~0,2%-%robobakmytime:~3,2%-%robobakmytime:~6,2%
IF %robobakdebug% EQU debug (ECHO . & ECHO . & ECHO rightnow is YYYY-MM-DD_hh-mm-ss: %robobakrightnow% & ECHO . & ECHO . )


REM reduce line size a bit
IF %robobakmode% == diff (SET robobakcopymode=DIFF& ECHO %robobakcopymode%) ELSE (IF %robobakmode% == full ( SET robobakcopymode=FULL& ECHO %robobakcopymode% 	) ELSE ( 

		ECHO *********************************************************************************
		ECHO * No proper backup mode defined, please use as first param either diff or full: *
		ECHO *    robobak.bat [full or diff] [debug or nodebug] [targetpath] [soucepath]     *
		ECHO *********************************************************************************
		
		ECHO *********************************************************************************>>%robobaktarget%\_ERROR_%robobakrightnow%.txt
		ECHO * No proper backup mode defined, please use as first param either diff or full: *>>%robobaktarget%\_ERROR_%robobakrightnow%.txt
		ECHO *    robobak.bat [full or diff] [debug or nodebug] [targetpath] [soucepath]     *>>%robobaktarget%\_ERROR_%robobakrightnow%.txt
		ECHO *********************************************************************************>>%robobaktarget%\_ERROR_%robobakrightnow%.txt

		GOTO :cleanup )
		
		)
	
SET robobakfolder=%robobaksourcefolder%_%robobakcopymode%_%robobakrightnow%

IF %robobakdebug% NEQ debug (ECHO "no debug mode") ELSE (ECHO "HURRAA, DEBUG MODE" & ECHO . )
IF %robobakdebug% NEQ debug (ECHO "no debug mode") ELSE (ECHO "HURRAA, DEBUG MODE" & ECHO . )>>"%robobaktarget%\%robobakfolder%.txt"

IF %robobakdebug% EQU debug (

		ECHO ------------------------------------------------------------------------------->>"%robobaktarget%\%robobakfolder%.txt"
		ECHO rightnow is YYYY-MM-DD_hh-mm-ss: %robobakrightnow%>>"%robobaktarget%\%robobakfolder%.txt"
		ECHO ------------------------------------------------------------------------------->>"%robobaktarget%\%robobakfolder%.txt"
		ECHO DEBUGMODE = %robobakdebug%>>"%robobaktarget%\%robobakfolder%.txt">>"%robobaktarget%\%robobakfolder%.txt"
		SET robobakdebug>>"%robobaktarget%\%robobakfolder%.txt"
		ECHO ------------------------------------------------------------------------------->>"%robobaktarget%\%robobakfolder%.txt"
		ECHO FOLDER robobaksource       = %robobaksource%>>"%robobaktarget%\%robobakfolder%.txt"
		ECHO FOLDER robobaksourcefolder = %robobaksourcefolder%>>"%robobaktarget%\%robobakfolder%.txt"
		ECHO FOLDER robobakfolder       = %robobakfolder%>>"%robobaktarget%\%robobakfolder%.txt"
		ECHO ------------------------------------------------------------------------------->>"%robobaktarget%\%robobakfolder%.txt"
		ECHO SET robobak>>"%robobaktarget%\%robobakfolder%.txt"
		SET robobak>>"%robobaktarget%\%robobakfolder%.txt"
		ECHO ------------------------------------------------------------------------------->>"%robobaktarget%\%robobakfolder%.txt"
		ECHO now running Robocopy with option /L - nothing will be changed:>>"%robobaktarget%\%robobakfolder%.txt"
		
	)
	
REM		GOTO :cleanup


REM backup target folder does not exists, so we will stop here and write an ERROR log
IF not exist "%robobaktarget%\" ECHO ERROR: WTF, backup target folder %robobaktarget% does not exist ....>>"_ERROR_%robobakfolder%.txt" & EXIT

REM this should never happen that the backup folder already exists, but if we stop here and write an ERROR log
IF exist "%robobaktarget%\%robobakfolder%\" ECHO ERROR: WTF, backup folder %robobaktarget%\%robobakfolder% already exists ....>>"%robobaktarget%\_ERROR_%robobakfolder%.txt" & exit

IF %robobakdebug% EQU debug (ECHO Zieldatei / target folder - not created & ECHO %robobaktarget%\%robobakfolder%)
IF %robobakdebug% NEQ debug (ECHO create  Zieldatei / target folder & MKDIR "%robobaktarget%\%robobakfolder%")

REM backup source folder does not exists, so we will stop here and write an ERROR log
IF not exist "%robobaksource%\" ECHO ERROR: WTF, backup source folder %robobaksource% does not exist ....>>"%robobaktarget%\_ERROR_%robobakfolder%.txt" & EXIT


IF %robobakmode% == diff (

	REM for some strange reason robocopying only files with archive attribute (/M) and resetting the same only works with option /E which copies all  folders too, these have to be removed in a second step
	IF %robobakdebug% EQU debug ROBOCOPY "%robobaksource%" "%robobaktarget%\%robobakfolder%"  /L /M /E /COPY:DT /DCOPY:DT /R:1 /W:1 /NP /TEE /LOG+:"%robobaktarget%\%robobakfolder%.txt"
	IF %robobakdebug% NEQ debug ROBOCOPY "%robobaksource%" "%robobaktarget%\%robobakfolder%"     /M /E /COPY:DT /DCOPY:DT /R:1 /W:1 /NP /TEE /LOG+:"%robobaktarget%\%robobakfolder%.txt"


	ECHO "##################################">>%robobaktarget%\%robobakfolder%.txt
	ECHO "##################################">>%robobaktarget%\%robobakfolder%.txt
	ECHO "###  Delete empty directories  ###">>%robobaktarget%\%robobakfolder%.txt
	ECHO "##################################">>%robobaktarget%\%robobakfolder%.txt
	ECHO "##################################">>%robobaktarget%\%robobakfolder%.txt

	REM remove empty directories from first robocopy command
	IF %robobakdebug% EQU debug (ECHO ... & ECHO ROBOCOPY can not clean up %robobaktarget%\%robobakfolder% as it is not created in DEBUG mode & ECHO --------- & ECHO DEBUG END)>>%robobaktarget%\%robobakfolder%.txt
	IF %robobakdebug% NEQ debug ROBOCOPY "%robobaktarget%\%robobakfolder%" "%robobaktarget%\%robobakfolder%" /S /MOVE /LOG+:%robobaktarget%\%robobakfolder%.txt

) ELSE (
	IF %robobakmode% == full ( 
	
		REM using robocopy to copy all files, retaining directory timestamp (/DCOPY:DT) and copying empty folders (/E)
		IF %robobakdebug% EQU debug ROBOCOPY "%robobaksource%" "%robobaktarget%\%robobakfolder%"  /L /E /COPY:DT /DCOPY:DT /R:1 /W:1 /NP /TEE /LOG+:"%robobaktarget%\%robobakfolder%.txt"
		IF %robobakdebug% NEQ debug ROBOCOPY "%robobaksource%" "%robobaktarget%\%robobakfolder%"     /E /COPY:DT /DCOPY:DT /R:1 /W:1 /NP /TEE /LOG+:"%robobaktarget%\%robobakfolder%.txt"
	) ELSE (
		ECHO Something STRANGE has happened ...  robocopy did not start
		ECHO Something STRANGE has happened ... robocopy did not start>>%robobaktarget%\%robobakfolder%.txt
		GOTO :cleanup
	)
)


:cleanup

ECHO **********************************************************
ECHO  having used  robobak.bat  with the following parameters:
ECHO ----------------------------------------------------------
SET robo
SET CurrDay
SET CurrMonth
SET CurrYear
ECHO ----------------------------------------------------------
ECHO **********************************************************>>%robobaktarget%\%robobakfolder%.txt
ECHO  having used  robobak.bat  with the following parameters:>>%robobaktarget%\%robobakfolder%.txt
ECHO ---------------------------------------------------------->>%robobaktarget%\%robobakfolder%.txt
SET robo>>%robobaktarget%\%robobakfolder%.txt
ECHO ---------------------------------------------------------->>%robobaktarget%\%robobakfolder%.txt

ECHO ... just to make sure, cleanup by deleting variables after use - but actually not necessary because of SETLOCAL in the beginning

IF %robobakdebug% EQU debug (ECHO **************************************** & ECHO * we ran in debug mode, check log file * & ECHO **************************************** ) 

SET robobakcopymode=
SET robobakdebug=
SET robobakfolder=
SET robobakmode=
SET robobakmytime=
SET robobakrightnow=
SET robobaksource=
SET robobakname=
SET robobaksourcefolder=
SET robobaktarget=
SET CurrDay=
SET CurrMonth=
SET CurrYear=

GOTO :EOF

:displayhelp
ECHO.
ECHO robobak.bat v1-20220129 
ECHO a script for differential and full backups using robocopy, maintaining the date of directories, 
ECHO also copying empty directories (see robocopy command in batch file for details and settings)
ECHO licensed under the MIT license, use parameter /license to see the license text
ECHO.
ECHO Usage:
ECHO.================================================================================================
ECHO ^>robobak.bat [full^|diff] [debug^|nodebug] [targetpath] [sourcepath] [backupname - optional or !]
ECHO.
ECHO [full^|diff]       full creates a full backup, diff creates a differential backup using the archive bit which will be deleted after copy
ECHO [debug^|nodebug]   debug will run robocopy with option /L, also no folders will be created, a logfile is written to the target folder
ECHO [targetpath]      backups will go into targetpath, a folder and a logfile will be created in targetpath - do not use blanks
ECHO [sourcepath]      sourcepath to the files and folders you want to have backed up - do not use blanks
ECHO [backupname]      optional - if it is set, the backup folder and logfile will start with this name, 
ECHO                   if not set or "!" is used, the last folder's name of sourcepath is used
ECHO.
ECHO If you want to use robobak.bat within a batch file not requiring any manual input, you have to give all five parameters 
ECHO and you have to use as backupname "!" to have the last folder's name of the sourcepath to be used as backup folder name.
ECHO.
ECHO You can create a batch using only [full^|diff] [debug^|nodebug] [targetpath] [soucepath] to enter an own backupname 
ECHO manually from the console each time or you leave the last two entries empty using [full^|diff] [debug^|nodebug] [targetpath], 
ECHO so that you can enter each time a new source path to be backed up and optionally a backupname. 
ECHO NOTE: This is why the TARGET path has to be given BEFORE the SOURCE path in the parameter list!
ECHO.
PAUSE
ECHO --- batch example 1
ECHO.
ECHO ^>robobak.bat full nodebug D:\backups D:\myfiles\somefolder\Testordner1 !
ECHO.
ECHO       results in a folder for a full backup and a robocopy log file in:
ECHO.
ECHO D:\backups\Testordner1_full_yyyy-mm-dd_hh-mm-ss
ECHO D:\backups\Testordner1_full_yyyy-mm-dd_hh-mm-ss.txt
ECHO.
ECHO --- batch example 2
ECHO.
ECHO ^>robobak.bat diff nodebug D:\backups D:\myfiles\somefolder\Testordner1 MyBackup
ECHO.
ECHO       results in a folder for a differential backup and a robocopy log file in:
ECHO.
ECHO D:\backups\MyBackup_full_yyyy-mm-dd_hh-mm-ss
ECHO D:\backups\MyBackup_full_yyyy-mm-dd_hh-mm-ss.txt
ECHO.
ECHO --- batch example 3
ECHO.
ECHO ^>robobak.bat full debug D:\backups D:\myfiles\somefolder\Testordner1 MyBackup
ECHO.
ECHO       results in a test drive for a full backup where no folder is created and nothing copied but a robocopy log file is created with potential errors in:
ECHO.
ECHO D:\backups\MyBackup_full_yyyy-mm-dd_hh-mm-ss.txt

GOTO :EOF

:license
ECHO SPDX-License-Identifier: MIT
ECHO.
ECHO Copyright (c) 2021-<today> nachtschicht 90715870+gutenachtschicht@users.noreply.github.com
ECHO.
ECHO Permission is hereby granted, free of charge, to any person obtaining a copy of this 
ECHO software and associated documentation files (the "Software"), to deal in the Software 
ECHO without restriction, including without limitation the rights to use, copy, modify, 
ECHO merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
ECHO permit persons to whom the Software is furnished to do so, subject to the following 
ECHO conditions:
ECHO.
ECHO The above copyright notice and this permission notice shall be included in all copies 
ECHO or substantial portions of the Software.
ECHO.
ECHO THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
ECHO INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
ECHO PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
ECHO HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
ECHO CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
ECHO THE USE OR OTHER DEALINGS IN THE SOFTWARE.


