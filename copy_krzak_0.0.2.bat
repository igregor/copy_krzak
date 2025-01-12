::===============================================================
:: copy_krzak
:: Helps photographers organizing orders
:: 
:: version: 0.0.2
:: author: Greg Grzegorz Wojtanowicz
:: email: wojtanowiczgrzegorz@gmail.com
::
::===============================================================


@echo off
rem @g.wojtanowicz read more https://stackoverflow.com/questions/10558316/example-of-delayed-expansion-in-batch-file
rem @g.wojtanowicz read more https://stackoverflow.com/questions/38650536/batch-file-to-copy-and-rename-files-from-multiple-directories#38658281
rem @g.wojtanowicz read more https://stackoverflow.com/questions/38650536/batch-file-to-copy-and-rename-files-from-multiple-directories#38658281
rem @g.wojtanowicz read more https://www.alttechnical.com/knowledge-base/windows/102-file-name-variables-in-windows-batch

SET execution_path=%~dp0
echo %execution_path:~0,-1%

rem @g.wojtanowicz Create output file if does not exist
set output_dir_name=TU_ZADZIALA_SIE_MAGIA
set output_dir_produkty=%output_dir_name%\produkty
set output_dir_pliki=%output_dir_name%\pliki
set output_dir_10x15=%output_dir_name%\10x15
set output_dir_15x23=%output_dir_name%\15x23
set output_dir_20x30=%output_dir_name%\20x30
set output_dir_30x45=%output_dir_name%\30x45
set output_dir_nieobsluzone_przez_program=%output_dir_name%\nieobsluzone_przez_program

rem @g.wojtanowicz TEMP! remove the directory for development perspective
rmdir /S /Q %output_dir_name%
rem @g.wojtanowicz end TEMP!

call :create-output-directory-if-not-exists %output_dir_name%

rem @g.wojtanowicz loop directories to look for files
echo gregorek: starting looping the directories
for /R %%J in (*.jpg) do (
    echo
    echo -------------------------- start of file --------------------------
    call :process-jpg-file "%%~nJ", "%%~xJ", "%%~dpJ", "%%~nxJ", "%%~fJ"
    echo --------------------------- end of file ---------------------------
)

exit /B 0

:create-output-directory-if-not-exists
    echo gregorek: calling create-output-directory-if-not-exists() with %~1
    
    setlocal enabledelayedexpansion
    set local_output_name=%~1
    rem @g.wojtanowicz read more: https://stackoverflow.com/questions/17743757/how-to-concatenate-strings-in-windows-batch-file-for-loop
    set "local_output_name_check=%local_output_name%/*"
    set local_error="nie to ma byc"

    if not exist %local_output_name_check% (
        echo gregorek: %local_output_name% does not exist, I am creating one now
        md %output_dir_produkty%
        md %output_dir_pliki%
        md %output_dir_10x15%
        md %output_dir_15x23%
        md %output_dir_20x30%
        md %output_dir_30x45%
        md %output_dir_nieobsluzone_przez_program%
        echo gregorek: directory %local_output_name% created
    ) else (
        set "local_error=gregorek: directory %local_output_name% already exists"
        echo gregorek: !local_error!
        call :terminate-with-error "!local_error!"
    )
    endlocal
    exit /B 0
goto:eof

:terminate-with-error
    echo gregorek: TODO errrroooooorrrrrrrr %~1
    exit /B 0
goto:eof

:process-jpg-file
    echo gregorek: process-jpg-file() with %~1 %~2 %~3 %~4 %~5
    setlocal enabledelayedexpansion
    set local_file_name=%~1
    set local_file_extension=%~2
    set local_file_path=%~3
    set local_file_name_with_extension=%~4
    set local_file_path_with_name_and_extension=%~5
    
    rem @g.wojtanowicz read more: https://stackoverflow.com/questions/38853942/string-replace-with-variable-in-batch
    call set relative_path=%%local_file_path:!execution_path!=%%

    
    echo execution_path %execution_path%
    echo local_file_name %local_file_name%
    echo local_file_extension %local_file_extension%
    echo local_file_name_with_extension %local_file_name_with_extension%
    echo local_file_path %local_file_path%
    echo local_file_path_with_name_and_extension %local_file_path_with_name_and_extension%
    echo relative_path = !relative_path!

    setlocal enabledelayedexpansion
    set odbitka_keyword=odbitki
    set produkt_keyword=produkty
    set plik_keyword=pliki

    rem read more: https://stackoverflow.com/questions/38853942/string-replace-with-variable-in-batch
    rem @g.wojtanowicz check if full path does not contain odbitka_keyword
    if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%odbitka_keyword%=!" (
        rem it is odbitka
        call :process-odbitka "%local_file_name_with_extension%" "%relative_path%"
    ) else (
        rem @g.wojtanowicz check if full path does not contain produkt_keyword
        if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%produkt_keyword%=!" (
            rem it is produkt
            call :process-produkt "%local_file_name_with_extension%" "%relative_path%"
        ) else (
            rem @g.wojtanowicz check if full path does not contain plik_keyword
            if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%plik_keyword%=!" (
                rem it is plik!
                call :process-plik "%local_file_name_with_extension%" "%relative_path%"
            ) else (
               rem @g.wojtanowicz all other unhandled files
               call :process-other "%local_file_name_with_extension%" "%relative_path%"
            )
        ) 
    )
    endLocal

    exit /B 0
goto:eof

:process-odbitka
    echo gregorek: process-odbitka() with %~1 %~2
    setlocal enabledelayedexpansion
    set local_file_name=%~1
    set relative_path=%~2
    
    rem @g.wojtanowicz https://stackoverflow.com/questions/11419046/how-do-i-return-a-value-from-a-function-in-a-batch-file
    set "returned_new_name="
    call :get_parsed_name "%local_file_name%","%relative_path%",returned_new_name
    
    
    rem @g.wojtanowicz check number of copies to be made
    rem the direct parent directory is a numeric value of number of copies - that's the convention of the source folder structure
    rem read more https://stackoverflow.com/questions/17279114/split-path-and-take-last-folder-name-in-batch-script
    if "%relative_path:~-1%" == "\" set "temp_dir=%relative_path:~0,-1%"
    for %%f in ("%temp_dir%") do set "direct_parent_directory=%%~nxf"
    set number_of_copies=%direct_parent_directory%
    echo number of copies to be made: %number_of_copies%

    rem @g.wojtanowicz choose correct directory to store the file in

    set format_10x15_keyword=10x15
    set format_15x23_keyword=15x23
    set format_20x30_keyword=20x30
    set format_30x45_keyword=30x45

    rem read more: https://stackoverflow.com/questions/38853942/string-replace-with-variable-in-batch
    rem @g.wojtanowicz check if full path does not contain odbitka_keyword
    if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%format_10x15_keyword%=!" (
        rem it is 10x15
        call :copy-jpg-file "%relative_path%%local_file_name%" "%output_dir_10x15%\%returned_new_name%" %number_of_copies%
    ) else (
        if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%format_15x23_keyword%=!" (
            rem it is 15x23
            call :copy-jpg-file "%relative_path%%local_file_name%" "%output_dir_15x23%\%returned_new_name%" %number_of_copies%
        ) else (
            if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%format_20x30_keyword%=!" (
                rem it is 20x30
                call :copy-jpg-file "%relative_path%%local_file_name%" "%output_dir_20x30%\%returned_new_name%" %number_of_copies%
            ) else (
                if not "%local_file_path_with_name_and_extension%"=="!local_file_path_with_name_and_extension:%format_30x45_keyword%=!" (
                    rem it is 30x45
                    call :copy-jpg-file "%relative_path%%local_file_name%" "%output_dir_30x45%\%returned_new_name%" %number_of_copies%
                ) else (
                    rem it is not supported
                    call :copy-jpg-file "%relative_path%%local_file_name%" "%output_dir_nieobsluzone_przez_program%\%returned_new_name%" %number_of_copies%
                )
            )
        )    
    )

    endlocal

    exit /B 0
goto:eof

:process-plik
    echo gregorek: process-plik() with %~1 %~2
    setlocal enabledelayedexpansion
    set local_file_name=%~1
    set relative_path=%~2
    
    rem @g.wojtanowicz read more: https://stackoverflow.com/questions/11419046/how-do-i-return-a-value-from-a-function-in-a-batch-file
    set "returned_new_name="
    call :get_parsed_name "%local_file_name%","%relative_path%",returned_new_name
    
    copy /B /Y "%relative_path%%local_file_name%" "%output_dir_pliki%\%returned_new_name%"

    endlocal

    exit /B 0
goto:eof

:process-produkt
    echo gregorek: process-produkt() with %~1 %~2
    setlocal enabledelayedexpansion
    set local_file_name=%~1
    set relative_path=%~2
    
    rem @g.wojtanowicz https://stackoverflow.com/questions/11419046/how-do-i-return-a-value-from-a-function-in-a-batch-file
    set "returned_new_name="
    call :get_parsed_name "%local_file_name%","%relative_path%",returned_new_name
    
    copy /B /Y "%relative_path%%local_file_name%" "%output_dir_produkty%\%returned_new_name%"
    
    endlocal

    exit /B 0
goto:eof

:process-other
    echo gregorek: process-other() with %~1 %~2
    setlocal enabledelayedexpansion
    set local_file_name=%~1
    set relative_path=%~2
    
    rem @g.wojtanowicz https://stackoverflow.com/questions/11419046/how-do-i-return-a-value-from-a-function-in-a-batch-file
    set "returned_new_name="
    call :get_parsed_name "%local_file_name%","%relative_path%",returned_new_name
    
    copy /B /Y "%relative_path%%local_file_name%" "%output_dir_nieobsluzone_przez_program%\%returned_new_name%"
    
    endlocal

    exit /B 0
goto:eof

:get_parsed_name
    echo gregorek: get_parsed_name() with %~1 %~2

    set local_file_name=%~1
    set relative_path=%~2
    
    set replaced_slash=%relative_path:\=____%
    set parsed_name=%replaced_slash%%local_file_name%

    rem @g.wojtanowicz read more why this: https://stackoverflow.com/questions/11419046/how-do-i-return-a-value-from-a-function-in-a-batch-file
    set "%~3=%parsed_name%"
    exit /B 0
goto:eof

:copy-jpg-file
    echo gregorek: copy-jpg-file() with %~1 %~2 %~3
    setlocal enabledelayedexpansion
    set source=%~1
    set destination=%~2
    
    set number_of_copies=%~3

    rem @g.wojtanowicz read more: https://stackoverflow.com/questions/25293670/windows-batch-file-to-make-multiple-copies-of-a-single-file-with-each-copy-bein

    echo
    echo %%~nxdestination
    echo number_of_copies: %number_of_copies%
    for /l %%A in (1,1,%number_of_copies%) do (
        if %%A==1 (
            echo copying %source% to: "%destination%"

            copy /B /Y "%source%" "%destination%"
        ) else (
            setlocal enabledelayedexpansion
            set extension=.jpg
            set incremental_name=-kopia-%%A.jpg
    
            rem @g.wojtanowicz read more: https://stackoverflow.com/questions/38853942/string-replace-with-variable-in-batch
            call set incremental_destination=%%destination:!extension!=!incremental_name!%%
            
            echo copying %source% to: "!incremental_destination!"

            copy /B /Y "%source%" "!incremental_destination!"
            
            endlocal
        ) 
    )
    exit /B 0
goto:eof


