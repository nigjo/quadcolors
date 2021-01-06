@echo off
setlocal
pushd "%~dp0"

if exist "%~n0.private.cmd" call "%~n0.private.cmd"

if not defined sevenzip_home set "sevenzip_home=%PROGRAMFILES%\7-Zip"
if not defined love2d_home set "love2d_home=%CD%\..\love-11.3-win64"
if not defined deploydir set "deploydir=deploy.love"

(
echo *.lua
echo res\frame.png
echo res\frame64.png
echo res\DejaVuSans.ttf
echo lib\button\button.lua
echo lib\voronoi\voronoi.lua
)>pack.lst

set appbase=colors-%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%%TIME:~0,2%%TIME:~3,2%

if not exist "%deploydir%" md "%deploydir%"

"%sevenzip_home%\7z.exe" a -tzip "%deploydir%\%appbase: =0%.love" @pack.lst

copy /B "%love2d_home%\love.exe"+"%deploydir%\%appbase: =0%.love" "%appbase: =0%.exe"

(
echo %appbase: =0%.exe
echo %love2d_home%\license.txt
echo %love2d_home%\love.dll
echo %love2d_home%\lua51.dll
echo %love2d_home%\mpg123.dll
echo %love2d_home%\OpenAL32.dll
echo %love2d_home%\SDL2.dll
)>pack.lst

"%sevenzip_home%\7z.exe" a -tzip "%deploydir%\%appbase: =0%.zip" @pack.lst
move "%appbase: =0%.exe" %deploydir%

del pack.lst