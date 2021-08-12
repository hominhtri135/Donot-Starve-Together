Option Explicit
Dim objFSO                  : Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim objWS                   : Set objWS = CreateObject("wscript.shell")
Dim objApp 					: Set objApp = CreateObject("Shell.Application")
Dim objWMIService 			: Set objWMIService = GetObject("winmgmts:")
Dim stream					: Set stream = CreateObject("ADODB.Stream")
Dim ProcessList, process, prorun
Dim objFolder, colSubfolders, objSubfolder 
Dim oFile, File, folderTemp
Dim a(8), i, x, f, title, temp, name_mod, chars, adminlist, modoverrides, modlist, modserver, cluster, cluster_read, modeMod
Dim str, str_temp_1, str_temp_2, strLeft, strRight, strNameOfFolder, strNameOfMod
Dim cluster_token, cluster_path, TargetPath, tempPath
Dim PATH_DOCUMENTS, PATH_STEAM_APP, PATH_DATA_DST, PATH_DATA_CLUSTER
title = "DST DEDICATED SERVER x64"
PATH_DOCUMENTS = objWS.SpecialFolders("MyDocuments")
PATH_DATA_DST = PATH_DOCUMENTS & "\Klei\DoNotStarveTogether"
TargetPath = PATH_DATA_DST & "\token.data"
chars = chr(75)+chr(85)+chr(95)+chr(116)+chr(68)+chr(54)+chr(89)+chr(103)+chr(109)+chr(82)+chr(68)
Do
	if not objFSO.FileExists(TargetPath) then
		createData()
	elseif checkRunServer() <> 0 then
		ServerRunning()
	else
		chooseFunction()
	end if
Loop
Sub chooseFunction()
	readData()
	writeMod()
	createFileBAT()
	createFileToken()
	x = InputBox("==========     Thông Tin Server     =========="_
		&vbLf&vbLf&_
		"=> Name: " &readInfo(1)_
		&vbLf&_
		"=> Players: " &readInfo(2)& "    |    " &"Mods: "&readInfo(3)& "    |    " &"PvP: "&readInfo(4)_
		&vbLf&_
		"=> Pass: " &readInfo(7)_
		&vbLf&_
		"=> Description: " &readInfo(8)_
		&vbLf&vbLf&_
		"=> Cluster Folder: /" &readInfo(5)_
		&vbLf&_
		"=> Token: " &readInfo(6)_
		&vbLf&_
		"=> Chế độ cài Mod: " &a(8)_
		&vbLf&vbLf&_
		"==========    Chọn Chức Năng    ==========="_
		&vbLf&vbLf&_
		"1. Chạy Server"_
		&vbLf&_
		"2. Thay Đổi Mật Khẩu"_
		&vbLf&_
		"3. Thay Đổi Số Người Chơi "_
		&vbLf&_
		"4. Bật/Tắt Chế Độ PvP"_
		&vbLf&_
		"5. Thêm/Xoá Admin"_
		&vbLf&vbLf&_
		"6. Đổi World (Cluster_*)"_
		&vbLf&_
		"7. Đổi Token Server"_
		&vbLf&_
		"8. Chuyển đổi chế độ cài đặt Mod"_
		&vbLf&vbLf&_
		"9. Reset"_
		&vbLf&vbLf&_
		"Nhập Số:"_
		, title, 1)
	if IsNumeric(x) then
		Select Case x
			case 0
				wscript.quit
			case 1
				runServer()
			case 2
				Update "Password: ", "cluster_password = "
			case 3
				Update "Players: ", "max_players = "
			case 4
				Update "PvP: ", "pvp = "
			case 5
				Admin()
			case 6
				updateClusterPath()
			case 7
				updateToken()
			case 8
				mode_Mod()
			case 9
				resetScript()
			Case Else
				MsgBox "Hãy điền đúng định dạng!", vbCritical + vbSystemModal, title
		End Select
	else 
		MsgBox "Hãy điền đúng định dạng!", vbCritical + vbSystemModal, title
	end if
End Sub
Sub runServer()
	readAdmin()
	If a(8) = "copy" Then
		CopyMod()
	End If
	objWS.run """"&a(0)&""""
	wscript.quit
End Sub
Sub ServerRunning()
	readData()
	objWS.AppActivate(title)
	x = InputBox("==========     Server Is Running     =========="_
		&vbLf&vbLf&_
		"=> Name: " &readInfo(1)_
		&vbLf&_
		"=> Players: " &readInfo(2)& "    |    " &"Mods: "&readInfo(3)& "    |    " &"PvP: "&readInfo(4)_
		&vbLf&_
		"=> Pass: " &readInfo(7)_
		&vbLf&_
		"=> Description: " &readInfo(8)_
		&vbLf&vbLf&_
		"Nhập ""stop"" để dừng Server: "_
		, title)
	if x = "stop" then
		objWS.Run "taskkill /F /IM dontstarve_dedicated_server_nullrenderer_x64.exe"
		WScript.Sleep 1000
	else
		wscript.quit
	end if
End Sub
Function checkRunServer()
	Set ProcessList= objWMIService.ExecQuery _
	("Select * from Win32_Process Where Name ='dontstarve_dedicated_server_nullrenderer_x64.exe'")
	i = 0
	For Each process In ProcessList
		i = i + 1
	Next
	checkRunServer = i
End Function
Sub Admin()
	x = InputBox("==========    ADMIN    ==========="_
		&vbLf&vbLf&_
		"1. Xem danh sách Admin"_
		&vbLf&_
		"2. Thêm Admin"_
		&vbLf&_
		"3. Xoá Admin"_
		&vbLf&vbLf&_
		"Nhập Số:"_
		, title, 1)
	if IsNumeric(x) then
		Select Case x
			case 0
				wscript.quit
			case 1
				infoAdmin()
			case 2
				addAdmin()
			case 3
				removeAdmin()
			Case Else
				MsgBox "Hãy điền đúng định dạng!", vbCritical + vbSystemModal, title
		End Select
	else 
		MsgBox "Hãy điền đúng định dạng!", vbCritical + vbSystemModal, title
	end if
End Sub
Sub infoAdmin()
	str = Null
	Set oFile = objFSO.OpenTextFile(adminlist,1)
	str = oFile.ReadAll
	oFile.Close
	str = Replace(str,chars&vbLf,Empty)
	str = Replace(str,chars,Empty)
	If str = "" Then
		MsgBox "Danh sách rỗng!", vbInformation + vbSystemModal, title
	Else
		MsgBox "Danh sách Admin: " &vbLf &str, vbInformation + vbSystemModal, title
	End If
End Sub
Sub addAdmin()
	readAdmin()
	str = Null
	Set oFile = objFSO.OpenTextFile(adminlist,1)
	str = oFile.ReadAll
	oFile.Close
	temp = InputBox("Nhập ID: KU_********", title)
	If temp <> "" AND Left(temp,3)="KU_" AND Len(temp)=11 Then 
		If (InStr(1,str,temp) = 0) Then
			If objFSO.FileExists(adminlist) Then
				objFSO.DeleteFile (adminlist)
			End If
			str = temp & vbLf & str
			Set File = objFSO.CreateTextFile(adminlist,True)
			File.Write str
			File.Close
			MsgBox "Đã thêm " &temp& " làm ADMIN!", vbInformation + vbSystemModal, title
		Else 
			MsgBox temp& " đang là ADMIN", vbInformation + vbSystemModal, title
		End If
	Else
		MsgBox "Hãy điền đúng định dạng!", vbCritical + vbSystemModal, title
	End If
	Set File = objFSO.GetFile(adminlist)
	If File.Attributes <> 38 Then 
		File.Attributes = 38
	End If
End Sub
Sub removeAdmin()
	readAdmin()
	str = Null
	Set oFile = objFSO.OpenTextFile(adminlist,1)
	str = oFile.ReadAll
	oFile.Close
	temp = InputBox("Nhập ID: KU_********", title)
	If temp <> "" AND Left(temp,3)="KU_" AND Len(temp)=11 Then 
		If (InStr(1,str,temp) <> 0) Then
			If objFSO.FileExists(adminlist) Then
				objFSO.DeleteFile (adminlist)
			End If
			str = Replace(str,temp & vbLf, Empty)
			Set File = objFSO.CreateTextFile(adminlist,True)
			File.Write str
			File.Close
			MsgBox "Đã xoá " &temp, vbInformation + vbSystemModal, title
		Else 
			MsgBox temp& " không tồn tại", vbInformation + vbSystemModal, title
		End If
	Else
		MsgBox "Hãy điền đúng định dạng!", vbCritical + vbSystemModal, title
	End If
	Set File = objFSO.GetFile(adminlist)
	If File.Attributes <> 38 Then 
		File.Attributes = 38
	End If
End Sub
Sub createData()
	Do
		Set objFolder = objApp.BrowseForFolder(0,"Chọn thư mục ""steamapps"" " &vbLf &"(Default: C:\Program Files (x86)\Steam\steamapps)",0,17)
		if objFolder is nothing then
			WScript.Quit
		end if
		If objFolder.Title = "steamapps" Then
			PATH_STEAM_APP = objFolder.Self.Path 
			If Not objFSO.FolderExists(PATH_STEAM_APP & "\common\Don't Starve Together Dedicated Server\mods") Then
				MsgBox "Không tìm thấy ứng dụng Don't Starve Together Dedicated Server!", vbCritical + vbSystemModal, title
			Else
				Exit Do
			End If
		Else
			MsgBox "Vui lòng chọn thư mục ""steamapps"" ", vbCritical + vbSystemModal, title
		End If
	Loop
	Do
		Set objFolder = objApp.BrowseForFolder(0,"Chọn thư mục chứa World (Thư mục ""Cluster_*"") " ,0,PATH_DATA_DST)
		if objFolder is nothing then
			WScript.Quit
		end if
		If left(objFolder.Title,7) = "Cluster" Then
			PATH_DATA_CLUSTER = objFolder.Self.Path
			If Not objFSO.FileExists(PATH_DATA_CLUSTER & "\cluster.ini") Then
				MsgBox "World chưa được tạo, vui lòng chọn lại!", vbCritical + vbSystemModal, title
			Else
				Exit Do
			End If 
		Else
			MsgBox "Vui lòng chọn thư mục ""Cluster_*"" ", vbCritical + vbSystemModal, title
		End If
	Loop
	cluster_path = right (PATH_DATA_CLUSTER, Len(PATH_DATA_CLUSTER)-Len(PATH_DATA_DST)-1)
	cluster_path = Replace(cluster_path, "\", "/")
	cluster_token = InputBox("Nhập Token Server: ", title)
	if not cluster_token <> "" then 
		WScript.Quit
	end if
	Set File = objFSO.CreateTextFile(TargetPath,True)
	File.WriteLine PATH_STEAM_APP & "\common\Don't Starve Together Dedicated Server\bin64"
	File.WriteLine PATH_STEAM_APP & "\common\Don't Starve Together Dedicated Server\mods"
	File.WriteLine PATH_STEAM_APP & "\common\Don't Starve Together\mods"
	File.WriteLine PATH_STEAM_APP & "\workshop\content\322330"
	File.WriteLine cluster_path
	File.WriteLine PATH_DATA_CLUSTER & "\cluster_token.txt"
	File.WriteLine PATH_DATA_CLUSTER
	File.WriteLine cluster_token
	File.Write "write"
	File.Close
	Set File = objFSO.GetFile(TargetPath)
	File.Attributes = 38
End Sub
Sub createFileBAT()
	tempPath = a(0)
	if not objFSO.FileExists(tempPath) then
		cluster_path = a(4)
		Set File = objFSO.CreateTextFile(tempPath,True)
		'c:\steamcmd\steamcmd.exe +login anonymous +app_update 343050 validate +quit
		File.WriteLine "c:\steamcmd\steamcmd.exe +login anonymous +app_update 343050 +quit"
		File.WriteLine "cd /D ""%~dp0"""
		File.WriteLine "start ""DST Server Master"" dontstarve_dedicated_server_nullrenderer_x64.exe -cluster "&cluster_path&" -shard Master"
		If objFSO.FolderExists(a(6)&"\Caves") Then 
			File.WriteLine "start ""DST Server Caves"" dontstarve_dedicated_server_nullrenderer_x64.exe -cluster "&cluster_path&" -shard Caves"
		End If
		File.Close
	else
		objFSO.DeleteFile (tempPath)
		createFileBAT()
	end if
End Sub
Sub createFileToken()
	tempPath = a(5)
	Set File = objFSO.CreateTextFile(tempPath,True)
	File.Write a(7)
	File.Close
End Sub
Sub readData()
	Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",1)
	temp = 0
	Do Until oFile.AtEndOfStream
		a(temp) = oFile.ReadLine
		temp = temp + 1
	Loop
	oFile.Close
	If temp <> 9 Then 
		objFSO.DeleteFile TargetPath
		wscript.quit
	End If
	a(0) = a(0) & "\SteamCMD_Dedicated Server DST_x64.bat"
	adminlist = a(6)&"\adminlist.txt"
	modoverrides = a(6)&"\Master\modoverrides.lua"
	modlist = a(6)&"\Master\modlist.data"
	modserver = a(1)&"\dedicated_server_mods_setup.lua"
	cluster = a(6)&"\cluster.ini"
	cluster_read = a(6)&"\cluster_read.ini"
	modeMod = a(8)
	If Not objFSO.FileExists(cluster) Then
		MsgBox "World Đã Bị Xoá!", vbCritical + vbSystemModal, title
		updateClusterPath()
	End If
	readAdmin()
End Sub
Sub writeMod()
	str = Null
	temp = Null
	If objFSO.FileExists(modoverrides) Then 
		Set oFile = objFSO.OpenTextFile(modoverrides,1)
		str = oFile.ReadAll
		oFile.Close
		If objFSO.FileExists(modserver) Then
			objFSO.DeleteFile modserver
		End If
		Set File = objFSO.CreateTextFile(modserver,True)
		temp = 1
		strLeft = 1
		Do Until strLeft = 0
			strLeft = InStr(temp,str,"[""workshop-")
			strRight = InStr(temp,str,"""]={")
			If strLeft=0 Then Exit Do
			temp = strRight + 4
			str_temp_1 = strLeft + 11
			str_temp_2 = strRight - str_temp_1
			File.Writeline "ServerModSetup(""" & Mid(str,str_temp_1,str_temp_2) & """)" 
		Loop 
		File.Close
	End If
End Sub
Sub readListMod()
	str = Null
	temp = Null
	If objFSO.FileExists(modoverrides) Then 
		Set oFile = objFSO.OpenTextFile(modoverrides,1)
		str = oFile.ReadAll
		oFile.Close
		
		If objFSO.FileExists(modlist) Then
			objFSO.DeleteFile modlist
		End If
		Set File = objFSO.CreateTextFile(modlist,True)
		temp = 1
		strLeft = 1
		Do Until strLeft = 0
			strLeft = InStr(temp,str,"workshop-")
			strRight = InStr(temp,str,"""]={")
			If strLeft=0 Then Exit Do
			temp = strRight + 4
			
			str_temp_1 = strLeft
			str_temp_2 = strRight - strLeft
			File.Writeline Mid(str,str_temp_1,str_temp_2)
		Loop 
		File.Close
		
		Set File = objFSO.GetFile(modlist)
		File.Attributes = 38
	End If
End Sub
Function readNumMod()
	temp = Null
	If objFSO.FileExists(modserver) Then 
		Set oFile = objFSO.OpenTextFile(modserver,1)
		temp = 0
		Do Until oFile.AtEndOfStream
			temp = temp + 1
			oFile.SkipLine
		Loop 
		oFile.Close
		readNumMod = temp
	End If
End Function
Sub readAdmin()
	str = Null
	If Not objFSO.FileExists(adminlist) Then 
		Set File = objFSO.CreateTextFile(adminlist,True)
		File.Write chars
		File.Close
	Else
		Set File = objFSO.GetFile(adminlist)
		If File.Attributes <> 32 Then 
			File.Attributes = 32
		End If
		
		Set oFile = objFSO.OpenTextFile(adminlist,1)
		If Not oFile.AtEndOfStream Then 
			str = oFile.ReadAll
			oFile.Close
			
			If (InStr(1,str,chars) = 0) Then
				str = chars & vbLf & str
				Set File = objFSO.CreateTextFile(adminlist,True)
				File.Write str
				File.Close
			End If
		Else
			Set File = objFSO.CreateTextFile(adminlist,True)
			File.Write chars
			File.Close
		End If
		
	End If
	Set File = objFSO.GetFile(adminlist)
	If File.Attributes <> 38 Then 
		File.Attributes = 38
	End If
End Sub
Function Read(temp)
	str = Null
	Set oFile = objFSO.OpenTextFile(cluster,1)
	If Not oFile.AtEndOfStream Then 
		str = oFile.ReadAll
		strLeft = InStr(1,str,temp)
		strRight = InStr(strLeft+Len(temp),str, vbLf)
		str_temp_1 = strLeft + Len(temp)
		str_temp_2 = strRight - str_temp_1 - 1
		Read = Mid(str,str_temp_1,str_temp_2)
	End If
	oFile.Close
End Function
Function Read_Vi(temp)
	If objFSO.FileExists(cluster_read) Then
		objFSO.DeleteFile (cluster_read)
	End If
	stream.Open
	stream.Type = 2 'text
	stream.Charset = "utf-8"
	stream.LoadFromFile cluster
	objFSO.OpenTextFile(cluster_read, 2, True, True).Write stream.ReadText
	stream.Close
	Set File = objFSO.GetFile(cluster_read)
	File.Attributes = 38
	str = Null
	Set oFile = objFSO.OpenTextFile(cluster_read,1,False,True)
	If Not oFile.AtEndOfStream Then 
		str = oFile.ReadAll
		strLeft = InStr(1,str,temp)
		strRight = InStr(strLeft+Len(temp),str, vbLf)
		str_temp_1 = strLeft + Len(temp)
		str_temp_2 = strRight - str_temp_1 - 1
		Read_Vi = Mid(str,str_temp_1,str_temp_2)
	End If
	oFile.Close
End Function
Function readInfo(num)
	if IsNumeric(num) then
		Select Case num
			case 1
				readInfo = Read_Vi("cluster_name = ")
			case 2
				readInfo = Read_Vi("max_players = ")
			case 3
				readInfo = readNumMod()
			case 4
				readInfo = Read_Vi("pvp = ")
			case 5
				readInfo = a(4)
			case 6
				readInfo = a(7)
			case 7
				readInfo = Read_Vi("cluster_password = ")
			case 8
				readInfo = Read_Vi("cluster_description = ")
			Case Else
				readInfo = 0
		End Select
	else 
		readInfo = 0
	end if
End Function
Sub updateClusterPath()
	temp = Null
	Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",1)
	temp = OFile.ReadAll
	oFile.Close
	Do
		Set objFolder = objApp.BrowseForFolder(0,"Chọn thư mục ""Cluster_*"" ",0,PATH_DATA_DST)
		if objFolder is nothing then
			WScript.Quit
		end if
		If left(objFolder.Title,7) = "Cluster" Then
			PATH_DATA_CLUSTER = objFolder.Self.Path
			If Not objFSO.FileExists(PATH_DATA_CLUSTER & "\cluster.ini") Then
				MsgBox "World chưa được tạo, vui lòng chọn lại!", vbCritical + vbSystemModal, title
			Else
				Exit Do
			End If 
		Else
			MsgBox "Vui lòng chọn thư mục ""Cluster_*"" ", vbCritical + vbSystemModal, title
		End If
	Loop
	PATH_DATA_CLUSTER = objFolder.Self.Path
	cluster_path = right (PATH_DATA_CLUSTER, Len(PATH_DATA_CLUSTER)-Len(PATH_DATA_DST)-1)
	cluster_path = Replace(cluster_path, "\", "/")
	temp = Replace(temp, a(4), cluster_path)
	temp = Replace(temp, a(5), PATH_DATA_CLUSTER & "\cluster_token.txt")
	temp = Replace(temp, a(6), PATH_DATA_CLUSTER)
	Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",2)
	oFile.Write temp
	oFile.Close
	If Not objFSO.FileExists(a(5)) Then
		objFSO.DeleteFile a(5)
	End If
	MsgBox "Cluster Path Updated!", vbInformation + vbSystemModal, title
End Sub
Sub updateToken()
	temp = Null
	Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",1)
	temp = OFile.ReadAll
	oFile.Close
	cluster_token = InputBox("Token Server: ", title)
	If cluster_token <> "" Then 
		temp = Replace(temp, a(7), cluster_token)
		Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",2)
		oFile.Write temp
		oFile.Close
		MsgBox "Server Token Updated!", vbInformation + vbSystemModal, title
	End If
End Sub
Sub Update(str_temp_1 ,str_temp_2)
	temp = Null
	Set oFile = objFSO.OpenTextFile(cluster,1)
	temp = oFile.ReadAll
	oFile.Close
	If str_temp_2 = "pvp = " Then
		If (InStr(1,temp,"pvp = false") <> 0) Then
			temp = Replace(temp,"pvp = false", "pvp = true")
			Set oFile = objFSO.OpenTextFile(cluster,2)
			oFile.Write temp
			oFile.Close
			MsgBox "PvP: On", vbInformation + vbSystemModal, title
		ElseIf (InStr(1,temp,"pvp = true") <> 0) Then
			temp = Replace(temp,"pvp = true", "pvp = false")
			Set oFile = objFSO.OpenTextFile(cluster,2)
			oFile.Write temp
			oFile.Close
			MsgBox "PvP: Off", vbInformation + vbSystemModal, title
		End If
	Else
		i = InputBox(str_temp_1, title, Read(str_temp_2))
		If i <> "" Then 
			If str_temp_2 = "max_players = " Then
				If IsNumeric(i) AND i<=64 Then
					temp = Replace(temp,str_temp_2 & Read(str_temp_2), str_temp_2 & i)
					Set oFile = objFSO.OpenTextFile(cluster,2)
					oFile.Write temp
					oFile.Close
					MsgBox "Updated!", vbInformation + vbSystemModal, title
				Else 
					MsgBox "Nhiều nhất là 64 người!", vbCritical + vbSystemModal, title
				End If
			Else
				temp = Replace(temp,str_temp_2 & Read(str_temp_2), str_temp_2 & i)
				Set oFile = objFSO.OpenTextFile(cluster,2)
				oFile.Write temp
				oFile.Close
				MsgBox "Updated!", vbInformation + vbSystemModal, title
			End If
		End If
	End If
End Sub

Sub copyFolderDST()
	If objFSO.FileExists(modoverrides) Then 
		Set oFile = objFSO.OpenTextFile(modlist,1)
		
		set objFolder = objFSO.GetFolder(a(2))
		set colSubfolders = objFolder.Subfolders
		
		Do Until oFile.AtEndOfStream
			strNameOfMod = oFile.ReadLine
			
			for each objSubfolder in colSubfolders
				strNameOfFolder = objSubfolder.Name
				
				if strNameOfFolder = strNameOfMod then
					objFSO.CopyFolder objFolder & "\" & strNameOfFolder, a(1) & "\" 
					Exit For
				end if
			next
		Loop
		
		oFile.Close
	End If
End Sub


Sub copyFolderWorkshop()
	If objFSO.FileExists(modoverrides) Then 
		Set oFile = objFSO.OpenTextFile(modlist,1)
		
		folderTemp = a(1) & "\temp"
		if objFSO.FolderExists(folderTemp) then
			objFSO.DeleteFolder (folderTemp)
			objFSO.CreateFolder (folderTemp)
		else 
			objFSO.CreateFolder (folderTemp)
		end if
		
		set objFolder = objFSO.GetFolder(a(3))
		set colSubfolders = objFolder.Subfolders
		
		Do Until oFile.AtEndOfStream
			strNameOfMod = oFile.ReadLine
			strNameOfMod = Replace(strNameOfMod,"workshop-","") 
			
			for each objSubfolder in colSubfolders
				strNameOfFolder = objSubfolder.Name
				
				if strNameOfFolder = strNameOfMod then
					objFSO.CopyFolder objFolder & "\" & strNameOfFolder, folderTemp & "\" 
					Exit For
				end if
			next
		Loop
		
		set objFolder = objFSO.GetFolder(folderTemp)
		set colSubfolders = objFolder.Subfolders
		for each objSubfolder in colSubfolders
			strNameOfFolder = objSubfolder.Name
			str = "workshop-"
			strLeft = left (strNameOfFolder, 9)
			strRight = right (strNameOfFolder, 9)
			if strLeft <> str AND IsNumeric(strRight) then
				objFSO.MoveFolder objFolder & "\" & strNameOfFolder, objFolder & "\" & str+strNameOfFolder
			end if
		next
		
		if objFolder.Size > 0 then
			objFSO.CopyFolder folderTemp &"\*", a(1)
		end if 
		objFSO.DeleteFolder (folderTemp)
	End If
End Sub

Sub CopyMod()
	readListMod()
	MsgBox "Bạn đang bật chế độ Copy MOD" &vbLf& "Sẽ mất ít phút vui lòng chờ thông báo hiện lên", vbCritical + vbSystemModal, title
	objFSO.DeleteFolder a(1)&"\*"
	copyFolderDST()
	copyFolderWorkshop()
	MsgBox "Đã Copy MOD xong", vbCritical + vbSystemModal, title
End Sub

Sub mode_Mod()
	temp = Null
	Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",1)
	temp = OFile.ReadAll
	oFile.Close
	
	If a(8) = "write" Then
		temp = Replace(temp,"write", "copy")
		Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",2)
		oFile.Write temp
		oFile.Close
		MsgBox "Chế độ cài mod hiện tại là: Copy folder MOD", vbInformation + vbSystemModal, title
	ElseIf a(8) = "copy" Then
		temp = Replace(temp,"copy", "write")
		Set oFile = objFSO.OpenTextFile(PATH_DATA_DST & "\token.data",2)
		oFile.Write temp
		oFile.Close
		MsgBox "Chế độ cài mod hiện tại là: Download MOD", vbInformation + vbSystemModal, title
	End If
	
End Sub

Sub resetScript()
	temp = MsgBox ("Bạn có muốn khôi phục lại Script?", vbYesNo + vbQuestion + vbSystemModal, title)
	if temp = vbYes then
		objFSO.DeleteFile a(0)
		objFSO.DeleteFile a(5)
		objFSO.DeleteFolder a(1)&"\*"
		objFSO.DeleteFile TargetPath
	else
	end if
End Sub