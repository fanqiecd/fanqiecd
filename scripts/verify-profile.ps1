param(
    [string]$ProfileRoot = (Split-Path -Parent $PSScriptRoot)
)

$errors = [System.Collections.Generic.List[string]]::new()

function Require-File([string]$RelativePath) {
    $path = Join-Path $ProfileRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing file: $RelativePath")
        return $null
    }
    return Get-Content -LiteralPath $path -Raw
}

function Require-Match([string]$Text, [string]$Pattern, [string]$Message) {
    if ($null -ne $Text -and $Text -notmatch $Pattern) {
        $errors.Add($Message)
    }
}

function Reject-Match([string]$Text, [string]$Pattern, [string]$Message) {
    if ($null -ne $Text -and $Text -match $Pattern) {
        $errors.Add($Message)
    }
}

$readme = Require-File 'README.md'
$snake = Require-File '.github/workflows/snake.yml'
$profile3d = Require-File '.github/workflows/profile-3d.yml'
$settings = Require-File 'profile-3d-contrib/settings.json'

Require-Match $readme '番茄\s*/\s*fanqiecd' 'README must identify 番茄 / fanqiecd.'
Require-Match $readme '把游戏里的想法与日常需求，做成真正可用的模组和 Web 工具' 'Chinese positioning is missing.'
Require-Match $readme 'Turning game ideas and everyday needs into practical mods and web tools' 'English positioning is missing.'
Require-Match $readme 'https://github\.com/fanqiecd/BP_ResourcePlanter' 'BP_ResourcePlanter link is missing.'
Require-Match $readme 'https://equip-sheet\.vercel\.app' 'EquipSheet live link is missing.'
Require-Match $readme 'https://github\.com/fanqiecd/astrbot_plugin_github_monitor' 'GitHub monitor plugin link is missing.'
Require-Match $readme 'https://github\.com/fanqiecd/astrbot_plugin_warband_status' 'Warband status plugin link is missing.'
Require-Match $readme '源码暂未公开' 'EquipSheet should state that source is not public yet.'
Require-Match $readme 'profile-tomato-workshop\.svg' 'The custom 3D contribution image is missing.'
Require-Match $readme 'github-contribution-grid-snake-dark\.svg' 'The dark snake image is missing.'
Require-Match $readme 'github-contribution-grid-snake\.svg' 'The light snake image is missing.'
Require-Match $readme '模板设计灵感来源：©.*Zephyr Zhong' 'Required source attribution is missing.'
Reject-Match $readme '(?i)YOUR_USERNAME|your-id|example\.com|mailto:|zephyrzhong248@gmail\.com' 'README contains a placeholder or an email address.'

foreach ($workflow in @($snake, $profile3d)) {
    Require-Match $workflow 'permissions:\s*\r?\n\s+contents:\s+write' 'Each workflow must declare only contents: write.'
    Reject-Match $workflow '(?i)secrets\.TOKEN|personal access token|\bPAT\b|--force' 'Workflow must not use a PAT, TOKEN secret, or force push.'
}

Require-Match $snake 'Platane/snk@v3\.5\.0' 'Snake action must be pinned to v3.5.0.'
Require-Match $snake 'crazy-max/ghaction-github-pages@v5\.0\.0' 'Pages deployment action must be pinned to v5.0.0.'
Require-Match $snake 'target_branch:\s+output' 'Snake assets must publish to the output branch.'
Require-Match $profile3d 'yoshi389111/github-profile-3d-contrib@v0\.9\.3' '3D action must be pinned to v0.9.3.'
Require-Match $profile3d 'secrets\.GITHUB_TOKEN' '3D workflow must use the built-in GITHUB_TOKEN.'
Require-Match $profile3d 'git push\s*(\r?\n|$)' '3D workflow must use a normal git push.'

Require-Match $settings '"fileName"\s*:\s*"profile-tomato-workshop\.svg"' '3D output filename is incorrect.'
Require-Match $settings '#FF8A3D' '3D settings must include the warm-orange accent.'
Require-Match $settings '#E94B35' '3D settings must include the tomato-red accent.'

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Profile verification failed with $($errors.Count) error(s)."
}

Write-Host 'Profile verification passed.' -ForegroundColor Green
