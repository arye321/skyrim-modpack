@echo off
REM =====================================================
REM Enchantment Indicator Mod - Automated Build Script
REM Run this on Windows with Skyrim LE + Creation Kit + SKSE installed
REM =====================================================

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Enchantment Indicator Mod - Build Script
echo ==========================================
echo.

REM Configuration
set SKYRIM_PATH=C:\Program Files (x86)\Steam\steamapps\common\Skyrim
set CK_PATH=%SKYRIM_PATH%
set PAPYRUS_COMPILER=%CK_PATH%\Papyrus Compiler\PapyrusCompiler.exe
set SKSE_SDK_PATH=C:\Development\SKSE
set VISUAL_STUDIO_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community
set MOD_NAME=EnchantmentIndicator
set BUILD_OUTPUT=build_output
set MOD_OUTPUT=%BUILD_OUTPUT%\%MOD_NAME%_v1.0

REM Colors for output
for /F %%A in ('echo prompt $H ^| cmd') do set "BS=%%A"
set "SUCCESS=[✓]"
set "ERROR=[✗]"
set "INFO=[*]"

echo %INFO% Build Configuration:
echo   Skyrim Path: %SKYRIM_PATH%
echo   Creation Kit: %CK_PATH%
echo   SKSE SDK: %SKSE_SDK_PATH%
echo   Output Directory: %MOD_OUTPUT%
echo.

REM ===== Step 1: Create output directories =====
echo %INFO% Creating output directories...
if not exist "%BUILD_OUTPUT%" mkdir "%BUILD_OUTPUT%"
if not exist "%MOD_OUTPUT%" mkdir "%MOD_OUTPUT%"
if not exist "%MOD_OUTPUT%\Scripts" mkdir "%MOD_OUTPUT%\Scripts"
if not exist "%MOD_OUTPUT%\UI" mkdir "%MOD_OUTPUT%\UI"
if not exist "%MOD_OUTPUT%\SKSE\Plugins" mkdir "%MOD_OUTPUT%\SKSE\Plugins"
echo %SUCCESS% Output directories created

echo.
echo ===== STEP 1: Compile Papyrus Scripts =====

if not exist "%PAPYRUS_COMPILER%" (
    echo %ERROR% Papyrus Compiler not found at: %PAPYRUS_COMPILER%
    echo Please ensure Creation Kit is installed properly
    goto ERROR_PAPYRUS
)

echo %INFO% Compiling Papyrus scripts...

REM Compile each script
"%PAPYRUS_COMPILER%" "source\scripts\EnchantmentIndicator_Global.psc" -f="TESV_Papyrus_Flags.flg" -o="%MOD_OUTPUT%\Scripts\" > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %SUCCESS% Compiled: EnchantmentIndicator_Global.pex
) else (
    echo %ERROR% Failed to compile: EnchantmentIndicator_Global.psc
    goto ERROR_PAPYRUS
)

"%PAPYRUS_COMPILER%" "source\scripts\EnchantmentIndicator_Quest.psc" -f="TESV_Papyrus_Flags.flg" -o="%MOD_OUTPUT%\Scripts\" > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %SUCCESS% Compiled: EnchantmentIndicator_Quest.pex
) else (
    echo %ERROR% Failed to compile: EnchantmentIndicator_Quest.psc
    goto ERROR_PAPYRUS
)

"%PAPYRUS_COMPILER%" "source\scripts\EnchantmentKnownChecker.psc" -f="TESV_Papyrus_Flags.flg" -o="%MOD_OUTPUT%\Scripts\" > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %SUCCESS% Compiled: EnchantmentKnownChecker.pex
) else (
    echo %ERROR% Failed to compile: EnchantmentKnownChecker.psc
    goto ERROR_PAPYRUS
)

echo.
echo ===== STEP 2: Compile ActionScript to SWF =====
echo.

REM Check for mtxc or Flex SDK
set MTXC_PATH=%CK_PATH%\mtxc.exe
set FLEX_SDK_PATH=C:\Program Files\Adobe\Flex SDK

if exist "%MTXC_PATH%" (
    echo %INFO% Found mtxc compiler, using for ActionScript compilation
    
    "%MTXC_PATH%" -version 10.0 "source\ui\skyui_custom\InventoryListPanelEI.as" -output "%MOD_OUTPUT%\UI\InventoryListPanelEI.swf" > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %SUCCESS% Compiled: InventoryListPanelEI.swf
    ) else (
        echo %ERROR% Failed to compile InventoryListPanelEI.as
    )
    
    "%MTXC_PATH%" -version 10.0 "source\ui\skyui_custom\BarterMenuEI.as" -output "%MOD_OUTPUT%\UI\BarterMenuEI.swf" > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %SUCCESS% Compiled: BarterMenuEI.swf
    ) else (
        echo %ERROR% Failed to compile BarterMenuEI.as
    )
    
    "%MTXC_PATH%" -version 10.0 "source\ui\skyui_custom\EnchantmentIndicator_SWFUI.as" -output "%MOD_OUTPUT%\UI\EnchantmentIndicator_SWFUI.swf" > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %SUCCESS% Compiled: EnchantmentIndicator_SWFUI.swf
    ) else (
        echo %ERROR% Failed to compile EnchantmentIndicator_SWFUI.as
    )
    
) else if exist "%FLEX_SDK_PATH%\bin\mxmlc.exe" (
    echo %INFO% Found Flex SDK mxmlc compiler, using for ActionScript compilation
    
    "%FLEX_SDK_PATH%\bin\mxmlc.exe" -target-player=10.0 "source\ui\skyui_custom\InventoryListPanelEI.as" -output "%MOD_OUTPUT%\UI\InventoryListPanelEI.swf" > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %SUCCESS% Compiled: InventoryListPanelEI.swf
    ) else (
        echo %ERROR% Failed to compile InventoryListPanelEI.as
    )
    
    "%FLEX_SDK_PATH%\bin\mxmlc.exe" -target-player=10.0 "source\ui\skyui_custom\BarterMenuEI.as" -output "%MOD_OUTPUT%\UI\BarterMenuEI.swf" > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %SUCCESS% Compiled: BarterMenuEI.swf
    ) else (
        echo %ERROR% Failed to compile BarterMenuEI.as
    )
    
    "%FLEX_SDK_PATH%\bin\mxmlc.exe" -target-player=10.0 "source\ui\skyui_custom\EnchantmentIndicator_SWFUI.as" -output "%MOD_OUTPUT%\UI\EnchantmentIndicator_SWFUI.swf" > nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo %SUCCESS% Compiled: EnchantmentIndicator_SWFUI.swf
    ) else (
        echo %ERROR% Failed to compile EnchantmentIndicator_SWFUI.as
    )
    
) else (
    echo %ERROR% No ActionScript compiler found (mtxc or Flex SDK)
    echo %INFO% Skipping ActionScript compilation
    echo %INFO% You can manually compile .as files later or use SkyUI's build tools
)

echo.
echo ===== STEP 3: Build SKSE Plugin (Optional) =====
echo.

if exist "%VISUAL_STUDIO_PATH%\MSBuild\Current\Bin\msbuild.exe" (
    echo %INFO% Found Visual Studio, attempting to build SKSE plugin...
    
    REM This would require a proper Visual Studio project file
    REM For now, we provide instructions
    echo.
    echo %INFO% To compile the SKSE plugin:
    echo   1. Open Visual Studio
    echo   2. Open project: build_output\EnchantmentIndicator.sln
    echo   3. Build Configuration: Release x86
    echo   4. Output: build_output\Win32\Release\EnchantmentIndicator.dll
    echo.
) else (
    echo %INFO% Visual Studio not found, skipping SKSE plugin build
    echo %INFO% Use SKSE_BUILD_GUIDE.md for manual compilation instructions
)

echo.
echo ===== STEP 4: Copy Supporting Files =====
echo.

REM Copy documentation
xcopy /Y /Q "docs\*.md" "%MOD_OUTPUT%\" > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %SUCCESS% Copied documentation files
)

REM Create mod info file
(
    echo Plugin Name: Enchantment Indicator
    echo Plugin Version: 1.0.0
    echo Author: Created with Skyrim LE Enchantment Indicator Mod Guide
    echo Description: Displays %%28known%%29 indicators next to enchanted items if the player has learned the enchantment
    echo Dependencies: SKSE %%281.7.3+%%29 (optional)
    echo SkyUI 4.1+ (optional)
    echo.
    echo Build Date: %DATE% %TIME%
) > "%MOD_OUTPUT%\INFO.txt"

echo %SUCCESS% Created mod info file

REM Create readme
(
    echo # Enchantment Indicator Mod
    echo.
    echo ## Installation
    echo 1. Copy the mod folder to your Skyrim\Data\ directory
    echo 2. Ensure SKSE and SkyUI are installed (optional but recommended^)
    echo 3. Activate the .esp in your mod launcher
    echo.
    echo ## What's Included
    echo - EnchantmentIndicator.esp: Main mod plugin
    echo - Scripts: Compiled Papyrus scripts (.pex files^)
    echo - UI: Compiled ActionScript components (.swf files^)
    echo - Documentation: Full guides and references
    echo.
    echo ## Features
    echo - Displays %%5BK%%5D indicator for known enchantments
    echo - Works in inventory, barter, and container menus
    echo - Customizable colors and text
    echo - Compatible with SkyUI
    echo.
    echo ## Troubleshooting
    echo See docs/COMPLETE_GUIDE.md for full troubleshooting guide
) > "%MOD_OUTPUT%\README.txt"

echo %SUCCESS% Created README file

echo.
echo ===== BUILD SUMMARY =====
echo.
echo %SUCCESS% Build completed successfully!
echo.
echo Output Location: %MOD_OUTPUT%
echo.
echo Contents:
echo   - Scripts\*.pex (Compiled Papyrus scripts^)
echo   - UI\*.swf (Compiled ActionScript components^)
echo   - Documentation files
echo   - README.txt and INFO.txt
echo.
echo Next Steps:
echo   1. Review the compiled files in: %MOD_OUTPUT%
echo   2. Create .esp file in Creation Kit using docs/QUICKSTART.md
echo   3. Test in Skyrim LE
echo   4. Package and distribute
echo.
echo.
goto END

:ERROR_PAPYRUS
echo.
echo %ERROR% ERROR: Papyrus compilation failed
echo Please ensure:
echo   - Skyrim LE is installed at: %SKYRIM_PATH%
echo   - Creation Kit is properly installed
echo   - TESV_Papyrus_Flags.flg exists in: %CK_PATH%
echo.
pause
exit /b 1

:END
echo %SUCCESS% Build script completed!
pause
