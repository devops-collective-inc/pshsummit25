import-module Pode.Web

Start-PodeServer {
    # Create a New Pode Web Server
    # The server will listen on localhost:8080
    # The server will use the HTTP protocol
    # The server also could use HTTPS and a certificate
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http
    
    Use-PodeWebTemplates -Title 'HelpDeskDashboard' -Theme Dark

    # Create a session middleware to store the user object
    # The user object will be used to determine the access level of the user
    # The Session will last for 2 minutes and will be extended on each request
    Enable-PodeSessionMiddleware -Duration 120 -Extend

    New-PodeAuthScheme -Form | Add-PodeAuth -Name 'Example' -ScriptBlock {
        param($username, $password)

        switch($username){
            'Christian' { 
                return @{
                    User = @{
                        ID ='C0R7Y301'
                        Name = 'Christian <2nd Level>'
                        Type = '2ndLevel'
                        Groups = '1st Level','2nd Level'
                    }
                }
            }
            'Ben' { 
                return @{
                    User = @{
                        ID ='C0R7Y302'
                        Name = 'Ben <1st Level>'
                        Type = '1stLevel'
                        Groups = '1st Level'
                    }
                }
            }
            'Emrys' { 
                return @{
                    User = @{
                        ID ='C0R7Y302'
                        Name = 'Emrys <3rd Level>'
                        Type = '3rdLevel'
                        Groups = '3rd Level'
                    }
                }
            }
        }
    }
    Set-PodeWebLoginPage -Authentication 'Example'
    $HelpDeskScriptFolder = "$pwd\HelpDeskScripts"

    
    # Create the main dashboard page
    # This page will display all the support scripts
    # grouped by their script level
    # Each script will be displayed as a tile with a brief description (Get-Help -Synopsis)
    # Regardless of the script level, all users will have access to this page and see all scripts
    Add-PodeWebpage -name 'DashBoard' -icon 'view-dashboard-outline' -scriptblock {
        $HelpDeskScriptFolder = "$pwd\HelpDeskScripts"
        New-PodeWebParagraph -Value 'All Support Scripts'
        New-PodeWebLine
        $Scripts = Get-ChildItem -Path $HelpDeskScriptFolder -Recurse -Filter *.ps1 | Select-Object BaseName,FullName,@{Name='ScriptLevel';Expression={($_.FullName | Split-Path -Parent) | Split-Path -Leaf}}
        
        # Get the unique script levels from the folder structure
        $ScriptLevels = $Scripts.ScriptLevel | Sort-Object -Unique

        # Helper function to get the color of the tile based on the script level
        function Get-PodeWebTileColor {
            param (
                $ScriptLevel
            )
            switch($ScriptLevel){
                '1st Level' { return 'Green' }
                '2nd Level' { return 'Yellow' }
                '3rd Level' { return 'Red' }
                default { return 'Blue' }
            }
            
        }

        # Create a grid for each script level
        # Each grid will contain tiles for each script in that level
        foreach($ScriptLevel in $ScriptLevels){
            New-PodeWebContainer -content @(
                New-PodeWebHeader -Value $ScriptLevel -Size 2 
                New-PodeWebGrid -Cells @(

                    # Create a tile for each script in the current script level
                    $Scripts | Where-Object {$_.ScriptLevel -eq $ScriptLevel} | ForEach-Object {
                        New-PodeWebCell -Content @(
                            $NewPodeWebTileSplat = @{
                                Name = $_.BaseName
                                NoRefresh = $true
                                Colour = (Get-PodeWebTileColor -ScriptLevel $ScriptLevel)
                                Icon = (Get-Help $_.FullName).relatedLinks.navigationLink.LinkText
                            }
                            New-PodeWebTile @NewPodeWebTileSplat -ScriptBlock {
                                param(
                                    [Parameter(Mandatory = $true)]
                                    $ScriptFile
                                )
                                return $(Get-Help $ScriptFile.FullName).Synopsis
                            } -ClickScriptBlock {
                                param(
                                    [Parameter(Mandatory = $true)]
                                    $ScriptFile
                                )
                                move-PodeWebpage -name $ScriptFile.BaseName -Group $ScriptFile.ScriptLevel
                            } -ArgumentList $_
                        )  
                    } 
                )
            )
        }
    }

    # Create a page to display the results of the last run and the history of all runs
    # This page will be accessible to all users
    # The results will be displayed in a table format
    # The table will be populated from a CSV file
    # The CSV file will be updated by the script execution
    Add-PodeWebPage -name 'Results' -icon 'math-log' -scriptblock {        
        New-PodeWebText -Value 'Last Run Result' -Style Bold 
        New-PodeWebTable -Name "LastRunResult"  -ScriptBlock {$(Import-Csv -Path $pwd\Result.csv -Delimiter ';')[-1]}
        New-PodeWebLine
        New-PodeWebText -Value 'History' -Style Bold 
        New-PodeWebTable -Name "Results"  -Scriptblock {Import-Csv -Path $pwd\Result.csv -Delimiter ';'} 
    }
    
    # Helper function to extract the parameters from a script
    # This function will be used to create the input form for each script
    # The input form will be created based on the parameters of the script
    function Get-ScriptBlockParameter {
        param (
            [Parameter(Mandatory = $true)]
            [string]$ScriptPath
        )
    
        # Ensure the script path exists
        if (-not (Test-Path -Path $ScriptPath)) {
            throw "The script path '$ScriptPath' does not exist."
        }
    
        # Parse the script content into an AST (Abstract Syntax Tree)
        $scriptContent = Get-Content -Path $ScriptPath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$null, [ref]$null)
    
        # Traverse the AST to find parameter definitions
        $parameters = $ast.FindAll({
            param ($node)
            $node -is [System.Management.Automation.Language.ParameterAst]
        }, $true)
    
        # Process each parameter and extract relevant information
        $parameters | ForEach-Object {
            [PSCustomObject]@{
                ParamName = $_.Name.VariablePath.UserPath
                ParamType = if ($_.StaticType) { $_.StaticType.Name } else { 'Unknown' }
                ParamValidationType = $_.Attributes | Where-Object { $_.TypeName.FullName -like '*Validate*' } | ForEach-Object { $_.TypeName.FullName }
                ParamValidationArguments = $_.Attributes | ForEach-Object { $_.PositionalArguments.Value }
                Mandatory = $_.Attributes.NamedArguments.ArgumentName -contains 'Mandatory'
            }
        }
    }

    # Iterate through all scripts in the HelpDeskScripts folder
    # and create a web page for each script
    # Define Groups based on the folder structure == ScriptLevel
    # Define AccessGroups based on the folder structure == ScriptLevel AND Groups key of the user object
    foreach($Script in Get-ChildItem -Path $HelpDeskScriptFolder -Recurse -Filter '*.ps1' ){
        $ScriptParameter = Get-ScriptBlockParameter -ScriptPath $Script.FullName
        $ScriptLevel = ($Script.FullName | Split-Path -Parent) | Split-Path -Leaf
        $ScriptPageSplat = @{
            Name = $Script.BaseName
            Icon = (Get-Help $Script.FullName).relatedLinks.navigationLink.LinkText
            AccessGroups = @($ScriptLevel)
            Group = $ScriptLevel
        }
        Add-PodeWebPage @ScriptPageSplat  -ScriptBlock {
            param(
                [Parameter(Mandatory = $true)]
                $ScriptParameter,
                [Parameter(Mandatory = $true)]
                $Script
            )
            New-PodeWebContainer -content @(
                # Display the script Description for each script
                New-PodeWebParagraph -value $((get-help $Script.FullName).Description).Text
                New-PodeWebLine

                # Create a form based on the parameters of the script
                # The form will be created based on the parameter type
                # The form will be validated based on the parameter validation
                New-PodeWebForm -name $(Get-Random -minimum 1 -maximum 50) -content @(
                    foreach($ScriptParameterObject in $ScriptParameter){
                        # Common Splat for all input types
                        $CommandSplat = @{}
                        $CommandSplat['Name'] = $ScriptParameterObject.ParamName
                        if($ScriptParameterObject.Mandatory){
                            $CommandSplat['required'] = $true
                        }
                        try {
                            # Switch based on the parameter type and validation
                            switch ($ScriptParameterObject) {
                                {$_.ParamValidationType -eq 'ValidateRange'}{
                                    $CommandSplat['min'] = $_.ParamValidationArguments[0]
                                    $CommandSplat['max'] = $_.ParamValidationArguments[1]
                                    $CommandSplat['showValue'] = $true
                                    New-PodeWebRange @CommandSplat
                                    continue
                                }
                                {$_.ParamValidationType -eq 'ValidateSet'}{
                                    # Remove empty strings from the validation arguments and add them to the Options key
                                    $CleanedParamValidationArguments = $_.ParamValidationArguments | where-object {-not [string]::IsNullOrEmpty($_)}
                                    $CommandSplat['Options'] = $CleanedParamValidationArguments
                                    New-PodeWebSelect @CommandSplat
                                    continue
                                }
                                {$_.ParamType -eq "SwitchParameter"} { 
                                    New-PodeWebCheckbox @CommandSplat
                                    continue
                                }
                                {$_.ParamType -eq "String"} { 
                                    New-PodeWebTextbox @CommandSplat
                                    continue
                                }
                                {$_.ParamType -eq "Int32"} { 
                                    # Validate the TextBox to only accept numbers
                                    $CommandSplat['type'] = 'number'
                                    New-PodeWebTextbox @CommandSplat
                                    continue
                                }
                                Default {
                                    New-PodeWebTextbox @CommandSplat
                                }
                            }
                        }
                        catch {
                            $_ | Out-Default
                        }
                    }
                ) -scriptblock {
                    Param($Script)
                        $WebEvent.Data | Out-Default
                    try{
                        $HelperSplat = $WebEvent.Data

                        $keys = @($HelperSplat.Keys)

                        $keys | ForEach-Object {
                            if ($_ -match '^Is[A-Z].*' -or $_ -eq 'Force') {
                                $HelperSplat[$_] = [bool]$HelperSplat[$_]
                            }
                        }
                        $State = . $Script.FullName @HelperSplat
                        $State | Export-CSV -Path $pwd\Result.csv -Append -Delimiter ';'
                        move-PodeWebPage -name 'Results'
                    }catch{
                        $_ | Out-Default
                    }
                } -ArgumentList @($Script) 
            )
        } -ArgumentList @($ScriptParameter,$Script)
    }

    # Create a page to display the QNA
    # This page will be accessible to all users
    # The QNA will be displayed in a card format
    Add-PodeWebPage -name 'QNA' -icon 'head-question-outline' -scriptblock {        
        New-PodeWebText -Value 'If it doesn`t work, Remember:' -Style Bold 
        New-PodeWebCard -Content @(
            New-PodeWebIFrame -Url "https://www.memecreator.org/static/images/memes/4600757.jpg"
            #New-PodeWebIFrame -Url "https://c4.wallpaperflare.com/wallpaper/142/751/831/landscape-anime-digital-art-fantasy-art-wallpaper-preview.jpg"
        )
    }
}