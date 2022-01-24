unit unMain;

interface

uses
	Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs,Vcl.StdCtrls,	Vcl.ExtCtrls, Vcl.ComCtrls,
	CoreAudioMixer,caConsts,ActiveX;


type
	TfrmMain = class(TForm)
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    laMax: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cbEndpointMute: TCheckBox;
		tbEndpointBal: TTrackBar;
		tbEndpointVol: TTrackBar;
    GroupBox5: TGroupBox;
    tbSessionVol: TTrackBar;
    cbSessionMute: TCheckBox;
    GroupBox4: TGroupBox;
    buGetFriendlyName: TButton;
    rbRender: TRadioButton;
    rbCapture: TRadioButton;
    rbAll: TRadioButton;
    laPos: TLabel;
    pbMaster: TProgressBar;
    Timer1: TTimer;
    buRegisterNotification: TButton;
    buUnregisterNotification: TButton;
    buRegisterEnpointNotify: TButton;
    buUnregisterEndpointNotify: TButton;
    Button2: TButton;
    buRemoveSessionControl: TButton;
    Button4: TButton;
    cbAllEP: TRadioButton;
    cbActiveEP: TRadioButton;
    cbUnpluggedEP: TRadioButton;
    cbDisabledEP: TRadioButton;
    cbNotPresentEP: TRadioButton;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    edSessionName: TEdit;
		procedure FormCreate(Sender: TObject);
    procedure tbEndpointBalChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbEndpointMuteClick(Sender: TObject);
    procedure cbSessionMuteClick(Sender: TObject);
		procedure tbEndpointVolChange(Sender: TObject);
		procedure tbSessionVolChange(Sender: TObject);
		procedure buGetFriendlyNameClick(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure buRegisterEnpointNotifyClick(Sender: TObject);
    procedure buUnregisterEndpointNotifyClick(Sender: TObject);
    procedure buRegisterNotificationClick(Sender: TObject);
    procedure buUnregisterNotificationClick(Sender: TObject);
    procedure buRemoveSessionControlClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
	private
		Procedure OnEndpointVolumeEvent(pNotify:TMasterVolumeData);
		procedure OnSimpleVolumeEvent(NewVolume:Integer; NewMute:Boolean; EventContext:TGUID);
		procedure OnChannelVolumeEvent(ChannelCount:Integer; NewChannelArray:Array of Integer; ChangedChannel:Integer;EventContext:TGuid);
		procedure OnDisplayNameEvent(strNewDisplayName:String; EventContext:TGuid);
		procedure OnIconPathEvent (strNewIconPath:String; EventContext:TGuid);
		procedure OnGroupingParamEvent  (NewGroupingParam:PGUID; EventContext:TGuid);
		procedure OnSessionStateEvent (NewState:TAudioSessionState);
		procedure OnSessionDisconnectedEvent (DisconnectReason:TAudioSessionDisconnectReason);
		procedure OnDeviceStateEvent   (strDeviceId:String; dwNewState:DWORD);
		procedure OnDeviceAddedEvent   (strDeviceId:String);
		procedure OnDeviceRemovedEvent (strDeviceId:String);
		procedure OnDefaultDeviceEvent (flow:EDataFlow;role:ERole;strDefaultDeviceId:String);
		procedure OnPropertyValueEvent (strDeviceId:String; key:PROPERTYKEY);


	public
		{ Public-Deklarationen }
	end;

type
 TBalanceOnChange = procedure(Sender: TObject) of object;

var
	AppGuid: TGuid;
	LastEventCtx:TGUID;
	frmMain: TfrmMain;
	CoreAudioMixer:TCoreAudioMixer;
	BalanceOnChange:TBalanceOnChange;
	MsgFromMixer:Boolean;
	WinMajorVersion:Integer;
	ChannelCount:Integer;
implementation



{$R *.dfm}

Function CompareGuid(strSender:String;SysGuid:TGuid):String;
Begin
	If GuidToString(SysGuid) = GuidToString(Appguid) then frmMain.Memo1.Lines.add(strSender + ': OWN_CHANGE')
	else
	frmMain.Memo1.Lines.add(strSender + ': '+  SysGuid.ToString);
End;



procedure TfrmMain.FormCreate(Sender: TObject);
Begin
	edSessionName.Text:='CoreAudioTest' + TimeToStr(now);
	AppGuid :=  StringToGUID('{92F06F7D-B140-40C7-8116-28F5BA66E991}');
	tbEndpointVol.Max:=100;
	tbEndpointVol.PageSize:=10;
	CoreAudioMixer:=TCoreAudioMixer.Create(AppGuid);
	CoreAudioMixer.OnMasterVolChanged:=OnEndpointVolumeEvent;
	CoreAudioMixer.OnSimpleVolChanged:=OnSimpleVolumeEvent;
	CoreAudioMixer.OnChannelVolChanged:=OnChannelVolumeEvent ;
	CoreAudioMixer.OnDisplayName:=OnDisplayNameEvent;
	CoreAudioMixer.OnIconPath:=OnIconPathEvent;
	CoreAudioMixer.OnGroupingParam:=OnGroupingParamEvent;
	CoreAudioMixer.OnSessionState:=OnSessionStateEvent;
	CoreAudioMixer.OnSessionDisconnectedNotify:=OnSessionDisconnectedEvent;
	CoreAudioMixer.OnIMMDeviceState:=OnDeviceStateEvent;
	CoreAudioMixer.OnIMMDeviceAdded:=OnDeviceAddedEvent;
	CoreAudioMixer.OnIMMDeviceRemoved:=OnDeviceRemovedEvent;
	CoreAudioMixer.OnIMMDefaultDevice:=OnDefaultDeviceEvent;
	CoreAudioMixer.OnIMMProperty:=OnPropertyValueEvent;
	BalanceOnChange:=tbEndpointBal.OnChange;
	try
		CoreAudioMixer.CreateEndpointMixer();
	except
	On E:Exception Do
	Begin
		ShowMessage(CoreAudioMixer.LastOleError +  E.Message + e.ClassName);
		tbEndpointVol.Enabled:=False;
		cbEndpointMute.Enabled:=false;
		Exit;
	End;
	end;

	try
		CoreAudioMixer.CreateSessionMixer;
	except
	On E:Exception Do
	Begin
		ShowMessage(CoreAudioMixer.LastOleError +  E.Message + e.ClassName);
		tbSessionVol.Enabled:=False;
		cbSessionMute.Enabled:=False;
		Exit;
	End;
	end;


	tbEndpointVol.Enabled:=True;
	cbEndpointMute.Checked:=CoreAudioMixer.GetEndpointMute;
	cbSessionMute.Checked:=CoreAudioMixer.GetSessionMute;
	tbEndpointVol.Position:=CoreAudioMixer.GetMasterVolume;
	tbSessionVol.Position:=CoreAudioMixer.GetSessionVolume;
	Timer1.Enabled:=True;
	ChannelCount:=CoreAudioMixer.GetChannelCount();
//	tbEndpointBal.Position:=Win7Mixer.GetChannelVolumeLevel(0);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	CoreAudioMixer.Destroy;
end;



procedure TfrmMain.buGetFriendlyNameClick(Sender: TObject);
Var
	sl:TStringList;
  aDeviceState:TDeviceState;

begin
	sl:=TStringList.Create;
	try
	  if cbAllEP.Checked then aDeviceState:=dsAll
  	else if cbActiveEP.Checked then aDeviceState:=dsActive
	  else if cbUnpluggedEP.Checked then aDeviceState:=dsUnplugged
  	else if cbDisabledEP.Checked then aDeviceState:=dsDisabled
	  else if cbNotPresentEP.Checked then aDeviceState:=dsNotPresent;
		CoreAudioMixer.GetFriendlyDeviceNames2(sl,aDeviceState);
		Memo1.Lines.Add(sl.text);
  finally
		sl.Free;
  end;
end;

procedure TfrmMain.buRegisterNotificationClick(Sender: TObject);
begin
	CoreAudioMixer.RegisterAudioSessionNotification();
end;

procedure TfrmMain.buRemoveSessionControlClick(Sender: TObject);
begin
	CoreAudioMixer.FreeSessionMixer;
end;

procedure TfrmMain.buUnregisterNotificationClick(Sender: TObject);
begin
	CoreAudioMixer.UnRegisterAudioSessionNotification();
end;



procedure TfrmMain.Button2Click(Sender: TObject);
Var
	L,R:Integer;
begin
	tbEndpointBal.OnChange:=nil;
	L:=CoreAudioMixer.GetChannelVolumeLevel(0) ;
	R:=CoreAudioMixer.GetChannelVolumeLevel(1);
	If L > R then tbEndpointBal.Max:=L else tbEndpointBal.Max:=R;
	tbEndpointBal.Min := tbEndpointBal.Max * -1;
	tbEndpointBal.Position:=R-L;
	laMax.Caption:=tbEndpointBal.Max.ToString;
	Memo1.Lines.Add('L:' + L.ToString + '  R:' + R.ToString);
	tbEndpointBal.OnChange:=BalanceOnChange;
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
	CoreAudioMixer.SetSessionName(edSessionName.text);
end;

procedure TfrmMain.buRegisterEnpointNotifyClick(Sender: TObject);
begin
	CoreAudioMixer.RegisterEndpointVolumeChange();
end;

procedure TfrmMain.buUnregisterEndpointNotifyClick(Sender: TObject);
begin
	CoreAudioMixer.UnRegisterEndpointVolumeChange();
end;


procedure TfrmMain.cbEndpointMuteClick(Sender: TObject);
begin
	CoreAudioMixer.SetEndpointMute(cbEndpointMute.Checked);
end;

procedure TfrmMain.cbSessionMuteClick(Sender: TObject);
begin
	CoreAudioMixer.SetSessionMute(cbSessionMute.Checked);
end;



Procedure TfrmMain.OnEndpointVolumeEvent (pNotify:TMasterVolumeData);
Begin
	//CompareGuid('Master-' + pNotify.intMasterVolume.ToString ,pNotify.guidEventContext);
	if pNotify.guidEventContext = AppGuid then Exit;
	Memo1.Lines.Add('HANDLEMaster');
	if pNotify.intMasterVolume <> tbEndpointVol.Position then tbEndpointVol.Position:=pNotify.intMasterVolume;
	laPos.Caption:=pNotify.afChannelVolumes[0].ToString + '/' + pNotify.afChannelVolumes[1].ToString;
	if pNotify.bMuted <> cbEndpointMute.Checked then
	Begin
		cbEndpointMute.Checked:=pNotify.bMuted;
		cbEndpointMuteClick(nil);
	End;
End;

procedure TfrmMain.OnSimpleVolumeEvent(NewVolume:Integer; NewMute:Boolean; EventContext:TGUID);
Begin
//	CompareGuid('Session ' + NewVolume.ToString,EventContext^);
	if EventContext = AppGuid then Exit;
	Memo1.Lines.Add('HANDLESession');
	if tbSessionVol.Position <> NewVolume then tbSessionVol.Position:=NewVolume;
	if cbSessionMute.Checked <> NewMute then
	Begin
		cbSessionMute.Checked:=NewMute;
		cbSessionMuteClick(nil);
	End;
End;

procedure TfrmMain.OnChannelVolumeEvent(ChannelCount:Integer; NewChannelArray:Array of Integer; ChangedChannel:Integer;EventContext:TGuid);
Begin
	if tbEndpointBal.Position <> NewChannelArray[0] then tbEndpointBal.Position:=Round(NewChannelArray[0] *100);
End;

procedure TfrmMain.tbEndpointBalChange(Sender: TObject);
Var
	p:Integer;
begin
	laPos.Caption:=tbEndpointBal.Position.ToString;
	if tbEndpointBal.Position =0 then
	Begin
		CoreAudioMixer.SetBalance(0,tbEndpointBal.Max);
		Application.ProcessMessages;
		CoreAudioMixer.SetBalance(1,tbEndpointBal.Max);
	End;
	p:=tbEndpointBal.Position;
	if p <0  then
	Begin
		p:=p *-1;
		CoreAudioMixer.SetBalance(1,tbEndpointBal.max - p);
		Application.ProcessMessages;
	End
	else if p >0 then
	Begin
		CoreAudioMixer.SetBalance(0,tbEndpointBal.max - p );
		Application.ProcessMessages;
	End;
end;

procedure TfrmMain.tbEndpointVolChange(Sender: TObject);
begin
	Memo1.Lines.add('tbMaster!');
	CoreAudioMixer.SetMasterVolume(tbEndpointVol.Position);
end;

procedure TfrmMain.tbSessionVolChange(Sender: TObject);
begin
	CoreAudioMixer.SetSimpleVolume(tbSessionVol.Position);
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
	pbMaster.Position:=CoreAudioMixer.GetMasterPeakValue();
end;





procedure TfrmMain.OnDisplayNameEvent(strNewDisplayName:String; EventContext:TGuid);
begin
	frmMain.Memo1.Lines.Add('OnDisplayNameEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('NewName=' + strNewDisplayName);
end;

procedure TfrmMain.OnIconPathEvent (strNewIconPath:String; EventContext:TGuid);
begin
	frmMain.Memo1.Lines.Add('OnIconPathEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('NewPath=' + strNewIconPath);
end;

procedure TfrmMain.OnGroupingParamEvent(NewGroupingParam:PGUID; EventContext:TGuid);
begin
	frmMain.Memo1.Lines.Add('OnGroupingEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('NewGroupParam=' + NewGroupingParam.ToString);
end;

procedure TfrmMain.OnSessionStateEvent (NewState:TAudioSessionState);
begin
	frmMain.Memo1.Lines.Add('OnSessState - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('NewState=' + Integer(NewState).ToString );
end;

procedure TfrmMain.OnSessionDisconnectedEvent (DisconnectReason:TAudioSessionDisconnectReason);
begin
	frmMain.Memo1.Lines.Add('OnSessDiscon - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('DeviceID=' + Integer(DisconnectReason).ToString) ;
end;

procedure TfrmMain.OnDeviceStateEvent   (strDeviceId:String; dwNewState:DWORD);
begin
	frmMain.Memo1.Lines.Add('DevStatEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('DeviceID=' + strDeviceID);

end;

procedure TfrmMain.OnDeviceAddedEvent   (strDeviceId:String);
begin
	frmMain.Memo1.Lines.Add('DevAddEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('DeviceID=' + strDeviceID);
end;

procedure TfrmMain.OnDeviceRemovedEvent (strDeviceId:String);
begin
	frmMain.Memo1.Lines.Add('DevRemoveEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('DeviceID=' + strDeviceID);
end;


procedure TfrmMain.OnDefaultDeviceEvent(flow:EDataFlow;role:ERole;strDefaultDeviceId:String);
begin
	if role <> 2 then exit;
	frmMain.Memo1.Lines.Add('DefaultDeviceEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('Role=' + IntToStr(role) + ' Flow=' + IntToStr(Flow));
	frmMain.Memo1.Lines.Add('OldDefDevice=' + CoreAudioMixer.GetDefaultDeviceFriendlyName());
	frmMain.Memo1.Lines.Add('NewDevDevice=' + strDefaultDeviceID);
end;


procedure TfrmMain.OnPropertyValueEvent (strDeviceId:String; key:PROPERTYKEY);
begin
	frmMain.Memo1.Lines.Add('PropValEvent - ' + DateTimeToStr(Now));
	frmMain.Memo1.Lines.Add('DeviceID=' + strDeviceID);
end;





end.
