program CoreAudioApi;

uses
  Vcl.Forms,
  unMain in 'unMain.pas' {frmMain};

{$R *.res}
{$DEFINE USE_SAFECALL}


begin
	ReportMemoryLeaksOnShutdown:=True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
