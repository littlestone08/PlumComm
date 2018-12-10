unit u_dmUpgrade;

interface

uses
  SysUtils, Classes, auHTTP, auAutoUpgrader, u_AutoUpgraderEditorCrack, u_Version;

type
  TauAutoUpgrader = Class(auAutoUpgrader.TauAutoUpgrader)
  public
    Procedure Loaded; override;
  End;


  TdmUpgrade = class(TDataModule)
    auAutoUpgrader1: TauAutoUpgrader;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure UpdateDeplyConfigFile();
  end;

var
  dmUpgrade: TdmUpgrade;

implementation

{$R *.dfm}

procedure TdmUpgrade.DataModuleCreate(Sender: TObject);
begin
  dmUpgrade.auAutoUpgrader1.InfoFileURL:= CONST_URL_DEPLY_INF_FILE;
  dmUpgrade.auAutoUpgrader1.CheckUpdate(False);
end;

procedure TdmUpgrade.UpdateDeplyConfigFile;
var
  x: TAutoUpgraderEditorCrack;
  stm: TMemoryStream;
begin
  x:= TAutoUpgraderEditorCrack.Create(Nil);
  stm:= TMemoryStream.Create;
  try
    ForceDirectories(ExtractFilePath(CONST_LOCAL_DEPLY_INF_FILE));
    x.AutoUpgrader:= self.auAutoUpgrader1;
    x.SaveDialog.FileName:= CONST_LOCAL_DEPLY_INF_FILE;
    x.ExportBtnClick(Nil);
    stm.LoadFromFile(ParamStr(0));
    stm.SaveToFile(
      ExtractFilePath(x.SaveDialog.FileName) +
      ExtractFileName(ParamStr(0))
      );
  finally
    stm.Free;
    x.Free;
  end;
end;

{ TauAutoUpgrader }

procedure TauAutoUpgrader.Loaded;
begin
  inherited;
  VersionNumber:= u_Version.CONST_VERISION;
  InfoFile.UpgradeMsg:= GetUpdateMsg;
end;
end.
