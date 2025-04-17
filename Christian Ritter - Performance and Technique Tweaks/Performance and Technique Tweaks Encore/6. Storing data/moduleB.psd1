@{
    ModuleVersion   = '1.0.0'
    Author         = 'YourName'
    Description    = 'Example module'
    RootModule     = 'moduleB.psm1'
    
    # Custom data for module usage
    PrivateData = @{
        Settings = @{
            Timeout    = 30
            LogLevel   = 'Warning'
            RetryCount = 3
        }
    }
}