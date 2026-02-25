# Exemples d'utilisation de Write-PSSAKProgressBar

# ============================================================================
# Charger le module PSSAK
# ============================================================================
Import-Module -fullyQualifiedName ./output/module/PSSAK/0.0.1/pssak.psm1 -Force

# ============================================================================
# Exemple 1 : Barre de progression simple
# ============================================================================
Write-Verbose "=== Exemple 1: Barre de progression simple ===" -Verbose

$items = @('fichier1.txt', 'fichier2.txt', 'fichier3.txt', 'fichier4.txt', 'fichier5.txt')
$total = $items.Count

for ($i = 1; $i -le $total; $i++) {
    Write-PSSAKProgressBar -Activity "Traitement des fichiers" -Current $i -Total $total -Status "Traitement: $($items[$i-1])"
    Start-Sleep -Milliseconds 500  # Simule un traitement
}

Write-PSSAKProgressBar -Activity "Traitement des fichiers" -Completed
Write-Verbose "✓ Traitement terminé!`n" -Verbose

# ============================================================================
# Exemple 2 : Avec estimation de temps restant (ETA)
# ============================================================================
Write-Verbose "=== Exemple 2: Avec estimation de temps restant ===" -Verbose

$startTime = [datetime]::UtcNow
$itemsToProcess = 50

for ($i = 1; $i -le $itemsToProcess; $i++) {
    Write-PSSAKProgressBar -Activity "Téléchargement" `
        -Current $i `
        -Total $itemsToProcess `
        -Status "Fichier $i / $itemsToProcess" `
        -StartTime $startTime

    Start-Sleep -Milliseconds 100  # Simule un téléchargement
}

Write-PSSAKProgressBar -Activity "Téléchargement" -Completed
Write-Verbose "✓ Téléchargement terminé!`n" -Verbose

# ============================================================================
# Exemple 3 : Barres de progression imbriquées (parent/enfant)
# ============================================================================
Write-Verbose "=== Exemple 3: Barres imbriquées ===" -Verbose

$servers = @('SERVER1', 'SERVER2', 'SERVER3')
$filesPerServer = 5

for ($s = 1; $s -le $servers.Count; $s++) {
    $server = $servers[$s - 1]

    Write-PSSAKProgressBar -Activity "Serveurs" `
        -Current $s `
        -Total $servers.Count `
        -Status $server `
        -Id 1

    for ($f = 1; $f -le $filesPerServer; $f++) {
        Write-PSSAKProgressBar -Activity "Fichiers" `
            -Current $f `
            -Total $filesPerServer `
            -Status "Fichier $f sur $server" `
            -Id 2 `
            -ParentId 1

        Start-Sleep -Milliseconds 200
    }

    Write-PSSAKProgressBar -Activity "Fichiers" -Completed -Id 2
}

Write-PSSAKProgressBar -Activity "Serveurs" -Completed -Id 1
Write-Verbose "✓ Tous les serveurs traités!`n" -Verbose

# ============================================================================
# Exemple 4 : Avec status personnalisé
# ============================================================================
Write-Verbose "=== Exemple 4: Status personnalisé ===" -Verbose

$total = 100
$startTime = [datetime]::UtcNow

for ($i = 1; $i -le $total; $i++) {
    $percent = [Math]::Round(($i / $total) * 100)
    $customStatus = "[$('█' * ($percent / 5))]  Traitement: $percent%"

    Write-PSSAKProgressBar -Activity "Processing" `
        -Current $i `
        -Total $total `
        -Status $customStatus `
        -StartTime $startTime `
        -NoTimeEstimate

    Start-Sleep -Milliseconds 50
}

Write-PSSAKProgressBar -Activity "Processing" -Completed
Write-Verbose "✓ Traitement complété!`n" -Verbose

# ============================================================================
# Exemple 5 : Cas réel - Copie de fichiers
# ============================================================================
Write-Verbose "=== Exemple 5: Cas réel - Copie de fichiers ===" -Verbose

# Créer des fichiers de test
$testDir = "$HOME/test_progress"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir | Out-Null
}

# Créer 20 fichiers de test
1..20 | ForEach-Object {
    $null | Out-File -FilePath "$testDir/test_$_.txt"
}

$files = Get-ChildItem -Path $testDir -File
$total = $files.Count
$startTime = [datetime]::UtcNow

Write-Verbose "Copie de $total fichiers..." -Verbose

for ($i = 0; $i -lt $total; $i++) {
    $file = $files[$i]
    $destination = "$testDir/backup_$($file.Name)"

    Copy-Item -Path $file.FullName -Destination $destination -Force

    Write-PSSAKProgressBar -Activity "Copie de fichiers" `
        -Current ($i + 1) `
        -Total $total `
        -Status "Copie: $($file.Name)" `
        -StartTime $startTime

    Start-Sleep -Milliseconds 100
}

Write-PSSAKProgressBar -Activity "Copie de fichiers" -Completed
Write-Verbose "✓ Copie terminée!`n" -Verbose

# Nettoyer
Remove-Item -Path $testDir -Recurse -Force

Write-Verbose "=== Tous les exemples exécutés avec succès! ===" -Verbose
