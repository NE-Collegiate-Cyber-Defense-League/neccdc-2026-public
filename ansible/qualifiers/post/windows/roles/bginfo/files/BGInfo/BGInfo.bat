reg add HKU\.DEFAULT\Software\Sysinternals\BGInfo /v EulaAccepted /t REG_DWORD /d 1 /f

"\\placebo-pharma.local\SYSVOL\placebo-pharma.local\scripts\BGInfo\BGInfo64.exe" "\\placebo-pharma.local\SYSVOL\placebo-pharma.local\scripts\BGInfo\BGInfoConfig.bgi" /silent /nolicprompt /timer:0