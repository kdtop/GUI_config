inherited frmHSplit: TfrmHSplit
  Left = 53
  Top = 138
  Width = 320
  Height = 240
  Caption = 'Basic Splitter Page'
  PixelsPerInch = 96
  TextHeight = 13
  inherited shpPageBottom: TShape
    Top = 201
    Width = 312
  end
  object sptHorz: TSplitter
    Left = 97
    Top = 0
    Width = 4
    Height = 201
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 97
    Height = 201
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinWidth = 30
    TabOrder = 0
  end
  object pnlRight: TPanel
    Left = 101
    Top = 0
    Width = 211
    Height = 201
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinWidth = 24
    TabOrder = 1
  end
end
