#requires -version 2.0
## Resolve-Aliases Module
########################################################################################################################
## Sample Use:
##    Resolve-Aliases Script.ps1 | Set-Content Script.Resolved.ps1 
##    ls *.ps1 | Resolve-Aliases -Inplace
########################################################################################################################
## Version History
## 1.0 - First Version. "It worked on my sample script"
## 1.1 - Now it parses the $(...) blocks inside strings
## 1.2 - Some tweaks to spacing and indenting (I really gotta get some more test case scripts)
## 1.3 - I went back to processing the whole script at once (instead of a line at a time)
##       Processing a line at a time makes it impossible to handle Here-Strings...
##       I'm considering maybe processing the tokens backwards, replacing just the tokens that need it
##       That would mean I could get rid of all the normalizing code, and leave the whitespace as-is
## 1.4 - Now resolves parameters too
## 1.5 - Fixed several bugs with command resolution (the ? => ForEach-Object problem)
##     - Refactored the Resolve-Line filter right out of existence
##     - Created a test script for validation, and 
########################################################################################################################
function which {
PARAM( [string]$command )
   # aliases, functions, cmdlets, scripts, executables, normal files
   $cmds = @(Get-Command $command -EA "SilentlyContinue")
   if($cmds.Count -gt 1) {
      $cmd = @( $cmds | Where-Object { $_.Name -match "^$([Regex]::Escape($command))" })[0]
   } else {
      $cmd = $cmds[0]
   }
   if(!$cmd) {
      $cmd = @(Get-Command "Get-$command" -EA "SilentlyContinue" | Where-Object { $_.Name -match "^Get-$([Regex]::Escape($command))" })[0]
   }
   if( $cmd.CommandType -eq "Alias" ) {
      $cmd = which $cmd.Definition
   }
   return $cmd
}

Cmdlet Resolve-Aliases -ConfirmImpact low -DefaultParameterSet Files -snapin Huddled.Tests 
{
   Param (
      #[ParameterSetName ("Text")]
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Text")]
      [string[]]$Line
      ,
      #[ParameterSetName ("Files")]
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Files")]
      #[Alias("FullName","PSChildName","PSPath")]
      [IO.FileSystemInfo]$File
      ,
      #[ParameterSetName ("Files")]
      [Parameter(Position=1, ParameterSetName="Files")] 
      [Switch]$InPlace
   )
   BEGIN {
      Write-Debug $PSCmdlet.ParameterSetName
   }
   PROCESS {
      if($PSCmdlet.ParameterSetName -eq "Files") {
         if($File -is [System.IO.FileInfo]){
            $Line = ((Get-Content $File) -join "`n")
         } else {
            throw "We can't resolve a whole folder at once yet" 
         }
      }

      $Tokens = [System.Management.Automation.PSParser]::Tokenize($Line,[ref]$null)
      for($t = $Tokens.Count; $t -ge 0; $t--) {
         $token = $Tokens[$t]
         # DEBUG $token | fl * | out-host
         switch($token.Type) {
            "Command" {
               $cmd = which $token.Content
               Write-Debug "Command $($token.Content) => $($cmd.Name)"
               #if($cmd.CommandType -eq "Alias") {
               $Line = $Line.Remove( $token.Start, $token.Length ).Insert( $token.Start, $cmd.Name )
               #}
            }
            "CommandParameter" {
               Write-Debug "Parameter $($token.Content)"
               for($c = $t; $c -ge 0; $c--) {
                  if( $Tokens[$c].Type -eq "Command" ) {
                     $cmd = which $Tokens[$c].Content
                     # if($cmd.CommandType -eq "Alias") {
                        # $cmd = @(which $cmd.Definition)[0]
                     # }
                     Write-Debug "Parameter $($token.Content -replace "^-?","^")"
                     $param = @(($cmd.ParameterSets | % { $_.Parameters | % { $_.Name } } | Sort -Unique) -match ($token.Content -replace "^-?","^"))
                     if($param.Count -eq 1) {
                        $Line = $Line.Remove( $token.Start, $token.Length ).Insert( $token.Start, "-$($param[0])" )
                     }
                     break
                  }
               }
            }
         }
      }

      switch($PSCmdlet.ParameterSetName) {
         "Text" {
            $Line
         }
         "Files" {
            switch($File.GetType()) {
               "System.IO.FileInfo" {
                  if($InPlace) {
                     $Line | Set-Content $File 
                  } else {
                     $Line
                  }
               }
               default { throw "We can't resolve a whole folder at once yet" }
            }
         }
         default { throw "ParameterSet: $($PSCmdlet.ParameterSetName)" }
      }
   }
}

# SIG # Begin signature block
# MIIK0AYJKoZIhvcNAQcCoIIKwTCCCr0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6I1SxD5ha/Iq/SiEgWIGlzyK
# LtGgggbEMIIGwDCCBKigAwIBAgIJAKpDRVMtv0LqMA0GCSqGSIb3DQEBBQUAMIHG
# MQswCQYDVQQGEwJVUzERMA8GA1UECBMITmV3IFlvcmsxEjAQBgNVBAcTCVJvY2hl
# c3RlcjEaMBgGA1UEChMRSHVkZGxlZE1hc3Nlcy5vcmcxHjAcBgNVBAsTFUNlcnRp
# ZmljYXRlIEF1dGhvcml0eTErMCkGA1UEAxMiSm9lbCBCZW5uZXR0IENlcnRpZmlj
# YXRlIEF1dGhvcml0eTEnMCUGCSqGSIb3DQEJARYYSmF5a3VsQEh1ZGRsZWRNYXNz
# ZXMub3JnMB4XDTA4MDcwMjAzNTA1OVoXDTA5MDcwMjAzNTA1OVowgcAxCzAJBgNV
# BAYTAlVTMREwDwYDVQQIEwhOZXcgWW9yazESMBAGA1UEBxMJUm9jaGVzdGVyMRow
# GAYDVQQKExFIdWRkbGVkTWFzc2VzLm9yZzEuMCwGA1UECxMlaHR0cDovL0h1ZGRs
# ZWRNYXNzZXMub3JnL0NvZGVDZXJ0LmNydDEVMBMGA1UEAxMMSm9lbCBCZW5uZXR0
# MScwJQYJKoZIhvcNAQkBFhhKYXlrdWxASHVkZGxlZE1hc3Nlcy5vcmcwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDXuceXJZYARJbSTU4hoh91goVp2POx
# 6Mz/QZ6D5jcT/JNhdW2GwYQ9YUxNj8jkhXg2Ixbgb1djRGMFC/ekgRkgLxyiuhRh
# NrVE1IdV4hT4as3idqnvWOi0S3z2R2EGdebqwm2mrRmq9+DbY+FGxuNwLboWZx8Z
# roGlLLHRPzt9pabQq/Nu/FIFO+4JzZ8S5ZnEaKTm4dpD0g6j653OWYVvNXJbS/W4
# Dis5aRkHT1q1Gp02dYHh3NTKrpv1nus9BTDlJRwmU/FgGLNQIvnRwqVoBh+I7tVq
# NIRnI1RpDTGyFEohbH8mRlwq3z4ijtb6j9boUJEqd8hQshzUMcALoTIR1tN/5APX
# u2j4OqGFESM/OG0i2hLKbnP81u581aZT1BfVfQxvDuWrFiurMxllVGY1NvKkXwc8
# aOZktqMQWbWAs2bxZqERbOILXOmkL/mvPdy+e5yQveriHAhrDONu7a79ylreMHBR
# XrmYJTK2G/aHvB5vrXjMPw0TBeph0sM2BN2eVzenAAMsIiGlXPXvtKrpKRiBdx5f
# 9SV5dyUG2tR8ANDuc2AMB8FKICuMUd8Sx96p4FOBQhXhvF/RZcWZIW5o+A4sHvYE
# /s4oiX7LxGrQK2abNiCVs9BDLI/EcSs/TP+ZskBqu7Qb+AVeevoY3T7skihuyC/l
# h7EwqjfNpVQ9UwIDAQABo4G0MIGxMB0GA1UdDgQWBBTgB9XYJV/kJAvnkWmKDHsh
# 7Cn3PzAfBgNVHSMEGDAWgBQ+5x4ah0JG0o4iUj0TebNd4MCVxTAJBgNVHRMEAjAA
# MBEGCWCGSAGG+EIBAQQEAwIEEDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDAzALBgNV
# HQ8EBAMCBsAwLAYJYIZIAYb4QgENBB8WHU9wZW5TU0wgR2VuZXJhdGVkIENlcnRp
# ZmljYXRlMA0GCSqGSIb3DQEBBQUAA4ICAQAw8B6+s48CZZo5h5tUeKV7OWNXKRG7
# xkyavMkXpEi58BSLutmE3O7smc3uvu3TdCXENNUlGrcq/KQ8y2eEI8QkHgT99VgX
# r+v5xu2KnJXiOOIxi65EZybRFFFaGJNodTcrK8L/tY6QLF02ilOlEgfcc1sV/Sj/
# r60JS1iXIMth7nYZVjtWeYXOrsd+I+XwJuoVNJlELNdApOU4ZVNrPEuV+QRNMimj
# lqIOv2tn9TDdNGUqaOCI0w+a1XQvapEPWETfQK+o9pvYINTswGDjNeb7Xz8ar2JB
# 9IVs2xtxDohHB75kyRrlY1hkoY5j12ZhWOlm0L9Ks6XvmMtXJIjj0/m9Z+3s+9p6
# U7IYjz5NnzmDvtNUn2y9zxB/rUx/JqoUO3BWRKiLX0lvGRWJlzFr9978kH2SXxAD
# rsKfzB7YZzMh9hZkGNlJf4T+HTB/OXG1jyfkyqQvhNB/tDAaq+ejDtKNBF4hMS7K
# Z0B4vagIxFwMuTiei4UaOjrGzeCfT9w1Bmj6uLJme5ydQVM0V7z3Z6jR3LVq4c4s
# Y1dfPmYlw62cbyV9Kb/H2hYw5K0OMX60LfLQZOzIPzAeRJ87NufwZnC1afxsSCmU
# bvSx4kCMgRZMXw+d1SHRhh7z+06YTQjnUMmtTGt7DtUkU6I8LKEWF/mAzF7sq/7P
# AyhPsbu91X5FuzGCA3YwggNyAgEBMIHUMIHGMQswCQYDVQQGEwJVUzERMA8GA1UE
# CBMITmV3IFlvcmsxEjAQBgNVBAcTCVJvY2hlc3RlcjEaMBgGA1UEChMRSHVkZGxl
# ZE1hc3Nlcy5vcmcxHjAcBgNVBAsTFUNlcnRpZmljYXRlIEF1dGhvcml0eTErMCkG
# A1UEAxMiSm9lbCBCZW5uZXR0IENlcnRpZmljYXRlIEF1dGhvcml0eTEnMCUGCSqG
# SIb3DQEJARYYSmF5a3VsQEh1ZGRsZWRNYXNzZXMub3JnAgkAqkNFUy2/QuowCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFOvLNU6+8DDX82nGYrbW6PQveyjfMA0GCSqGSIb3DQEBAQUA
# BIICANMEMm6b38+4XO2OvegDHbZF99B0McYH1yL6AgIgcyOPoSEVzlrsBjgCPIRg
# VW5yhhaNO7iEFKnPVwQzk9fxh/59obuzUqNL3Pz+I1YOjRBgNXomABwUKJJu+44Y
# qcqxM/4uRWzi2oCidPKEw2wJxK/q+AxkudE6/mcX98qz/P4VMv18/kh3fBhCa+pP
# jQsFcxNa2aOCsFYDtkjx0cT51ZKFG9+yeMeamyl1evCvhdwXpqeEKYRj6ZC99zfI
# vBtj8gG8adv4WOHvUwo2s/G6RL1zPWNlblm5ZhsiBw98KG7/0KeaVFc3BUZyrOJZ
# Wt8QUF/YBUsGpvbvBYfeh2wPne+dyo+TkiCPe45SN50SqVqGqKiKL4bB4vrpv1Qy
# n390diw7Z0n71HBFfKulbcu14KjHWS7NRCi7HuIXBmbRWCuX+BFrMAgyj0NWbFbe
# NgSaVB9RO8mu1QdgujTxH5CvTEvg64w4glPwCb6/oBKoKsiEXamAPkvpcZ1coW0q
# Jn5hbgJMx4i3AkTuDKEl1X7CWlXb3todJ+OgQc2Ss0EPemfm9sRqFaMMctziiGWO
# sQy3wWRF8Dz4kVtr27VM/6F7JPPL7a/8aREmTqmvvLhWpjJ6/4bgZ7ihhadzWjoI
# g7pJadoPkDDCdH4o5m9sQIOwZf/tlY/BYY6EXVXCxhKnsCFl
# SIG # End signature block