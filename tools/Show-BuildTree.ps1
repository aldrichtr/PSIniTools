<#
.Synopsis
	Shows Invoke-Build task trees with brief information.
	Copyright (c) Roman Kuzmin

.Description
	This script analyses task references and shows parent tasks and child trees
	for the specified tasks. Tasks are not invoked.

.Parameter Task
		Task names.
		If it is "*" then all root tasks are used.
		If it is omitted or "." then the default task is used.
.Parameter File
		The build script.
		If it is omitted then the default script is used.
.Parameter Parameters
		Build script parameters needed in special cases when they alter tasks.
.Parameter Upstream
		Tells to show upstream tasks for each task.

.Inputs
	None.
.Outputs
	Specified task trees.

.Link
	https://github.com/nightroman/Invoke-Build
#>

param(
	[Parameter(Position=0)][string[]]$Task,
	[Parameter(Position=1)][string]$File,
	[Parameter(Position=2)][hashtable]$Parameters,
	[switch]$Upstream
)

$private:_Task = $Task
$private:_File = $File
$private:_Parameters = if ($Parameters) {$Parameters} else {@{}}
$private:_Upstream = $Upstream
Remove-Variable Task, File, Parameters, Upstream

# Shows the task tree.
function ShowTaskTree($Task, $Docs, $Step = 0) {
	if ($Step -eq 0) {''}
	$tab = '    ' * $Step
	++$Step

	# synopsis
	$synopsis = Get-BuildSynopsis $Task $docs

	# name
	$info = $tab + $Task.Name

	# upstream
	if ($references.get_Count()) {
		$reference = $references[$Task]
		if ($reference.get_Count()) {
			$info += ' (' + (($reference.get_Keys() | Sort-Object) -join ', ') + ')'
		}
	}

	# synopsis, output
	if ($synopsis) {"$info # $synopsis"} else {$info}

	# task jobs
	foreach($_ in $Task.Jobs) {
		if ($_ -is [string]) {
			$r, $s = *Job $_
			ShowTaskTree $tasks[$r] $Docs $Step
		}
		else {
			$tab + '    {}'
		}
	}
}

$ErrorActionPreference = 'Stop'
try {
	. Invoke-Build

	# get tasks
	$tasks = Invoke-Build ?? $_File @_Parameters

	# references
	$references = @{}
	if ($_Upstream) {
		foreach($it in $tasks.get_Values()) {
			$references[$it] = @{}
		}
		foreach($it in $tasks.get_Values()) {foreach($job in $it.Jobs) {if ($job -is [string]) {
			$references[$tasks[$job]][$it.Name] = 0
		}}}
	}

	# resolve task
	if ($_Task -eq '*') {
		$_Task = :task foreach($_ in $tasks.get_Keys()) {
			foreach($task in $tasks.get_Values()) {
				if ($task.Jobs -contains $_ -or $task.Jobs -contains "?$_") {
					continue task
				}
			}
			$_
		}
	}
	elseif (!$_Task -or '.' -eq $_Task) {
		$_Task = if ($tasks['.']) {'.'} else {$tasks.Item(0).Name}
	}

	# test tasks
	foreach($name in $_Task) {
		if (!$tasks[$name]) {throw "Missing task '$name'."}
	}

	# show trees
	$docs = @{}
	foreach($name in $_Task) {
		ShowTaskTree $tasks[$name] $docs
	}
}
catch {
	if ($_.InvocationInfo.ScriptName -ne $MyInvocation.MyCommand.Path) {throw}
	$PSCmdlet.ThrowTerminatingError($_)
}
