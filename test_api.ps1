# PowerShell script to test the Genome Matcher API
$testData = @{
    reference = "ATGCGATCGATCGATCGTAGCTAGCTAGCAATCGATCGATCGATCGTAGCTAGCTAG"
    patients = @(
        @{
            name = "Patient_1_WithMutation"
            content = "ATGCGATCGATCGATCGTAGCTACCTAGCAATCGATCGATCGATCGTAGCTAGCTAG"
        },
        @{
            name = "Patient_2_WithDifferentMutation"  
            content = "ATGCGATCGATCGATCGTAGCTAGCTTGCAATCGATCGATCGATCGTAGCTAGCTAG"
        }
    )
} | ConvertTo-Json -Depth 3

Write-Host "Testing Genome Matcher API..."
Write-Host "Sending data to http://localhost:3000/analyze"

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/analyze" `
                                 -Method POST `
                                 -ContentType "application/json" `
                                 -Body $testData
    
    Write-Host "Response Status: $($response.StatusCode)"
    Write-Host "Response Content:"
    Write-Host $response.Content
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}