
Param(
    [string]$dbAdminPassword,
    [string]$dbName,
	[string]$serverName,
	[string]$workingDir
)
# variables
$dbUser = $env:DBADMINUSERNAME
$dbPass = $dbAdminPassword

# derived variables
$sqlScript = "$workingDir/sql/01-initialdata.sql"
$connectionString = "Server=tcp:$serverName.database.windows.net,1433;Initial Catalog=$dbName;Persist Security Info=False;User ID=$dbUser;Password=$dbPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "Sql Script = $sqlScript"
Write-Host "Connection String = $connectionString"

Add-PSSnapin SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue
Add-PSSnapin SqlServerProviderSnapin100 -ErrorAction SilentlyContinue

Try
{
		
	#Execute the query
	Write-Host "Running Script"
	$Query = Get-Content $sqlScript -Encoding UTF8 | Out-String
	$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
	$SqlConnection.ConnectionString = $connectionString
	
	$handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {param($sender, $event) Write-Host $event.Message -ForegroundColor DarkBlue} 
    $SqlConnection.add_InfoMessage($handler) 
	$SqlConnection.FireInfoMessageEventOnUserErrors=$true
	$SqlConnection.Open()
	$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	$SqlCmd.Connection = $SqlConnection
	$SqlCmd.CommandTimeout = 120

	Write-Host "Running Script " $sqlScript " on Database " $dbName
	
    Write-Host $Query

    #Execute the query
    (Get-Content $sqlScript -Encoding UTF8 | Out-String) -split '\r?\n\s*go\s*\r\n?' |
        ForEach-Object { $SqlCmd.CommandText = $_.Trim(); $reader = $SqlCmd.ExecuteNonQuery() }


	$SqlConnection.Close()
	Write-Host "Finished"
}

Catch
{
	Write-Host "Error running SQL script: $_" -ForegroundColor Red
	throw $_
}

