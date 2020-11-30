unit PlumSerialPortEnum;

interface
uses
  Classes, Windows, StrUtils, SysUtils, Registry, SetupAPI;

Procedure SetupEnumAvailableComPort(SerialPortList: TStringList; OnlyOpenSucc: Boolean = False);
implementation


Procedure SetupEnumAvailableComPort(SerialPortList: TStringList; OnlyOpenSucc: Boolean);
var
  RequiredSize: Cardinal;
  Guid: TGUID;
  DevInfoHandle: HDEVINFO;
  DeviceInfoData: TSPDevInfoData;
  MemberIndex: Cardinal;
  PropertyRegDataType: DWord;
  RegProperty: Cardinal;
  RegTyp: Cardinal;
  Key: Hkey;
  Info: TRegKeyInfo;
  FriendName: Ansistring;
  stdNameBuf: WideString;
  stdName: String;
  hc: THandle;
begin
  // If we cannot access the setupapi.dll then we return a nil pointer.
  if (SerialPortList = Nil) or (not LoadsetupAPI) then Exit;

  try
    // get 'Ports' class guid from name
    if SetupDiClassGuidsFromName('Ports', @Guid, RequiredSize, RequiredSize)
    then
    begin
      // get object handle of 'Ports' class to interate all devices
      DevInfoHandle := SetupDiGetClassDevs(@Guid, Nil, 0, DIGCF_PRESENT);
      if Cardinal(DevInfoHandle) <> Invalid_Handle_Value then
      begin

        begin
          try
            MemberIndex := 0;
            // iterate device list
            repeat
              FillChar(DeviceInfoData, SizeOf(DeviceInfoData), 0);
              DeviceInfoData.cbSize := SizeOf(DeviceInfoData);
              // get device info that corresponds to the next memberindex
              if Not SetupDiEnumDeviceInfo(DevInfoHandle, MemberIndex,
                DeviceInfoData) then
                break;
              begin
                RegProperty := SPDRP_;
                { SPDRP_Driver, SPDRP_SERVICE, SPDRP_ENUMERATOR_NAME,SPDRP_PHYSICAL_DEVICE_OBJECT_NAME,SPDRP_FRIENDLYNAME, }
                SetupDiGetDeviceRegistryProperty(DevInfoHandle, DeviceInfoData,
                  RegProperty, PropertyRegDataType, NIL, 0, RequiredSize)
              end;
              // query friendly device name LIKE 'BlueTooth Communication Port (COM8)' etc
              RegProperty := SPDRP_FriendlyName;
              { SPDRP_Driver, SPDRP_SERVICE, SPDRP_ENUMERATOR_NAME,SPDRP_PHYSICAL_DEVICE_OBJECT_NAME,SPDRP_FRIENDLYNAME, }
              SetupDiGetDeviceRegistryProperty(DevInfoHandle, DeviceInfoData,
                RegProperty, PropertyRegDataType, NIL, 0, RequiredSize);
              SetLength(FriendName, RequiredSize);
              if SetupDiGetDeviceRegistryProperty(DevInfoHandle, DeviceInfoData,
                RegProperty, PropertyRegDataType, @FriendName[1], RequiredSize,
                RequiredSize) then
              begin
                Key := SetupDiOpenDevRegKey(DevInfoHandle, DeviceInfoData,
                  DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_READ);
                if Key <> Invalid_Handle_Value then
                begin
                  FillChar(Info, SizeOf(Info), 0);
                  // query the real port name from the registry value 'PortName'
                  if RegQueryInfoKey(Key, nil, nil, nil, @Info.NumSubKeys,
                    @Info.MaxSubKeyLen, nil, @Info.NumValues, @Info.MaxValueLen,
                    @Info.MaxDataLen, nil, @Info.FileTime) = ERROR_SUCCESS then
                  begin
                    RequiredSize := Info.MaxValueLen + 1;
                    SetLength(stdNameBuf, RequiredSize);
                    if RegQueryValueEx(Key, 'PortName', Nil, @RegTyp, @stdNameBuf[1],
                      @RequiredSize) = ERROR_SUCCESS then
                    begin
                      stdName:= WideCharToString(PWideChar(stdNameBuf));
                      if Not OnlyOpenSucc then
                      begin
                        SerialPortList.AddPair(stdName, FriendName);
                      end
                      else If (Pos('COM', stdName) = 1) then
                      begin
                        // Test if the device can be used
                        hc := CreateFile(pchar('\\.\' + stdName + #0),
                          GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL, 0);
                        if hc <> Invalid_Handle_Value then
                        begin
                          SerialPortList.AddPair(stdName, FriendName);
                          CloseHandle(hc);
                        end;
                      end;
                    end;
                  end;
                  RegCloseKey(Key);
                end;
              end;
              Inc(MemberIndex);
            until False;
          finally
            SetupDiDestroyDeviceInfoList(DevInfoHandle);
          end;
        end;
      end;
    end;
  finally
    UnloadSetupApi;
  end;
end;

end.
