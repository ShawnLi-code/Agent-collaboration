param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName
)

$ErrorActionPreference = "Stop"

function Convert-ToSlug {
    param([string]$Value)

    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9\u4e00-\u9fff]+", "-"
    $slug = $slug.Trim("-")

    if ([string]::IsNullOrWhiteSpace($slug)) {
        throw "ProjectName must contain at least one letter, number, or CJK character."
    }

    return $slug
}

$root = (Resolve-Path ".").Path
$slug = Convert-ToSlug $ProjectName
$projectRoot = Join-Path $root "projects\$slug"
$templateProject = Join-Path $root "projects\_template"

if (Test-Path $projectRoot) {
    throw "Project already exists: $projectRoot"
}

if (-not (Test-Path $templateProject)) {
    throw "Project template not found: $templateProject"
}

New-Item -ItemType Directory -Path $projectRoot | Out-Null
New-Item -ItemType Directory -Path (Join-Path $projectRoot "source") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $projectRoot "docs") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $projectRoot "outputs") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $projectRoot ".agent-work") | Out-Null

Copy-Item -LiteralPath (Join-Path $templateProject "PROJECT.md") -Destination (Join-Path $projectRoot "PROJECT.md")

$projectFile = Join-Path $projectRoot "PROJECT.md"
$content = Get-Content -Raw -LiteralPath $projectFile
$content = $content -replace "Replace with project name\.", $ProjectName
Set-Content -LiteralPath $projectFile -Value $content -Encoding UTF8

Write-Host "Created project: $projectRoot"
Write-Host "Next: add source files, then run:"
Write-Host ".\scripts\New-AgentTask.ps1 -Project `"$slug`" -TaskName `"first task`""

