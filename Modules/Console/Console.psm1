function Show-Colors {
    $colors = [Enum]::GetValues([ConsoleColor])
    $max = ($colors | ForEach-Object { "$_ ".Length } | Measure-Object -Maximum).Maximum
    foreach ($color in $colors) {
        Write-Host (" {0,2} {1, $max} " -f [int] $color, $color) -NoNewline
        Write-Host "$color" -ForegroundColor $color
    }
}