#This script is to encrypt and decrypt the plain text to Base64 encoding.
#Change UTF8 to UTF32 as necessary
#Param([String]$Text)

function EncodeBase64($Text){    
        $ByteStr = [system.Text.Encoding]::UTF8.GetBytes($Text)
        $Base64enc = [Convert]::ToBase64String($ByteStr)
        return $Base64enc
<#
.Synopsis
   Encode the given text to Base64 string.
.DESCRIPTION
   The cmdlet encrypts the given text to Base64 encoded string.
.EXAMPLE
   EncodeBase64 -Text "String to Encode to Base64"
.EXAMPLE
   An example of copying the encoded string to clipboard
   Set-Clipboard -Value (EncodeBase64 -Text "String to Encode to Base64")
#>
}

function DecodeBase64($Text){        
        $Base64dec = [system.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Text))        
        return $Base64dec
<#
.Synopsis
   Decode the given Base64 string to simple text output.
.DESCRIPTION
   The cmdlet decrypts the given Base64 encoded string to a normal text output.
.EXAMPLE
   DecodeBase64 -Text "U3RyaW5nIHRvIEVuY29kZSB0byBCYXNlNjQ="
.EXAMPLE
   An example of copying the encoded string to clipboard
   Set-Clipboard -Value (DecodeBase64 -Text "U3RyaW5nIHRvIEVuY29kZSB0byBCYXNlNjQ=")
#>
}

