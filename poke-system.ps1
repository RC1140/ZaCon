function get-users()
{
    gwmi win32_useraccount | %{$_}
}

function get-applications()
{
    gwmi Win32_Product
}

function get-firewallrules()
{
    param([string]$rulename='Windows Media')
    (New-Object -ComObject HNetCfg.FwPolicy2).rules | ? {$_.name -match $rulename}
}

function get-ADComputers()
{
    ([adsisearcher]"objectcategory=computer").findall() | %{([adsi]$_.path).cn + $_.properties.operatingsystemversion}

}

function get-osname()
{
    param([parameter(Mandatory=$true)][string]$osversion)
    switch($osversion)
    {
        '6.1'  { 'Windows 7/Windows Server 2008 R2'}
        '6.0'  { 'Windows Server 2008/Windows Vista'}
        '5.2'  { 'Windows Server 2003 R2/Windows Server 2003/Windows XP 64-Bit Edition'}
        '5.1'  { 'Windows XP'}
        '5.0'  { 'Windows 2000'}
    }
}

function get-localOsVersion()
{
    get-wmiobject Win32_OperatingSystem | select caption,ServicePackMajorVersion
}

