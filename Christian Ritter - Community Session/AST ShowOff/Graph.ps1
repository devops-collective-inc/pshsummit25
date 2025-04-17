Connect-MgGraph -Scopes "User.Read.All","AccessReview.ReadWrite.All"


$User = Get-Mguser 