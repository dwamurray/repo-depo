$cipherpath = "HKLM\system\currentcontrolset\control\securityproviders\schannel\ciphers"
$ciphers = @(
'NULL',
'DES 56/56',
'RC2 128/128',
'RC2 40/128',
'RC2 56/128',
'RC2 64/128',
'RC4 128/128',
'RC4 40/128',
'RC4 56/128',
'RC4 64/128',
'AES 128/128',
'AES 256/256',
'Triple DES 168/168'
)

$protocolpath = "HKLM\system\currentcontrolset\control\securityproviders\schannel\protocols"
$protocols = @(
'SSL 2.0\Client',
'SSL 2.0\Server',
'SSL 3.0\Client',
'SSL 3.0\Server',
'TLS 1.0\Client',
'TLS 1.0\Server'
)

$COE = if ( 
get-content C:\vlogdir\coe08128.log | 
select-string "9.9.0\\.*has"
) { 
"9.9.0 installed"
} else {
"9.9.0 not installed"
}

$KB948963 = if ( 
get-hotfix | select KB948963
) {
"Installed"
} else {
"Not installed"
}

$KB4012598 = if ( 
get-hotfix | select KB4012598
) {
"Installed"
} else {
"Not installed"
}

$obj = new-object –typename psobject

$obj | add-member –membertype noteproperty `
-name Server –value $env:computername

$obj | add-member –membertype noteproperty `
-name "Patch level" –value $COE

$obj | add-member –membertype noteproperty `
-name "KB948963 AES & TLS patch" –value $KB948963

$obj | add-member –membertype noteproperty `
-name "KB4012598 Crit1 SMB patch" –value $KB4012598


foreach ( $cipher in $ciphers ) {
$value = reg query $cipherpath\$cipher /v Enabled 2>&1
if ( $LASTEXITCODE -eq "1" )
{ $value = "Not configured" }
elseif ( 
( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $value = "Disabled" }
else { $value = "Enabled" }

#$ciphertable = @{
#Server = $env:computername
#Value = $cipher
#Status = $value
#}

#new-object psobject -property $ciphertable
$obj | add-member –membertype noteproperty `
-name "$cipher cipher" –value $value

}

foreach ( $protocol in $protocols ) {
$value = reg query "$protocolpath\$protocol" /v Enabled 2>&1
if ( $LASTEXITCODE -eq "1" )
{ $value = "Not configured" }
elseif ( 
( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $value = "Disabled" }
else { $value = "Enabled" }

#$protocoltable = @{
#Server = $env:computername
#Value = $protocol
#Status = $value
#}

#new-object psobject -property $protocoltable

$obj | add-member –membertype noteproperty `
-name "$protocol protocol" –value $value


}
write-output $obj