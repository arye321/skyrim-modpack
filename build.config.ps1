# Build configuration for Enchantment Indicator Mod

# Skyrim paths (adjust to your system)
$skyrimPath = "C:\Program Files (x86)\Steam\steamapps\common\Skyrim"
$ckPath = $skyrimPath
$papyrusCompiler = Join-Path $ckPath "Papyrus Compiler\PapyrusCompiler.exe"
$skseSdkPath = "C:\Development\SKSE"
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community"

# Output configuration
$modName = "EnchantmentIndicator"
$modVersion = "1.0.0"
$buildOutput = "build_output"
$modOutput = Join-Path $buildOutput "${modName}_v${modVersion}"

# Compiler paths
$mtxcPath = Join-Path $ckPath "mtxc.exe"
$flexSdkPath = "C:\Program Files\Adobe\Flex SDK"
$msbuildPath = Join-Path $vsPath "MSBuild\Current\Bin\msbuild.exe"

# Script sources
$scriptSources = @(
    "source\scripts\EnchantmentIndicator_Global.psc",
    "source\scripts\EnchantmentIndicator_Quest.psc",
    "source\scripts\EnchantmentKnownChecker.psc"
)

# ActionScript sources
$actionScriptSources = @(
    "source\ui\skyui_custom\InventoryListPanelEI.as",
    "source\ui\skyui_custom\BarterMenuEI.as",
    "source\ui\skyui_custom\EnchantmentIndicator_SWFUI.as"
)

# Papyrus compiler flags
$papyrusFlags = "TESV_Papyrus_Flags.flg"

# Export these for use in build scripts
Export-ModuleMember -Variable @(
    'skyrimPath', 'ckPath', 'papyrusCompiler', 'skseSdkPath', 'vsPath',
    'modName', 'modVersion', 'buildOutput', 'modOutput',
    'mtxcPath', 'flexSdkPath', 'msbuildPath',
    'scriptSources', 'actionScriptSources', 'papyrusFlags'
)
