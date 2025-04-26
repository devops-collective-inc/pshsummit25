using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

class NumberCompleter : IArgumentCompleter {

    [int] $From
    [int] $To
    [int] $Step

    NumberCompleter([int] $from, [int] $to, [int] $step) {
        if ($from -gt $to) {
            throw [ArgumentOutOfRangeException]::new("from")
        }
        $this.From = $from
        $this.To = $to
        $this.Step = $step -lt 1 ? 1 : $step
    }

    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $parameterName,
        [string] $wordToComplete,
        [CommandAst] $commandAst,
        [IDictionary] $fakeBoundParameters) {

        $resultList = [List[CompletionResult]]::new()
        $local:to = $this.To
        $local:step = $this.Step
        for ($i = $this.From; $i -lt $to; $i += $step) {
            $resultList.Add([CompletionResult]::new($i.ToString()))
        }

        return $resultList
    }
}

class NumberCompletionsAttribute : ArgumentCompleterAttribute, IArgumentCompleterFactory {
    [int] $From
    [int] $To
    [int] $Step

    NumberCompletionsAttribute([int] $from, [int] $to, [int] $step) {
        $this.From = $from
        $this.To = $to
        $this.Step = $step
    }

    [IArgumentCompleter] Create() { return [NumberCompleter]::new($this.From, $this.To, $this.Step) }
    #[IArgumentCompleter] Create() { return @([CompletionResult]::new(1),[CompletionResult]::new(2),[CompletionResult]::new(3))}
}
function Add {
    param(
        [NumberCompletions(0, 100, 5)]
        [int] $X,
        [NumberCompletions(0, 100, 5)]
        [int] $Y
    )
    $X + $Y
}