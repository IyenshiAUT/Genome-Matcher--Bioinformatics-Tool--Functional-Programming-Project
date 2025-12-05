# Test the genome matcher with curl-like functionality using PowerShell
$uri = "http://localhost:3000/analyze"
$refFile = "test_reference.txt"
$patientFile = "test_patient1.txt"

# Read file contents
$refContent = Get-Content $refFile -Raw
$patientContent = Get-Content $patientFile -Raw

Write-Host "Testing genome analysis..."
Write-Host "Reference DNA: $refContent"
Write-Host "Patient DNA: $patientContent"

# Create multipart form data
$boundary = [System.Guid]::NewGuid().ToString()
$bodyLines = @(
    "--$boundary",
    'Content-Disposition: form-data; name="reference"; filename="reference.txt"',
    'Content-Type: text/plain',
    '',
    $refContent,
    "--$boundary",
    'Content-Disposition: form-data; name="patients"; filename="patient1.txt"',
    'Content-Type: text/plain',
    '',
    $patientContent,
    "--$boundary--"
)

$body = $bodyLines -join "`r`n"

try {
    $response = Invoke-WebRequest -Uri $uri -Method POST -Body $body -ContentType "multipart/form-data; boundary=$boundary"
    Write-Host "Status Code: $($response.StatusCode)"
    Write-Host "Response:"
    Write-Host $response.Content
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseText = $reader.ReadToEnd()
        Write-Host "Response: $responseText"
    }
}