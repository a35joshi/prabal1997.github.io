﻿Type=Service
Version=3.2
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
Dim AStream As AsyncStreams
Dim aSensor As List 
Dim bSensor As List
Dim sendDataTimer As Timer      
Dim tempString As String = ""
End Sub
Sub Service_Create
aSensor.Initialize
bSensor.Initialize

sendDataTimer.Initialize("sendDataTimer",2500)
sendDataTimer.Enabled = True
End Sub

Sub Service_Start (StartingIntent As Intent)
	Try
		If AStream.IsInitialized = False Then
			AStream.Initialize(Main.serial1.InputStream,  Null, "AStream")
		End If
	Catch
	End Try
	
End Sub

Sub Service_Destroy
	AStream.Close
End Sub

Sub AStream_NewData (Buffer() As Byte)
	If Buffer.Length > 0 Then
		Dim data As String= BytesToString(Buffer, 0, Buffer.Length, "US-ASCII")
		If data = "a" OR data = "b" Then
			tempString = data
		Else
			If Not(data.CharAt(0) = "a") AND Not(data.CharAt(0) = "b") Then 
				data = tempString & data
			End If
			
			Dim tempValue As Int
		
			If (data.CharAt(0) = "a") Then 
				data = data.SubString(1)
				Try
					tempValue = data
					If data = "" Then 
						data = "-1"
					End If
					aSensor.Add(data)
				Catch
				End Try
			Else If (data.CharAt(0) = "b") Then
				data = data.SubString(1)
				Try
					tempValue = data
					If data = "" Then 
						data = "-1"
					End If
					bSensor.Add(data)
				Catch
				End Try
			End If 
			
			tempString = ""
		End If
	End If
End Sub

Sub sendDataTimer_tick
	
	Dim aSensorString As String = ""
	Dim bSensorString As String = ""
	
	If aSensor.Size > 0 Then
		For i = 0 To aSensor.Size - 1 
			If Not(i = aSensor.Size - 1) Then
				aSensorString = aSensorString & aSensor.Get(i) & "," 
			Else
				aSensorString = aSensorString & aSensor.Get(i)
			End If
		Next
	End If
	
	If bSensor.Size > 0 Then
		For i = 0 To bSensor.Size - 1 
			If Not(i = bSensor.Size - 1) Then
				bSensorString = bSensorString & bSensor.Get(i) & "," 
			Else
				bSensorString = bSensorString & bSensor.Get(i)
			End If
		Next
	End If
	
	Dim data As String = ""
	data = data
	
	'Dim data As String = ""
	'data = data & "{"
	'data = data &   """startDateTime"": """ & DateTimeValue & ""","
	'data = data &   """data"": ["
	'data = data &    "{""id"": ""a"", ""sensorData"": [" & aSensorString & "],"
	'data = data &    "{""id"": ""b"", ""sensorData"": [" & bSensorString & "]]"
	
	' {
	'	"startDateTime" : 2018-03-03 12:10:44, 
	'	"data" : 
	'		[
	'			{"id" :"a", "sensorData" : [323.22, 232.2, 55.6]}, 
	'			{"id" :"b", "sensorData" : [323.22, 232.2, 55.6]}
	'		]
	'	}
	
	Log(data)
	
	'Dim job As HttpJob
	'job.Initialize("JobName", Me)
	'job.GetRequest.SetContentType("application/json")
	'job.GetRequest.InitializePost2("http://40.113.192.222:5000/RealtimeUpdate/1", (stringData )
	
	  Dim Register As HttpJob
   	  Register.Initialize("rest", Me)
      Register.Download("http://40.113.245.233:5000/RealtimeUpdate/0/" & aSensorString)
	
	  Dim Register2 As HttpJob
   	  Register2.Initialize("rest", Me)
      Register2.Download("http://40.113.245.233:5000/RealtimeUpdate/1/" & bSensorString)
	  
	  
	 ' Dim Register2 As HttpJob
   	 ' Register.Initialize("rest", Me)
     ' Register.Download("http://40.113.192.222:5000/RealtimeUpdate/1/" & stringData)
	
	
	
	
	aSensor.Clear
	bSensor.Clear
End Sub

Sub JobDone(job As HttpJob)
  If job.Success Then
  'ToastMessageShow ("SuccessFully Finish !", True)
  'ShowData
  Log(job.GetString)
  job.Release
  Else
  Log(job.ErrorMessage)
  End If
End Sub

Sub DateTimeValue As String
	Dim now As Long
	Dim dt As String
	DateTime.DateFormat = "dd MMM yyyy" 
	dt = DateTime.Date(DateTime.Now) 
	DateTime.DateFormat = "hh:mm:ss" 
	dt = dt & " " & DateTime.Time(now)
	Return dt
End Sub

Sub AStream_Error
	ToastMessageShow("Connection is broken.", True)
End Sub