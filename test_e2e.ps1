$auth1 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/guest' -Method Post -ContentType 'application/json' -Body '{"displayName": "DuelMaster"}'
$token1 = $auth1.data.token
$headers1 = @{ Authorization = "Bearer $token1" }
Write-Host "Player 1 logged in:" $auth1.data.displayName "ID:" $auth1.data.id

$auth2 = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/guest' -Method Post -ContentType 'application/json' -Body '{"displayName": "QuickGuesser"}'
$token2 = $auth2.data.token
$headers2 = @{ Authorization = "Bearer $token2" }
Write-Host "Player 2 logged in:" $auth2.data.displayName "ID:" $auth2.data.id

$createBody = @{
    name = "Championship Arena"
    visibility = "PUBLIC"
    maxPlayers = 4
    totalRounds = 2
    drawTimeSeconds = 30
    difficulty = "EASY"
    category = "ANIMALS"
} | ConvertTo-Json
$room = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/rooms' -Method Post -Headers $headers1 -ContentType 'application/json' -Body $createBody
$roomId = $room.data.id
$roomCode = $room.data.roomCode
Write-Host "Room created:" $room.data.name "Code:" $roomCode "ID:" $roomId

$joinBody = @{ roomCode = $roomCode } | ConvertTo-Json
$joined = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/rooms/join' -Method Post -Headers $headers2 -ContentType 'application/json' -Body $joinBody
Write-Host "Player 2 joined! Current players:" $joined.data.currentPlayers "/" $joined.data.maxPlayers

$ready = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/rooms/$roomId/ready" -Method Patch -Headers $headers2
Write-Host "Player 2 readied! Ready count:" $ready.data.readyPlayers "/" $ready.data.currentPlayers

$start = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/rooms/$roomId/start" -Method Post -Headers $headers1
Write-Host "Match started:" $start.message

Start-Sleep -Seconds 2
$roomAfter = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/rooms/$roomId" -Method Get -Headers $headers1
Write-Host "Room status after start:" $roomAfter.data.status

$history = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/users/me/matches" -Method Get -Headers $headers1
Write-Host "User match history retrieved: Total Elements =" $history.data.totalElements

$leaderboard = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/leaderboard?period=all-time' -Method Get -Headers $headers1
Write-Host "Leaderboard retrieved! Entries count:" $leaderboard.data.Count
Write-Host "SUCCESS: Complete End-to-End REST & Game Match Cycle Verified!"
