unit frmConfig;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  HotKeyManager,
  untALTRunOption,
  ExtCtrls,
  CheckLst,
  ComCtrls,
  Mask,
  Spin,
  rxToolEdit;

type
  TConfigForm = class(TForm)
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    pgcConfig: TPageControl;
    tsConfig: TTabSheet;
    tsHotKey: TTabSheet;
    tsFont: TTabSheet;
    chklstConfig: TCheckListBox;
    grpKeys: TGroupBox;
    chkWindows: TCheckBox;
    chkAlt: TCheckBox;
    chkCtrl: TCheckBox;
    chkShift: TCheckBox;
    lblPlus: TLabel;
    lbledtHotKey: TLabeledEdit;
    mmoDesc: TMemo;
    spl1: TSplitter;
    dlgFont: TFontDialog;
    lblTitleFont: TLabel;
    lblKeywordFont: TLabel;
    lblListFont: TLabel;
    btnModifyTitleFont: TButton;
    lblTitleSample: TLabel;
    btnModifyKeywordFont: TButton;
    lblKeywordSample: TLabel;
    lblListSample: TLabel;
    btnModifyListFont: TButton;
    btnReset: TBitBtn;
    btnResetFont: TButton;
    lblResetFont: TLabel;
    cbbListFormat: TComboBox;
    lblListFormat: TLabel;
    lblListFormatSample: TLabel;
    shp1: TShape;
    lblFormatSample: TLabel;
    tsForm: TTabSheet;
    lblFormAlphaColor: TLabel;
    lstAlphaColor: TColorBox;
    seAlpha: TSpinEdit;
    lblFormAlpha: TLabel;
    lblBackGroundImage: TLabel;
    edtClientDBFileBGFileName: TFilenameEdit;
    lblAlphaHint: TLabel;
    tsLang: TTabSheet;
    lblLanguage: TLabel;
    cbbLang: TComboBox;
    lblLanguageHint: TLabel;
    procedure lbledtHotKeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chklstConfigClick(Sender: TObject);
    procedure fontcbbTitleChange(Sender: TObject);
    procedure btnModifyTitleFontClick(Sender: TObject);
    procedure btnModifyKeywordFontClick(Sender: TObject);
    procedure btnModifyListFontClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnResetFontClick(Sender: TObject);
    procedure cbbListFormatChange(Sender: TObject);
    procedure seAlphaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    function DisplayHotKey(KeyName: string): Boolean;
    function GetHotKey: string;
  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.dfm}

const
  WIN_KEY = 'Win';
  ALT_KEY = 'Alt';
  CTRL_KEY = 'Ctrl';
  SHIFT_KEY = 'Shift';

procedure TConfigForm.btnModifyKeywordFontClick(Sender: TObject);
begin
  dlgFont.Font := lblKeywordSample.Font;
  if dlgFont.Execute then
    lblKeywordSample.Font := dlgFont.Font;
end;

procedure TConfigForm.btnModifyListFontClick(Sender: TObject);
begin
  dlgFont.Font := lblListSample.Font;
  if dlgFont.Execute then
  begin
    lblListSample.Font := dlgFont.Font;
    lblListFormatSample.Font := dlgFont.Font;
  end;

end;

procedure TConfigForm.btnResetClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(resResetAllConfig),
    PChar(resInfo), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) = IDCANCEL then
    Exit;

  ModalResult := mrRetry;
end;

procedure TConfigForm.btnResetFontClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(resResetAllFonts), PChar(resInfo),
    MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) = IDCANCEL then
    Exit;

  StrToFont(DEFAULT_TITLE_FONT_STR, lblTitleSample.Font);
  StrToFont(DEFAULT_KEYWORD_FONT_STR, lblKeywordSample.Font);
  StrToFont(DEFAULT_LIST_FONT_STR, lblListSample.Font);
end;

procedure TConfigForm.btnModifyTitleFontClick(Sender: TObject);
begin
  dlgFont.Font := lblTitleSample.Font;
  if dlgFont.Execute then
  begin
    lblTitleSample.Font := dlgFont.Font;
    lblTitleSample.Font.Pitch := fpFixed;
  end;
  //  if dlgFont.Execute then
  //  begin
  //    if (dlgFont.Font.Pitch in [fpFixed]) and
  //      (Application.MessageBox('FontPitch is not Fixed type, still choose it?',
  //      PChar(resInfo), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) = IDCANCEL) then
  //      Exit
  //    else
  //      lblTitleFontSample.Font := dlgFont.Font;
  //  end;
end;

procedure TConfigForm.cbbListFormatChange(Sender: TObject);
begin
  try
    lblListFormatSample.Font := lblListSample.Font;
    lblListFormatSample.Caption := Format(cbbListFormat.Text, ['calc', '¼ÆËãÆ÷']);
  except
    Exit;
  end;
end;

procedure TConfigForm.chklstConfigClick(Sender: TObject);
begin
  mmoDesc.Text := ConfigDescList[chklstConfig.ItemIndex];

end;

function TConfigForm.DisplayHotKey(KeyName: string): Boolean;
var
  KeyList: TStringList;
  i: Cardinal;
begin
  Result := False;

  lbledtHotKey.Text := '';
  chkWindows.Checked := False;
  chkAlt.Checked := False;
  chkCtrl.Checked := False;
  chkShift.Checked := False;

  if Trim(KeyName) = '' then
  begin
    lbledtHotKey.Text := resVoidHotKey;
    Exit;
  end;

  try
    KeyList := TStringList.Create;

    KeyList.Delimiter := '+';
    KeyList.DelimitedText := KeyName;

    if KeyList.Count > 1 then
      for i := 0 to KeyList.Count - 2 do
      begin
        if LowerCase(Trim(KeyList.Strings[i])) = LowerCase(Trim(WIN_KEY)) then
          chkWindows.Checked := True
        else if LowerCase(Trim(KeyList.Strings[i])) = LowerCase(Trim(ALT_KEY)) then
          chkAlt.Checked := True
        else if LowerCase(Trim(KeyList.Strings[i])) = LowerCase(Trim(CTRL_KEY)) then
          chkCtrl.Checked := True
        else if LowerCase(Trim(KeyList.Strings[i])) = LowerCase(Trim(SHIFT_KEY)) then
          chkShift.Checked := True;
      end;

    lbledtHotKey.Text := KeyList.Strings[KeyList.Count - 1];
  finally
    KeyList.Free;
  end;
end;

procedure TConfigForm.fontcbbTitleChange(Sender: TObject);
begin
  if dlgFont.Execute then
  begin
    ShowMessage(dlgFont.Font.Name);
  end;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
var
  i: Cardinal;
begin
  Self.Caption := resConfigFormCaption;

  btnOK.Caption := resBtnOK;
  btnCancel.Caption := resBtnCancel;
  btnReset.Caption := resBtnReset;

  tsConfig.Caption := resPageConfig;
  tsHotKey.Caption := resPageHotKey;
  tsFont.Caption := resPageFont;
  tsForm.Caption := resPageForm;
  tsLang.Caption := resPageLang;

  chklstConfig.Clear;
  chklstConfig.Items.Add(resConfigList_0);
  chklstConfig.Items.Add(resConfigList_1);
  chklstConfig.Items.Add(resConfigList_2);
  chklstConfig.Items.Add(resConfigList_3);
  chklstConfig.Items.Add(resConfigList_4);
  chklstConfig.Items.Add(resConfigList_5);
  chklstConfig.Items.Add(resConfigList_6);
  chklstConfig.Items.Add(resConfigList_7);
  chklstConfig.Items.Add(resConfigList_8);
  chklstConfig.Items.Add(resConfigList_9);
  chklstConfig.Items.Add(resConfigList_10);
  chklstConfig.Items.Add(resConfigList_11);
  chklstConfig.Items.Add(resConfigList_12);
  chklstConfig.Items.Add(resConfigList_13);
  chklstConfig.Items.Add(resConfigList_14);

  lbledtHotKey.EditLabel.Caption := resLblHotKey;
  LblTitleFont.Caption := resLblTitleFont;
  LblTitleSample.Caption := resLblTitleSample;
  LblKeywordFont.Caption := resLblKeywordFont;
  LblKeywordSample.Caption := resLblKeywordSample;
  LblListFont.Caption := resLblListFont;
  LblListSample.Caption := resLblListSample;
  LblListFormat.Caption := resLblListFormat;
  lblResetFont.Caption := resLblResetFont;
  lblFormatSample.Caption := resLblFormatSample;
  LblListFormatSample.Caption := resLblListFormatSample;
  LblFormAlphaColor.Caption := resLblFormAlphaColor;
  LblFormAlpha.Caption := resLblFormAlpha;
  LblBackGroundImage.Caption := resLblBackGroundImage;
  LblAlphaHint.Caption := resLblAlphaHint;
  LblLanguage.Caption := resLblLanguage;
  LblLanguageHint.Caption := resLblLanguageHint;
  lbledtHotKey.Hint:=resLblHotKeyHint;

  BtnModifyTitleFont.Caption := resBtnModifyTitleFont;
  btnModifyKeywordFont.Caption := resBtnModifyKeywordFont;
  BtnModifyListFont.Caption := resBtnModifyListFont;
  BtnResetFont.Caption := resBtnResetAllFonts;
end;

function TConfigForm.GetHotKey: string;
begin
  Result := '';

  if chkWindows.Checked then Result := Result + WIN_KEY + ' + ';
  if chkAlt.Checked then Result := Result + ALT_KEY + ' + ';
  if chkCtrl.Checked then Result := Result + CTRL_KEY + ' + ';
  if chkShift.Checked then Result := Result + SHIFT_KEY + ' + ';

  Result := Result + lbledtHotKey.Text;
end;

procedure TConfigForm.lbledtHotKeyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  lbledtHotKey.Text := HotKeyManager.HotKeyToText(Key, LOCALIZED_KEYNAMES);
end;

procedure TConfigForm.seAlphaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    13: ModalResult := mrOk;                           //»Ø³µ
    VK_ESCAPE: ModalResult := mrCancel;                //ESC
  end;
end;

end.

