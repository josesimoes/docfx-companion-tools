# This is the script to build and zip the executables
# from the solutions.

# Include settings and common functions
$scriptRoot = $($MyInvocation.MyCommand.Definition) | Split-Path
. "$scriptRoot/tools/config.ps1"
. "$scriptRoot/tools/common.ps1"

# Clean output first
if (Test-Path -Path $solution.targetFolder) {
    Remove-Item $solution.targetFolder -Recurse
}
if (Test-Path -Path $solution.assetZipPath) {
    Remove-Item $solution.assetZipPath
}

# Build all dotnet solution into $solution.targetFolder as single exe's
foreach ($sln in (Get-ChildItem -Recurse src\*.sln)) {
    Write-Host "Start building $($sln.FullName)"

    & dotnet publish $sln.FullName -c Release -r win-x64 /p:PublishSingleFile=true /p:CopyOutputSymbolsToPublishDirectory=false --self-contained false -o $solution.targetFolder
}

# remove possible generated XML documentation files
Remove-Item "$($solution.targetFolder)\*.xml"
# Copy license to the folder to package
Copy-Item LICENSE $solution.targetFolder
# Zip targetFolder
PackAssetZip $solution.targetFolder $solution.assetZipPath