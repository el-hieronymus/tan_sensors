'========================================
' Custom Tag Add Tag
'========================================

'Multiple tags may be specified as a delimited list using spaces or the #|# character sequence

Option Explicit

Const HKLM = &H80000002

If WScript.Arguments.Count > 0 Then
	Dim strRegKey, strArg, arrTags, strTag
	Dim objReg : Set objReg = Getx32RegistryProvider()
	Dim objWshShell : Set objWshShell = CreateObject("WScript.Shell")
	
	strRegKey = GetClientRegistryPathReg(objReg) & "\Sensor Data\Tags"
	
	strArg = UTF8Decode(WScript.Arguments.Item(0))
	
	If InStr(1, strArg, "#|#", vbTextCompare) > 0 Then
		arrTags = Split(strArg, "#|#", -1, vbTextCompare)
	Else
		arrTags = Split(strArg, " ")
	End If
	For Each strTag In arrTags
		strTag = Trim(strTag)
		If Len(strTag) > 0 Then
			WScript.Echo "Process tag: " & strTag
			
			Dim strTagtest, intReturn
			intReturn = objReg.GetStringValue(HKLM, strRegKey, strTag, strTagtest)
			If intReturn = 0 Then
				WScript.Echo "Tag already exists: " & strTag
			Else
				Dim strCommand : strCommand = "reg.exe Add ""HKLM\" & strRegKey & """ /v """ & strTag & """ /d ""Added: " & CStr(Now()) & """ /f /reg:32"
				WScript.Echo "Run: " & strCommand
				Dim objExec : Set objExec = objWshShell.Exec(strCommand)
				Do While objExec.StdOut.AtEndOfStream = False
					WScript.Echo objExec.StdOut.ReadAll
				Loop
				Do While objExec.StdErr.AtEndOfStream = False
					WScript.Echo objExec.StdErr.ReadAll
				Loop
				
				intReturn = objReg.GetStringValue(HKLM, strRegKey, strTag, strTagtest)
				If intReturn = 0 Then
					WScript.Echo "Added tag: " & strTag
				Else
					WScript.Echo "Failed to add tag: " & strTag
				End If
			End If
		End If
	Next	
Else
	WScript.Echo "No argument passed in.  Do nothing."
End If

Function UTF8Decode(str)
    Dim arraylist(), strLen, i, sT, val, depth, sR
    Dim arraysize
    arraysize = 0
    strLen = Len(str)
    for i = 1 to strLen
        sT = mid(str, i, 1)
        if sT = "%" then
            if i + 2 <= strLen then
                Redim Preserve arraylist(arraysize + 1)
                arraylist(arraysize) = cbyte("&H" & mid(str, i + 1, 2))
                arraysize = arraysize + 1
                i = i + 2
            end if
        else
            Redim Preserve arraylist(arraysize + 1)
            arraylist(arraysize) = asc(sT)
            arraysize = arraysize + 1
        end if
    next
    depth = 0
    for i = 0 to arraysize - 1
		Dim mybyte
        mybyte = arraylist(i)
        if mybyte and &h80 then
            if (mybyte and &h40) = 0 then
                if depth = 0 then
                    Err.Raise 5
                end if
                val = val * 2 ^ 6 + (mybyte and &h3f)
                depth = depth - 1
                if depth = 0 then
                    sR = sR & chrw(val)
                    val = 0
                end if
            elseif (mybyte and &h20) = 0 then
                if depth > 0 then Err.Raise 5
                val = mybyte and &h1f
                depth = 1
            elseif (mybyte and &h10) = 0 then
                if depth > 0 then Err.Raise 5
                val = mybyte and &h0f
                depth = 2
            else
                Err.Raise 5
            end if
        else
            if depth > 0 then Err.Raise 5
            sR = sR & chrw(mybyte)
        end if
    next
    if depth > 0 then Err.Raise 5
    UTF8Decode = sR
End Function

Function Getx32RegistryProvider
	Dim objCtx : Set objCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
	objCtx.Add "__ProviderArchitecture", 32
	Dim objLocator : Set objLocator = CreateObject("Wbemscripting.SWbemLocator")
	Dim objServices : Set objServices = objLocator.ConnectServer("","root\default","","",,,,objCtx)
	Dim objRegProv : Set objRegProv = objServices.Get("StdRegProv")   
	
	Set Getx32RegistryProvider = objRegProv
End Function ' Getx32RegistryProvider

Function GetClientRegistryPathReg(objReg)
	'GetClientRegistryPathReg works in x64 or x32
	'looks for a valid Path value

	Dim strPath
	Dim strKeyPath : For Each strKeyPath In Array("Software\Tanium\Tanium Client", "Software\Wow6432Node\Tanium\Tanium Client")
		objReg.GetStringValue &h80000002, strKeyPath, "Path", strPath
		
		If (IsNull(strPath) = False) And (strPath <> "") Then
			GetClientRegistryPathReg = strKeyPath
			Exit Function
		End If
	Next
	fRaiseError 5, "GetClientRegistryPathReg", "TSE-Error:Can not locate client registry area", False
End Function 'GetClientRegistryPathReg

Function fRaiseError(errCode, errSource, errorMsg, RaiseError)
    If RaiseError Then
      On Error Resume Next
      Call Err.Raise(errCode, errSource, errorMsg)
      Exit Function
    Else
      WScript.Echo errorMsg
      Wscript.Quit
    End If
End Function
' Copyright 2022, Tanium Inc.

'' SIG '' Begin signature block
'' SIG '' MIIjbgYJKoZIhvcNAQcCoIIjXzCCI1sCAQExCzAJBgUr
'' SIG '' DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
'' SIG '' gjcCAR4wJAIBAQQQTvApFpkntU2P5azhDxfrqwIBAAIB
'' SIG '' AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFGPhMPQcI6/L
'' SIG '' 7Rs5E7xE74pXIDfaoIIdjjCCBSUwggQNoAMCAQICEAps
'' SIG '' RMexcxJHJwozgKuRmMowDQYJKoZIhvcNAQELBQAwcjEL
'' SIG '' MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IElu
'' SIG '' YzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8G
'' SIG '' A1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENv
'' SIG '' ZGUgU2lnbmluZyBDQTAeFw0yMTAyMTgwMDAwMDBaFw0y
'' SIG '' NDAzMDYyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRMwEQYD
'' SIG '' VQQIEwpDYWxpZm9ybmlhMRMwEQYDVQQHEwpFbWVyeXZp
'' SIG '' bGxlMRQwEgYDVQQKEwtUYW5pdW0gSW5jLjEUMBIGA1UE
'' SIG '' AxMLVGFuaXVtIEluYy4wggEiMA0GCSqGSIb3DQEBAQUA
'' SIG '' A4IBDwAwggEKAoIBAQClopxvUwtO/9wXE+s4O2r3PM6W
'' SIG '' wwsSjBuOMs+UNRUUgErQo60bRHgZT0DBgAV+vp6L3iHY
'' SIG '' SEf6I1tCmSn3rdW0fS/NHnzFO4ggqPukYdB1A7dQ6DQw
'' SIG '' dMxVxXdzUsPkyARIGYLx7DecQ5TEdzbkpq9g2jjM5ACm
'' SIG '' 0etzFU2KWKmCm7/VW3BRL24yaEvXVEqOBOkPugNzSPoU
'' SIG '' oVlFNPR/Ao9sEr89AwyAZ0F48PHXTGRFS1lwgL+VC28i
'' SIG '' F0ELXaKKz/3OODT21rS7ydh6On4yd/hDKhlgKi5Cy/wf
'' SIG '' UDFlkTlkQC6aQ6WOIhYvLFQZBVX2c4iuTQiUtucgZd5c
'' SIG '' VMTUeAutAgMBAAGjggHEMIIBwDAfBgNVHSMEGDAWgBRa
'' SIG '' xLl7KgqjpepxA8Bg+S32ZXUOWDAdBgNVHQ4EFgQUXUq5
'' SIG '' tVbzg9KQCh9xDSpkH/iuKNQwDgYDVR0PAQH/BAQDAgeA
'' SIG '' MBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4w
'' SIG '' NaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9z
'' SIG '' aGEyLWFzc3VyZWQtY3MtZzEuY3JsMDWgM6Axhi9odHRw
'' SIG '' Oi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVk
'' SIG '' LWNzLWcxLmNybDBLBgNVHSAERDBCMDYGCWCGSAGG/WwD
'' SIG '' ATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2lj
'' SIG '' ZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcB
'' SIG '' AQR4MHYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
'' SIG '' Z2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZCaHR0cDovL2Nh
'' SIG '' Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFz
'' SIG '' c3VyZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB
'' SIG '' /wQCMAAwDQYJKoZIhvcNAQELBQADggEBAL3iDKusBRNd
'' SIG '' dWqYzgi4gle9uGbw22VS2KlwUKS4dcYpeOIt1BrI9WD3
'' SIG '' l6MazbG5dOHWQf1gfPRizJbOl7ElC0xW9/pSPqwQyXpY
'' SIG '' iFfLsR28LprBljklYPBrcIiuMeB6tnj0atmCtJz0YNzw
'' SIG '' n+vumP1oEVtc6WlGqdqwbREm8py0mA4CKzdpUBeagU5C
'' SIG '' i7xtZbZfioywPiQAoCYDdaE5cKDeWvQbIqN1q8kFMKMy
'' SIG '' FPnGBenxVxkProuixnzZaGpZ9uL9Xi2ylkLtd4IkXiyn
'' SIG '' C3ID2QRU8T3V2P4oh6Ir/IkExz0PuOqK60qPdyKfISeF
'' SIG '' bNrTqZ7CKP4YnD10MEFKHDkwggUwMIIEGKADAgECAhAE
'' SIG '' CRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUx
'' SIG '' CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
'' SIG '' bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
'' SIG '' BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBD
'' SIG '' QTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAwMDBa
'' SIG '' MHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
'' SIG '' dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
'' SIG '' MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJ
'' SIG '' RCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEB
'' SIG '' AQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZ
'' SIG '' z9D7RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnU
'' SIG '' NxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
'' SIG '' lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj
'' SIG '' 6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvO
'' SIG '' f+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv
'' SIG '' 5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0
'' SIG '' xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6f
'' SIG '' pjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8E
'' SIG '' CDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUE
'' SIG '' DDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYI
'' SIG '' KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
'' SIG '' bTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGln
'' SIG '' aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
'' SIG '' LmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2Ny
'' SIG '' bDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
'' SIG '' Um9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGln
'' SIG '' aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
'' SIG '' LmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
'' SIG '' BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQu
'' SIG '' Y29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5
'' SIG '' eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReui
'' SIG '' r/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQAD
'' SIG '' ggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+
'' SIG '' C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSB
'' SIG '' ThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6R
'' SIG '' Ffu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwU
'' SIG '' R6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZk
'' SIG '' DCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qz
'' SIG '' sIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmC
'' SIG '' SfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggWx
'' SIG '' MIIEmaADAgECAhABJAr7HjgLihbxS3Gd9NPAMA0GCSqG
'' SIG '' SIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
'' SIG '' EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
'' SIG '' Y2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3Vy
'' SIG '' ZWQgSUQgUm9vdCBDQTAeFw0yMjA2MDkwMDAwMDBaFw0z
'' SIG '' MTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYD
'' SIG '' VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
'' SIG '' aWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
'' SIG '' dXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQAD
'' SIG '' ggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqcl
'' SIG '' LskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutW
'' SIG '' xpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVy
'' SIG '' r2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvu
'' SIG '' INXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0
'' SIG '' QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclP
'' SIG '' XuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN
'' SIG '' 2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1Lyu
'' SIG '' GwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
'' SIG '' WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aa
'' SIG '' dMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTS
'' SIG '' YW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqx
'' SIG '' YxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+U
'' SIG '' DCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRES
'' SIG '' W+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LW
'' SIG '' RV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMB
'' SIG '' AAGjggFeMIIBWjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
'' SIG '' DgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSME
'' SIG '' GDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8B
'' SIG '' Af8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgweQYI
'' SIG '' KwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8v
'' SIG '' b2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0
'' SIG '' dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
'' SIG '' dEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6
'' SIG '' oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
'' SIG '' Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAgBgNVHSAE
'' SIG '' GTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
'' SIG '' hvcNAQEMBQADggEBAJoWAqUB74H7DbRYsnitqCMZ2XM3
'' SIG '' 2mCeUdfL+C9AuaMffEBOMz6QPOeJAXWF6GJ7HVbgcbre
'' SIG '' XsY3vHlcYgBN+El6UU0GMvPF0gAqJyDqiS4VOeAsPvh1
'' SIG '' fCyCQWE1DyPQ7TWV0oiVKUPL4KZYEHxTjp9FySA3FMDt
'' SIG '' Gbp+dznSVJbHphHfNDP2dVJCSxydjZbVlWxHEhQkXyZB
'' SIG '' +hpGvd6w5ZFHA6wYCMvL22aJfyucZb++N06+LfOdSsPM
'' SIG '' zEdeyJWVrdHLuyoGIPk/cuo260VyknopexQDPPtN1khx
'' SIG '' ehARigh0zWwbBFzSipUDdlFQU9Yu90pGw64QLHFMsIe2
'' SIG '' JzdEYEQwggauMIIElqADAgECAhAHNje3JFR82Ees/Shm
'' SIG '' Kl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVT
'' SIG '' MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
'' SIG '' EHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
'' SIG '' ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAw
'' SIG '' MDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVT
'' SIG '' MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
'' SIG '' AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNI
'' SIG '' QTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3
'' SIG '' DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
'' SIG '' JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI
'' SIG '' 82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR
'' SIG '' 8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU
'' SIG '' 5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3Hxq
'' SIG '' V3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtA
'' SIG '' rF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECn
'' SIG '' wHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu
'' SIG '' 9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz
'' SIG '' 9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpUR
'' SIG '' K1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
'' SIG '' 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/
'' SIG '' BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T
'' SIG '' /jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uK
'' SIG '' IqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11G
'' SIG '' deJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzS
'' SIG '' M7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
'' SIG '' /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+e
'' SIG '' yG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4c
'' SIG '' D08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
'' SIG '' AQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcw
'' SIG '' AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsG
'' SIG '' AQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
'' SIG '' b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNV
'' SIG '' HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2Vy
'' SIG '' dC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAg
'' SIG '' BgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
'' SIG '' DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m
'' SIG '' 1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxp
'' SIG '' wc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGId
'' SIG '' DAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqr
'' SIG '' hc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp8
'' SIG '' 76i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
'' SIG '' RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY
'' SIG '' +/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHx
'' SIG '' cpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fx
'' SIG '' ZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhz
'' SIG '' q6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o
'' SIG '' 08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1Oby
'' SIG '' F5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvt
'' SIG '' lUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ
'' SIG '' 8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8
'' SIG '' mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
'' SIG '' 1nz8MIIGxjCCBK6gAwIBAgIQCnpKiJ7JmUKQBmM4TYaX
'' SIG '' nTANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEX
'' SIG '' MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
'' SIG '' MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEy
'' SIG '' NTYgVGltZVN0YW1waW5nIENBMB4XDTIyMDMyOTAwMDAw
'' SIG '' MFoXDTMzMDMxNDIzNTk1OVowTDELMAkGA1UEBhMCVVMx
'' SIG '' FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSQwIgYDVQQD
'' SIG '' ExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIwggIi
'' SIG '' MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5KpYj
'' SIG '' ply8X9ZJ8BWCGPQz7sxcbOPgJS7SMeQ8QK77q8TjeF1+
'' SIG '' XDbq9SWNQ6OB6zhj+TyIad480jBRDTEHukZu6aNLSOiJ
'' SIG '' QX8Nstb5hPGYPgu/CoQScWyhYiYB087DbP2sO37cKhyp
'' SIG '' vTDGFtjavOuy8YPRn80JxblBakVCI0Fa+GDTZSw+fl69
'' SIG '' lqfw/LH09CjPQnkfO8eTB2ho5UQ0Ul8PUN7UWSxEdMAy
'' SIG '' Rxlb4pguj9DKP//GZ888k5VOhOl2GJiZERTFKwygM9tN
'' SIG '' JIXogpThLwPuf4UCyYbh1RgUtwRF8+A4vaK9enGY7BXn
'' SIG '' /S7s0psAiqwdjTuAaP7QWZgmzuDtrn8oLsKe4AtLyAjR
'' SIG '' MruD+iM82f/SjLv3QyPf58NaBWJ+cCzlK7I9Y+rIroEg
'' SIG '' a0OJyH5fsBrdGb2fdEEKr7mOCdN0oS+wVHbBkE+U7IZh
'' SIG '' /9sRL5IDMM4wt4sPXUSzQx0jUM2R1y+d+/zNscGnxA7E
'' SIG '' 70A+GToC1DGpaaBJ+XXhm+ho5GoMj+vksSF7hmdYfn8f
'' SIG '' 6CvkFLIW1oGhytowkGvub3XAsDYmsgg7/72+f2wTGN/G
'' SIG '' baR5Sa2Lf2GHBWj31HDjQpXonrubS7LitkE956+nGijJ
'' SIG '' rWGwoEEYGU7tR5thle0+C2Fa6j56mJJRzT/JROeAiylC
'' SIG '' cvd5st2E6ifu/n16awIDAQABo4IBizCCAYcwDgYDVR0P
'' SIG '' AQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
'' SIG '' BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwB
'' SIG '' BAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1N
'' SIG '' hS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSNZLeJIf5W
'' SIG '' WESEYafqbxw2j92vDTBaBgNVHR8EUzBRME+gTaBLhklo
'' SIG '' dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRU
'' SIG '' cnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5n
'' SIG '' Q0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEF
'' SIG '' BQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgG
'' SIG '' CCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
'' SIG '' dC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hB
'' SIG '' MjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEB
'' SIG '' CwUAA4ICAQANLSN0ptH1+OpLmT8B5PYM5K8WndmzjJeC
'' SIG '' KZxDbwEtqzi1cBG/hBmLP13lhk++kzreKjlaOU7YhFml
'' SIG '' vBuYquhs79FIaRk4W8+JOR1wcNlO3yMibNXf9lnLocLq
'' SIG '' THbKodyhK5a4m1WpGmt90fUCCU+C1qVziMSYgN/uSZW3
'' SIG '' s8zFp+4O4e8eOIqf7xHJMUpYtt84fMv6XPfkU79uCnx+
'' SIG '' 196Y1SlliQ+inMBl9AEiZcfqXnSmWzWSUHz0F6aHZE8+
'' SIG '' RokWYyBry/J70DXjSnBIqbbnHWC9BCIVJXAGcqlEO2lH
'' SIG '' EdPu6cegPk8QuTA25POqaQmoi35komWUEftuMvH1uzit
'' SIG '' zcCTEdUyeEpLNypM81zctoXAu3AwVXjWmP5UbX9xqUga
'' SIG '' eN1Gdy4besAzivhKKIwSqHPPLfnTI/KeGeANlCig69sa
'' SIG '' UaCVgo4oa6TOnXbeqXOqSGpZQ65f6vgPBkKd3wZolv4q
'' SIG '' oHRbY2beayy4eKpNcG3wLPEHFX41tOa1DKKZpdcVazUO
'' SIG '' hdbgLMzgDCS4fFILHpl878jIxYxYaa+rPeHPzH0VrhS/
'' SIG '' inHfypex2EfqHIXgRU4SHBQpWMxv03/LvsEOSm8gnK7Z
'' SIG '' czJZCOctkqEaEf4ymKZdK5fgi9OczG21Da5HYzhHF1tv
'' SIG '' E9pqEG4fSbdEW7QICodaWQR2EaGndwITHDGCBUwwggVI
'' SIG '' AgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
'' SIG '' aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
'' SIG '' dC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNz
'' SIG '' dXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0ECEApsRMexcxJH
'' SIG '' JwozgKuRmMowCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
'' SIG '' AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
'' SIG '' AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
'' SIG '' gjcCARUwIwYJKoZIhvcNAQkEMRYEFNsgGftB1C95i1QE
'' SIG '' GnFDhh+s1LiAMA0GCSqGSIb3DQEBAQUABIIBAFQ75ilz
'' SIG '' 3Y6TzfxRMsuLBuAcRpEB0aTV/oYKGExW/grzZxQzaEWy
'' SIG '' JbfQaAcvaO3qOu1XGJscz2VXXqeVvi6BwSKdio6yjrhX
'' SIG '' QhZhFXsXYB4GqLrNHBjmPvwfaQyoQC2s2vWNltOzdPwu
'' SIG '' WMcMVFJhQaRNVAQXrx+PwIsjlDWNgJR/3KLzFz947jvM
'' SIG '' rYSvO6B2yBzG1L3HxGFlzItKE9/cE6kX3WzfnyhNeCKz
'' SIG '' XX5W9OKAKm4y2gBZIUcxCdJpmwi03Xx2FZqkH7n5f9Hl
'' SIG '' uDPL3oo9gdU8txD0pS21l/AxG5MiZNbNwIxSRkKksggS
'' SIG '' 0znZyxR9N1nVe/R041J0e6tr+V6hggMgMIIDHAYJKoZI
'' SIG '' hvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJV
'' SIG '' UzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
'' SIG '' BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBT
'' SIG '' SEEyNTYgVGltZVN0YW1waW5nIENBAhAKekqInsmZQpAG
'' SIG '' YzhNhpedMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcN
'' SIG '' AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
'' SIG '' MjIwNjE3MDUzOTA5WjAvBgkqhkiG9w0BCQQxIgQgymeq
'' SIG '' +VwB3S8Bc4J68YH44bo5nYDc2Cu1nEnR+lIhQzEwDQYJ
'' SIG '' KoZIhvcNAQEBBQAEggIAocpxtP58aykXkUoMFYm1fkcl
'' SIG '' PRKCgUm0U+HhTif8wmXFNhbJt0/4X7K/SzeT2qWYcXXB
'' SIG '' x2EeMW9kF30Ec2NG/llZ3aGSfHKt2rIEnL1LEZokg7m0
'' SIG '' fHcnZvIKWF54LeOmgWndMXEu3EPaY3M3drzSvo7ozjuf
'' SIG '' bPoA2DVwsVq/+CBQrVRwlupIkiBUuqqOGBgVKo/bAH3F
'' SIG '' XW9Hmkl1f2Eo089AmRGZPFS5cUhirklxs1WFyeaWBc+y
'' SIG '' n01WacnvjoIFQsMDHFx+4CUvdYuZMjgNaC3pKfjhWtJe
'' SIG '' XCPgRQg9ZX/+gEDAywkdIJylGnGVZ5PPJF1yPqLRIVIr
'' SIG '' wD5ajAFr9REiEzYnmczzgBIkx8Nw8PzVcGkeewHbJHtz
'' SIG '' lTW8iBnOHE/vtfutsyLtWdbTywwZq5oIUvc6ZiJQn81Q
'' SIG '' qiLEp1alcTqsuQddJ08CyrPSVuNPuD/r0A+Xw//pAlug
'' SIG '' ur56h4EzV1qoNNCH+4B21knS8iye9vaWQ7NJlVzqLDsx
'' SIG '' BrPwKFsjW2xcdXB+/BETMs6O3nTWHtXvBxZnyekmZzIJ
'' SIG '' qSNQ87GqoK0hgKR4AMt8eXecRxZY04JnLMwztX+lGn/V
'' SIG '' EcbZ+96OghpImYpsQXes/WV/iUc30vWpzaYdlWInNPLO
'' SIG '' VmcdTNLRvXTQPm8Zb0vGtmxSbN51nx866aVldPEPakc=
'' SIG '' End signature block
