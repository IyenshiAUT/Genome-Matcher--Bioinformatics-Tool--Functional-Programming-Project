# Test script to check analysis results display
$reference = Get-Content "sample_reference.txt" -Raw
$patient1 = Get-Content "sample_patient1.txt" -Raw  
$patient2 = Get-Content "sample_patient2.txt" -Raw

$body = @{
    reference = $reference.Trim()
    patients = @(
        @{ name = "Patient Alpha"; content = $patient1.Trim() }
        @{ name = "Patient Beta"; content = $patient2.Trim() }
    )
} | ConvertTo-Json -Depth 3

$response = Invoke-RestMethod -Uri "http://localhost:3000/analyze" -Method Post -ContentType "application/json" -Body $body

Write-Host "Response received. Saving to results.html..."
$response | Out-File "results.html" -Encoding UTF8
Write-Host "Results saved to results.html"