'@INCLUDE=i18n/UTF8Decode.vbs
'@INCLUDE=utils/settings/GetClientRegistryPath.vbs

'Multiple tags may be specified as a delimited list using spaces or the #|# character sequence

Option Explicit

If WScript.Arguments.Count > 0 Then
	Dim objWshShell, strRegKey, strArg, arrTags, strTag
	Set objWshShell = CreateObject("Wscript.Shell")
	
	strRegKey = GetClientRegistryPath() & "\Sensor Data\Tags\"
	
	strArg = UTF8Decode(WScript.Arguments.Item(0))
	
	If InStr(1, strArg, "#|#", vbTextCompare) > 0 Then
		arrTags = Split(strArg, "#|#", -1, vbTextCompare)
	Else
		arrTags = Split(strArg, " ")
	End If
	For Each strTag In arrTags
		strTag = Trim(strTag)
		If Len(strTag) > 0 Then
			On Error Resume Next
			Dim strTagtest : strTagtest = objWshShell.RegRead(strRegKey & strTag)
			If Err = 0 Then
				WScript.Echo "Tag already exists: " & strTag
			Else
				Err.Clear
				objWshShell.RegWrite strRegKey & strTag, "Added: " & CStr(Now())
				If Err = 0 Then
					WScript.Echo "Added tag: " & strTag
				Else
					WScript.Echo "Failed to add tag: " & strTag & " Error: " & Err.number
					Err.Clear
				End If
			End If
		End If
	Next	
Else
	WScript.Echo "No argument passed in.  Do nothing."
End If
'------------ INCLUDES after this line. Do not edit past this point -----
'- Begin file: i18n/UTF8Decode.vbs
'========================================
' UTF8Decode
'========================================
' Used to convert the UTF-8 style parameters passed from 
' the server to sensors in sensor parameters.
' This function should be used to safely pass non english input to sensors.

' To include this file, copy/paste: INCLUDE=i18n/UTF8Decode.vbs


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
'- End file: i18n/UTF8Decode.vbs
'- Begin file: utils/settings/GetClientRegistryPath.vbs
' Returns a registry path value to the Tanium Clients registry area,
' regardless of the context in which the script is currently running.

' This method should only be used with objShell style retrievals - Not for use
' with RegistryProviders.  Use GetTaniumRegistryPathReg for use with registry providers

' To include this file, copy/paste: INCLUDE=utils/settings/GetClientRegistryPath.vbs


Function GetClientRegistryPath()
	Dim objShell : Set objShell = CreateObject("WScript.Shell")
	On Error Resume Next
	Dim strPath : strPath = objShell.RegRead("HKLM\Software\Tanium\Tanium Client\Path")
	If strPath <> "" Then
		Dim strResult : strResult = "HKLM\Software\Tanium\Tanium Client"
	Else
		strPath = objShell.RegRead("HKLM\Software\Wow6432Node\Tanium\Tanium Client\Path")
		If strPath <> "" Then _
			strResult = "HKLM\Software\Wow6432Node\Tanium\Tanium Client"
	End If
	On Error GoTo 0
	
	If strResult="" Then Call fRaiseError(5, "GetClientRegistryPath", "TSE-Error:Can not locate client registry area", False)

	GetClientRegistryPath = strResult
End Function
'- End file: utils/settings/GetClientRegistryPath.vbs
'- Begin file: utils/RaiseError.vbs
' To include this file, copy/paste: INCLUDE=utils/RaiseError.vbs

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
'- End file: utils/RaiseError.vbs
' Copyright 2022, Tanium Inc.

'' SIG '' Begin signature block
'' SIG '' MIIZhAYJKoZIhvcNAQcCoIIZdTCCGXECAQExCzAJBgUr
'' SIG '' DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
'' SIG '' gjcCAR4wJAIBAQQQTvApFpkntU2P5azhDxfrqwIBAAIB
'' SIG '' AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFF07sopS/DW1
'' SIG '' NZw+kl7ffrZzaxCNoIIUlDCCBP4wggPmoAMCAQICEA1C
'' SIG '' SuC+Ooj/YEAhzhQA8N0wDQYJKoZIhvcNAQELBQAwcjEL
'' SIG '' MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IElu
'' SIG '' YzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8G
'' SIG '' A1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRp
'' SIG '' bWVzdGFtcGluZyBDQTAeFw0yMTAxMDEwMDAwMDBaFw0z
'' SIG '' MTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYD
'' SIG '' VQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGln
'' SIG '' aUNlcnQgVGltZXN0YW1wIDIwMjEwggEiMA0GCSqGSIb3
'' SIG '' DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXK
'' SIG '' Y2tR1zoRQr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E
'' SIG '' 5b+bYc0VkWJauP9nC5xj/TZqgfop+N0rcIXeAhjzeG28
'' SIG '' ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj
'' SIG '' 4S8bOrdh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al
'' SIG '' 6GTm3dOPL1e1hyDrDo4s1SPa9E14RuMDgzEpSlwMMYpK
'' SIG '' jIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDCm2mC
'' SIG '' tNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6f
'' SIG '' egFz+BnW/g1JhL0BAgMBAAGjggG4MIIBtDAOBgNVHQ8B
'' SIG '' Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
'' SIG '' DDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG
'' SIG '' /WwHATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRp
'' SIG '' Z2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgwFoAU9LbhIB3+
'' SIG '' Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBm
'' SIG '' vrwoLR1ENt3janq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0
'' SIG '' dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3Vy
'' SIG '' ZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdp
'' SIG '' Y2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYI
'' SIG '' KwYBBQUHAQEEeTB3MCQGCCsGAQUFBzABhhhodHRwOi8v
'' SIG '' b2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0
'' SIG '' dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
'' SIG '' dFNIQTJBc3N1cmVkSURUaW1lc3RhbXBpbmdDQS5jcnQw
'' SIG '' DQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrnIA6O
'' SIG '' Z0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDR
'' SIG '' BMOG2Tu9/kQCZk3taaQP9rhwz2Lo9VFKeHk2eie38+dS
'' SIG '' n5On7UOee+e03UEiifuHokYDTvz0/rdkd2NfI1Jpg4L6
'' SIG '' GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1
'' SIG '' CAB2vIEO+MDhXM/EEXLnG2RJ2CKadRVC9S0yOIHa9GCi
'' SIG '' urRS+1zgYSQlT7LfySmoc0NR2r1j1h9bm/cuG08THfdK
'' SIG '' DXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5
'' SIG '' NpjhyyjaW4emii8wggUlMIIEDaADAgECAhAKbETHsXMS
'' SIG '' RycKM4CrkZjKMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNV
'' SIG '' BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
'' SIG '' BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMT
'' SIG '' KERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNp
'' SIG '' Z25pbmcgQ0EwHhcNMjEwMjE4MDAwMDAwWhcNMjQwMzA2
'' SIG '' MjM1OTU5WjBjMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' Q2FsaWZvcm5pYTETMBEGA1UEBxMKRW1lcnl2aWxsZTEU
'' SIG '' MBIGA1UEChMLVGFuaXVtIEluYy4xFDASBgNVBAMTC1Rh
'' SIG '' bml1bSBJbmMuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
'' SIG '' MIIBCgKCAQEApaKcb1MLTv/cFxPrODtq9zzOlsMLEowb
'' SIG '' jjLPlDUVFIBK0KOtG0R4GU9AwYAFfr6ei94h2EhH+iNb
'' SIG '' Qpkp963VtH0vzR58xTuIIKj7pGHQdQO3UOg0MHTMVcV3
'' SIG '' c1LD5MgESBmC8ew3nEOUxHc25KavYNo4zOQAptHrcxVN
'' SIG '' ilipgpu/1VtwUS9uMmhL11RKjgTpD7oDc0j6FKFZRTT0
'' SIG '' fwKPbBK/PQMMgGdBePDx10xkRUtZcIC/lQtvIhdBC12i
'' SIG '' is/9zjg09ta0u8nYejp+Mnf4QyoZYCouQsv8H1AxZZE5
'' SIG '' ZEAumkOljiIWLyxUGQVV9nOIrk0IlLbnIGXeXFTE1HgL
'' SIG '' rQIDAQABo4IBxDCCAcAwHwYDVR0jBBgwFoAUWsS5eyoK
'' SIG '' o6XqcQPAYPkt9mV1DlgwHQYDVR0OBBYEFF1KubVW84PS
'' SIG '' kAofcQ0qZB/4rijUMA4GA1UdDwEB/wQEAwIHgDATBgNV
'' SIG '' HSUEDDAKBggrBgEFBQcDAzB3BgNVHR8EcDBuMDWgM6Ax
'' SIG '' hi9odHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc2hhMi1h
'' SIG '' c3N1cmVkLWNzLWcxLmNybDA1oDOgMYYvaHR0cDovL2Ny
'' SIG '' bDQuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1n
'' SIG '' MS5jcmwwSwYDVR0gBEQwQjA2BglghkgBhv1sAwEwKTAn
'' SIG '' BggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5j
'' SIG '' b20vQ1BTMAgGBmeBDAEEATCBhAYIKwYBBQUHAQEEeDB2
'' SIG '' MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
'' SIG '' dC5jb20wTgYIKwYBBQUHMAKGQmh0dHA6Ly9jYWNlcnRz
'' SIG '' LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVk
'' SIG '' SURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAA
'' SIG '' MA0GCSqGSIb3DQEBCwUAA4IBAQC94gyrrAUTXXVqmM4I
'' SIG '' uIJXvbhm8NtlUtipcFCkuHXGKXjiLdQayPVg95ejGs2x
'' SIG '' uXTh1kH9YHz0YsyWzpexJQtMVvf6Uj6sEMl6WIhXy7Ed
'' SIG '' vC6awZY5JWDwa3CIrjHgerZ49GrZgrSc9GDc8J/r7pj9
'' SIG '' aBFbXOlpRqnasG0RJvKctJgOAis3aVAXmoFOQou8bWW2
'' SIG '' X4qMsD4kAKAmA3WhOXCg3lr0GyKjdavJBTCjMhT5xgXp
'' SIG '' 8VcZD66LosZ82WhqWfbi/V4tspZC7XeCJF4spwtyA9kE
'' SIG '' VPE91dj+KIeiK/yJBMc9D7jqiutKj3cinyEnhWza06me
'' SIG '' wij+GJw9dDBBShw5MIIFMDCCBBigAwIBAgIQBAkYG1/V
'' SIG '' u2Z1U0O1b5VQCDANBgkqhkiG9w0BAQsFADBlMQswCQYD
'' SIG '' VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
'' SIG '' FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQD
'' SIG '' ExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcN
'' SIG '' MTMxMDIyMTIwMDAwWhcNMjgxMDIyMTIwMDAwWjByMQsw
'' SIG '' CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
'' SIG '' MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYD
'' SIG '' VQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29k
'' SIG '' ZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOC
'' SIG '' AQ8AMIIBCgKCAQEA+NOzHH8OEa9ndwfTCzFJGc/Q+0WZ
'' SIG '' sTrbRPV/5aid2zLXcep2nQUut4/6kkPApfmJ1DcZ17aq
'' SIG '' 8JyGpdglrA55KDp+6dFn08b7KSfH03sjlOSRI5aQd4L5
'' SIG '' oYQjZhJUM1B0sSgmuyRpwsJS8hRniolF1C2ho+mILCCV
'' SIG '' rhxKhwjfDPXiTWAYvqrEsq5wMWYzcT6scKKrzn/pfMuS
'' SIG '' oeU7MRzP6vIK5Fe7SrXpdOYr/mzLfnQ5Ng2Q7+S1TqSp
'' SIG '' 6moKq4TzrGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi
'' SIG '' 6CxR93O8vYWxYoNzQYIH5DiLanMg0A9kczyen6Yzqf0Z
'' SIG '' 3yWT0QIDAQABo4IBzTCCAckwEgYDVR0TAQH/BAgwBgEB
'' SIG '' /wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYI
'' SIG '' KwYBBQUHAwMweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUF
'' SIG '' BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
'' SIG '' KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
'' SIG '' LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQw
'' SIG '' gYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRp
'' SIG '' Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
'' SIG '' QS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
'' SIG '' LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmww
'' SIG '' TwYDVR0gBEgwRjA4BgpghkgBhv1sAAIEMCowKAYIKwYB
'' SIG '' BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9D
'' SIG '' UFMwCgYIYIZIAYb9bAMwHQYDVR0OBBYEFFrEuXsqCqOl
'' SIG '' 6nEDwGD5LfZldQ5YMB8GA1UdIwQYMBaAFEXroq/0ksuC
'' SIG '' MS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+
'' SIG '' 7A1aJLPzItEVyCx8JSl2qB1dHC06GsTvMGHXfgtg/cM9
'' SIG '' D8Svi/3vKt8gVTew4fbRknUPUbRupY5a4l4kgU4QpO4/
'' SIG '' cY5jDhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7uq+1
'' SIG '' UcKNJK4kxscnKqEpKBo6cSgCPC6Ro8AlEeKcFEehemho
'' SIG '' r5unXCBc2XGxDI+7qPjFEmifz0DLQESlE/DmZAwlCEIy
'' SIG '' sjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPas7CM1ekN
'' SIG '' 3fYBIM6ZMWM9CBoYs4GbT8aTEAb8B4H6i9r5gkn3Ym6h
'' SIG '' U/oSlBiFLpKR6mhsRDKyZqHnGKSaZFHvMIIFMTCCBBmg
'' SIG '' AwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0B
'' SIG '' AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
'' SIG '' aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
'' SIG '' Y29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElE
'' SIG '' IFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3
'' SIG '' MTIwMDAwWjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
'' SIG '' RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
'' SIG '' cnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
'' SIG '' c3VyZWQgSUQgVGltZXN0YW1waW5nIENBMIIBIjANBgkq
'' SIG '' hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvdAy7kvNj3/d
'' SIG '' qbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI
'' SIG '' 5Je/YyGQmL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5f
'' SIG '' ZT/gm+vjRkcGGlV+Cyd+wKL1oODeIj8O/36V+/OjuiI+
'' SIG '' GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3Fy
'' SIG '' Tgqt30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZ
'' SIG '' iFBe/WZuVmEnKYmEUeaC50ZQ/ZQqLKfkdT66mA+Ef58x
'' SIG '' FNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4Ud
'' SIG '' xB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYD
'' SIG '' VR0OBBYEFPS24SAd/imu0uRhpbKiJbLIFzVuMB8GA1Ud
'' SIG '' IwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIGA1Ud
'' SIG '' EwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMG
'' SIG '' A1UdJQQMMAoGCCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0w
'' SIG '' azAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
'' SIG '' cnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0
'' SIG '' cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
'' SIG '' b290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRw
'' SIG '' Oi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
'' SIG '' cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3Js
'' SIG '' My5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
'' SIG '' b290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAAC
'' SIG '' BDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdp
'' SIG '' Y2VydC5jb20vQ1BTMAsGCWCGSAGG/WwHATANBgkqhkiG
'' SIG '' 9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3
'' SIG '' QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqu
'' SIG '' mfgnoma/Capg33akOpMP+LLR2HwZYuhegiUexLoceywh
'' SIG '' 4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFNYkYk
'' SIG '' h2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tT
'' SIG '' YYmo9WuWwPRYaQ18yAGxuSh1t5ljhSKMYcp5lH5Z/IwP
'' SIG '' 42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8QlK0cCCHxJ
'' SIG '' rhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY
'' SIG '' 9aaOUjGCBFwwggRYAgEBMIGGMHIxCzAJBgNVBAYTAlVT
'' SIG '' MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
'' SIG '' EHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lD
'' SIG '' ZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcg
'' SIG '' Q0ECEApsRMexcxJHJwozgKuRmMowCQYFKw4DAhoFAKB4
'' SIG '' MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
'' SIG '' hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
'' SIG '' CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
'' SIG '' FNBgPBEyWT6Ynxngrj25CyUrq4QFMA0GCSqGSIb3DQEB
'' SIG '' AQUABIIBADdFrBXaYTzXgL37zAKtBofg43VLh0o5dbt7
'' SIG '' tp7mvgvZzCoEykstiSnqqBbga33GyYC0zUXnR+D9pNAn
'' SIG '' 5K3lvppJXEIhRnPhxevBYLHqZh2LaVkotjop+Gk3vMzm
'' SIG '' kosql4cPsOso+bg2eWAp86KA/+RQbH92NupOUrWJOlC9
'' SIG '' p3I5Fxt6G1EugL3mhvdXO5Y3cvqqf4wfeCkZHDMGSk5F
'' SIG '' F+yNatiI6V7yQCk9Fegr1O5DNGY1s99IrBlnLfS1rIpm
'' SIG '' BDGoZExqqCnG9yRQQZJ/qbWV8bU5dOcpGrWts0wBvtPc
'' SIG '' kLo2F1iYWo8e925I3CnXcY/cmZdZ1TsfthnK2TMNz/Kh
'' SIG '' ggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYw
'' SIG '' cjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
'' SIG '' IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEx
'' SIG '' MC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElE
'' SIG '' IFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw
'' SIG '' 3TANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
'' SIG '' BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMDIw
'' SIG '' NDIxMDMwOVowLwYJKoZIhvcNAQkEMSIEIDJq7Y8EtYvw
'' SIG '' TDn600EZ1eqfigzrdq5uRkTzU1jYSEshMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBACQmkjddt7+jiFtprEvOxETe0dsoHWKI
'' SIG '' agqJVLAyfiudftjmpISyNAGmNSRchKcJj00WgLOEm2Rs
'' SIG '' ljpLxMjJPFwotacl9PMpr5OiPYATuWzJs6vhKAhYGCVk
'' SIG '' wnBrNHOX9DvFqmzVdttATv94b8D5hqZzSoXwTZGOVwSy
'' SIG '' o3Xy+EXxs3WufgNW14fAcCVDMNCRyFE2wLLnvquYApv+
'' SIG '' hPVykeJiGQEOnR+v4z/jD/kVxWsuaZnaANznlRHwGxcK
'' SIG '' 10ydW+CWLR0iaaCQkaCzft9jR3cmMFcIwBxEH8hzmaoS
'' SIG '' +RUoFGGx0wXLpixyBYv8t9eoeNSagUbB73dozcvpyFUGp2g=
'' SIG '' End signature block
