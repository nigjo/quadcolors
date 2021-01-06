@echo off
setlocal

call :checkFolder voronoi "https://github.com/nigjo/iVoronoi.git"
call :checkFolder button "https://gist.github.com/da0c7e596eff6cd0703bd70880e6b0a7.git"
rem call :checkFolder suit "https://github.com/vrld/suit.git"

title done - %~nx0
goto :eof
:checkFolder
title "%~1" - %~nx0
if exist "%~1\.git" (
  pushd "%~1"
  git pull 
  popd
) else if exist "%~1\.svn" (
  svn update "%~1"
) else if "%~x2" == ".git" (
  git clone "%~2" "%~1"
) else (
  svn checkout "%~2" "%~1"
)