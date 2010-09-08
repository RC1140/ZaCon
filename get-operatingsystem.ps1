$sku = Get-WmiObject Win32_OperatingSystem
switch ($sku.OperatingSystemSKU)
{
    0   {"Undefined"; break}
    1   {"Ultimate Edition"; break}
    2   {"Home Basic Edition"; break}
    3   {"Home Basic Premium Edition"; break}
    4   {"Enterprise Edition"; break}
    5   {"Home Basic N Edition"; break}
    6   {"Business Edition"; break}
    7   {"Standard Server Edition"; break}
    8   {"Datacenter Server Edition"; break}
    9   {"Small Business Server Edition"; break}
    10  {"Enterprise Server Edition"; break}
    11  {"Starter Edition"; break}
    12  {"Datacenter Server Core Edition"; break}
    13  {"Standard Server Core Edition"; break}
    14  {"Enterprise Server Core Edition"; break}
    15  {"Enterprise Server Edition for Itanium-Based Systems"; break}
    16  {"Business N Edition"; break}
    17  {"Web Server Edition"; break}
    18  {"Cluster Server Edition"; break}
    19  {"Home Server Edition"; break}
    20  {"Storage Express Server Edition"; break}
    21  {"Storage Standard Server Edition"; break}
    22  {"Storage Workgroup Server Edition"; break}
    23  {"Storage Enterprise Server Edition"; break}
    24  {"Server For Small Business Edition"; break}
    25  {"Small Business Server Premium Edition"; break}
    default {"UNKNOWN: " + $SKU.OperatingSystemSKU}
}