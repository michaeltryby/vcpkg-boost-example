::
:: Purpose: Adds repository metadata to a vcpkg-export nuget package
::
:: Created: Aug 24, 2022
:: Updated:
::
:: Author: Michael E. Tryby
::
:: Requires:
::  7zip
::
:: Required arguments:
::  "repo URL" (quoted)
::
:: Note: Run in same directory as PACKAGE
::

setlocal


:: check if on an Actions runner or local
if not defined GITHUB_ENV (
  set GITHUB_ENV=nul
)

:: check for requirements
where 7z > nul && (
  echo CHECK: 7z installed
) || (
  echo ERROR: 7z not installed & goto ERROR
)


:: process arguments
if [%1]==[] ( goto ERROR
) else ( set REPO_URL=%1 )


:: get package name and id
for /F "tokens=*" %%p in ( 'dir *.nupkg /B' ) do ( set PACKAGE=%%p )
for /F "delims=. tokens=1" %%p in ( 'echo %PACKAGE%' ) do ( set PKG_ID=%%p
) || (
  echo ERROR: PKG_ID could not be determined & goto ERROR
)
echo CHECK: using PKG_ID = %PKG_ID%

:: GitHub Actions
echo PACKAGE=%PACKAGE%>> %GITHUB_ENV%


:: extract manifest
7z e %PACKAGE% -o. %PKG_ID%.nuspec -r > nul && (
  echo CHECK: manifest file extraction successful
) || (
  echo ERROR: manifest extraction failed & goto ERROR
)


:: create scratch manifest with repository element
set "ELEMENT=    ^<repository type="git" url=%REPO_URL% /^>"
set TARGET="  </metadata>"

for /F tokens^=*^ delims^=^ eol^= %%n in ( %PKG_ID%.nuspec ) do (
  if not "%%n" == %TARGET% (echo %%n >> scratch.txt )
  if "%%n" == %TARGET% ( echo %ELEMENT% >> scratch.txt & echo %%n >> scratch.txt )
)


:: replace manifest
move /y scratch.txt %PKG_ID%.nuspec

7z u %PACKAGE% %PKG_ID%.nuspec > nul && (
  echo CHECK: manifest replacement successful
) || (
  echo ERROR: manifest replacement failed & goto ERROR
)


:: clean up
del /q %PKG_ID%.nuspec


exit /B 0

:ERROR
echo ERROR: package repair exiting with errors
exit /B 1
