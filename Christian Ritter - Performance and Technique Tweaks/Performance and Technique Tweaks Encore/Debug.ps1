switch -file ("C:\Temp\randomfile.txt"){

    {$_ -eq "blah"}{
        "Something happens"
    }
    default{
        $_
    }
}