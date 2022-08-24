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
::  nupkg file
::  repo URL
::

setlocal


:: check for requirements
where 7z > nul && (
  echo CHECK: 7z installed
) || (
  echo ERROR: 7z not installed & goto ERROR
)


:: process arguments
if [%1]==[] ( goto ERROR
) else ( set NUPKG=%1 )

if [%2]==[] ( goto ERROR
) else ( set REPO_URL="%2" )


:: get package id
for /F "delims=. tokens=1" %%p in ( 'echo %NUPKG%' ) do ( set PKG_ID=%%p
) || (
  echo ERROR: PKG_ID could not be determined & goto ERROR
)
echo CHECK: using PKG_ID = %PKG_ID%


:: extract manifest
7z e %NUPKG% -o. %PKG_ID%.nuspec -r > nul && (
  echo CHECK: manifest file extraction successful
) || (
  echo ERROR: manifest extraction failed & goto ERROR
)


:: create scratch manifest with repair
set "ELEMENT=    ^<repository type="git" url=%REPO_URL% /^>"
set TARGET="  </metadata>"

for /F tokens^=*^ delims^=^ eol^= %%n in ( %PKG_ID%.nuspec ) do (
  if not "%%n" == %TARGET% (echo %%n >> scratch.txt )
  if "%%n" == %TARGET% ( echo %ELEMENT% >> scratch.txt & echo %%n >> scratch.txt )
)


:: replace manifest
move /y scratch.txt %PKG_ID%.nuspec
7z u %NUPKG% %PKG_ID%.nuspec > nul && (
  echo CHECK: manifest file replaced successfully
) || (
  echo ERROR: manifest replacement failed & goto ERROR
)


:: clean up
del /q %PKG_ID%.nuspec


exit /b 0

:ERROR
echo ERROR: package repair exiting with errors
exit /b 1
