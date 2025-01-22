@echo off
REM CopyFolder.bat - Copies contents from one folder to another

REM Set the source and destination folders
set "source=C:\xampp\htdocs\memberlink\"
set "destination=C:\Users\slumb\Documents\GitHub\FlutterA241\my_member_link\server\memberlink\"

REM Check if source folder exists
if not exist "%source%" (
    echo Source folder "%source%" does not exist.
    goto :eof
)

REM Create destination folder if it doesn't exist
if not exist "%destination%" (
    mkdir "%destination%"
)

REM Copy files and subdirectories from source to destination
xcopy "%source%\*" "%destination%\" /E /I /Y

echo Files have been copied successfully from "%source%" to "%destination%".
pause
