# User and password token for Jenkins
$user = "jenkins-user"
$password = "jenkins-token-for-user"

# Jenkins url
$jenkins_host_url = "https://jenkins.lab123.local"

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $password)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))

# Quiet time
$delay_time = "50sec"

$url = "$jenkins_host_url/job/Test/job/dummy_pipeline/job/master/buildWithParameters?msg=kala2&delay=$delay_time"
Invoke-WebRequest -Headers $headers -Method Post -Uri $url