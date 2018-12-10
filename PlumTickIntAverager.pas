unit PlumTickIntAverager;

interface
uses
  Classes, SysUtils, Windows, SyncObjs;
type
  PTickIntRec = ^TTickIntRec;
  TTickIntRec = Record
    Tick: Cardinal;
    Value: Integer;
  End;

  TTickIntPool = Class
  Private
    FCS: TCriticalSection;
    FUnLockItems: TList;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    function Lock: PTickIntRec;
    Procedure UnLock(P: PTickIntRec);
  End;

  TTickIntAverager = Class
  Private
    FList: TList;
    FMaxToShrinkCount: Integer;
    FTickInterval: Cardinal;
    function GetAvgValue: Integer;
    procedure DoShrink;
    Procedure DeleteItem(Index: Integer);
  Private
    {$IFDEF DEBUG}
    FLastAvgHint: TStringList;
    function GetLastAvgLog: AnsiString;
    {$ENDIF}
  Public
    Constructor Create(TickInterval: Cardinal; MaxToShrinkCount: Integer);
    Destructor Destroy; Override;
    Procedure PushValue(Value: Integer);
    Property AvgValue: Integer Read GetAvgValue;
    {$IFDEF DEBUG}
    Property LastAvgLog: AnsiString Read GetLastAvgLog;
    {$ENDIF}
  End;

implementation
var
  Pool: TTickIntPool;
{ TTickIntAverager }

constructor TTickIntAverager.Create(TickInterval: Cardinal; MaxToShrinkCount: Integer);
begin
  inherited Create;
  FList:= TList.Create;
  FTickInterval:= TickInterval;
  FMaxToShrinkCount:= MaxToShrinkCount;
  {$IFDEF DEBUG}
  FLastAvgHint:= TStringList.Create;
  {$ENDIF}
end;

procedure TTickIntAverager.DeleteItem(Index: Integer);
begin
  Pool.UnLock(PTickIntRec(FList[Index]));
  FList.Delete(Index);
end;

destructor TTickIntAverager.Destroy;
var
  i: Integer;
begin
  {$IFDEF DEBUG}
  FreeAndNil(FLastAvgHint);
  {$ENDIF}
  for i := 0 to FList.Count - 1 do
    Pool.UnLock(FList[i]);
  FList.Free;
  inherited;
end;

procedure TTickIntAverager.DoShrink;
var
  L_Curr: Cardinal;
  {$IFDEF DEBUG}
  L_Info: AnsiString;
  {$ENDIF}
begin
  L_Curr:= GetTickCount;
  {$IFDEF DEBUG}
  L_Info:= L_Info + Format('从%d个中删除过时数据:', [FList.Count]);
  {$ENDIF}
  while (FList.Count > 0) and (L_Curr - PTickIntRec(FList[0]).Tick > FTickInterval) do
  begin
    {$IFDEF DEBUG}
    L_Info:= L_Info + Format('%d, ', [PTickIntRec(FList[0]).Value]);
    {$ENDIF}
    DeleteItem(0);
  end;
  //OutputDebugString(PChar(Format('Count = %d after shrink', [FList.Count])));
  {$IFDEF DEBUG}
  L_Info:= L_Info + Format('剩余%d个数据:', [FList.Count]);  
  FLastAvgHint.Add(L_Info)
  {$ENDIF}

end;

  function sort_int_callback(Item1, Item2: Pointer): Integer;
  begin
    Result:= Integer(Item1) - Integer(Item2);
    if Result > 0 then
      Result:= 1
    else if Result < 0 then
      Result:= -1;
  end;
function TTickIntAverager.GetAvgValue: Integer;
var
  i: Integer;
  //L_Curr: Cardinal;
  L_Sort: TList;
  {$IFDEF DEBUG}
  L_Info: AnsiString;
  Procedure Push_Info(const AInfo: AnsiString; ACRLF: Boolean = False);
  begin
    L_Info:= L_Info + AInfo;
    if ACRLF then
      L_Info:= L_Info + #13#10;
  end;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  FLastAvgHint.Clear;
  {$ENDIF}

  //L_Curr:= GetTickCount;
  DoShrink;
  Result:= 0;

  //去掉最高最低各两个,防止有误值.
  L_Sort:= TList.Create;
  try
    {$IFDEF DEBUG}
    Push_Info(Format('当前共%d个: ', [FList.Count]));
    {$ENDIF}
    for i := 0 to FList.Count - 1 do
    begin
      L_Sort.Add(Pointer(PTickIntRec(FList[i])^.Value));
      {$IFDEF DEBUG}
      Push_Info(Format('%d, ', [PTickIntRec(FList[i])^.Value]));
      {$ENDIF}
    end;
    {$IFDEF DEBUG}
    Push_Info(#13#10);
    {$ENDIF}

    {$IFDEF DEBUG}
    L_Info:= L_Info +  '删除最大最小值: ';
    {$ENDIF}
    L_Sort.Sort(sort_int_callback);
    if L_Sort.Count > 2 then
    begin
      {$IFDEF DEBUG}
      Push_Info(Format('%d, ', [PTickIntRec(FList[0])^.Value]));
      Push_Info(Format('%d, ', [PTickIntRec(FList[L_Sort.Count - 1])^.Value]));
      {$ENDIF}
      L_Sort.Delete(0);
      L_Sort.Delete(L_Sort.Count - 1);
    end;
    if L_Sort.Count > 2 then
    begin
      {$IFDEF DEBUG}
      Push_Info(Format('%d, ', [PTickIntRec(FList[0])^.Value]));
      Push_Info(Format('%d, ', [PTickIntRec(FList[L_Sort.Count - 1])^.Value]));
      {$ENDIF}

      L_Sort.Delete(0);
      L_Sort.Delete(L_Sort.Count - 1);
    end;
    {$IFDEF DEBUG}
    Push_Info(Format('剩余%d个: ', [FList.Count]), True);
    {$ENDIF}

    //结果为全部值求平均
    {$IFDEF DEBUG}
    Push_Info('平均值: ');
    {$ENDIF}
    for i := 0 to L_Sort.Count - 1 do
    begin
      Inc(Result, Integer(L_Sort[i]));
    end;
    if L_Sort.Count > 0 then
      Result:= Round(Result / L_Sort.Count)
    else
      Result:= 0;
    {$IFDEF DEBUG}
    Push_Info(Format('%d '#13#10, [Result]), True);
    FLastAvgHint.Add(L_Info)
    {$ENDIF}
  finally
    L_Sort.Free;
  end;

//  if FList.Count > 0 then
//  begin
//    for i := 0 to FList.Count - 1 do
//    begin
////      OutputDebugString(PChar(intToStr(L_Curr - PTickIntRec(FList[i])^.Tick)));
//      Inc(Result, PTickIntRec(FList[i])^.Value);
//    end;
//    Result:= Round(Result / FList.Count);
////    OutputDebugString(PChar('有' + INtToStr(FList.count) + '个电平数据, 平均值为 ' +FloatToStr(Result)));
//  end;
  while self.FList.Count > 0 do
    DeleteItem(0);
end;

{$IFDEF DEBUG}
function TTickIntAverager.GetLastAvgLog: AnsiString;
begin
  Result:= '';
  if FLastAvgHint <> nil then
    Result:= FLastAvgHint.Text;
end;
{$ENDIF}

procedure TTickIntAverager.PushValue(Value: Integer);
var
  P: PTickIntRec;
begin
  P:= Pool.Lock;
  P.Tick:= GetTickCount;
  P.Value:= Value;
  self.FList.Add(P);
  if FList.Count >= FMaxToShrinkCount then
  begin
    self.DoShrink;
  end;
  
end;

{ TTickIntPool }

constructor TTickIntPool.Create;
begin
  inherited;
  FCS:= TCriticalSection.Create;
  FUnLockItems:= TList.Create;
end;

destructor TTickIntPool.Destroy;
var
  i: Integer;
  L_P: PTickIntRec;
begin
  FCS.Enter;
  try
    for i := 0 to FUnLockItems.Count - 1 do
    begin
      L_P:= PTickIntRec(FUnLockItems[i]);
      Dispose(L_P);
    end;
    FUnLockItems.Free;
  finally
    FCS.Leave;
  end;

  FCS.Free;

  inherited;
end;

function TTickIntPool.Lock: PTickIntRec;
begin
  FCS.Enter;
  try
    if self.FUnLockItems.Count > 0 then
    begin
      Result:= FUnLockItems.Last;
      FUnLockItems.Delete(FUnLockItems.Count - 1);
    end
    else
    begin
      New(Result);
      //OutputDebugString('New Rec!!!');
    end;
  finally
    FCS.Leave;
  end;
end;

procedure TTickIntPool.UnLock(P: PTickIntRec);
begin
  FCS.Enter;
  try
    FUnLockItems.Add(P);
  finally
    FCS.Leave;
  end;
end;

initialization
  Pool:= TTickIntPool.Create;
finalization
  FreeAndNil(Pool);
end.
