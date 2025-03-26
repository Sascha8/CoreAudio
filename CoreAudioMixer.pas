unit CoreAudioMixer;

{
	MIT License

Copyright (c) 2022-2025 Sascha Ott

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

}

interface

Uses
	Winapi.ActiveX,Windows,propsys,sysUtils,Classes, COMObj,caConsts,CoreAudioI;


type
	TMasterVolumeData = packed record
		guidEventContext  : TGUID;
		bMuted            : Boolean;
		intMasterVolume   : Integer;
		nChannels         : UINT;
		afChannelVolumes  : Array of Integer;
	end;

{$REGION 'Interfaces-Overwrite'}

{AudioEndpoint}
type
	TEndpointVolumeEvent = procedure (pNotify:TMasterVolumeData) of object;
	TNotifyEndpointVolumeEvent=class(TInterfacedObject,IAudioEndpointVolumeCallback)
	private
		FOnEndpointVolumeChange:TEndpointVolumeEvent;
		procedure OnNotify(pNotify: PAudioVolumeNotificationData); safecall;
	Public
	 property OnMasterVolChanged: TEndpointVolumeEvent read FOnEndpointVolumeChange write FOnEndpointVolumeChange;
end;


{AudioSession}
	TSimpleVolumeEvent = procedure (NewVolume:Integer; NewMute:Boolean; EventContext:TGUID)of object;
	TChannelVolumeEvent = procedure (ChannelCount: Integer; NewChannelArray :Array of Integer; ChangedChannel:Integer; EventContext: TGUID) of object;
	TDisplayNameEvent = procedure (strNewDisplayName:String; EventContext:TGuid) of object;
	TIconPathEvent = procedure (strNewIconPath:String; EventContext:TGuid) of object;
	TGroupingParamEvent = procedure (NewGroupingParam:PGUID; EventContext:TGuid)of object;
	TSessionStateEvent = procedure (NewState:TAudioSessionState)of object;
	TSessionDisconnectedEvent = procedure (DisconnectReason:TAudioSessionDisconnectReason) of object;

type
	TAudioSessionEvents =class(TInterfacedObject,IAudioSessionEvents)
	private
		FOnDisplayName:TDisplayNameEvent;
		FOnIconPath:TIconPathEvent;
		FOnSimpleVolume:TSimpleVolumeEvent;
		FOnChannelVolume:TChannelVolumeEvent;
		FOnGroupingParam:TGroupingParamEvent;
		FOnSessionState:TSessionStateEvent;
		FOnSessionDisconnected:TSessionDisconnectedEvent;
		Procedure OnDisplayNameChanged(NewDisplayName:LPCWSTR; EventContext:pGuid);safecall;
		Procedure OnIconPathChanged(NewIconPath:LPCWSTR; EventContext:pGuid); safecall;
		Procedure OnSimpleVolumeChanged(NewVolume:Single; NewMute:LongBool; EventContext:PGuid);safecall;
		Procedure OnChannelVolumeChanged(ChannelCount:UINT; NewChannelArray:Array of Single; ChangedChannel: UINT; EventContext: pGUID); safecall;
		Procedure OnGroupingParamChanged(NewGroupingParam, EventContext:pGuid); safecall;
		Procedure OnStateChanged(NewState:TAudioSessionState); safecall;
		Procedure OnSessionDisconnected(DisconnectReason:TAudioSessionDisconnectReason); safecall;
	Public
		property OnSimpleVol: TSimpleVolumeEvent read FOnSimpleVolume write FOnSimpleVolume;
		property OnChannelVol: TChannelVolumeEvent read FOnChannelVolume write FOnChannelVolume;
		property OnDisplayName: TDisplayNameEvent read FOnDisplayName write FOnDisplayName;
		property OnIconPath: TIconPathEvent read FOnIconPath write FOnIconPath;
		property OnGroupingParam: TGroupingParamEvent read FOnGroupingParam write FOnGroupingParam;
		property OnSessionState: TSessionStateEvent read FOnSessionState write FOnSessionState;
		property OnSessionDisconnectedNotify: TSessionDisconnectedEvent read FOnSessionDisconnected write FOnSessionDisconnected;
end;

{IMMNotificationClient}
	TOnDefaultDeviceChanged = procedure (flow:EDataFlow;role:ERole;strDeviceId:String)of object;
	TOnDeviceAdded					= procedure (strDeviceId:String) of object;
	TOnDeviceRemoved				= procedure (strDeviceId:String) of object;
	TOnDeviceStateChanged		= procedure (strDeviceId:String; dwNewState:DWORD)of object;
	TOnPropertyValueChanged	= procedure (strDeviceId:String; key:PROPERTYKEY)of object;


type
	TIMMNotifyClient=class(TInterfacedObject,IMMNotificationClient)
	Private
		FOnDefaultDeviceChanged:TOnDefaultDeviceChanged;
		FOnDeviceAdded:TOnDeviceAdded;
		FOnDeviceRemoved:TOnDeviceRemoved;
		FOnDeviceStateChanged: TOnDeviceStateChanged;
		FOnPropertyValueChanged:TOnPropertyValueChanged;

		procedure OnDefaultDeviceChanged(flow:EDataFlow;role:ERole;pwstrDeviceId:LPCWSTR); safecall;
		procedure OnDeviceAdded(pwstrDeviceId:LPCWSTR ); safecall;
		procedure OnDeviceRemoved(pwstrDeviceId:LPCWSTR); safecall;
		procedure OnDeviceStateChanged(pwstrDeviceId:LPCWSTR; dwNewState:DWORD); safecall;
		procedure OnPropertyValueChanged(pwstrDeviceId:LPCWSTR; key:PROPERTYKEY); safecall;
	Public
		property OnIMMDefaultDeviceChanged:TOnDefaultDeviceChanged read FOnDefaultDeviceChanged write FOnDefaultDeviceChanged;
		property OnIMMDeviceAdded: TOnDeviceAdded read FOnDeviceAdded write FOnDeviceAdded;
		property OnIMMDeviceRemoved: TOnDeviceRemoved read FOnDeviceRemoved write FOnDeviceRemoved;
		property OnIMMDeviceStateChanged: TOnDeviceStateChanged read FOnDeviceStateChanged write FOnDeviceStateChanged;
		property OnIMMPropertyValueChanged: TOnPropertyValueChanged read FOnPropertyValueChanged write FOnPropertyValueChanged;
end;
{$ENDREGION}

type
	TErrResult=Record
	ErrNum:Integer;
	ErrText:String;
	end;


TCoreAudioMixer = class

private
	FAppGuid:TGuid; 	{ID of the application which a send a volChange to the mixer. Own IDs will be ignored and doesn't generate race conditions}
	FLastOleError:String;
	FAudiometer:IAudioMeterInformation;
	FNotifyEndpointVolumeEvent:TNotifyEndpointVolumeEvent;
	FIMMNotifyClient:TIMMNotifyClient;
	FAudioSessionEvents:TAudioSessionEvents;

	FAudioSessionManager:IAudioSessionManager;
	FSimpleVolume:ISimpleAudioVolume;
	FASessionControl:IAudioSessionControl;

	{Notifications/Events}
	FOnMasterVolChanged:TEndpointVolumeEvent;
	FOnSimpleVol:TSimpleVolumeEvent;
	FOnDisplayName:TDisplayNameEvent;
	FOnIconPath:TIconPathEvent;
	FOnChannelVol:TChannelVolumeEvent;
	FOnGroupingParam:TGroupingParamEvent;
	FOnSessionState:TSessionStateEvent;
	FOnSessionDisconnected:TSessionDisconnectedEvent;

	{IMMNotification (Device Added,Remove,changed)}
	FOnDefaultDeviceChanged:TOnDefaultDeviceChanged;
	FOnDeviceAdded:TOnDeviceAdded;
	FOnDeviceRemoved:TOnDeviceRemoved;
	FOnDeviceStateChanged: TOnDeviceStateChanged;
	FOnPropertyValueChanged:TOnPropertyValueChanged;
public
	FDeviceEnumerator: IMMDeviceEnumerator;
	FDefaultDevice: IMMDevice;
	FEndPointVolume:IAudioEndpointVolume;
	FPolicyConfigClient:IPolicyConfigClient;
	FPolicyConfig:IPolicyConfig;
	FPolicyConfig10_1:IPolicyConfig10_1;

	Constructor Create(AppGuid:TGUID);
	Destructor Destroy;override;
	Procedure CreateEndpointMixer;
	Procedure CreateSessionMixer;
	Procedure FreeEndpointMixer;
	Procedure FreeSessionMixer;
	Function GetEndpointMute:Bool;
	Function GetChannelCount:Cardinal;
	Function GetChannelVolumeLevel(Channel:Cardinal):Integer;
	Procedure SetEndpointMute(Value:Boolean);
	Function GetSessionMute:Bool;
	Procedure SetSessionMute(Value:Bool);
	Function GetMasterVolume:Integer;
	Function GetSessionVolume:Integer;
	Procedure SetMasterVolume(value:Integer);
	Procedure SetBalance(Channel:Cardinal;value:Integer);
	Procedure SetSimpleVolume(value:Integer);
	Procedure GetFriendlyDeviceNames(var slNames:TStringlist);
	Procedure GetFriendlyDeviceNames2(var slNames:TStringlist;DeviceState: TDeviceState);
	Function GetDeviceIDFromFriendlyDeviceName(FriendlyDevName:String):String;
	Function GetDefaultDeviceID():String;
	Function GetDefaultDeviceFriendlyName():String;
	Function SetDefaultDeviceByDevID(devID:String):Boolean;
	Function SetDefaultDeviceByFriendlyName(FriendlyDevName:String):Boolean;
	Function GetMasterPeakValue():Integer;
	Function GetFriendlyName(ID:LPWSTR):String;
	Procedure SetSessionName(strName:String);
	Procedure RegisterEndpointVolumeChange();
	Procedure UnRegisterEndpointVolumeChange();
	Procedure RegisterAudioSessionNotification();
	Procedure UnRegisterAudioSessionNotification();
	Property LastOleError:String read FLastOleError;
	Property AppGUID:TGUID read FAppGuid write FAppGuid;
	property aDeviceEnumerator  : IMMDeviceEnumerator read FDeviceEnumerator;
	property OnMasterVolChanged : TEndpointVolumeEvent read FOnMasterVolChanged write FOnMasterVolChanged;
	property OnSimpleVolChanged : TSimpleVolumeEvent read FOnSimpleVol write FOnSimpleVol;
	property OnChannelVolChanged: TChannelVolumeEvent read FOnChannelVol write FOnChannelVol;
	property OnDisplayName      : TDisplayNameEvent read FOnDisplayName write FOnDisplayName;
	property OnIconPath: TIconPathEvent read FOnIconPath write FOnIconPath;
	property OnGroupingParam: TGroupingParamEvent read FOnGroupingParam write FOnGroupingParam;
	property OnSessionState: TSessionStateEvent read FOnSessionState write FOnSessionState;
	property OnSessionDisconnectedNotify: TSessionDisconnectedEvent read FOnSessionDisconnected write FOnSessionDisconnected;
	property OnIMMDefaultDeviceChanged:TOnDefaultDeviceChanged read FOnDefaultDeviceChanged write FOnDefaultDeviceChanged;
	property OnIMMDeviceStateChanged: TOnDeviceStateChanged read FOnDeviceStateChanged write FOnDeviceStateChanged;
	property OnIMMDeviceAdded: TOnDeviceAdded read FOnDeviceAdded write FOnDeviceAdded;
	property OnIMMDeviceRemoved:TOnDeviceRemoved read FOnDeviceRemoved write FOnDeviceRemoved;
	property OnIMMPropertyValueChanged:TOnPropertyValueChanged read FOnPropertyValueChanged write FOnPropertyValueChanged;
end;



implementation

{$REGION 'TCoreAudioMixer'}

Constructor TCoreAudioMixer.Create(AppGuid:TGUID);
begin
	inherited Create();
	fAppGuid:=AppGuid;
	CoInitializeEx(Nil,COINIT_APARTMENTTHREADED);
end;

Destructor TCoreAudioMixer.Destroy;
begin
	FreeSessionMixer;
	FreeEndpointMixer;
	CoUninitialize();
	inherited Destroy();
end;

Procedure TCoreAudioMixer.CreateEndpointMixer;
var
	HR:HResult;
begin
	FLastOleError:='Try to get DeviceEnumerator';
	HR:=CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, FDeviceEnumerator);
	OleCheck(HR);

	HR:=CoCreateInstance(IID_PolicyConfigClient, nil, CLSCTX_ALL, IID_PolicyConfig, FPolicyConfig);

	// get DefaultDevice
	FLastOleError:='Could not got Endpoint default device! No active ouput device!';
	FDefaultDevice:=FdeviceEnumerator.GetDefaultAudioEndpoint(eRender, eMultimedia);

	// get Audiometer
	FLastOleError:='Could not got Audiometer ';
	FDefaultdevice.Activate(IID_IAudioMeterInformation, CLSCTX_ALL,nil,FAudiometer);

	// activate Endpoint
	FLastOleError:='Could not got activate enpointVolume';
	FDefaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_ALL, nil, FEndpointVolume);

	RegisterEndpointVolumeChange();

	// register notifications for EnpointChanges
	FLastOleError:='Could not register endpoint notification';
	FIMMNotifyClient:=TIMMNotifyClient.Create;
	FDeviceEnumerator.RegisterEndpointNotificationCallback(FIMMNotifyClient);

	FIMMNotifyClient.FOnDefaultDeviceChanged:=OnIMMDefaultDeviceChanged;
	FIMMNotifyClient.FOnDeviceAdded:=OnIMMDeviceAdded;
	FIMMNotifyClient.FOnDeviceRemoved:=OnIMMDeviceRemoved;
	FIMMNotifyClient.FOnDeviceStateChanged:=OnIMMDeviceStateChanged;
	FIMMNotifyClient.FOnPropertyValueChanged:=OnIMMPropertyValueChanged;
End;

Procedure TCoreAudioMixer.RegisterEndpointVolumeChange();
Begin
	//Create listener for MasterVol changes
	If FNotifyEndpointVolumeEvent <> nil then UnRegisterEndpointVolumeChange;
	FLastOleError:='Could not got register controlchange notify';
	FNotifyEndpointVolumeEvent:=TNotifyEndpointVolumeEvent.Create;
	FEndpointVolume.RegisterControlChangeNotify(FNotifyEndpointVolumeEvent);
	FNotifyEndpointVolumeEvent.FOnEndpointVolumeChange:=OnMasterVolChanged;
end;


Procedure TCoreAudioMixer.UnRegisterEndpointVolumeChange();
Begin
	If (FEndPointVolume <> nil) AND (FNotifyEndpointVolumeEvent <> nil) then
	Begin
		FLastOleError:='Could not unregister ControlChangeNotification!';
		FEndpointVolume.unRegisterControlChangeNotify(FNotifyEndpointVolumeEvent);
		FNotifyEndpointVolumeEvent := NIL;
	End;
End;




Procedure TCoreAudioMixer.CreateSessionMixer;
begin
	//----------------- Session mixer ----------------------------
	//Register notifications for AudioSessionEvents
	if FDefaultdevice = nil then Exit;
	FLastOleError:='Could not activate AudioSessionManager';
	FDefaultDevice.Activate(IID_IAudioSessionManager, CLSCTX_INPROC_SERVER, nil, FAudioSessionManager);

	FLastOleError:='Could not got AudioSessionControl';
	FASessionControl:=FAudioSessionManager.GetAudioSessionControl(nil, 0);

	FLastOleError:='Could not got SimpleAudioVolume';
	FSimpleVolume:=FAudioSessionManager.GetSimpleAudioVolume(nil, 0);
	RegisterAudioSessionNotification;
end;


Procedure TCoreAudioMixer.RegisterAudioSessionNotification();
Begin
	UnregisterAudioSessionNotification();
	FLastOleError:='Could not register AudioSessionNotfication';
	FAudioSessionEvents:=TAudioSessionEvents.Create;
	If FASessionControl <> nil then
	Begin
		FASessionControl.RegisterAudioSessionNotification(FAudioSessionEvents);
		FAudioSessionEvents.FOnDisplayName:=OnDisplayName;
		FAudioSessionEvents.FOnIconPath:=OnIconPath;
		FAudioSessionEvents.FOnSimpleVolume:=OnSimpleVolChanged;
		FAudioSessionEvents.FOnChannelVolume:=OnChannelVolChanged;
		FAudioSessionEvents.FOnGroupingParam:=OnGroupingParam;
		FAudioSessionEvents.FOnSessionState:=OnSessionState;
		FAudioSessionEvents.FOnSessionDisconnected:=OnSessionDisconnectedNotify;
	End;
end;

Procedure TCoreAudioMixer.UnregisterAudioSessionNotification();
Begin
	If (FASessionControl <> nil) AND (FAudioSessionEvents <> nil) then
	begin
		FLastOleError:='Could not unregister AudioSessionNotification!';
		FASessionControl.UnregisterAudioSessionNotification(FAudioSessionEvents);
		FAudioSessionEvents:=nil;
	end;
End;


Procedure TCoreAudioMixer.FreeEndpointMixer;
Begin
	If (FEndPointVolume <> nil) AND (FNotifyEndpointVolumeEvent <> nil) then
	Begin
		FLastOleError:='Could not unregister ControlChangeNotification!';
		FEndpointVolume.unRegisterControlChangeNotify(FNotifyEndpointVolumeEvent);

		If (FDeviceEnumerator <> nil) and (FIMMNotifyClient <> nil) then
		begin
			FLastOleError:='Could not unregister EndpointNotificationCallback!';
			FDeviceEnumerator.unRegisterEndpointNotificationCallback(FIMMNotifyClient);
		end;
	End;
	if FIMMNotifyClient <> nil then FreeAndNil(FIMMNotifyClient);
	if FDeviceEnumerator <> nil then FDeviceEnumerator:=nil;
	if FDefaultDevice  <> nil then FDefaultDevice:=nil;
	if FEndPointVolume <> nil then FEndPointVolume:=nil;
	if FPolicyConfig <> nil then 	FPolicyConfig:=NIL;
End;


Procedure TCoreAudioMixer.FreeSessionMixer;
Begin
	UnregisterAudioSessionNotification();
	if FAudioSessionManager     <> nil then FAudioSessionManager:=nil;
	if FASessionControl     <> nil then FASessionControl:=nil;
	if FAudioSessionEvents <> nil then FAudioSessionEvents:=nil;
	if FSimpleVolume   <> nil then FSimpleVolume:=nil;
end;




{===================== Endpoint/Master Routines ===========================}

Function TCoreAudioMixer.GetMasterVolume:Integer;
Begin
	Result:=0;
	if FEndpointvolume = nil then exit;
	Result:=Round(FEndPointVolume.GetMasterVolumeLevelScalar *100);
End;

Function TCoreAudioMixer.GetEndpointMute:Bool;
Begin
	Result:=False;
	if FEndpointvolume = nil then exit;
	Result:=FEndPointVolume.GetMute();
End;

Function TCoreAudioMixer.GetChannelCount:Cardinal;
Begin
	Result:=0;
	if FEndpointvolume = nil then exit;
	Result:=FEndPointVolume.GetChannelCount();
End;

Function TCoreAudioMixer.GetChannelVolumeLevel(Channel:Cardinal):Integer;
Begin
	Result:=0;
	if FEndpointvolume = nil then exit;
	Result:=Round(FEndPointVolume.GetChannelVolumeLevelScalar(Channel)*100);
End;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Procedure TCoreAudioMixer.SetMasterVolume(value:Integer);
Begin
	FEndPointVolume.SetMasterVolumeLevelScalar(value / 100 ,@FAppGUID);
End;

Procedure TCoreAudioMixer.SetEndpointMute(Value:Boolean);
Begin
	FEndPointVolume.SetMute(LongInt(Value),@FAppGUID);
End;

Procedure TCoreAudioMixer.SetBalance(Channel:Cardinal;value:Integer);
Begin
	FEndPointVolume.SetChannelVolumeLevelScalar(Channel,value / 100 ,@FAppGUID);
End;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


{===================== Session Volume Routines ===========================}

Function TCoreAudioMixer.GetSessionVolume:Integer;
Begin
	Result:=0;
	If FSimpleVolume = nil then Exit;
	Result:=Round(FSimpleVolume.GetMasterVolume()*100);
end;

Function TCoreAudioMixer.GetSessionMute:Bool;
Begin
	Result:=False;
	If FSimpleVolume = nil then Exit;
	Result:=FSimpleVolume.GetMute();
End;

Function TCoreAudioMixer.GetMasterPeakValue():Integer;
Begin
	Result:=0;
	If FAudiometer = nil then Exit;
	Result:=Round(FAudiometer.GetPeakValue() *100);
End;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Procedure TCoreAudioMixer.SetSimpleVolume(value:Integer);
Begin
	If FSimpleVolume = nil then Exit;
	FSimpleVolume.SetMasterVolume(Value / 100,@FAppGUID);
end;

Procedure TCoreAudioMixer.SetSessionMute(Value:Bool);
Begin
	If FSimpleVolume = nil then Exit;
	FSimpleVolume.SetMute(Value,@FAppGUID);
end;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Procedure TCoreAudioMixer.SetSessionName(strName:String);
Begin
	If FASessionControl= nil then Exit;
	FASessionControl.SetDisplayName(PWideChar(strName),@FAppGuid);     // March 2025: LPWSTR(strVar) is wrong!
End;

Function TCoreAudioMixer.GetFriendlyName(ID:LPWSTR):String;
Var
	MMDevice:IMMDevice;
	varName:TPropvariant;
	FProps:IPropertyStore;
Begin
	Result:='';

	if ID='' then Exit;
	MMDevice:=FDeviceEnumerator.GetDevice(ID);
	FProps:=MMDevice.OpenPropertyStore(STGM_READ);
	FProps.GetValue(PKEY_Device_FriendlyName,varName);
	result:=String(varName.bstrVal);
	PropVariantClear(varName);
End;

Function TCoreAudioMixer.GetDefaultDeviceID():String;
Var
	ID:LPWSTR;
begin
	ID:=FDefaultDevice.GetId();
	Result:=String(ID);
end;


Function TCoreAudioMixer.GetDefaultDeviceFriendlyName():String;
Var
	varName:TPropvariant;
	FProps:IPropertyStore;
begin
	FProps:=FDefaultDevice.OpenPropertyStore(STGM_READ);
	PropVariantInit(varname);
	FProps.GetValue(PKEY_Device_FriendlyName, varName);
	Result:=String(varName.bstrVal);
	PropVariantClear(varName);
end;





Procedure TCoreAudioMixer.GetFriendlyDeviceNames2(var slNames:TStringlist;DeviceState: TDeviceState);
Var
	devCollection:IMMDeviceCollection;
	count:Cardinal;
	varName:TPropvariant;
	pEndpoint:IMMDevice;
	endPointID:LPWSTR;
	I:Integer;
	str:String;
	FProps:IPropertyStore;
Begin
	if FDeviceEnumerator=nil then Exit;
	devCollection:=FDeviceEnumerator.EnumAudioEndpoints(eRender, Cardinal(DeviceState));
	Count:= devCollection.GetCount();
	PropVariantInit(varname);
	for I:=0 to count-1 do
	Begin
		str:='';
		pEndpoint:= devCollection.Item(i);
		endpointID:=pEndpoint.GetId();
		str:=endpointID;

		FProps:=pEndpoint.OpenPropertyStore(STGM_READ);
		FProps.GetValue(PKEY_Device_FriendlyName,varName);
		if varName.vt <> 0 then str:=str + ' - ' + String(varName.bstrVal);

		FProps.GetValue(PKEY_Device_DeviceDesc,varName);
		if varName.vt <> 0 then str:=str + ' - ' +  String(varName.bstrVal);

		FProps.GetValue(PKEY_Device_EnumeratorName,varName);
		if varName.vt <> 0 then str:=str + ' - ' +  String(varName.bstrVal);

		FProps.GetValue(PKEY_Device_LocationPaths,varName);
		if varName.vt <> 0 then str:=str + ' - ' + String(varName.bstrVal);
		slNames.Add(str);
		CoTaskMemFree(endpointID);
	end;
	PropVariantClear(varName);
End;


// Obsolete - Use above
Procedure TCoreAudioMixer.GetFriendlyDeviceNames(var slNames:TStringlist);
Var
	statemask:Cardinal;
	devCollection:IMMDeviceCollection;
	count:Cardinal;
	varName:TPropvariant;
	pEndpoint:IMMDevice;
	endPointID:LPWSTR;
	I:Integer;
	FProps:IPropertyStore;
Begin
	if FDeviceEnumerator=nil then Exit;
	StateMask:=DEVICE_STATE_ACTIVE;
	devCollection:=FDeviceEnumerator.EnumAudioEndpoints(eRender, StateMask);
	Count:= devCollection.GetCount();
	PropVariantInit(varname);
	for I:=0 to count-1 do
	Begin
		pEndpoint:= devCollection.Item(i);
		endpointID:=pEndpoint.GetId();
		FProps:=pEndpoint.OpenPropertyStore(STGM_READ);
		FProps.GetValue(PKEY_Device_FriendlyName,varName);
		slNames.add(String(varName.bstrVal));
		CoTaskMemFree(endpointID);
	end;
	PropVariantClear(varName);
End;


Function TCoreAudioMixer.GetDeviceIDFromFriendlyDeviceName(FriendlyDevName:String):String;
Var
	statemask:Cardinal;
	devCollection:IMMDeviceCollection;
	count:Cardinal;
	varName:TPropvariant;
	pEndpoint:IMMDevice;
	endPointID:LPWSTR;
	I:Integer;
	FProps:IPropertyStore;
Begin
	if FDeviceEnumerator=nil then Exit;
	StateMask:=DEVICE_STATE_ACTIVE;
	devCollection:=FDeviceEnumerator.EnumAudioEndpoints(eRender, StateMask);
	Count:= devCollection.GetCount();
	PropVariantInit(varname);
	for I:=0 to count-1 do
	Begin
		pEndpoint:= devCollection.Item(i);
		endpointID:=pEndpoint.GetId();
		FProps:=pEndpoint.OpenPropertyStore(STGM_READ);
		FProps.GetValue(PKEY_Device_FriendlyName,varName);
		if String(varName.bstrVal) = FriendlyDevName then
		Begin
			Result:=endPointID;
			CoTaskMemFree(endpointID);
			break;
		End;
		CoTaskMemFree(endpointID);
	end;
	PropVariantClear(varName);
End;

Function TCoreAudioMixer.SetDefaultDeviceByDevID(devID:String):Boolean;
var
	HR:HResult;
Begin
	HR:=FPolicyConfig.SetDefaultEndpoint(PWideChar(devID),eMultimedia);    // March 2025: LPWSTR(strVar) is wrong!
End;

Function TCoreAudioMixer.SetDefaultDeviceByFriendlyName(friendlyDevName:String):Boolean;
var
	HR:HResult;
Begin
	HR:=FPolicyConfig.SetDefaultEndpoint(PWideChar(friendlyDevName),eMultimedia);    // March 2025: LPWSTR(strVar) is wrong!
End;



{===========================================================================================================================================}
{===========================================================================================================================================}
{===========================================================================================================================================}

procedure TNotifyEndpointVolumeEvent.OnNotify(pNotify: PAudioVolumeNotificationData); safecall;
Var
	VolData:TMasterVolumeData;
	p0,p1:Pointer;
	str:String;
Begin
	SetLength(VolData.afChannelVolumes,pNotify.nChannels);
	p0:=@pNotify.afChannelVolumes[0];
	p1:=p0;
	str:=IntToHex(Integer(p0), 8) + #13#10;
	Inc(PSingle(p1),1);
	str:=str + IntToHex(Integer(p1), 8);

	VolData.guidEventContext:=pNotify.guidEventContext;
	VolData.bMuted:=Boolean(pNotify.bMuted);
	VolData.intMasterVolume:=Round(pNotify.fMasterVolume *100);
	VolData.nChannels:=pNotify.nChannels;
	VolData.afChannelVolumes[0]:=Round(pNotify.afChannelVolumes[0] *100);
	VolData.afChannelVolumes[1]:=Round(Single(p1^) *100);
	if assigned(self.OnMasterVolChanged) then OnMasterVolChanged(VolData);
End;


{$REGION 'AudioSessionEvents'}

Procedure TAudioSessionEvents.OnSimpleVolumeChanged(NewVolume:Single; NewMute:LongBool; EventContext:PGuid); safecall;
Begin
	if assigned(self.OnSimpleVol) then OnSimpleVol(Round(NewVolume * 100),NewMute,EventContext^);
End;

Procedure TAudioSessionEvents.OnChannelVolumeChanged(ChannelCount:UINT; NewChannelArray: Array of Single; ChangedChannel: UINT; EventContext: PGUID); safecall;
Begin
End;

Procedure TAudioSessionEvents.OnDisplayNameChanged(NewDisplayName:LPCWSTR; EventContext:pGuid); safecall;
Begin
	if assigned(self.OnDisplayName) then OnDisplayName(NewDisplayName,EventContext^);
End;

Procedure TAudioSessionEvents.OnIconPathChanged(NewIconPath:LPCWSTR; EventContext:pGuid); safecall;
Begin
	if assigned(self.OnIconPath) then OnIconPath(NewIconPath,EventContext^);
End;

Procedure TAudioSessionEvents.OnGroupingParamChanged(NewGroupingParam, EventContext:pGuid); safecall;
Begin
	if assigned(self.OnGroupingParam) then OnGroupingParam(NewGroupingParam,EventContext^);
End;

Procedure TAudioSessionEvents.OnStateChanged(NewState:TAudioSessionState); safecall;
Begin
	if assigned(self.OnSessionState) then OnSessionState(NewState);
End;

Procedure TAudioSessionEvents.OnSessionDisconnected(DisconnectReason:TAudioSessionDisconnectReason); safecall;
Begin
	if assigned(self.OnSessionDisconnectedNotify) then OnSessionDisconnectedNotify(DisconnectReason);
End;

{$ENDREGION}


{$REGION 'NotifyClientEvents'}

Procedure TIMMNotifyClient.OnDefaultDeviceChanged(flow:EDataFlow;role:ERole;pwstrDeviceId:LPCWSTR); safecall;
Begin
	if assigned(self.OnIMMDefaultDeviceChanged) then OnIMMDefaultDeviceChanged(flow,role,pwstrDeviceId);
End;

Procedure TIMMNotifyClient.OnDeviceAdded(pwstrDeviceId:LPCWSTR ); safecall;
Begin
	if assigned(self.OnIMMDeviceAdded) then OnIMMDeviceAdded(pwstrDeviceId);
End;

Procedure TIMMNotifyClient.OnDeviceRemoved(pwstrDeviceId:LPCWSTR); safecall;
Begin
	if assigned(self.OnIMMDeviceRemoved) then OnIMMDeviceRemoved(pwstrDeviceId);
End;


Procedure TIMMNotifyClient.OnDeviceStateChanged(pwstrDeviceId:LPCWSTR; dwNewState:DWORD); safecall;
Begin
	if assigned(self.OnIMMDeviceStateChanged) then OnIMMDeviceStateChanged(pwstrDeviceId,dwNewState);
//	DEVICE_STATE_ACTIVE
//	DEVICE_STATE_DISABLED
//	DEVICE_STATE_NOTPRESENT
//	DEVICE_STATE_UNPLUGGED
//	DEVICE_STATEMASK_ALL
End;

Procedure TIMMNotifyClient.OnPropertyValueChanged(pwstrDeviceId:LPCWSTR; key:PROPERTYKEY); safecall;
Begin
	if assigned(self.OnIMMPropertyValueChanged) then OnIMMPropertyValueChanged(pwstrDeviceId,key);
End;
{$ENDREGION}

end.
