#####################################################
# HelloID-Conn-Prov-Target-Moodle-Create
#
# Version: 1.0.0
#####################################################
# Initialize default values
$config = $configuration | ConvertFrom-Json
$p = $person | ConvertFrom-Json
$success = $false
$auditLogs = [System.Collections.Generic.List[PSCustomObject]]::new()

# Account mapping
$account = [PSCustomObject]@{
    username  = $p.ExternalId
    firstname = $p.Name.GivenName
    lastname  = $p.Name.FamilyName
    email     = $p.Contact.Business.Email

    # The password is a mandatory field and cannot be left empty
    password  = ''
}

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Set debug logging
switch ($($config.IsDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

# Set to true if accounts in the target system must be updated
$updatePerson = $false

# Begin
try {
    # Verify if a user must be either [created and correlated], [updated and correlated] or just [correlated]
    # The 'GET' is currently based on field [email]
    $splatParams = @{
        Uri    = "$($config.BaseUrl)/webservice/rest/server.php?wstoken=$($config.token)&wsfunction=core_user_get_users_by_field&field=email&values[0]=$($account.email)&moodlewsrestformat=json"
        Method = 'GET'
    }
    $responseUser = Invoke-RestMethod @splatParams
    if ($null -eq $responseUser[0]){
        $action = 'Create-Correlate'
    } elseif ($updatePerson -eq $true) {
        $action = 'Update-Correlate'
    } else {
        $action = 'Correlate'
    }

    # Add a warning message showing what will happen during enforcement
    if ($dryRun -eq $true) {
        Write-Warning "[DryRun] $action Moodle account for: [$($p.DisplayName)], will be executed during enforcement"
    }

    # Process
    if (-not($dryRun -eq $true)) {
        switch ($action) {
            'Create-Correlate' {
                Write-Verbose "Creating and correlating Moodle account"
                $splatParams = @{
                    Uri         = "$($config.BaseUrl)/webservice/rest/server.php?wstoken=$($config.token)&wsfunction=core_user_create_users&moodlewsrestformat=json"
                    Method      = 'POST'
                    Body        = ($account.psObject.Properties.ForEach({"users[0][$($_.Name)]=$($_.Value)"}) -join "&")
                    ContentType = 'application/x-www-form-urlencoded'
                }
                $response = Invoke-RestMethod @splatParams
                if ($null -ne $response.exception){
                    throw $response.debuginfo
                }
                $accountReference = $response[0].id
                break
            }

            'Update-Correlate' {
                Write-Verbose "Updating and correlating Moodle account"
                $splatParams = @{
                    Uri         = "$($config.BaseUrl)/webservice/rest/server.php?wstoken=$($config.token)&wsfunction=core_user_update_users&moodlewsrestformat=json"
                    Method      = 'POST'
                    Body        = "users[0][id]=$($responseUser[0].id)&"+($account.psObject.Properties.ForEach({"users[0][$($_.Name)]=$($_.Value)"}) -join "&")
                    ContentType = 'application/x-www-form-urlencoded'
                }
                # The update call does not give back a response when the update was successful.
                $response = Invoke-RestMethod @splatParams
                if ($null -ne $response.exception){
                    throw $response.debuginfo
                }
                $accountReference = $responseUser[0].id
                break
            }

            'Correlate' {
                Write-Verbose "Correlating Moodle account"
                $accountReference = $responseUser[0].id
                break
            }
        }

        $success = $true
        $auditLogs.Add([PSCustomObject]@{
                Message = "$action account was successful. AccountReference is: [$accountReference]"
                IsError = $false
            })
    }
} catch {
    $success = $false
    $ex = $PSItem
    $auditMessage = "Could not $action Moodle account. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    $auditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
# End
} finally {
    $result = [PSCustomObject]@{
        Success          = $success
        AccountReference = $accountReference
        Auditlogs        = $auditLogs
        Account          = $account
    }
    Write-Output $result | ConvertTo-Json -Depth 10
}
