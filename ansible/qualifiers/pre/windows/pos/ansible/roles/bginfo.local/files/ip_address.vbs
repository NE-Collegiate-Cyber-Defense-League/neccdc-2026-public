strMsg = ""
strComputer = "."

Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set IPConfigSet = objWMIService.ExecQuery("Select IPAddress from Win32_NetworkAdapterConfiguration WHERE IPEnabled = 'True'")

For Each IPConfig in IPConfigSet
  If Not IsNull(IPConfig.IPAddress) Then
    For i = LBound(IPConfig.IPAddress) to UBound(IPConfig.IPAddress)
     strMsg = strMsg & IPConfig.IPAddress(i) & vbcrlf & vbtab
    Next
  End If
Next

Echo strMsg