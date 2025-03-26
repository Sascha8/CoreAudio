Unit caConsts;
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

uses
	Windows, ActiveX;

Const
	PKEY_Device_DeviceDesc:TPropertyKey			= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:2);
	PKEY_Device_HardwareIds:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:3);
	PKEY_Device_CompatibleIds:TPropertyKey	= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:4);
	PKEY_Device_Service:TPropertyKey				= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:6);
	PKEY_Device_Class:TPropertyKey					= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:9);
	PKEY_Device_ClassGuid:TPropertyKey			= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:10);
	PKEY_Device_Driver:TPropertyKey					= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:11);
	PKEY_Device_ConfigFlags:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:12);
	PKEY_Device_Manufacturer:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:13);
	PKEY_Device_FriendlyName:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:14);
	PKEY_Device_LocationInfo:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:15);
	PKEY_Device_PDOName:TPropertyKey				= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:16);
	PKEY_Device_Capabilities:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:17);
	PKEY_Device_UINumber:TPropertyKey				= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:18);
	PKEY_Device_UpperFilters:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:19);
	PKEY_Device_LowerFilters:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:20);
	PKEY_Device_BusTypeGuid:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:21);
	PKEY_Device_LegacyBusType:TPropertyKey	= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:22);
	PKEY_Device_BusNumber:TPropertyKey			= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:23);
	PKEY_Device_EnumeratorName:TPropertyKey = (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:24);
	PKEY_Device_Security:TPropertyKey				= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:25);
	PKEY_Device_SecuritySDS:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:26);
	PKEY_Device_DevType:TPropertyKey				= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:27);
	PKEY_Device_Exclusive:TPropertyKey			= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:28);
	PKEY_Device_Address:TPropertyKey				= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:30);
	PKEY_Device_PowerData:TPropertyKey			= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:32);
	PKEY_Device_RemovalPolicy:TPropertyKey	= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:33);
	PKEY_Device_InstallState:TPropertyKey		= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:36);
	PKEY_Device_LocationPaths:TPropertyKey	= (fmtid:(D1:$a45c254e; D2:$df1c; D3:$4efd; D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:37);


	DEVICE_STATE_ACTIVE                   = $00000001;
	DEVICE_STATE_DISABLED                 = $00000002;
	DEVICE_STATE_NOTPRESENT               = $00000004;
	DEVICE_STATE_UNPLUGGED                = $00000008;
	DEVICE_STATEMASK_ALL                  = $0000000F;

	eRender                               = 0;
	eCapture                              = eRender + 1;
	eAll                                  = eCapture + 1;
	EDataFlow_enum_count                  = eAll + 1;

	eConsole                              = 0;
	eMultimedia                           = eConsole + 1;
	eCommunications                       = eMultimedia + 1;
	ERole_enum_count                      = eCommunications + 1;

type
	TDeviceState =(
  	dsActive 			= DEVICE_STATE_ACTIVE,
	  dsDisabled 		= DEVICE_STATE_DISABLED,
		dsNotPresent = DEVICE_STATE_NOTPRESENT,
		dsUnplugged   = DEVICE_STATE_UNPLUGGED,
		dsAll         = DEVICE_STATEMASK_ALL);

type
	__MIDL___MIDL_itf_mmdeviceapi_0000_0000_0002 = TOleEnum;
	ERole = __MIDL___MIDL_itf_mmdeviceapi_0000_0000_0002;

	__MIDL___MIDL_itf_mmdeviceapi_0000_0000_0001 = TOleEnum;
	EDataFlow = __MIDL___MIDL_itf_mmdeviceapi_0000_0000_0001;


type
	PAUDIO_VOLUME_NOTIFICATION_DATA = ^AUDIO_VOLUME_NOTIFICATION_DATA;
	AUDIO_VOLUME_NOTIFICATION_DATA = packed record
		guidEventContext  : TGUID;
		bMuted            : BOOL;
		fMasterVolume     : Single;
		nChannels         : UINT;
		afChannelVolumes  : array[0..0] of Single;
	end;
	TAudioVolumeNotificationData = AUDIO_VOLUME_NOTIFICATION_DATA;
	PAudioVolumeNotificationData = PAUDIO_VOLUME_NOTIFICATION_DATA;

type
	AudioSessionState = (AudioSessionStateInactive, AudioSessionStateActive,AudioSessionStateExpired);
	TAudioSessionState = AudioSessionState;

type
	AUDCLNT_SHAREMODE  = (AUDCLNT_SHAREMODE_SHARED, AUDCLNT_SHAREMODE_EXCLUSIVE);
	TAudClntShareMode  = AUDCLNT_SHAREMODE;

type
	REFERENCE_TIME                        = LONGLONG;
	TReferenceTime                        = REFERENCE_TIME;
	LPREFERENCE_TIME                      = ^REFERENCE_TIME;
	PReferenceTime                        = LPREFERENCE_TIME;
	MUSIC_TIME                            = Longint;

type
	AudioSessionDisconnectReason =(
	DisconnectReasonDeviceRemoval         = 0,
	DisconnectReasonServerShutdown        = DisconnectReasonDeviceRemoval + 1,
	DisconnectReasonFormatChanged         = DisconnectReasonServerShutdown + 1,
	DisconnectReasonSessionLogoff         = DisconnectReasonFormatChanged + 1,
	DisconnectReasonSessionDisconnected   = DisconnectReasonSessionLogoff + 1,
	DisconnectReasonExclusiveModeOverride = DisconnectReasonSessionDisconnected + 1);

	TAudioSessionDisconnectReason = AudioSessionDisconnectReason;



implementation

end.