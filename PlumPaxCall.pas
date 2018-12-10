unit PlumPaxCall;

interface
uses
  Classes, SysUtils;//, PaxCompiler, PaxProgram;
type
  TCalcuLevelProc = Procedure (FreqMHz: Double; WishLevelDbm: Double; var CompensatedLevelDbm);

  TCustomCalcuOutLevel = Class
  Public
    Procedure Calc(AFreqMHz: Double; AWishLevelDbm: Double; var ACompensatedLevelDbm: Double); virtual; abstract;
  end;

//  TCalcuOutLevel_Pax = Class(TCustomCalcuOutLevel)
//  Private
//    FCompiler: TPaxCompiler;
//    FProgram: TPaxProgram;
//    FLanguage: TPaxPascalLanguage;
//    FErrorMessage: String;
//    FCalcuProcStub: TCalcuLevelProc;
//    Procedure ReleasePax;
//  Public
//    Procedure Calc(AFreqMHz: Double; AWishLevelDbm: Double; var ACompensatedLevelDbm: Double); Override;
//    Constructor Create;
//    Destructor Destroy; Override;
//    Property ErrorMessage: String Read FErrorMessage;
//  End;
type
  TCalcuOutLevel_NoChange = Class(TCustomCalcuOutLevel)
  Public
    Procedure Calc(AFreqMHz: Double; AWishLevelDbm: Double; var ACompensatedLevelDbm: Double); override;
  End;

  TDoublePair = Record
    X, Y: Double;
  end;
  TDynamicDoublePareArray = Array of TDoublePair;

  TCalcuOutLevel_Subsection = Class(TCustomCalcuOutLevel)
  Private
    Fsamples: TDynamicDoublePareArray;
  Protected
    Procedure  Init(var ASamples: TDynamicDoublePareArray); Virtual; Abstract;
  Public
    Constructor Create;
    Procedure Calc(AFreqMHz: Double; AWishLevelDbm: Double; var ACompensatedLevelDbm: Double); override;

  End;

implementation

const
  CONST_SCRIPT_FILE: TFileName = 'CalcuLevel.txt';
  CONST_FUNCNAME: Ansistring = 'CalcuLevel';


//{ TCalcuOutLevel }
//
//
//
//procedure TCalcuOutLevel_Pax.Calc(AFreqMHz, AWishLevelDbm: Double;
//  var ACompensatedLevelDbm: Double);
//begin
//  ACompensatedLevelDbm:= AWishLevelDbm;
//  if Assigned(FCalcuProcStub) then
//  begin
//    FCalcuProcStub(AFreqMHz, AWishLevelDbm, ACompensatedLevelDbm);
//  end;
//end;
//
//constructor TCalcuOutLevel_Pax.Create;
//var
//  i: Integer;
//  L_HFunc: Integer;
//  L_Dummy: Double;
//begin
//  inherited;
//  if Not FileExists(CONST_SCRIPT_FILE) then
//  begin
//    With TStringList.Create do
//    begin
//      Add('Procedure CalcuLevel(AFreqMHz: Double; AWishLevelDBm: Double; var ACompensatedLevelDBm: Double);');
//      Add('Begin');
//      Add(' ACompensatedLevelDBm:= AWishLevelDBm;');
//      Add('End;');
//      try
//        try
//          SaveToFile(CONST_SCRIPT_FILE);
//        finally
//          Free;
//        end;
//      except
//
//      end;
//    end;
//  end;  
//  if FileExists(CONST_SCRIPT_FILE) then
//  begin
//    FCompiler := TPaxCompiler.Create(nil);
//    FProgram := TPaxProgram.Create(nil);
//    FLanguage := TPaxPascalLanguage.Create(nil);
//    try
//      FCompiler.RegisterLanguage(FLanguage);
//      FCompiler.AddModule('0', FLanguage.GetLanguageName);
//      FCompiler.AddCodeFromFile('0', CONST_SCRIPT_FILE);
//      FCompiler.AddCode('0', 'Begin');
//      FCompiler.AddCode('0', 'End.');
//
//      if FCompiler.Compile(FProgram) then
//      begin
//        L_HFunc := FCompiler.GetHandle(0, CONST_FUNCNAME, true);
//        if L_HFunc <> 0 then
//          FCalcuProcStub := FProgram.GetAddress(L_HFunc); // get address of script-defind procedure
//        if Assigned(FCalcuProcStub) then
//        begin
//          {$O-}
//          FCalcuProcStub(0, 0, L_Dummy);
//          {$O+}
//        end
//        else
//        begin
//          Raise Exception.Create('未找到函数['+CONST_FUNCNAME+']定义');
//        end;
//      end
//      else
//      begin
//        for I:=0 to FCompiler.ErrorCount do
//          FErrorMessage:= FErrorMessage + #$D#$A + FCompiler.ErrorMessage[I];
//        ReleasePax;
//      end;
//    except
//      On E: Exception do
//      begin
//        FErrorMessage:= Format('编译函数文件异常: %s = %s', [E.ClassName, E.Message]);
//        ReleasePax;
//      end;
//    end;
//  end
//  else
//  begin
//    FErrorMessage:= Format('信号修正文件 [%s] 未找到', [CONST_SCRIPT_FILE]);
//  end;
//end;
//
//destructor TCalcuOutLevel_Pax.Destroy;
//begin
//  ReleasePax;
//  inherited;
//end;
//
//procedure TCalcuOutLevel_Pax.ReleasePax;
//begin
//  FreeAndNil(FLanguage);
//  FreeAndNil(FProgram);
//  FreeAndNil(FCompiler);
//end;

{ TCalcuOutLevel2 }

procedure TCalcuOutLevel_Subsection.Calc(AFreqMHz, AWishLevelDbm: Double;
  var ACompensatedLevelDbm: Double);
//const
//  const_samples: Array[0..32] of TDoublePair = (
//    (X:0.5; Y:15.52),
//    (X:0.6; Y:14.98),
//    (X:0.7; Y:14.59),
//    (X:0.8; Y:14.30),
//    (X:0.9; Y:14.09),
//    (X:1.0; Y:13.92),
//    (X:1.1; Y:13.79),
//    (X:1.2; Y:13.69),
//    (X:1.3; Y:13.58),
//    (X:1.4; Y:13.53),
//    (X:1.5; Y:13.47),
//    (X:1.7; Y:13.37),
//    (X:1.9; Y:13.31),
//    (X:2.1; Y:13.24),
//    (X:2.3; Y:13.21),
//    (X:2.5; Y:13.17),
//    (X:3.0; Y:13.12),
//    (X:3.5; Y:13.10),
//    (X:4.0; Y:13.08),
//    (X:4.5; Y:13.07),
//    (X:5.0; Y:13.04),
//    (X:5.5; Y:13.04),
//    (X:6.0; Y:13.04),
//    (X:9.0; Y:13.04),
//    (X:12.0; Y:13.05),
//    (X:15.0; Y:13.06),
//    (X:18.0; Y:13.08),
//    (X:21.0; Y:13.09),
//    (X:24.0; Y:13.12),
//    (X:27.0; Y:13.13),
//    (X:30.0; Y:13.10),
//    (X:88.0; Y:13.31),
//    (X:108.0; Y:13.39)
//  );
var
  L_DataCount: Integer;
  Index: Integer;
  L_1, L_2: TDoublePair;
  L_CoeffA, L_CoeffB: Double;

begin
  ACompensatedLevelDbm:= AWishLevelDbm;
  L_DataCount:= Length(Fsamples);
  if L_DataCount >= 2 then
  begin
    if AFreqMHz <= Fsamples[0].X then
    begin
      L_1:= Fsamples[0]; L_2:= Fsamples[1];
    end
    else
    if AFreqMHz >= Fsamples[L_DataCount - 1].X then
    begin
      L_1:= Fsamples[L_DataCount - 2]; L_2:= Fsamples[L_DataCount - 1];
    end
    else
    begin
      for Index := 0 to L_DataCount - 2 do
      begin
        if (AFreqMHz >= Fsamples[Index].X) and (AFreqMHz < Fsamples[Index + 1].X) then
        begin
          L_1:= Fsamples[Index];
          L_2:= Fsamples[Index + 1];
          Break;
        end;
      end;
    end;
    if L_2.X - L_1.X <> 0 then
    begin
      L_CoeffA:= (L_2.Y - L_1.Y) / (L_2.X - L_1.X);
      L_CoeffB:= L_1.Y - L_CoeffA * L_1.X;
      ACompensatedLevelDbm:= AWishLevelDbm + L_CoeffA * AFreqMHz + L_CoeffB;
    end;
  end;
end;



{ TCalcuOutLevel1 }

procedure TCalcuOutLevel_NoChange.Calc(AFreqMHz, AWishLevelDbm: Double;
  var ACompensatedLevelDbm: Double);
begin
  ACompensatedLevelDbm:= AWishLevelDbm;
end;

constructor TCalcuOutLevel_Subsection.Create;
begin
  inherited Create;
  Init(Fsamples);
end;

end.
