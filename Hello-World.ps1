#Single Line Comments 
[int]$CleanVariableName = ''
$CleanVariableName 
<#

    Mulit Line Comment 

#>
${Rea#llyD@dg3Variable} = 666

${Rea#llyD@dg3Variable} 

'Single Quotes' + ' Need to contactenate strings' 
<# VS #> 
$extrastrings = 'can embed extra data'
"Double Quotes $extraStrings"

#For
'For'
for($i = 0;$i -lt 2;$i++)
{
    $i
}

#Foreach
'Foreach'
$loopItems = 1,2,3,4,5
foreach($i in $loopItems)
{
    $i
}

#While
'While'
$count = 4
while($count -gt 2)
{
    $count
    $count--
}
#Do While
'Do While'
do
{
    'Only One Run'
    break
}while($true)