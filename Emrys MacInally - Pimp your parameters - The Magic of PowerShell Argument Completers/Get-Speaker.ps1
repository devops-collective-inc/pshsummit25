$acSpeaker = {
    param(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    )
    $WordToComplete = $WordToComplete.Trim()
    # $WordToComplete >> .\WordToComplete.txt 
    $speakers = Invoke-RestMethod -Uri "https://sessionize.com/api/v2/d560j5mp/view/Speakers" -ErrorAction Stop
    $speakers.Fullname | Where-Object { $_ -like "*$WordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new("'$_'", $_, [System.Management.Automation.CompletionResultType]::ParameterValue, $_)
    }
}
Register-ArgumentCompleter -CommandName Get-Session -ParameterName Speaker -ScriptBlock $acSpeaker


function Get-Session {

    [CmdletBinding()]
    param (
        [String[]]$Speaker,
        [int]$number
    )
    
    begin {}
    
    process {
        $all = Invoke-RestMethod -Uri "https://sessionize.com/api/v2/d560j5mp/view/all" -ErrorAction Stop
        $sessions = $all.sessions
        $rooms = $all.rooms
        $resultSessions = @()
        if ($speaker) {
            Write-Verbose "Filtering sessions by speaker(s): $speaker"
            foreach ($_speaker in $speaker) {
                Write-Verbose "Filtering sessions by speaker: $_speaker"
                $speakerId = $all.speakers | Where-Object { $_.fullname -eq $_speaker } | Select-Object -ExpandProperty id
                $resultSessions += $sessions | Where-Object { $_.speakers -contains $speakerId }
               
            }
        }
        else {
            $resultSessions = $sessions
        }
        foreach ($result in $resultSessions) {
            [PSCustomObject]@{
                Title       = $result.title
                Speaker     = ($all.speakers | Where-Object { $_.id -in $result.speakers } | Select-Object -ExpandProperty Fullname) -join ', '
                Room        = ($rooms | Where-Object { $_.id -eq $result.roomId }).name
                StartTime   = $result.startsAt
                Duration    = ($result.endsAt - $result.startsAt).TotalMinutes.toString() + 'min'
                Description = $result.description.Substring(0, 100) + '...'
            }
        }

    }
    
    end {}
}

Get-Session -Speaker 'James Brundage', 'Gael Colas', 'James Brundage'
