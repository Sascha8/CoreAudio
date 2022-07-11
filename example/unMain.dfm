object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 698
  ClientWidth = 867
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 412
    Width = 867
    Height = 286
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 4
    Top = 8
    Width = 385
    Height = 161
    Caption = ' EndpointVolume '
    TabOrder = 1
    object laMax: TLabel
      Left = 263
      Top = 10
      Width = 28
      Height = 13
      Caption = 'laMax'
    end
    object Label4: TLabel
      Left = 215
      Top = 30
      Width = 7
      Height = 14
      Caption = 'L'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 364
      Top = 30
      Width = 9
      Height = 14
      Caption = 'R'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object laPos: TLabel
      Left = 263
      Top = 60
      Width = 25
      Height = 13
      Caption = 'laPos'
    end
    object laVolPos: TLabel
      Left = 69
      Top = 10
      Width = 39
      Height = 13
      Caption = 'laVolPos'
    end
    object cbEndpointMute: TCheckBox
      Left = 72
      Top = 61
      Width = 56
      Height = 17
      Caption = 'Mute'
      TabOrder = 0
      OnClick = cbEndpointMuteClick
    end
    object tbEndpointBal: TTrackBar
      Left = 228
      Top = 21
      Width = 95
      Height = 33
      Max = 200
      Frequency = 25
      Position = 100
      TabOrder = 1
      TickMarks = tmBoth
      OnChange = tbEndpointBalChange
    end
    object tbEndpointVol: TTrackBar
      Left = 8
      Top = 21
      Width = 169
      Height = 34
      LineSize = 10
      Max = 100
      PageSize = 1
      Frequency = 20
      TabOrder = 2
      TickMarks = tmBoth
      OnChange = tbEndpointVolChange
    end
    object buRegisterEnpointNotify: TButton
      Left = 8
      Top = 100
      Width = 180
      Height = 27
      Caption = 'Register EndpointVolumeChange'
      TabOrder = 3
      OnClick = buRegisterEnpointNotifyClick
    end
    object buUnregisterEndpointNotify: TButton
      Left = 8
      Top = 128
      Width = 180
      Height = 27
      Caption = 'UnRegister EndpointVolumeChange'
      TabOrder = 4
      OnClick = buUnregisterEndpointNotifyClick
    end
    object buGetBalance: TButton
      Left = 242
      Top = 80
      Width = 75
      Height = 25
      Caption = 'Get Balance'
      TabOrder = 5
      OnClick = buGetBalanceClick
    end
  end
  object GroupBox5: TGroupBox
    Left = 395
    Top = 8
    Width = 330
    Height = 207
    Caption = ' AudioSessionVolume '
    TabOrder = 2
    object tbSessionVol: TTrackBar
      Left = 10
      Top = 15
      Width = 293
      Height = 40
      Max = 100
      PageSize = 1
      Frequency = 10
      TabOrder = 0
      TickMarks = tmBoth
      OnChange = tbSessionVolChange
    end
    object cbSessionMute: TCheckBox
      Left = 146
      Top = 61
      Width = 56
      Height = 17
      Caption = 'Mute'
      TabOrder = 1
      OnClick = cbSessionMuteClick
    end
    object buRegisterNotification: TButton
      Left = 8
      Top = 89
      Width = 119
      Height = 25
      Caption = 'RegisterNotification'
      TabOrder = 2
      OnClick = buRegisterNotificationClick
    end
    object buUnregisterNotification: TButton
      Left = 138
      Top = 89
      Width = 123
      Height = 25
      Caption = 'UnregisterNotification'
      TabOrder = 3
      OnClick = buUnregisterNotificationClick
    end
    object buRemoveSessionControl: TButton
      Left = 10
      Top = 120
      Width = 129
      Height = 25
      Caption = 'RemoveSessionControl'
      TabOrder = 4
      OnClick = buRemoveSessionControlClick
    end
    object buRenameSession: TButton
      Left = 11
      Top = 163
      Width = 104
      Height = 25
      Caption = 'Rename session to'
      TabOrder = 5
      OnClick = buRenameSessionClick
    end
    object edSessionName: TEdit
      Left = 121
      Top = 165
      Width = 200
      Height = 21
      TabOrder = 6
      Text = 'edSessionName'
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 175
    Width = 363
    Height = 200
    Caption = 'DeviceCollection'
    TabOrder = 3
    object buGetFriendlyName: TButton
      Left = 119
      Top = 154
      Width = 109
      Height = 25
      Caption = 'Get friendly names'
      TabOrder = 0
      OnClick = buGetFriendlyNameClick
    end
    object GroupBox2: TGroupBox
      Left = 184
      Top = 38
      Width = 161
      Height = 81
      Caption = 'Input/Output device'
      Enabled = False
      TabOrder = 1
      object rbAll: TRadioButton
        Left = 8
        Top = 56
        Width = 97
        Height = 17
        Caption = 'All devices'
        TabOrder = 0
      end
      object rbCapture: TRadioButton
        Left = 8
        Top = 39
        Width = 145
        Height = 17
        Caption = 'Capture devices (Input)'
        TabOrder = 1
        TabStop = True
      end
      object rbRender: TRadioButton
        Left = 8
        Top = 20
        Width = 145
        Height = 17
        Caption = 'Render devices (Output)'
        Checked = True
        TabOrder = 2
        TabStop = True
      end
    end
    object GroupBox3: TGroupBox
      Left = 9
      Top = 26
      Width = 169
      Height = 109
      Caption = 'Device state'
      TabOrder = 2
      object cbActiveEP: TRadioButton
        Left = 10
        Top = 18
        Width = 97
        Height = 17
        Caption = 'Active endpoints'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object cbAllEP: TRadioButton
        Left = 10
        Top = 87
        Width = 97
        Height = 17
        Caption = 'All endpoints'
        TabOrder = 1
      end
      object cbDisabledEP: TRadioButton
        Left = 10
        Top = 35
        Width = 109
        Height = 17
        Caption = 'Disabled endpoints'
        TabOrder = 2
        TabStop = True
      end
      object cbNotPresentEP: TRadioButton
        Left = 10
        Top = 52
        Width = 137
        Height = 17
        Caption = 'Not present endpoints'
        TabOrder = 3
        TabStop = True
      end
      object cbUnpluggedEP: TRadioButton
        Left = 10
        Top = 69
        Width = 129
        Height = 17
        Caption = 'Unplugged endpoints'
        TabOrder = 4
        TabStop = True
      end
    end
  end
  object pbMaster: TProgressBar
    Left = 412
    Top = 316
    Width = 357
    Height = 17
    Step = 1
    TabOrder = 4
  end
  object Button1: TButton
    Left = 528
    Top = 360
    Width = 75
    Height = 25
    Caption = '1'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 623
    Top = 360
    Width = 75
    Height = 25
    Caption = '50'
    TabOrder = 6
    OnClick = Button2Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 590
    Top = 404
  end
end
