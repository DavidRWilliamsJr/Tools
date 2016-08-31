@ECHO OFF
::Tool to easily update BitLocker info for a machine in Active Directory.
::By David Williams
SETLOCAL ENABLEDELAYEDEXPANSION
::Get the BitLocker info and store it in a txt file.
manage-bde -protectors -get c: >bde-output.txt
::Find the line number for the BitLocker ID
SET line_number=
FOR /F "delims=:" %%a IN ('findstr /I /N /C:"Numerical Password" bde-output.txt') do (
   SET /A after=%%a+1
   SET "line_number=!after!: "
)
::Search for the line specific to the ID, grab the ID and pass it to AD
FOR /F "tokens=2* delims=:" %%a IN ('findstr /NRC:"{" bde-output.txt ^| findstr /B "%line_number%"') DO CALL :SAVE_ID %%b
GOTO :AD
:SAVE_ID
SET BL_ID=%~1
EXIT /b
:AD
::Save the BitLocker key in AD, delete the txt file for security.
manage-bde -protectors -adbackup c: -id %BL_ID%
del bde-output.txt
