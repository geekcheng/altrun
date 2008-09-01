object ParamForm: TParamForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Please type parameter'
  ClientHeight = 21
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TBitBtn
    Left = 312
    Top = 0
    Width = 54
    Height = 21
    Align = alRight
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object cbbParam: TComboBoxEx
    Left = 0
    Top = 0
    Width = 312
    Height = 22
    Align = alClient
    AutoCompleteOptions = [acoAutoSuggest, acoAutoAppend]
    ItemsEx = <>
    Ctl3D = False
    ItemHeight = 16
    ParentCtl3D = False
    TabOrder = 0
  end
  object tmrHide: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = tmrHideTimer
    Left = 72
    Top = 8
  end
end
