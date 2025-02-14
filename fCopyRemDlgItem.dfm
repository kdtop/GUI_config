object frmCopyRemDlgItem: TfrmCopyRemDlgItem
  Left = 0
  Top = 0
  Caption = 'Copy Reminder Dialog Item'
  ClientHeight = 354
  ClientWidth = 434
  Color = clBtnFace
  Constraints.MinWidth = 430
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    434
    354)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 8
    Width = 46
    Height = 26
    Alignment = taRightJustify
    Caption = 'Source Element'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 119
    Top = 46
    Width = 248
    Height = 14
    Caption = 'Enter Namespace Prefix for Copy (2-4 letters)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 25
    Top = 42
    Width = 33
    Height = 26
    Alignment = taRightJustify
    Caption = 'New Prefix'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object lblCopyChildDescription: TLabel
    Left = 64
    Top = 133
    Width = 362
    Height = 14
    Caption = 'Will also copy descendant items below.  Uncheck to prevent copy.'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblCopyChild: TLabel
    Left = 24
    Top = 152
    Width = 34
    Height = 26
    Alignment = taRightJustify
    Caption = 'Child Items'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label6: TLabel
    Left = 26
    Top = 72
    Width = 32
    Height = 26
    Alignment = taRightJustify
    Caption = 'New Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object lblWorking: TLabel
    Left = 8
    Top = 327
    Width = 76
    Height = 19
    Anchors = [akLeft, akBottom]
    Caption = 'Working...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
    ExplicitTop = 308
  end
  object Label4: TLabel
    Left = 12
    Top = 106
    Width = 46
    Height = 13
    Alignment = taRightJustify
    Caption = 'Sponsor'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object edtSource: TEdit
    Left = 64
    Top = 8
    Width = 362
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 0
  end
  object edtNamespace: TEdit
    Left = 64
    Top = 44
    Width = 49
    Height = 21
    Color = clYellow
    TabOrder = 1
    Text = 'ZZ'
    OnChange = edtNamespaceChange
    OnClick = edtNamespaceClick
  end
  object btnCancel: TBitBtn
    Left = 170
    Top = 311
    Width = 100
    Height = 35
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FF000288010893010B99010C99010893000389FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000186010D9D021CAF021FB402
      1FB5021FB5021FB2021CB0010F9F000287FF00FFFF00FFFF00FFFF00FFFF00FF
      00038A0118B2021FB7021EB1021DB1021DB1021DB1021DB1021EB2021FB40219
      AC00048EFF00FFFF00FFFF00FF0001830118BB0220CC011CBF0015B4011AB002
      1DB1021DB1011CB00015AD011BB0021FB4021AAC000287FF00FFFF00FF010CA7
      0121E0011CD30726CC4966D70B28BC0018B00019AF0622B44A66CE0D2BB7011B
      B0021FB5010F9FFF00FF000187011CDC0120ED0017DC3655E2FFFFFFA4B4ED05
      20BB0119B28B9EE1FFFFFF4E6ACF0014AC021EB2021CB000038900069A0120F8
      011FF6001DE9031FE1738BEEFFFFFFA0B1ED93A5E7FFFFFF91A4E20823B4011B
      B0021DB1021FB4010895020CAA0A2EFE0323FB011FF6001CEB0018E1788FF0FF
      FFFFFFFFFF96A7EA021BB50019AF021DB1021DB10220B5010C99040EAC294DFE
      0D30FB011FFA001CF7011CEE8EA1F4FFFFFFFFFFFFA6B6EE0520C20018B6021D
      B1021DB10220B5010B980208A04162FB2F51FC001EFA0725FA8AA0FEFFFFFF8E
      A3F67991F2FFFFFFA3B4EE0C29C6011BB8021DB4021FB2000793000189314FEF
      7690FF0F2DFA3354FBFFFFFF91A5FE021EF30017E7738BF3FFFFFF4765E00016
      C2021FBD021CB2000288FF00FF0C1BBC819AFF728BFE1134FA3456FB0526FA00
      1CFA001CF40220ED3353ED0625DA011DD00220CB010DA1FF00FFFF00FF000189
      2943E6A5B7FF849AFC2341FB0323FA011FFA011FFA001EF7011BEE021FE50121
      E20118BF000184FF00FFFF00FFFF00FF01038F2A45E693A9FFABBBFF758FFE49
      69FC3658FB3153FC2346FC092CF70118CB00038BFF00FFFF00FFFF00FFFF00FF
      FF00FF0001890F1DBF3E5BF36B87FE728CFF5E7BFE395BFB1231EB010FB50001
      84FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000189030AA306
      11B2050FB10107A0000188FF00FFFF00FFFF00FFFF00FFFF00FF}
  end
  object btnCopy: TBitBtn
    Left = 276
    Top = 311
    Width = 150
    Height = 35
    Anchors = [akRight, akBottom]
    Caption = 'Copy and &Use'
    TabOrder = 3
    OnClick = btnCopyClick
    Glyph.Data = {
      36090000424D3609000000000000360000002800000018000000180000000100
      20000000000000090000130B0000130B00000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF000000FF000000FF920004FF920004FF920003FF9200
      03FF920003FF920003FF910003FF000000FF000000FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF000000FF920004FF920003FF920003FF920003FF9200
      03FF920004FF920003FF920003FF910003FF000000FF000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF920003FF920003FF920003FF920003FF920004FF9200
      03FF920003FF920003FF920003FF920003FF920003FF000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF920003FF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FF000000FF000000FF920004FF000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF920003FF920003FF920003FF920004FF920003FF9100
      04FF920003FF920003FF920004FF920003FF920003FF000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF950205FF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FF000000FF000000FF950205FF000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF5A5A5AFF5A5A5AFF5A5A5AFF5A5A5AFF5A5A5AFF5A5A5AFFB5B5B5FFA00A
      0EFFA10A0EFFA10A0DFFA00A0DFFA10A0EFFA10A0DFF000000FFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF00ABABFF00AAA9FF00A9A8FF00A8A7FF00A7A6FF00A6A5FFFFFFFFFF0000
      00FF000000FF000000FF000000FF000000FFAD1215FF000000FFFFFFFFFFFFFF
      FFFF000000FF000000FF000076FF000076FF000076FF000076FF000076FF0000
      76FF000075FF00BAB9FF00BAB8FF00B8B7FF00B7B6FF00B6B6FFFFFFFFFFB81A
      1EFFB81A1EFFB81A1EFFB81A1EFFB81A1EFFB91B1EFF000000FFFFFFFFFF0000
      00FF000000FF000075FF000075FF000076FF000076FF000076FF000076FF0000
      76FF000076FF5A5A5AFF00CAC9FF00C9C8FF00C7C6FF00C6C6FFFFFFFFFF0000
      00FF000000FF000000FF000000FF000000FFC42327FF000000FFFFFFFFFF0000
      00FF000076FF000076FF000075FF000076FF000076FF000076FF000076FF0000
      76FF5A5A5AFF00DBDAFF00D9D9FF00D9D8FF00D8D7FF00D7D6FFFFFFFFFFD02B
      2FFFCF2B2EFFD02A2FFFCF2B2FFFD02B2FFFD02A2EFF000000FFFFFFFFFF0000
      00FF000076FF000000FF000000FF000000FF000000FF000000FF000000FF5A5A
      5AFF00ECEBFF00EBEAFF00EAE9FFFFFFFFFF00E8E7FF00E7E6FFFFFFFFFFDB33
      37FFDC3337FFDC3336FFDB3237FFDC3337FF000000FF000000FFFFFFFFFF0000
      00FF000076FF000076FF000076FF000076FF000076FF000076FF5A5A5AFF00FD
      FCFF00FCFBFF00FBFAFFFFFFFFFF000000FFFFFFFFFF00F7F6FFFFFFFFFFE73B
      3EFFE73B3FFFE73B3FFFE83B3EFF000000FF000000FFFFFFFFFFFFFFFFFF0000
      00FF000076FF000000FF000000FF000000FF000000FF000000FFFFFFFFFF00FF
      FEFF00FFFEFFFFFFFFFF000076FF000000FF000000FFFFFFFFFFFFFFFFFF0000
      00FF000000FF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FF000078FF000078FF000078FF000077FF000078FF000077FF000078FFFFFF
      FFFFFFFFFFFF000078FF000078FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FF000086FF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FF000086FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FF000094FF000093FF000093FF000094FF000093FF000093FF000093FF0000
      93FF000094FF000093FF000094FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FF0000A1FF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FF0000A1FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FF0000AFFF0000AFFF0000AFFF0000AFFF0000AFFF0000B0FF0000AFFF0000
      AFFF0000AFFF0000AFFF0000AFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FF000000FF0000BDFF0000BCFF0000BDFF0000BDFF0000BCFF0000BDFF0000
      BDFF0000BDFF0000BDFF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF000000FF000000FF0000CBFF0000CBFF0000CAFF0000CAFF0000CBFF0000
      CBFF0000CBFF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
  end
  object clbChildren: TCheckListBox
    Left = 64
    Top = 152
    Width = 362
    Height = 148
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    Items.Strings = (
      'one'
      'two'
      'three'
      'four')
    TabOrder = 4
  end
  object edtDemoName: TEdit
    Left = 64
    Top = 74
    Width = 362
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 5
  end
  object cboSponsor: TORComboBox
    Left = 64
    Top = 101
    Width = 362
    Height = 21
    Anchors = [akLeft, akTop, akRight, akBottom]
    CaseChanged = False
    Style = orcsDropDown
    AutoSelect = True
    Caption = 'Patient'
    Color = clWindow
    DropDownCount = 8
    ItemHeight = 13
    ItemTipColor = clWindow
    ItemTipEnable = True
    ListItemsOnly = False
    LongList = True
    LookupPiece = 2
    MaxLength = 0
    ParentShowHint = False
    Pieces = '2,3'
    ShowHint = True
    Sorted = False
    SynonymChars = '<>'
    TabPositions = '20,25,30,60'
    TabOrder = 6
    OnChange = cboSponsorChange
    OnClick = cboSponsorClick
    OnDblClick = cboSponsorDblClick
    OnDropDown = cboSponsorDropDown
    OnNeedData = cboSponsorNeedData
    CharsNeedMatch = 1
  end
end
