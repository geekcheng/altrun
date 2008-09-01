object ConfigForm: TConfigForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Config'
  ClientHeight = 328
  ClientWidth = 494
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    494
    328)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TBitBtn
    Left = 330
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akTop, akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
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
  object btnCancel: TBitBtn
    Left = 411
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akTop, akRight, akBottom]
    TabOrder = 1
    Kind = bkCancel
  end
  object pgcConfig: TPageControl
    Left = 6
    Top = 8
    Width = 480
    Height = 281
    ActivePage = tsConfig
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object tsConfig: TTabSheet
      Caption = '&Config'
      object spl1: TSplitter
        Left = 0
        Top = 209
        Width = 472
        Height = 5
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 161
        ExplicitWidth = 448
      end
      object chklstConfig: TCheckListBox
        Left = 0
        Top = 0
        Width = 472
        Height = 209
        Align = alTop
        Ctl3D = False
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = #23435#20307
        Font.Style = []
        ItemHeight = 15
        Items.Strings = (
          'Auto run me when Windows start'
          'Add HotRun to SendTo Menu'
          'Enable Regex (Wild char = *, ?)'
          'Match Keyword from Anywhere'
          'Enable Number Key'
          'Index = 0, 1, ..., 8, 9'
          'Remember Last ShortCut Match'
          'Show Hint'
          'Show Command Line'
          'Show Start Notification'
          'Show Top 10 Only'
          'Play Popup Notify'
          'Exit When Execute'
          'Show Skin'
          'Show When Start')
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnClick = chklstConfigClick
      end
      object mmoDesc: TMemo
        Left = 0
        Top = 214
        Width = 472
        Height = 39
        Align = alClient
        Ctl3D = False
        Font.Charset = ANSI_CHARSET
        Font.Color = clGreen
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentCtl3D = False
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object tsHotKey: TTabSheet
      Caption = '&HotKey'
      ImageIndex = 1
      DesignSize = (
        472
        253)
      object lblPlus: TLabel
        Left = 183
        Top = 52
        Width = 7
        Height = 28
        Anchors = [akLeft, akBottom]
        AutoSize = False
        Caption = '+'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        ExplicitTop = 41
      end
      object grpKeys: TGroupBox
        Left = 196
        Top = 39
        Width = 167
        Height = 48
        Anchors = [akLeft, akBottom]
        TabOrder = 0
        object chkWindows: TCheckBox
          Left = 8
          Top = 3
          Width = 73
          Height = 17
          Caption = 'Windows'
          TabOrder = 0
        end
        object chkAlt: TCheckBox
          Left = 94
          Top = 3
          Width = 42
          Height = 17
          Caption = 'Alt'
          TabOrder = 1
        end
        object chkCtrl: TCheckBox
          Left = 8
          Top = 26
          Width = 70
          Height = 17
          Caption = 'Ctrl'
          TabOrder = 2
        end
        object chkShift: TCheckBox
          Left = 94
          Top = 26
          Width = 70
          Height = 17
          Caption = 'Shift'
          TabOrder = 3
        end
      end
      object lbledtHotKey: TLabeledEdit
        Left = 74
        Top = 52
        Width = 103
        Height = 19
        Hint = 'Type keyboard to select one key'
        Anchors = [akLeft, akBottom]
        Ctl3D = False
        EditLabel.Width = 56
        EditLabel.Height = 13
        EditLabel.Caption = 'HotKey ='
        LabelPosition = lpLeft
        ParentCtl3D = False
        ParentShowHint = False
        ReadOnly = True
        ShowHint = True
        TabOrder = 1
        OnKeyDown = lbledtHotKeyKeyDown
      end
    end
    object tsFont: TTabSheet
      Caption = '&Font'
      ImageIndex = 2
      DesignSize = (
        472
        253)
      object lblTitleFont: TLabel
        Left = 8
        Top = 20
        Width = 70
        Height = 13
        Caption = 'Title Font'
      end
      object lblKeywordFont: TLabel
        Left = 8
        Top = 51
        Width = 84
        Height = 13
        Caption = 'Keyword Font'
      end
      object lblListFont: TLabel
        Left = 8
        Top = 82
        Width = 63
        Height = 13
        Caption = 'List Font'
      end
      object lblTitleSample: TLabel
        Left = 277
        Top = 20
        Width = 84
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Title Sample'
      end
      object lblKeywordSample: TLabel
        Left = 277
        Top = 52
        Width = 98
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Keyword Sample'
      end
      object lblListSample: TLabel
        Left = 277
        Top = 82
        Width = 77
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'List Sample'
      end
      object lblResetFont: TLabel
        Left = 8
        Top = 113
        Width = 105
        Height = 13
        Caption = 'Reset All Fonts'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object lblListFormat: TLabel
        Left = 8
        Top = 151
        Width = 77
        Height = 13
        Caption = 'List Format'
      end
      object lblListFormatSample: TLabel
        Left = 126
        Top = 175
        Width = 126
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 'List Format Sample'
      end
      object shp1: TShape
        Left = 8
        Top = 139
        Width = 461
        Height = 3
        Anchors = [akLeft, akTop, akRight]
        Brush.Color = clSilver
        Pen.Color = clWhite
        Pen.Style = psInsideFrame
        ExplicitWidth = 439
      end
      object lblFormatSample: TLabel
        Left = 8
        Top = 175
        Width = 91
        Height = 13
        Caption = 'Format Sample'
      end
      object btnModifyTitleFont: TButton
        Left = 126
        Top = 15
        Width = 145
        Height = 25
        Caption = 'Modify &Title Font'
        TabOrder = 0
        OnClick = btnModifyTitleFontClick
      end
      object btnModifyKeywordFont: TButton
        Left = 126
        Top = 46
        Width = 145
        Height = 25
        Caption = 'Modify &Keyword Font'
        TabOrder = 1
        OnClick = btnModifyKeywordFontClick
      end
      object btnModifyListFont: TButton
        Left = 126
        Top = 77
        Width = 145
        Height = 25
        Caption = 'Modify &List Font'
        TabOrder = 2
        OnClick = btnModifyListFontClick
      end
      object btnResetFont: TButton
        Left = 126
        Top = 108
        Width = 145
        Height = 25
        Caption = 'Reset all Fonts'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = btnResetFontClick
      end
      object cbbListFormat: TComboBox
        Left = 126
        Top = 148
        Width = 167
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = False
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 4
        OnChange = cbbListFormatChange
      end
    end
    object tsForm: TTabSheet
      Caption = 'F&orm'
      ImageIndex = 3
      DesignSize = (
        472
        253)
      object lblFormAlphaColor: TLabel
        Left = 8
        Top = 20
        Width = 112
        Height = 13
        Caption = 'Form Alpha Color'
      end
      object lblFormAlpha: TLabel
        Left = 8
        Top = 48
        Width = 77
        Height = 13
        Caption = 'Form Alpha '
      end
      object lblBackGroundImage: TLabel
        Left = 8
        Top = 76
        Width = 112
        Height = 13
        Caption = 'BackGround Image'
        Visible = False
      end
      object lblAlphaHint: TLabel
        Left = 8
        Top = 224
        Width = 432
        Height = 16
        Caption = 'Alpha Setting will take into effect when next start up'
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object lstAlphaColor: TColorBox
        Left = 128
        Top = 17
        Width = 145
        Height = 22
        Ctl3D = False
        ItemHeight = 16
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 0
      end
      object seAlpha: TSpinEdit
        Left = 128
        Top = 45
        Width = 145
        Height = 22
        Ctl3D = False
        MaxValue = 255
        MinValue = 0
        ParentCtl3D = False
        TabOrder = 1
        Value = 0
        OnKeyDown = seAlphaKeyDown
      end
      object edtClientDBFileBGFileName: TFilenameEdit
        Left = 128
        Top = 73
        Width = 167
        Height = 19
        Ctl3D = False
        Anchors = [akLeft, akTop, akRight]
        NumGlyphs = 1
        ParentCtl3D = False
        TabOrder = 2
        Text = 'edtClientDBFileBGFileName'
        Visible = False
      end
    end
    object tsLang: TTabSheet
      Caption = 'Language'
      ImageIndex = 4
      DesignSize = (
        472
        253)
      object lblLanguage: TLabel
        Left = 8
        Top = 23
        Width = 56
        Height = 13
        Caption = 'Language'
      end
      object lblLanguageHint: TLabel
        Left = 8
        Top = 224
        Width = 456
        Height = 16
        Caption = 'Language Setting will take into effect when next start up'
        Font.Charset = ANSI_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object cbbLang: TComboBox
        Left = 126
        Top = 20
        Width = 167
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = False
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 0
        OnChange = cbbListFormatChange
      end
    end
  end
  object btnReset: TBitBtn
    Left = 10
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akLeft, akTop, akBottom]
    Caption = '&Reset'
    TabOrder = 3
    OnClick = btnResetClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333444444
      33333333333F8888883F33330000324334222222443333388F3833333388F333
      000032244222222222433338F8833FFFFF338F3300003222222AAAAA22243338
      F333F88888F338F30000322222A33333A2224338F33F8333338F338F00003222
      223333333A224338F33833333338F38F00003222222333333A444338FFFF8F33
      3338888300003AAAAAAA33333333333888888833333333330000333333333333
      333333333333333333FFFFFF000033333333333344444433FFFF333333888888
      00003A444333333A22222438888F333338F3333800003A2243333333A2222438
      F38F333333833338000033A224333334422224338338FFFFF8833338000033A2
      22444442222224338F3388888333FF380000333A2222222222AA243338FF3333
      33FF88F800003333AA222222AA33A3333388FFFFFF8833830000333333AAAAAA
      3333333333338888883333330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 96
    Top = 288
  end
end
