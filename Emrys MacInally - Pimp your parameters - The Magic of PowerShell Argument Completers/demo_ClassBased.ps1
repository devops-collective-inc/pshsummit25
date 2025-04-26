using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
class DateRangeCompleter : IArgumentCompleter {
    [int] $DaysBack
    [int] $DaysForward
    [string] $Format

    DateRangeCompleter([int] $daysBack, [int] $daysForward, [string] $format) {
        $this.DaysBack = $daysBack
        $this.DaysForward = $daysForward
        $this.Format = $format
    }

    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $parameterName,
        [string] $wordToComplete,
        [CommandAst] $commandAst,
        [IDictionary] $fakeBoundParameters) {

        $resultList = [List[CompletionResult]]::new()
        $today = Get-Date
        
        # Generate dates in the past
        for ($i = 0; $i -le $this.DaysBack; $i++) {
            $date = $today.AddDays(-$i)
            $dateString = $date.ToString($this.Format)
            
            if ($dateString -like "$wordToComplete*") {
                $description = if ($i -eq 0) { "Today" } elseif ($i -eq 1) { "Yesterday" } else { "$i days ago" }
                $resultList.Add([CompletionResult]::new($dateString, $dateString, 'ParameterValue', $description))
            }
        }
        
        # Generate dates in the future
        for ($i = 1; $i -le $this.DaysForward; $i++) {
            $date = $today.AddDays($i)
            $dateString = $date.ToString($this.Format)
            
            if ($dateString -like "$wordToComplete*") {
                $description = if ($i -eq 1) { "Tomorrow" } else { "In $i days" }
                $resultList.Add([CompletionResult]::new($dateString, $dateString, 'ParameterValue', $description))
            }
        }
        
        return $resultList
    }
}

class DateRangeCompletionsAttribute : ArgumentCompleterAttribute, IArgumentCompleterFactory {
    [int] $DaysBack
    [int] $DaysForward
    [string] $Format

    DateRangeCompletionsAttribute([int] $daysBack, [int] $daysForward, [string] $format) {
        $this.DaysBack = $daysBack
        $this.DaysForward = $daysForward
        $this.Format = $format
    }
    
    # You can also use other constructors

    DateRangeCompletionsAttribute() {
        $this.DaysBack = 7
        $this.DaysForward = 7
        $this.Format = "yyyy-MM-dd"
    }

    DateRangeCompletionsAttribute([int] $daysBack, [int] $daysForward) {
        $this.DaysBack = $daysBack
        $this.DaysForward = $daysForward
        $this.Format = "yyyy-MM-dd"
    }

    [IArgumentCompleter] Create() { 
        return [DateRangeCompleter]::new($this.DaysBack, $this.DaysForward, $this.Format) 
    }
}

function Get-LogsForDate {
    param(
        [DateRangeCompletions(1,1)]
        [string] $Date
    )
    
    "Retrieving logs for date: $Date"
    Get-Content -Path "C:\Logs\log-$Date.txt" -ErrorAction SilentlyContinue
}

Get-LogsForDate 08-04-2025