unit u_Log;

interface
uses
  Classes, SysUtils, IniFiles, PlumLogFile;

type
  TStringEvent = Procedure (const Str: String) of Object;

  IMultiLineLog = interface
    Procedure AddLine(const Info: String);
    Procedure Flush;
  end;

Procedure Log(Info: String; DateTime: Boolean = True; Space: byte = 0);
function  Log_Dir: String;
function MultiLineLog: IMultilineLog;

var
  g_dele_Log_Proc: TStringEvent;

var
  DefaultIniFileName: String;

implementation
//uses
//  CnCommon;
var
  _Log_: ILogFile;
  _MultiLineLog: IMultiLineLog;

type
  TMultilineLog = Class(TInterfacedObject, IMultiLineLog)
  var
    FInfo: String;
  Protected
    Procedure AddLine(const Info: String);
    Procedure Flush;
  Public
    Destructor Destroy; Override;
  End;




function  Log_Dir: String;
begin
  //Result:= _CnExtractFilePath(ParamStr(0)) + 'Log\'+ FormatDateTime('YYYYMMDD', Now) + '\';
  Result:= ChangeFileExt(GetModuleName(HInstance), '') + '_Log\'+ FormatDateTime('YYYYMMDD', Now) + '\';
end;


const
  CONST_SPACE: Array[0..10] of String = (
  '',
  ' ',
  '  ',
  '   ',
  '    ',
  '     ',
  '      ',
  '       ',
  '        ',
  '         ',
  '          '
  );
Procedure Log(Info: String; DateTime: Boolean; Space: byte);
var
  APath: String;
  AFullFileName: String;
begin
  if DateTime then
  begin
    Info:= FormatDateTime('HH:NN:SS.ZZZ: ', Now) + Info;
  end;
  if Space > 0 then
  begin
    if Space > 10 then
      Space:= 0;
    Info:= CONST_SPACE[Space] + CONST_SPACE[Space] + CONST_SPACE[Space] + Info;
  end;

  APath:= Log_Dir;
  ForceDirectories(APath);

  AFullFileName:= APath  + FormatDateTime('HH', Now) + '.Log';

  if (_Log_ = Nil)  or (_Log_.FileName <> AFullFileName) then
  begin
    _Log_:= IntfCreateLogFile(AFullFileName, 4096);
  end;

  _Log_.Log(Info);

    if Assigned(g_dele_Log_Proc) then
    begin
      g_dele_Log_Proc(Info);
    end;
end;

function MultiLineLog: IMultilineLog;
begin
  if _MultiLineLog = Nil then
    _MultiLineLog:= TMultilineLog.Create;
  Result:= _MultiLineLog;
end;


{ TMultilineLog }

procedure TMultilineLog.AddLine(const Info: String);
begin
  FInfo:= FInfo + #$D#$A + Info;
end;

destructor TMultilineLog.Destroy;
begin
  Flush();
  inherited;
end;

procedure TMultilineLog.Flush;
begin
  if FInfo <> '' then
    Log(FInfo);
  FInfo:= '';
end;

Initialization


  DefaultIniFileName:= ChangeFileExt(GetModuleName(HInstance), '.ini');



finalization

end.
