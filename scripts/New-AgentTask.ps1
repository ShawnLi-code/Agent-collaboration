param(
    [Parameter(Mandatory = $true)]
    [string]$Project,

    [Parameter(Mandatory = $true)]
    [string]$TaskName,

    [switch]$CreateBranches
)

$ErrorActionPreference = "Stop"

function Convert-ToSlug {
    param([string]$Value)

    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9\u4e00-\u9fff]+", "-"
    $slug = $slug.Trim("-")

    if ([string]::IsNullOrWhiteSpace($slug)) {
        throw "Value must contain at least one letter, number, or CJK character."
    }

    return $slug
}

$root = (Resolve-Path ".").Path
$projectSlug = Convert-ToSlug $Project
$taskSlug = Convert-ToSlug $TaskName
$projectRoot = Join-Path $root "projects\$projectSlug"
$agentRoot = Join-Path $projectRoot ".agent-work"
$templateRoot = Join-Path $root "templates\task-package"

if (-not (Test-Path $projectRoot)) {
    throw "Project not found: $projectRoot. Create it with scripts\New-AgentProject.ps1 first."
}

if (-not (Test-Path $templateRoot)) {
    throw "Task template not found: $templateRoot"
}

if (-not (Test-Path $agentRoot)) {
    New-Item -ItemType Directory -Path $agentRoot | Out-Null
}

$date = Get-Date -Format "yyyy-MM-dd"
$taskDirName = "task-$date-$taskSlug"
$taskDir = Join-Path $agentRoot $taskDirName

if (Test-Path $taskDir) {
    throw "Task package already exists: $taskDir"
}

New-Item -ItemType Directory -Path $taskDir | Out-Null

$files = @(
    "brief.md",
    "plan.md",
    "codex-notes.md",
    "claude-review.md",
    "trae-notes.md",
    "risks.md",
    "decisions.md",
    "done.md",
    "experiments.md"
)

foreach ($file in $files) {
    Copy-Item -LiteralPath (Join-Path $templateRoot $file) -Destination (Join-Path $taskDir $file)
}

$briefPath = Join-Path $taskDir "brief.md"
$brief = Get-Content -Raw -LiteralPath $briefPath
$brief = $brief -replace "Describe the concrete outcome\.", "Describe the concrete outcome for: $TaskName."
Set-Content -LiteralPath $briefPath -Value $brief -Encoding UTF8

$isGitRepo = $false
git -C $root rev-parse --is-inside-work-tree *> $null
$isGitRepo = $LASTEXITCODE -eq 0

if ($CreateBranches) {
    if (-not $isGitRepo) {
        throw "CreateBranches requires a Git repository."
    }

    git -C $root rev-parse --verify HEAD *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "CreateBranches requires at least one Git commit."
    }

    $branchNames = @(
        "agent/$projectSlug/$taskSlug/main",
        "agent/$projectSlug/$taskSlug/codex",
        "agent/$projectSlug/$taskSlug/claude",
        "agent/$projectSlug/$taskSlug/trae",
        "agent/$projectSlug/$taskSlug/review"
    )

    foreach ($branch in $branchNames) {
        git -C $root show-ref --verify --quiet "refs/heads/$branch"
        if ($LASTEXITCODE -eq 0) {
            Write-Warning "Branch already exists: $branch"
            continue
        }

        git -C $root branch $branch
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create branch: $branch"
        }
    }
}

Write-Host "Created task package: $taskDir"
Write-Host "Agent start order:"
Write-Host "  1. AGENTS.md"
Write-Host "  2. projects/$projectSlug/PROJECT.md"
Write-Host "  4. projects/$projectSlug/.agent-work/$taskDirName/brief.md"
Write-Host "  5. projects/$projectSlug/.agent-work/$taskDirName/plan.md"

