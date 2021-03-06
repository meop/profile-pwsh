enum DockerOption {
    execBash
    isRunning
    runDetach
    runInteractive
    runInteractiveTty
    stop
}

function Invoke-Docker (
    [Parameter(Mandatory = $true)] [DockerOption] $Option
    , [Parameter(Mandatory = $true)] [string] $ContainerName
    , [Parameter(Mandatory = $false)] [string[]] $ContainerArgs
    , [Parameter(Mandatory = $true)] [string] $ImageName
    , [Parameter(Mandatory = $false)] [string] $ImageTag
    , [Parameter(Mandatory = $false)] [string[]] $ImageArgs
    , [Parameter(Mandatory = $false)] [switch] $WhatIf
    , [Parameter(Mandatory = $false)] $Config = (Get-ProfileConfig)
) {
    $containerName = $ContainerName.ToLowerInvariant()

    function Exec (
        [string[]] $Arguments
    ) {
        if (-not $Arguments) {
            $t = '--interactive --tty'
            $Arguments = 'bash'
        } else {
            $t = ''
        }

        "docker exec $t $containerName $($Arguments -join ' ')"
    }

    function Run (
        [string[]] $TerminalArguments
    ) {
        $imageNameAndTag = $ImageTag ? "$($ImageName):$ImageTag" : $ImageName

        "docker run --rm" +
            " $($TerminalArguments -join ' ')" +
            " --name $containerName" +
            " $($ContainerArgs -join ' ')" +
            " $imageNameAndTag" +
            " $($ImageArgs -join ' ')"
    }

    switch ($Option) {
        ([DockerOption]::execBash) {
            Invoke-LineAsCommandOnConsole `
                -Line (Exec) `
                -WhatIf:$WhatIf `
                -Config $Config
        }
        ([DockerOption]::isRunning) {
            $ans = Invoke-LineAsCommandOnConsole `
                -Line "docker ps --filter `"name=$containerName`"" `
                -WhatIf:$WhatIf `
                -Config $Config
            if (-not $WhatIf.IsPresent) {
                $null -ne ($ans | Select-String $containerName)
            }
        }
        ([DockerOption]::runDetach) {
            Invoke-LineAsCommandOnConsole `
                -Line (Run '--detach') `
                -WhatIf:$WhatIf `
                -Config $Config
        }
        ([DockerOption]::runInteractive) {
            Invoke-LineAsCommandOnConsole `
                -Line (Run '--interactive') `
                -WhatIf:$WhatIf `
                -Config $Config
        }
        ([DockerOption]::runInteractiveTty) {
            Invoke-LineAsCommandOnConsole `
                -Line (Run '--interactive', '--tty') `
                -WhatIf:$WhatIf `
                -Config $Config
        }
        ([DockerOption]::stop) {
            Invoke-LineAsCommandOnConsole `
                -Line "docker stop $containerName" `
                -WhatIf:$WhatIf `
                -Config $Config
        }
    }
}