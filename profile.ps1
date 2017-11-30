$env:____HasGitPromptBeenSet = $false
function Enter-GitPrompt
{
	$env:____HasGitPromptBeenSet = $true
}
Import-Module posh-git
$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = ']'

Rename-Item function:\prompt RW___OriginalPrompt -Force
function prompt {
	$origLastExitCode = $LASTEXITCODE
	
	$gitDirectory = Get-GitDirectory
	if (($env:____HasGitPromptBeenSet -eq $true) -and ($gitDirectory -ne $null))
	{		
		$repositoryRootPath = Split-Path -Parent $gitDirectory
		$repositoryFolderName = Split-Path -Leaf $repositoryRootPath
		#This extra step is done to fix the casing of the repository folder name
		$repositoryFolderName = [System.IO.DirectoryInfo]::New($repositoryRootPath).Parent.GetFileSystemInfos($repositoryFolderName)[0].Name
		Write-Host -NoNewLine "[$RepositoryFolderName] "

		Write-VcsStatus
		
		#$maxPathLength = 60
		$curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
		#if ($curPath.Length -gt $maxPathLength) {
			#$curPath = '...' + $curPath.SubString($curPath.Length - $maxPathLength + 3)
		#}
		$curPath = $curPath.Substring($repositoryRootPath.Length)
		if (-Not($curPath))
		{
			$curPath = '~\'
		}
		else
		{
			$curPath = "~$curPath"
		}

		Write-Host " $curPath" -ForegroundColor Green
		$LASTEXITCODE = $origLastExitCode
		"$('>' * ($nestedPromptLevel + 1)) "
	}
	else
	{
		$LASTEXITCODE = $origLastExitCode
		RW___OriginalPrompt
	}
}

function Exit-GitPrompt
{
	$env:____HasGitPromptBeenSet = $false
}

function Remove-GitBranchesWithGoneUpstream
{
	[CmdletBinding(SupportsShouldProcess = $true)]
	PARAM(
		[switch]$Force
	)
	$veryVerboseBranchInfo = & git branch -vv
	$veryVerboseBranchInfo | foreach {
		if ($_ -match '^\s*(?<branchname>[^\s]+)\s*[^\s]+\s*\[[^\s]+: gone\]'){
			$branchName = $Matches['branchname']
			if ($PSCmdlet.ShouldProcess($branchName, 'Remove local branch copy')){
				if ($Force){
					& git branch -D $branchName
				}
				else{
					& git branch -d $branchName
				}
			}
		}
	}
}