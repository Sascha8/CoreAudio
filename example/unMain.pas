
{
Example is currently a bit messy because of trying to get channel balance stuff to work.
}

unit unMain;

interface

uses
	Winapi.Windows,Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs,Vcl.StdCtrls,	Vcl.ExtCtrls, Vcl.ComCtrls,
	CoreAudioMixer,caConsts,ActiveX;



	type
	TTrackBar = class(Vcl.ComCtrls.TTrackBar)
	protected
		procedure CNHScroll(var Message: TWMHScroll); message CN_HSCROLL;
	end;

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
		buGetBalance: TButton;
		buRemoveSessionControl: TButton;
		buRenameSession: TButton;
		cbAllEP: TRadioButton;
		cbActiveEP: TRadioButton;
		cbUnpluggedEP: TRadioButton;
		cbDisabledEP: TRadioButton;
		cbNotPresentEP: TRadioButton;
		GroupBox2: TGroupBox;
		GroupBox3: TGroupBox;
		edSessionName: TEdit;
		Button1: TButton;
		Button2: TButton;
		laVolPos: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Button10: TButton;
		procedure FormCreate(Sender: TObject);
		procedure tbEndpointBalChange(Sender: TObject);
		procedure buGetBalanceClick(Sender: TObject);
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
		procedure buRenameSessionClick(Sender: TObject);
		procedure Button1Click(Sender: TObject);
		procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
	private
		Procedure OnEndpointVolumeEvent(pNotify:TMasterVolumeData);
		procedure OnSimpleVolumeEvent(NewVolume:Integer; NewMute:Boolean; EventContext:TGUID);
		procedure OnChannelVolumeEvent(ChannelCount:Integer; NewChannelArray:Array of Integer; ChangedChannel:Integer;EventContext:TGuid);
		procedure OnDisplayNameEvent(strNewDisplayName:String; EventContext:TGuid);
		procedure OnIconPathEvent (strNewIconPath:String; EventContext:TGuid);
		procedure OnGroupingParamEvent  (NewGroupingParam:PGUID; EventContext:TGuid);
		procedure OnSessionStateEvent (NewState:TAudioSessionState);
		procedure OnSessionDisconnectedEvent (DisconnectReason:TAudioSessionDisconnectReason);
		procedure OnDeviceStateChanged (strDeviceId:String; dwNewState:DWORD);
		procedure OnDeviceAdded (strDeviceId:String);
		procedure OnDeviceRemoved (strDeviceId:String);
		procedure OnDefaultDeviceChanged (flow:EDataFlow;role:ERole;strDeviceId:String);
		procedure OnPropertyValueChanged (strDeviceId:String; key:PROPERTYKEY);


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
	WinMajorVersion:Integer;
	ChannelCount:Integer;
implementation

{$R *.dfm}

//expermintal...
Function CompareGuid(strSender:String;SysGuid:TGuid):String;
Begin
	If GuidToString(SysGuid) = GuidToString(Appguid) then frmMain.Memo1.Lines.add(strSender + ': OWN_CHANGE')
	else
	frmMain.Memo1.Lines.add(strSender + ': '+  SysGuid.ToString);
End;


procedure TfrmMain.FormCreate(Sender: TObject);
Begin
	edSessionName.Text:='CoreAudioTest_' + TimeToStr(now);
	AppGuid := StringToGUID('{92F06F7D-B140-40C7-8116-28F5BA66E997}');
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
	CoreAudioMixer.OnIMMDeviceStateChanged:=OnDeviceStateChanged;
	CoreAudioMixer.OnIMMDeviceAdded:=OnDeviceAdded;
	CoreAudioMixer.OnIMMDeviceRemoved:=OnDeviceRemoved;
	CoreAudioMixer.OnIMMDefaultDeviceChanged:=OnDefaultDeviceChanged;
	CoreAudioMixer.OnIMMPropertyValueChanged:=OnPropertyValueChanged;
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

{************************************************************ API Callbacks *****************************************************}

Procedure TfrmMain.OnEndpointVolumeEvent (pNotify:TMasterVolumeData);
Begin
	laVolPos.Caption:=pNotify.intMasterVolume.ToString;
	//CompareGuid('EVP',pNotify.guidEventContext);
	if pNotify.guidEventContext = AppGuid then Exit;
	Memo1.Lines.Add('HANDLEMaster');
	if pNotify.intMasterVolume <> tbEndpointVol.Position then tbEndpointVol.Position:=pNotify.intMasterVolume;

//  	if pNotify.afChannelVolumes[0] <> tbEndpointBal.Position then tbEndpointBal.Position:=pNotify.afChannelVolumes[0];
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
	if EventContext = AppGuid then Exit;
	if tbEndpointBal.Position <> NewChannelArray[0] then tbEndpointBal.Position:=Round(NewChannelArray[0] *100);
End;

{************************************************************ Control Events *****************************************************}


procedure TfrmMain.tbEndpointVolChange(Sender: TObject);
begin
	// Delphis onChangeEvent for TTrackbar fires even when change comes from code. This will give a race condition.
	// Better to react on HScroll Msg
end;

procedure TfrmMain.tbSessionVolChange(Sender: TObject);
begin
	//
end;

procedure TTrackBar.CNHScroll(var Message: TWMHScroll);
begin
	if message.ScrollBar = frmMain.tbEndpointVol.Handle then
	Begin
		if Message.ScrollCode = SB_THUMBTRACK then
		begin
			Message.Result := 0;
			frmMain.Memo1.Lines.add('On HScroll ' + Message.ScrollCode.ToString + ' ' +  frmMain.tbEndpointVol.Text);
			frmMain.Memo1.Lines.add(Message.Pos.ToString);
			CoreAudioMixer.SetMasterVolume(Message.Pos);
		end
		else
		Begin
			inherited;
			CoreAudioMixer.SetMasterVolume(frmMain.tbEndpointVol.Position);
		End;
	end

	else if message.ScrollBar = frmMain.tbSessionVol.Handle then
	Begin
		if Message.ScrollCode = SB_THUMBTRACK then
		begin
			Message.Result := 0;
			frmMain.Memo1.Lines.add('OnScroll Session' + frmMain.tbSessionVol.Text);
			frmMain.Memo1.Lines.add(Message.Pos.ToString);
			CoreAudioMixer.SetSimpleVolume(Message.Pos);
		End
		else
		Begin
			inherited;
			CoreAudioMixer.SetSimpleVolume(frmMain.tbSessionVol.Position);
		End;
	End;
end;




//This is buggy
procedure TfrmMain.tbEndpointBalChange(Sender: TObject);
Var
	p:Integer;
begin
	Memo1.Lines.add('tbBalance!');
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


procedure TfrmMain.cbEndpointMuteClick(Sender: TObject);
begin
	CoreAudioMixer.SetEndpointMute(cbEndpointMute.Checked);
end;

procedure TfrmMain.cbSessionMuteClick(Sender: TObject);
begin
	CoreAudioMixer.SetSessionMute(cbSessionMute.Checked);
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


//This is buggy
procedure TfrmMain.buGetBalanceClick(Sender: TObject);
Var
	L,R:Integer;
	L1,R1:Cardinal;
begin
//	tbEndpointBal.OnChange:=nil;
	L:=CoreAudioMixer.GetChannelVolumeLevel(0) ;
	R:=CoreAudioMixer.GetChannelVolumeLevel(1);
	Memo1.Lines.Add('L:' + L.ToString + '  R:' + R.ToString);
	CoreAudioMixer.FEndPointVolume.GetVolumeStepInfo(L1,R1);
	Memo1.Lines.Add('L1:' + L1.ToString + '  R1:' + R1.ToString);

	If L > R then tbEndpointBal.Max:=L else tbEndpointBal.Max:=R;
	tbEndpointBal.Min := tbEndpointBal.Max * -1;
	tbEndpointBal.Position:=R-L;
	laMax.Caption:=tbEndpointBal.Max.ToString;
	Memo1.Lines.Add('L:' + L.ToString + '  R:' + R.ToString);
 //	tbEndpointBal.OnChange:=BalanceOnChange;
end;

procedure TfrmMain.buRenameSessionClick(Sender: TObject);
begin
	CoreAudioMixer.SetSessionName(edSessionName.text);
end;

procedure TfrmMain.Button10Click(Sender: TObject);
begin
	CoreAudioMixer.FreeSessionMixer;
	CoreAudioMixer.FreeEndpointMixer;
	CoreAudioMixer.CreateEndpointMixer;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
	CoreAudioMixer.FEndPointVolume.VolumeStepDown(@AppGuid);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
	CoreAudioMixer.FEndPointVolume.VolumeStepUp(@AppGuid);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
	CoreAudioMixer.SetDefaultDeviceByDevID((Sender as TButton).Caption);
end;

procedure TfrmMain.Button5Click(Sender: TObject);
begin
	Memo1.lines.Add(CoreAudioMixer.GetDefaultDeviceID());
end;

procedure TfrmMain.buRegisterEnpointNotifyClick(Sender: TObject);
begin
	CoreAudioMixer.RegisterEndpointVolumeChange();
end;

procedure TfrmMain.buUnregisterEndpointNotifyClick(Sender: TObject);
begin
	CoreAudioMixer.UnRegisterEndpointVolumeChange();
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
	pbMaster.Position:=CoreAudioMixer.GetMasterPeakValue();
end;


procedure TfrmMain.OnDisplayNameEvent(strNewDisplayName:String; EventContext:TGuid);
begin
	Memo1.Lines.Add('OnDisplayNameEvent - ' + TimeToStr(Now));
	Memo1.Lines.Add('  NewName=' + strNewDisplayName);
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnIconPathEvent(strNewIconPath:String; EventContext:TGuid);
begin
	Memo1.Lines.Add('OnIconPathEvent - ' + TimeToStr(Now));
	Memo1.Lines.Add('  NewPath=' + strNewIconPath);
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnGroupingParamEvent(NewGroupingParam:PGUID; EventContext:TGuid);
begin
	Memo1.Lines.Add('OnGroupingEvent - ' + TimeToStr(Now));
	Memo1.Lines.Add('  NewGroupParam=' + NewGroupingParam.ToString);
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnSessionStateEvent(NewState:TAudioSessionState);
begin
	Memo1.Lines.Add('OnSessionState - ' + TimeToStr(Now));
	Memo1.Lines.Add('  NewState=' + Integer(NewState).ToString );
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnSessionDisconnectedEvent(DisconnectReason:TAudioSessionDisconnectReason);
begin
	Memo1.Lines.Add('OnSessionDisconnect - ' + TimeToStr(Now));
	Memo1.Lines.Add('  Reason=' + Integer(DisconnectReason).ToString) ;
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnDeviceStateChanged(strDeviceId:String; dwNewState:DWORD);
begin
	Memo1.Lines.Add('OnDeviceStateChanged - ' + TimeToStr(Now));
	Memo1.Lines.Add('  DeviceID=' + strDeviceID);
	Memo1.Lines.Add('  NewState=' + dwNewState.ToString);
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnDeviceAdded(strDeviceId:String);
begin
	Memo1.Lines.Add('OnDeviceAdded - ' + TimeToStr(Now));
	Memo1.Lines.Add('  DeviceID=' + strDeviceID);
	Memo1.Lines.Add('');
end;

procedure TfrmMain.OnDeviceRemoved(strDeviceId:String);
begin
	Memo1.Lines.Add('OnDeviceRemoved - ' + TimeToStr(Now));
	Memo1.Lines.Add('  DeviceID=' + strDeviceID);
	Memo1.Lines.Add('');
end;


procedure TfrmMain.OnDefaultDeviceChanged(flow:EDataFlow;role:ERole;strDeviceId:String);
begin
	//if role <> 2 then exit;
	Memo1.Lines.Add('OnDefaultDeviceChanged - ' + TimeToStr(Now));
	Memo1.Lines.Add('  Role=' + IntToStr(role) + ' Flow=' + IntToStr(Flow));
	Memo1.Lines.Add('  OldDefaultDevice=' + CoreAudioMixer.GetDefaultDeviceFriendlyName());
	Memo1.Lines.Add('  NewDefaultDevice=' + strDeviceID);
	Memo1.Lines.Add('');
end;


procedure TfrmMain.OnPropertyValueChanged(strDeviceId:String; key:PROPERTYKEY);
begin
	Memo1.Lines.Add('PropValEvent - ' + TimeToStr(Now));
	Memo1.Lines.Add('  DeviceID=' + strDeviceID);
	Memo1.Lines.Add('');
end;





end.
