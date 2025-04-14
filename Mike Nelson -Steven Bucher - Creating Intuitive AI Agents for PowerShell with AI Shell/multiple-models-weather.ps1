$models = @("openai:gpt-4o-mini", "anthropic:claude-3-5-sonnet-20240620", "azureai:gpt-4o-mini", "gemini:gemini-2.0-flash")

$message = New-ChatMessage -Prompt "Acting as an expert in meterology and weather trends, what is the average tempature in Seattle for April?"

foreach($model in $models) {
    Invoke-ChatCompletion -Message $message -Model $model
}