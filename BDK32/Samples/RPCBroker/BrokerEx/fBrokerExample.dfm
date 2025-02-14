object frmBrokerExample: TfrmBrokerExample
  Left = 248
  Top = 112
  BorderStyle = bsSingle
  Caption = 'RPCBroker Example UCX RPCBroker (p40)'
  ClientHeight = 389
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBtnText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object GroupBox2: TGroupBox
    Left = 8
    Top = 0
    Width = 457
    Height = 73
    Caption = 'VistA Server'
    TabOrder = 0
    object Label2: TLabel
      Left = 6
      Top = 51
      Width = 67
      Height = 16
      AutoSize = False
      Caption = 'Status:'
    end
    object Label3: TLabel
      Left = 73
      Top = 51
      Width = 88
      Height = 16
      Caption = 'Disconnected'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'System'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object btnConnect: TButton
      Left = 354
      Top = 12
      Width = 91
      Height = 25
      Caption = '&Connect'
      Default = True
      TabOrder = 2
      OnClick = btnConnectClick
    end
    object edtPort: TEdit
      Left = 192
      Top = 24
      Width = 49
      Height = 24
      Hint = 'Listener port number'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '9200'
      OnChange = edtServerChange
    end
    object edtServer: TEdit
      Left = 8
      Top = 24
      Width = 177
      Height = 24
      Hint = 'Name of server or IP address'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = 'BROKERSERVER'
      OnChange = edtServerChange
    end
    object BitBtn1: TBitBtn
      Left = 354
      Top = 44
      Width = 91
      Height = 25
      TabOrder = 3
      Kind = bkClose
    end
    object btnGetServerInfo: TBitBtn
      Left = 248
      Top = 24
      Width = 73
      Height = 25
      Hint = 'GetServerInfo'
      Caption = 'Server'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btnGetServerInfoClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333000000000
        00333FF777777777773F0000FFFFFFFFFF0377773F3F3F3F3F7308880F0F0F0F
        0FF07F33737373737337088880FFFFFFFFF07F3337FFFFFFFFF7088880000000
        00037F3337777777777308888033330F03337F3337F3FF7F7FFF088880300000
        00007F3337F7777777770FFFF030FFFFFFF07F3FF7F7F3FFFFF708008030F000
        00F07F7737F7F77777F70FFFF030F0AAE0F07F3FF7F7F7F337F708008030F0DA
        D0F07F7737F7F7FFF7F70FFFF030F00000F07F33F7F7F77777370FF9F030FFFF
        FFF07F3737F7FFFFFFF70FFFF030000000007FFFF7F777777777000000333333
        3333777777333333333333333333333333333333333333333333}
      NumGlyphs = 2
    end
    object cbxBackwardCompatible: TCheckBox
      Left = 186
      Top = 54
      Width = 161
      Height = 17
      Action = actBackwardCompatible
      State = cbChecked
      TabOrder = 5
    end
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 76
    Width = 457
    Height = 305
    ActivePage = TabSheet1
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Echo string'
      object lblSend: TLabel
        Left = 8
        Top = 24
        Width = 96
        Height = 16
        Caption = 'Original string:'
      end
      object lblReturn: TLabel
        Left = 8
        Top = 144
        Width = 93
        Height = 16
        Caption = 'Echoed string:'
      end
      object edtStrOrig: TEdit
        Left = 8
        Top = 40
        Width = 225
        Height = 24
        TabOrder = 0
        Text = 'Hello World!'
      end
      object edtStrRtrn: TEdit
        Left = 8
        Top = 160
        Width = 225
        Height = 24
        ReadOnly = True
        TabOrder = 1
      end
      object btnEchoString: TButton
        Left = 8
        Top = 88
        Width = 225
        Height = 25
        Hint = 'XWB EXAMPLE ECHO STRING'
        Caption = 'Execute RPC'
        Default = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = btnEchoStringClick
      end
      object Memo1: TMemo
        Left = 240
        Top = 8
        Width = 201
        Height = 257
        TabStop = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'Uses TRPCBroker.Call method '
          'to return a single string.'
          ''
          'Original string passed in as '
          'PType literal.'
          ''
          'RPC: XWB EXAMPLE ECHO '
          'STRING.'
          ''
          'Return Value Type: SINGLE '
          'VALUE.')
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Pass by reference'
      object Label1: TLabel
        Left = 8
        Top = 24
        Width = 70
        Height = 16
        Caption = 'Reference:'
      end
      object Label4: TLabel
        Left = 8
        Top = 144
        Width = 40
        Height = 16
        Caption = 'Value:'
      end
      object edtReference: TEdit
        Left = 8
        Top = 40
        Width = 225
        Height = 24
        TabOrder = 0
        Text = '$HOROLOG'
      end
      object edtValue: TEdit
        Left = 8
        Top = 160
        Width = 225
        Height = 24
        ReadOnly = True
        TabOrder = 1
      end
      object btnPassByRef: TButton
        Left = 8
        Top = 88
        Width = 225
        Height = 25
        Hint = 'XWB GET VARIABLE VALUE'
        Caption = 'Execute RPC'
        Default = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = btnPassByRefClick
      end
      object Memo2: TMemo
        Left = 240
        Top = 8
        Width = 201
        Height = 257
        TabStop = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'Uses TRPCBroker.strCall '
          'method to return a single string.'
          ''
          'Parameter passed in as PType '
          'reference.'
          ''
          'RPC: XWB GET VARIABLE '
          'VALUE.'
          ''
          'Return Value Type: SINGLE '
          'VALUE.')
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        TabOrder = 3
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Get list'
      object Label5: TLabel
        Left = 8
        Top = 120
        Width = 87
        Height = 16
        Caption = 'Returned list:'
      end
      object lstData: TListBox
        Left = 8
        Top = 136
        Width = 225
        Height = 129
        ItemHeight = 16
        TabOrder = 0
      end
      object btnGetList: TButton
        Left = 8
        Top = 88
        Width = 225
        Height = 25
        Hint = 'XWB EXAMPLE GET LIST'
        Caption = 'Execute RPC'
        Default = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnGetListClick
      end
      object RadioButton1: TRadioButton
        Left = 16
        Top = 16
        Width = 137
        Height = 17
        Caption = 'Number of lines'
        Checked = True
        TabOrder = 2
        TabStop = True
      end
      object RadioButton2: TRadioButton
        Left = 16
        Top = 48
        Width = 137
        Height = 17
        Caption = 'Kilobytes of data'
        TabOrder = 3
      end
      object spnLines: TSpinEdit
        Left = 160
        Top = 16
        Width = 65
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 4
        Value = 50
      end
      object spnKbytes: TSpinEdit
        Left = 160
        Top = 48
        Width = 65
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 5
        Value = 32
      end
      object Memo3: TMemo
        Left = 240
        Top = 8
        Width = 201
        Height = 257
        TabStop = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'Uses TRPCBroker.Call method '
          'to return several strings.'
          ''
          'Two parameters passed in as '
          'PType literal.'
          ''
          'RPC: XWB EXAMPLE GET LIST.'
          ''
          'Return Value Type: GLOBAL '
          'ARRAY.'
          ''
          'WORD WRAP ON field is True '
          'to break appart call result into '
          'separate Results strings instead '
          'of one long Results[0] string.')
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        TabOrder = 6
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'WP Text'
      object lblList: TLabel
        Left = 8
        Top = 56
        Width = 177
        Height = 17
        AutoSize = False
        Caption = 'REMOTE PROCEDURE file description:'
      end
      object btnWPText: TButton
        Left = 8
        Top = 16
        Width = 225
        Height = 25
        Hint = 'XWB EXAMPLE WPTEXT'
        Caption = 'Execute RPC'
        Default = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnWPTextClick
      end
      object mmoText: TMemo
        Left = 8
        Top = 80
        Width = 225
        Height = 185
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object Memo4: TMemo
        Left = 240
        Top = 8
        Width = 201
        Height = 257
        TabStop = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'Uses TRPCBroker.lstCall '
          'method to return several strings.'
          ''
          'No parameters are used in this '
          'call.'
          ''
          'RPC: XWB EXAMPLE WPTEXT.'
          ''
          'Return Value Type: WORD '
          'PROCESSING.'
          ''
          'WORD WRAP ON field is False '
          'to allow memo box to control '
          'word wrapping as necessary.')
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        TabOrder = 2
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Sort numbers'
      object Label6: TLabel
        Left = 8
        Top = 120
        Width = 87
        Height = 16
        Caption = 'Returned list:'
      end
      object Label7: TLabel
        Left = 8
        Top = 8
        Width = 72
        Height = 16
        Caption = 'How many:'
      end
      object lblStatus: TLabel
        Left = 8
        Top = 56
        Width = 57
        Height = 16
        Caption = 'lblStatus'
        Visible = False
      end
      object lstSorted: TListBox
        Left = 8
        Top = 136
        Width = 225
        Height = 129
        ItemHeight = 16
        TabOrder = 0
      end
      object btnSortNum: TButton
        Left = 8
        Top = 88
        Width = 225
        Height = 25
        Hint = 'XWB EXAMPLE SORT NUMBERS'
        Caption = 'Execute RPC'
        Default = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnSortNumClick
      end
      object spnNumbers: TSpinEdit
        Left = 8
        Top = 24
        Width = 81
        Height = 26
        MaxValue = 10000
        MinValue = 0
        TabOrder = 2
        Value = 500
      end
      object rgrDirection: TRadioGroup
        Left = 104
        Top = 8
        Width = 121
        Height = 65
        Caption = 'Sort direction'
        ItemIndex = 0
        Items.Strings = (
          'low -> high'
          'high -> low')
        TabOrder = 3
      end
      object Memo5: TMemo
        Left = 240
        Top = 88
        Width = 201
        Height = 177
        TabStop = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 4
      end
      object rgArrayType: TRadioGroup
        Left = 240
        Top = 8
        Width = 185
        Height = 65
        Caption = 'Array Type'
        ItemIndex = 0
        Items.Strings = (
          'Local'
          'Global')
        TabOrder = 5
        OnClick = rgArrayTypeClick
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 160
    Top = 320
    object mnuOptions: TMenuItem
      Caption = '&Options'
      object mnuOptOldConnectionOnly: TMenuItem
        Action = actOldConnectionOnly
        Caption = 'Old Connection Type Only'
      end
      object mnuOptBackwardCompatible: TMenuItem
        Action = actBackwardCompatible
      end
      object mnuOptDebugMode: TMenuItem
        Action = actDebugMode
      end
      object mnuOptUserContext: TMenuItem
        Action = actUserContext
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object AboutExample: TMenuItem
        Caption = '&About RPC Broker Example...'
        OnClick = AboutExampleClick
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 320
  end
  object ActionList1: TActionList
    Left = 52
    Top = 295
    object actBackwardCompatible: TAction
      Caption = '&Backward Compatible'
      Checked = True
      OnExecute = actBackwardCompatibleExecute
    end
    object actOldConnectionOnly: TAction
      Caption = '&Old Connection Only'
      OnExecute = actOldConnectionOnlyExecute
    end
    object actDebugMode: TAction
      Caption = '&Debug Mode'
      OnExecute = actDebugModeExecute
    end
    object actUserContext: TAction
      Caption = '&CCOW User Context'
      Enabled = False
      OnExecute = actUserContextExecute
    end
  end
  object RPCBroker1: TRPCBroker
    ClearParameters = True
    ClearResults = True
    Connected = False
    ListenerPort = 9200
    RpcVersion = '0'
    Server = 'BROKERSERVER'
    KernelLogIn = True
    LogIn.Mode = lmAVCodes
    LogIn.PromptDivision = False
    OldConnectionOnly = False
    Left = 100
    Top = 335
  end
end
