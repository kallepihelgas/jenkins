# Set user and token 
$user = "jenkins-user"
$password = "jenkins-user-token"

$jenkins_host_url = https://jenkins.lab123.local

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $password)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))

# Quiet time
$delay = "60sec"

$url = "$jenkins_host_url/job/Test/job/dummy_pipeline/job/master/buildWithParameters?msg=hello&delay=$delay"
$request = Invoke-WebRequest -Headers $headers -Method Post -Uri $url

# Get queue url and append json
$url1 = $request.Headers.Location
$queue_url = "$url1" + "api/json"
Write-Host "Job queued: $queue_url"

# clear job url
$job_url = $null

# Loop until job_url is empty
While ($job_url -eq "" -or $null -eq $job_url) {
  $request2 = Invoke-WebRequest -Headers $headers -Method GET -Uri $queue_url
  $response2 = $request2.Content | ConvertFrom-Json
  $job_url = $response2.executable.url
  Write-Host "Job status: QUEUED"
  Start-Sleep 3
}

# Replace http and 443 and append json.
$job_url = $job_url -replace ".net:443",".net"
$job_url = $job_url -replace "http:","https:"
$job_url = $job_url + "api/json"
Write-Host "Job URL: $job_url"

$request3 = Invoke-WebRequest -Headers $headers -Method GET -Uri $job_url
$request3_content = $request3.Content | ConvertFrom-JSON

$job_status = $null

While ($job_status -ne "SUCCESS" -and $job_status -ne "FAILURE") {
  $request3 = Invoke-WebRequest -Headers $headers -Method GET -Uri $job_url
  $request3_content = $request3.Content | ConvertFrom-JSON
  $job_status = $request3_content.result
  $building_status = $request3_content.building
  $desc = $request3_content.description
  while ($building_status -eq $true) {
    Write-Host "Job status: RUNNING"
    Start-Sleep 3
    $request3 = Invoke-WebRequest -Headers $headers -Method GET -Uri $job_url
    $request3_content = $request3.Content | ConvertFrom-JSON
    $job_status = $request3_content.result
    $building_status = $request3_content.building
    $desc = $request3_content.description
  }
}

Write-Host "Job status: $job_status"

if ($job_status -eq "FAILURE") {
  $request3 = Invoke-WebRequest -Headers $headers -Method GET -Uri $job_url
  $request3_content = $request3.Content | ConvertFrom-JSON
  $job_status = $request3_content.result
  $building_status = $request3_content.building
  $desc = $request3_content.description
  Write-Host Error: $desc
}