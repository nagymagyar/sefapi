# Automated smoke/validation tests for the Berlesek API
# Usage: Start the API server (dotnet run --urls http://localhost:5000)
# then in PowerShell run: .\scripts\run-tests.ps1

$base = 'http://localhost:5000'
$fmt = 'yyyy-MM-dd'
$now = Get-Date
$today = $now.ToString($fmt)
$tom = $now.AddDays(1).ToString($fmt)
Write-Output "Today: $today, Tomorrow: $tom"

function Post($obj){
    $json = $obj | ConvertTo-Json
    try{
        $r = Invoke-WebRequest -Uri "$base/api/berlesek" -Method Post -Body $json -ContentType 'application/json' -UseBasicParsing
        Write-Output "POST -> $($r.StatusCode)`n$r.Content`n"
        return $r
    } catch {
        if ($_.Exception.Response){
            $resp = $_.Exception.Response
            $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
            $body = $sr.ReadToEnd()
            $code = [int]$resp.StatusCode
            Write-Output "POST -> $code`n$body`n"
            return $null
        } else { Write-Output $_; return $null }
    }
}

function GetAll(){
    try{ $r = Invoke-WebRequest -Uri "$base/api/berlesek" -UseBasicParsing; Write-Output "GET all -> $($r.StatusCode)`n$r.Content`n" } catch { Write-Output $_ }
}

function GetId($id){
    try{ $r = Invoke-WebRequest -Uri "$base/api/berlesek/$id" -UseBasicParsing; Write-Output "GET $id -> $($r.StatusCode)`n$r.Content`n" } catch {
        if ($_.Exception.Response){ $resp = $_.Exception.Response; $sr = New-Object System.IO.StreamReader($resp.GetResponseStream()); $body = $sr.ReadToEnd(); $code = [int]$resp.StatusCode; Write-Output "GET $id -> $code`n$body`n" } else { Write-Output $_ }
    }
}

function DeleteId($id){
    try{ $r = Invoke-WebRequest -Uri "$base/api/berlesek/$id" -Method Delete -UseBasicParsing; Write-Output "DELETE $id -> $($r.StatusCode)`n" } catch {
        if ($_.Exception.Response){ $resp = $_.Exception.Response; $sr = New-Object System.IO.StreamReader($resp.GetResponseStream()); $body = $sr.ReadToEnd(); $code = [int]$resp.StatusCode; Write-Output "DELETE $id -> $code`n$body`n" } else { Write-Output $_ }
    }
}

Write-Output '--- Test: POST with start = today (invalid)'
$p1 = @{uid=1;chefId=10;startDate=$today;endDate=(Get-Date).AddDays(3).ToString($fmt);dailyRate=100;baseFee=20}
Post $p1
Start-Sleep -Milliseconds 200

Write-Output '--- Test: POST with duration 2 days (invalid)'
$p2 = @{uid=2;chefId=11;startDate=$tom;endDate=(Get-Date).AddDays(2).ToString($fmt);dailyRate=100;baseFee=20}
Post $p2
Start-Sleep -Milliseconds 200

Write-Output '--- Test: POST with duration >14 days (invalid)'
$p3 = @{uid=3;chefId=12;startDate=$tom;endDate=(Get-Date).AddDays(16).ToString($fmt);dailyRate=100;baseFee=20}
Post $p3
Start-Sleep -Milliseconds 200

Write-Output '--- Test: Create initial booking for overlap test (should succeed)'
$p4 = @{uid=4;chefId=99;startDate=$tom;endDate=(Get-Date).AddDays(3).ToString($fmt);dailyRate=100;baseFee=20}
$r4 = Post $p4
Start-Sleep -Milliseconds 200

Write-Output '--- Test: Overlapping booking for same chef (invalid)'
$p5 = @{uid=5;chefId=99;startDate=(Get-Date).AddDays(2).ToString($fmt);endDate=(Get-Date).AddDays(4).ToString($fmt);dailyRate=100;baseFee=20}
Post $p5
Start-Sleep -Milliseconds 200

Write-Output '--- Test: Booking same time different chef (should succeed)'
$p6 = @{uid=6;chefId=100;startDate=$tom;endDate=(Get-Date).AddDays(3).ToString($fmt);dailyRate=120;baseFee=30}
$r6 = Post $p6
Start-Sleep -Milliseconds 200

Write-Output '--- GET all'
GetAll
Start-Sleep -Milliseconds 200

if ($r4){
    $id1 = (ConvertFrom-Json $r4.Content).id
    Write-Output "--- GET by id $id1"
    GetId $id1
    Write-Output "--- DELETE id $id1"
    DeleteId $id1
    Write-Output "--- GET by id after delete $id1"
    GetId $id1
} else { Write-Output 'Initial booking creation failed; skipping GET/DELETE tests' }
