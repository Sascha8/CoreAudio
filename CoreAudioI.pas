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

Unit CoreAudioI;

interface


uses Windows,caConsts,PropSys,MMSystem, ActiveX;



const
	CLASS_IMMDeviceEnumerator             : TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
	IID_IMMDeviceEnumerator               : TGUID = '{A95664D2-9614-4F35-A746-DE8DB63617E6}';
	IID_IMMDeviceCollection               : TGUID = '{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}';
	IID_IMMEndpoint                       : TGUID = '{1BE09788-6894-4089-8586-9A2A6C265AC5}';
	IID_IAudioEndpointVolume              : TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';
	IID_IAudioEndpointVolumeCallback      : TGUID = '{657804FA-D6AD-4496-8A60-352752AF4F89}';
	IID_IMMNotificationClient             : TGUID = '{7991EEC9-7E89-4D85-8390-6C703CEC60C0}';
	IID_IMMDevice                         : TGUID = '{D666063F-1587-4E43-81F1-B948E807363F}';
	IID_ISimpleAudioVolume                : TGUID = '{87CE5498-68D6-44E5-9215-6DA47EF883D8}';
	IID_IAudioClient                      : TGUID = '{1CB9AD4C-DBFA-4c32-B178-C2F568A703B2}';
	IID_IAudioSessionEnumerator           : TGUID = '{E2F5BB11-0570-40CA-ACDD-3AA01277DEE8}';
	IID_IAudioSessionManager              : TGUID = '{BFA971F1-4D5E-40BB-935E-967039BFBEE4}';
	IID_IAudioSessionManager2             : TGUID = '{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}';
	IID_IAudioSessionEvents               : TGUID = '{24918ACC-64B3-37C1-8CA9-74A66E9957A8}';
	IID_IAudioSessionNotification         : TGUID = '{641DD20B-4D41-49CC-ABA3-174B9477BB08}';
	IID_IAudioSessionControl              : TGUID = '{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}';
	IID_IAudioSessionControl2             : TGUID = '{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}';
	IID_IAudioMeterInformation            : TGUID = '{C02216F6-8C67-4B5B-9D00-D008E73E0064}';

	IID_PolicyConfigClient								: TGUID = '{870AF99C-171D-4F9E-AF0D-E63DF40C2BC9}';
	IID_PolicyConfig											: TGUID = '{f8679f50-850a-41cf-9c72-430f290290c8}';
	IID_PolicyConfig10_1									: TGUID = '{00000000-0000-0000-C000-000000000046}';


Type
	IPolicyConfigClient = interface(IUnknown) [IID_PolicyConfigClient]
	Function GetMixFormat(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetDeviceFormat(pszDeviceName:LPCWSTR; bDefault:Bool; Format:PWaveFormat): DWORD; safecall;
	Function ResetDeviceFormat(pszDeviceName:LPCWSTR): DWORD; safecall;
	Function SetDeviceFormat(pszDeviceName:LPCWSTR; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function GetProcessingPeriod(pszDeviceName:LPCWSTR; bDefault:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetProcessingPeriod(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetShareMode(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function SetShareMode(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetPropertyValue(pszDeviceName:LPCWSTR; bFxStore:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetPropertyValue(pszDeviceName:LPCWSTR; bFxStore:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetDefaultEndpoint(pszDeviceName:LPCWSTR; role:ERole): DWORD; safecall;
	Function SetEndpointVisibility(pszDeviceName:LPCWSTR; bVisible:Bool): DWORD; safecall;
end;


Type
	IPolicyConfig10_1 = interface(IUnknown) [IID_PolicyConfig10_1]
	Function GetMixFormat(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetDeviceFormat(pszDeviceName:LPCWSTR; bDefault:Bool; Format:PWaveFormat): DWORD; safecall;
	Function ResetDeviceFormat(pszDeviceName:LPCWSTR): DWORD; safecall;
	Function SetDeviceFormat(pszDeviceName:LPCWSTR; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function GetProcessingPeriod(pszDeviceName:LPCWSTR; bDefault:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetProcessingPeriod(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetShareMode(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function SetShareMode(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetPropertyValue(pszDeviceName:LPCWSTR; bFxStore:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetPropertyValue(pszDeviceName:LPCWSTR; bFxStore:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetDefaultEndpoint(pszDeviceName:LPCWSTR; role:ERole): DWORD; safecall;
	Function SetEndpointVisibility(pszDeviceName:LPCWSTR; bVisible:Bool): DWORD; safecall;
end;

Type
	IPolicyConfig = interface(IUnknown) [IID_PolicyConfig]
	Function GetMixFormat(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetDeviceFormat(pszDeviceName:LPCWSTR; bDefault:Bool; Format:PWaveFormat): DWORD; safecall;
	Function ResetDeviceFormat(pszDeviceName:LPCWSTR): DWORD; safecall;
	Function SetDeviceFormat(pszDeviceName:LPCWSTR; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function GetProcessingPeriod(pszDeviceName:LPCWSTR; bDefault:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetProcessingPeriod(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetShareMode(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function SetShareMode(pszDeviceName:LPCWSTR; Format:PWaveFormatEx): DWORD; safecall;
	Function GetPropertyValue(pszDeviceName:LPCWSTR; bFxStore:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetPropertyValue(pszDeviceName:LPCWSTR; bFxStore:Bool; Format:PWaveFormatEx; Format2:PWaveFormatEx): DWORD; safecall;
	Function SetDefaultEndpoint(pszDeviceName:LPCWSTR; role:ERole): DWORD; safecall;
	Function SetEndpointVisibility(pszDeviceName:LPCWSTR; bVisible:Bool): DWORD; safecall;
end;


Type
	IMMDevice = interface(IUnknown) [IID_IMMDevice]
	procedure Activate(const iid: TGUID; dwClsCtx: DWORD; pActivationParams: PPropVariant; out ppInterface); safecall;
	function OpenPropertyStore(stgmAccess: DWORD): IPropertyStore; safecall;
	function GetId: LPWSTR; safecall;
	function GetState: DWORD; safecall;
end;

Type
	IAudioClient = interface(IUnknown) [IID_IAudioClient]
	procedure Initialize(ShareMode : TAudClntShareMode; StreamFlags: DWORD; hnsBufferDuration : TReferenceTime; hnsPeriodicity: TReferenceTime; const pFormat: PWaveFormatEx; AudioSessionGuid  : PGUID); safecall;
	function GetBufferSize: UINT32; safecall;
	function GetStreamLatency: TReferenceTime; safecall;
	function GetCurrentPadding: UINT; safecall;
	procedure IsFormatSupported(ShareMode : TAudClntShareMode; const pFormat: PWaveFormatEx; out ppClosestMatch : PWaveFormatEx); safecall;
	procedure GetMixFormat(out ppDeviceFormat: PWaveFormatEx); safecall;
	procedure GetDevicePeriod(out phnsDefaultDevicePeriod: TReferenceTime; out phnsMinimumDevicePeriod: TReferenceTime); safecall;
	procedure Start; safecall;
	procedure Stop; safecall;
	procedure Reset; safecall;
	procedure SetEventHandle(eventHandle: THandle); safecall;
	procedure GetService(const riid: TGUID; out ppv); safecall;
end;

Type
	ISimpleAudioVolume = interface(IUnknown) [IID_ISimpleAudioVolume]
	procedure SetMasterVolume(fLevel: Single; EventContext: PGUID); safecall;
	function GetMasterVolume: Single; safecall;
	procedure SetMute(bMute: Bool; EventContext: PGUID); safecall;
	function GetMute: BOOL; safecall;
end;

Type
	IAudioEndpointVolumeCallback = interface(IUnknown) [IID_IAudioEndpointVolumeCallback]
	procedure OnNotify(pNotify: PAudioVolumeNotificationData); safecall;
end;


Type
	IAudioEndpointVolume = interface(IUnknown) [IID_IAudioEndpointVolume]
	procedure RegisterControlChangeNotify(pNotify: IAudioEndpointVolumeCallback); safecall;
	procedure UnregisterControlChangeNotify(pNotify: IAudioEndpointVolumeCallback); safecall;
	function GetChannelCount: UINT; safecall;
	procedure SetMasterVolumeLevel(fLevelDB: Single; pguidEventContext: PGUID); safecall;
	procedure SetMasterVolumeLevelScalar(fLevel: Single; pguidEventContext: PGUID); safecall;
	function GetMasterVolumeLevel: Single; safecall;
	function GetMasterVolumeLevelScalar: Single; safecall;
	procedure SetChannelVolumeLevel(nChannel: UINT; fLevelDB: Single; pguidEventContext: PGUID); safecall;
	procedure SetChannelVolumeLevelScalar(nChannel: UINT; fLevel: Single; pguidEventContext: PGUID); safecall;

	function GetChannelVolumeLevel(nChannel: UINT): Single; safecall;
	function GetChannelVolumeLevelScalar(nChannel: UINT): Single; safecall;
	procedure SetMute(bMute: LongInt; pguidEventContext: PGUID); safecall;
	function GetMute: BOOL; safecall;
	procedure GetVolumeStepInfo(out pnStep: UINT; out pnStepCount: UINT); safecall;
	procedure VolumeStepUp(pguidEventContext: PGUID); safecall;
	procedure VolumeStepDown(pguidEventContext: PGUID); safecall;
	function QueryHardwareSupport: UINT; safecall;
	procedure GetVolumeRange(out pflVolumeMindB: Single; out pflVolumeMaxdB: Single; out pflVolumeIncrementdB: Single); safecall;
end;

Type
	IAudioMeterInformation = interface(IUnknown) [IID_IAudioMeterInformation]
	function GetPeakValue: Single; safecall;
	function GetMeteringChannelCount: UINT; safecall;
	function GetChannelsPeakValues(u32ChannelCount: UINT32): Single; safecall;
	function QueryHardwareSupport: DWORD; safecall;
end;

Type
	IAudioSessionEvents = interface(IUnknown)	[IID_IAudioSessionEvents]
	procedure OnDisplayNameChanged(NewDisplayName: LPCWSTR; EventContext: PGUID); safecall;
	procedure OnIconPathChanged(NewIconPath: LPCWSTR; EventContext: PGUID); safecall;
	procedure OnSimpleVolumeChanged(NewVolume: Single; NewMute : BOOL; EventContext : PGUID); safecall;
	procedure OnChannelVolumeChanged(ChannelCount :UINT; NewChannelArray: Array of Single; ChangedChannel:UINT; EventContext: PGUID); safecall;
	procedure OnGroupingParamChanged(NewGroupingParam, EventContext: PGUID); safecall;
	procedure OnStateChanged(NewState: TAudioSessionState); safecall;
	procedure OnSessionDisconnected(DisconnectReason: TAudioSessionDisconnectReason); safecall;
end;


Type
	IAudioSessionControl = interface(IUnknown) [IID_IAudioSessionControl]
	function GetState: TAudioSessionState; safecall;
	function GetDisplayName: LPWSTR; safecall;
	procedure SetDisplayName(Value: LPCWSTR; EventContext: PGUID); safecall;
	function GetIconPath: LPWSTR; safecall;
	procedure SetIconPath(Value: LPCWSTR; EventContext: PGUID); safecall;
	function GetGroupingParam: PGUID; safecall;
	procedure SetGroupingParam(OverrideValue, EventContext: PGUID); safecall;
	procedure RegisterAudioSessionNotification(const NewNotifications: IAudioSessionEvents); safecall;
	procedure UnregisterAudioSessionNotification(const NewNotifications: IAudioSessionEvents); safecall;
end;

Type
	IAudioSessionControl2 = interface(IAudioSessionControl) [IID_IAudioSessionControl2]
	Function GetState(out state:TAudioSessionState): HRESULT; stdcall;
	Function GetDisplayName(Name:LPCWSTR): HRESULT; stdcall;
	Function SetDisplayName(value:LPCWSTR; EventContext:PGUID): HRESULT; stdcall;
	Function GetIconPath([Out(), MarshalAs(UnmanagedType.LPWStr)] out  Path:string): HRESULT; stdcall;
	Function SetIconPath([MarshalAs(UnmanagedType.LPWStr)]  Value:string; EventContext:PGUID): HRESULT; stdcall;
	Function GetGroupingParam(out GroupingParam:PGuid): HRESULT; stdcall;
	Function SetGroupingParam(Override_:PGuid; Eventcontext:PGuid): HRESULT; stdcall;
	Function RegisterAudioSessionNotification(NewNotifications:IAudioSessionEvents ): HRESULT; stdcall;
	Function UnregisterAudioSessionNotification(NewNotifications:IAudioSessionEvents ): HRESULT; stdcall;
	function GetSessionIdentifier: LPWSTR; safecall;
	function GetSessionInstanceIdentifier: LPWSTR; safecall;
	function GetProcessId: DWORD; safecall;
	function IsSystemSoundsSession: Bool; safecall;
	procedure SetDuckingPreference(optOut: Longint); safecall;
end;

Type
	IAudioSessionEnumerator = interface(IUnknown) [IID_IAudioSessionEnumerator]
	function GetCount(out SessionCount:Integer):HRESULT;stdcall;
	Function GetSession(SessionCount:Integer; out Session:IAudioSessionControl2 ):HRESULT;stdcall;
end;

Type
	IAudioSessionNotification = interface(IUnknown)	[IID_IAudioSessionNotification]
	Function OnSessionCreated(NewSession:IAudioSessionControl2):HRESULT;stdcall;
end;


Type
	IAudioSessionManager2 = interface(IUnknown) [IID_IAudioSessionManager2]
	function GetAudioSessionControl(AudioSessionGuid:PGUID; StreamFlags:UINT; out ISessionControl:IAudioSessionControl2):HRESULT;stdcall;
	function GetSimpleAudioVolume(AudioSessionGuid:PGUID; StreamFlags:UINT; out SimpleAudioVolume:ISimpleAudioVolume ):HRESULT;stdcall;
	function GetSessionEnumerator(out SessionEnum:IAudioSessionEnumerator ):HRESULT;stdcall;
	function RegisterSessionNotification(SessionNotification:IAudioSessionNotification):HRESULT;stdcall;
	function UnregisterSessionNotification(SessionNotification:IAudioSessionNotification):HRESULT;stdcall;
	function RegisterDuckNotification(sessionID:string; IAudioVolumeDuckNotification:IAudioSessionNotification):HRESULT;stdcall;
	function UnregisterDuckNotification(IAudioVolumeDuckNotification:IntPtr):HRESULT;stdcall;
end;


Type
	IMMDeviceCollection = interface(IUnknown) [IID_IMMDeviceCollection]
	function GetCount: UINT; safecall;
	function Item(nDevice: UINT): IMMDevice; safecall;
end;

Type
	IMMNotificationClient = interface(IUnknown)  [IID_IMMNotificationClient]
	procedure OnDeviceStateChanged(pwstrDeviceId: LPCWSTR; dwNewState: DWORD); safecall;
	procedure OnDeviceAdded(pwstrDeviceId: LPCWSTR); safecall;
	procedure OnDeviceRemoved(pwstrDeviceId: LPCWSTR); safecall;
	procedure OnDefaultDeviceChanged(flow: EDataFlow; role: ERole; pwstrDeviceId: LPCWSTR); safecall;
	procedure OnPropertyValueChanged(pwstrDeviceId: LPCWSTR; key: PROPERTYKEY); safecall;
end;

Type
	IMMDeviceEnumerator = interface(IUnknown)	[IID_IMMDeviceEnumerator]
	function EnumAudioEndpoints(dataFlow: EDataFlow; dwStateMask: DWORD): IMMDeviceCollection; safecall;
	function GetDefaultAudioEndpoint(dataFlow: EDataFlow; role: ERole): IMMDevice; safecall;
	function GetDevice(pwstrId: LPCWSTR): IMMDevice; safecall;
	procedure RegisterEndpointNotificationCallback(const pClient: IMMNotificationClient); safecall;
	procedure UnregisterEndpointNotificationCallback(const pClient: IMMNotificationClient); safecall;
end;

Type
	IMMEndpoint = interface(IUnknown)[IID_IMMEndpoint]
	function GetDataFlow: EDataFlow; safecall;
end;



Type
	IAudioSessionManager = interface(IUnknown) [IID_IAudioSessionManager]
	function GetAudioSessionControl(AudioSessionGuid: PGUID; StreamFlag : UINT): IAudioSessionControl; safecall;
	function GetSimpleAudioVolume(AudioSessionGuid: PGUID; StreamFlag: UINT): ISimpleAudioVolume; safecall;
end;



implementation

end.

