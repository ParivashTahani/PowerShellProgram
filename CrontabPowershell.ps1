function ConvertingCrontabDate {

    param (
        $cronExpression,
        $givenDate
    )
    
    $cronFields = $cronExpression -split ' '
    $minutes = CrontabFieldValues $cronFields[0] 0 59
    $hours = CrontabFieldValues $cronFields[1] 0 23
    $days = CrontabFieldValues $cronFields[2] 1 ([System.DateTime]::DaysInMonth($givenDate.Year, $givenDate.Month))
    $months = CrontabFieldValues $cronFields[3] 1 12 
    $daysOfWeek = CrontabFieldValues $cronFields[4] 0 6

    $mostRecentDate = $givenDate

    while ($true) {
        $mostRecentDate = $mostRecentDate.AddMinutes(-1)
        if ($minutes -contains $mostRecentDate.Minute -and

            $hours -contains $mostRecentDate.Hour -and
            $days -contains $mostRecentDate.Day -and
            $months -contains $mostRecentDate.Month -and
            $daysOfWeek -contains $mostRecentDate.DayOfWeek) {
            return $mostRecentDate
        }
    }
}

function CrontabFieldValues {

    param (
        $field, 
        $minValue,
        $maxValue
    )
   
    if ($field -eq '*') { 
        return $minValue..$maxValue 
    }
   
    $values = @()
    $subFields = $field -split ','
    foreach ($subField in $subFields) {
        if ($subField -match '(\d+)\-(\d+)') {
            $values += $matches[1]..$matches[2]
        } 
        elseif ($subField -match '^\*/(\d+)') { 
            $step = $matches[1]
            $values += $minValue..$maxValue | Where-Object { ($_ - $minValue) % $step -eq 0 }
        } 
        else {
            $values += [int]$subField 
        }
    }
    return $values
}
#Example:
$cronExpression = "3 * * * *"  
$givenDate = Get-Date 
$formattedGivendate = $givenDate.ToString("dd/MM/yyyy HH:mm:ss")
$mostRecentDate = ConvertingCrontabDate -cronExpression $cronExpression -givenDate $givenDate
$formattedDate = $mostRecentDate.ToString("dd/MM/yyyy HH:mm:ss")
write-host $formattedDate
Write-Host "Most recent date before $formattedGivendate that matches '$cronExpression' is: $formattedDate "
