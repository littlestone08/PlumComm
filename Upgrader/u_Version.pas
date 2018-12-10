unit u_Version;

interface
uses
  Classes, PlumExeinfo, windows, SysUtils, StrUtils;


var
  ExeInfo: TExeInfo2;
  CONST_VERISION: String;
var
  IsDevloper: Boolean;
const
  CONST_LOCAL_DEPLY_INF_FILE = 'C:\Inetpub\wwwroot\update\UtralShortReceiver\PUtralShortReceiver.update.inf';
  CONST_URL_DEPLY_INF_FILE = 'http://192.168.0.81/update/UtralShortReceiver/PUtralShortReceiver.update.inf';



function GetUpdateMsg: String;

implementation


function GetUpdateMsg: String;
var
  StrStm: TStringStream;
  Res: TResourceStream;
  StrList: TStringList;
  i: integer;
  CanDelete: Boolean;
begin

//  Strstm.c
  Res:= TResourceStream.Create(HInstance, 'CHANGEINFO', 'MYFILE');
  StrStm:= TStringStream.Create('');
  StrList:= TStringList.Create;

  try
    StrStm.CopyFrom(Res, 0);
    StrList.Text:= StrStm.DataString;

    i:= 0;
    CanDelete:= False;
    while(i <= StrList.Count - 1) do
    begin
      if Not CanDelete then
      begin
        CanDelete:= StartsText('VER',Trim(StrList[i]));
        if Not CanDelete then
          Inc(i);
      end
      else
      begin
        StrList.Delete(i);
      end
    end;

    Result:= StrList.Text;
  finally
    StrList.Free;
    StrStm.Free;
    Res.Free;
  end;
end;


Initialization
  ExeInfo:= TExeInfo2.Create(Nil);
  CONST_VERISION:= Exeinfo.FileVersion;
  IsDevloper:= FileExists(CONST_LOCAL_DEPLY_INF_FILE);
Finalization
  ExeInfo.Free;

end.
