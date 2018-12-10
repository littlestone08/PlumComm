Unit PlumUtils.ADO;


interface
uses
  Classes, SysUtils, ADODB, DB;

type
  TADOConnectionCrack = Class(TADOConnection)
  Public
    function GetProperties(const StrList: TStrings; out ErrStr: String): Boolean;
    function GetTables(const StrList: TStrings; out ErrStr: String; SystemTable: Boolean = False): Boolean;
    function GetFieldNames(const Table: String; StrList: TStrings; out ErrStr: String): Boolean; Overload;
  End;
  TFilterRecall = Class
  Private
    FDS: TDataset;
    FFiltered: Boolean;
    FFilterStr: String;
    FFilterOptions: TFilterOptions;
  Public
    Constructor Create(ADataSet: TDataset);
    Destructor Destroy; Override;
  End;
implementation
uses
  Variants;

{ TADOConnectionCrack }

function TADOConnectionCrack.GetFieldNames(
  const Table: String; StrList: TStrings; out ErrStr: String): Boolean;
begin
  Result:= False;
  try
    GetFieldNames(Table, StrList);
    Result:= True;
  except
    on E: Exception do
    begin
      ErrStr:= E.Message;
    end;
  end;
end;

function TADOConnectionCrack.GetProperties(
  const StrList: TStrings; out ErrStr: String): Boolean;
var
  i: Integer;
  s: String;
begin
  Result:= False;
  try
    for i := 0 to Properties.Count - 1 do
    begin
      if VarIsNull(Properties[i].Value) then
        s:= ''
      else
        s:= Properties[i].Value;
      StrList.Add(Format('%s=%s', [Properties[i].Name, s]));

    end;
    Result:= True;
  except
    on E: Exception do
    begin
      ErrStr:= E.Message;
    end;
  end;
end;

function TADOConnectionCrack.GetTables(
  const StrList: TStrings; out ErrStr: String; SystemTable: Boolean): Boolean;
begin
  Result:= False;
  try
    GetTableNames(StrList, SystemTable);
    Result:= True;
  except
    on E: Exception do
    begin
      ErrStr:= E.Message;
    end;
  end;
end;

{ TFilterRecall }

constructor TFilterRecall.Create(ADataSet: TDataset);
begin
  inherited Create;
  FDS:= ADataSet;
  FFiltered:= FDS.Filtered;
  FFilterStr:= FDS.Filter;
  FFilterOptions:= FDS.FilterOptions;
end;

destructor TFilterRecall.Destroy;
begin
  FDS.FilterOptions:= FFilterOptions;
  FDS.Filter:= FFilterStr;
  FDS.Filtered:= FFiltered;
  inherited;
end;

end.
