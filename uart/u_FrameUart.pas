unit u_FrameUart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, CnClasses, CnRS232, ExtCtrls,
  Buttons, ToolWin, ImgList, ActnList, CnRS232Dialog;

type

  TframeUart = class(TFrame)
    ToolBar: TToolBar;
    cbbComPort: TComboBox;
    tbUartRefresh: TToolButton;
    ActionList: TActionList;
    tblUartParam: TToolButton;
    actSetupUart: TAction;
    StatusBar: TStatusBar;
    actPortOpenClose: TAction;
    ToolButton1: TToolButton;
    procedure HandleReceiveDataProc(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure FormCreate(Sender: TObject);
    procedure actRefreshPort1Execute(Sender: TObject);
    procedure actSetupUartUpdate(Sender: TObject);
    procedure actSetupUartExecute(Sender: TObject);
    procedure actPortOpenCloseUpdate(Sender: TObject);
    procedure actPortOpenCloseExecute(Sender: TObject);
  Private
    FRS232: TCnRS232;
    FRS232Dialog: TCnRS232Dialog;
    FBuff: AnsiString;
    Procedure UpdateStatusText;
  private
    { Private declarations }

  public
    { Public declarations }
    Constructor Create(AOwner: TComponent);Override;
    Procedure ProcessBuffer(var Buf: AnsiString); Virtual; Abstract;
    Property RS232: TCnRS232 Read FRS232;
  end;

implementation
uses
  StrUtils, Registry, TypInfo;

{$R *.dfm}
const
  SERIAL_PORT_SECT = 'SerialPort';

procedure TframeUart.actPortOpenCloseExecute(Sender: TObject);
begin
  if self.FRS232.Connected then
  begin
    FRS232.StopComm
  end
  else
  begin
    FRS232.CommName:= self.cbbComPort.Text;

    FRS232.WriteToIni(ChangeFileExt(ParamStr(0), '.ini'), SERIAL_PORT_SECT);
    try
      FRS232.StartComm;

    except
      on E: Exception do
        ShowMessage(Format('串口%s无法打开:'#10#13#10#13 +
          '%s: %s', [FRS232.CommName, E.ClassName, E.Message]));
    end;
  end;
  UpdateStatusText;
end;


procedure TframeUart.actPortOpenCloseUpdate(Sender: TObject);
begin
  actPortOpenClose.Enabled:= (FRS232 <> Nil) and (self.cbbComPort.Items.Count > 0);
  if (FRS232 <> Nil) then
  begin
    if FRS232.Connected then
      actPortOpenClose.Caption:= '关闭'
    else
      actPortOpenClose.Caption:= '打开';
  end
  else
  begin
    actPortOpenClose.Caption:= '无串口'
  end;
end;

procedure TframeUart.actRefreshPort1Execute(Sender: TObject);
var
  Names, Values: TStrings;
  i: Integer;
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  Names:= TStringList.Create;
  Values:= TStringList.Create;
  try
    Reg.RootKey:= HKEY_LOCAL_MACHINE;
    Reg.OpenKey('HARDWARE\DEVICEMAP\SERIALCOMM',  False);
    Reg.GetValueNames(Names);
    for i := 0 to Names.Count - 1 do
      Values.Add(Reg.ReadString(Names[i]));
    cbbComPort.Items.Assign(values);

    cbbComPort.Enabled:= cbbComPort.Items.Count > 0;

    if cbbComPort.Items.Count > 0 then
      cbbComPort.ItemIndex:= 0
    else
      cbbComPort.Text:= '无串口';

  finally
    Values.Free;
    Names.Free;
    Reg.Free;
  end;
end;



procedure TframeUart.actSetupUartExecute(Sender: TObject);
begin
  FRS232Dialog.CommName:= FRS232.CommName;
  FRS232Dialog.CommConfig:= self.FRS232.CommConfig;
  if FRS232Dialog.Execute then
  begin
    FRS232.CommConfig:= FRS232Dialog.CommConfig;
  end;
end;

procedure TframeUart.actSetupUartUpdate(Sender: TObject);
begin
  actSetupUart.Enabled:= Not self.FRS232.Connected
    and (FRS232 <> Nil)
    and (self.cbbComPort.Items.Count > 0);
end;



constructor TframeUart.Create(AOwner: TComponent);
begin
  inherited;
  FRS232:= TCnRS232.Create(Self);
  if FileExists(ChangeFileExt(ParamStr(0), '.ini')) then
    FRS232.ReadFromIni(ChangeFileExt(ParamStr(0), '.ini'), SERIAL_PORT_SECT);
  FRS232Dialog:= TCnRS232Dialog.Create(Self);
  FRS232.OnReceiveData:= HandleReceiveDataProc;
  self.actRefreshPort1Execute(Nil);
end;



procedure TframeUart.FormCreate(Sender: TObject);
begin
  actRefreshPort1Execute(nil);
end;



procedure TframeUart.HandleReceiveDataProc(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var
  tmp: AnsiString;
begin
  SetLength(tmp, BufferLength);
  Move(Buffer^, PAnsiChar(tmp)^, BufferLength);
  FBuff:= FBuff + tmp;
  ProcessBuffer(FBuff);
end;


procedure TframeUart.UpdateStatusText;
var
  LStatusStr: String;
begin
  if self.FRS232.Connected then
  begin
    LStatusStr:= self.FRS232.CommName +'打开, ' +
      IntToStr(self.FRS232.CommConfig.BaudRate)+', ';

    if Not FRS232.CommConfig.ParityCheck then
      LStatusStr:= LStatusStr + 'N, '
    else
      LStatusStr:= LStatusStr + GetEnumName(TypeInfo(TParity), Ord(self.FRS232.CommConfig.Parity)) + ',';

    LStatusStr:= LStatusStr + GetEnumName(TypeInfo(TByteSize), Ord(self.FRS232.CommConfig.ByteSize)) + ',';
    LStatusStr:= LStatusStr + GetEnumName(TypeInfo(TStopBits), Ord(self.FRS232.CommConfig.StopBits));
    self.StatusBar.Panels[0].Text:= LStatusStr;

  end
  else
  begin
    self.StatusBar.Panels[0].Text:= FRS232.CommName + '关闭';
  end;
end;

end.
