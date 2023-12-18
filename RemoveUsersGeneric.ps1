#apply OU filter
$targetOU = "INSERT OU DISTINGUISHED NAME HERE"

$comps = get-adcomputer -filter {Name -like "INSERT FILTER HERE"} -searchbase $targetOU

#put admin accounts, terminated employee accounts ,etc.
$users = "account.name1","account.name2","account.name3"

#Iterate through computers
foreach($computer in $comps)
    {
    write-host "Starting removal on: " $computer.Name
    #Iterate through users
    foreach($user in $users)
        {
        #Test if user exists on target machine
        $path = '\\' + $computer.Name + '\c$\users\' + $user
        #write-host '     Path to test: ' $path
        $userExists = Test-Path -Path $path
        if($userExists)
            {
            #Remove User
            write-host '     Removing: ' $user
            invoke-command -ea SilentlyContinue -computername $computer.name -ScriptBlock{
                param($User)
                $localpath = 'c:\users\' + $User
                Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq $localpath} | 
                Remove-WmiObject
                } -ArgumentList $User
            }
        else
            {
            write-host '     User not found: ' $user
            }
        }
    }