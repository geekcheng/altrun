unit frmShortCutMan;

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
  ActnList,
  StdCtrls,
  ComCtrls,
  Buttons,
  ImgList,
  Menus,
  ShellAPI,
  untShortCutMan,
  untUtilities,
  untALTRunOption,
  ToolWin;

type
  TShortCutManForm = class(TForm)
    lvShortCut: TListView;
    actlstShortCut: TActionList;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actClose: TAction;
    btnOK: TBitBtn;
    ilShortCutMan: TImageList;
    pmShortCutMan: TPopupMenu;
    mniCut: TMenuItem;
    mniInsert: TMenuItem;
    mniDelete: TMenuItem;
    tlbShortCutMan: TToolBar;
    btnAdd: TToolButton;
    btnEdit: TToolButton;
    btnDelete: TToolButton;
    btn1: TToolButton;
    btnHelp: TToolButton;
    actHelp: TAction;
    btnClose: TToolButton;
    actCancel: TAction;
    btnCancel: TToolButton;
    actValidate: TAction;
    btnValidate: TToolButton;
    statShortCutMan: TStatusBar;
    btnCancel0: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure MyDrag(var Msg: TWMDropFiles); message WM_DropFiles;
    procedure actAddExecute(Sender: TObject);
    procedure lvShortCutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvShortCutDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lvShortCutDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure lvShortCutKeyPress(Sender: TObject; var Key: Char);
    procedure lvShortCutKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actValidateExecute(Sender: TObject);
    procedure lvShortCutEdited(Sender: TObject; Item: TListItem; var S: string);
    procedure lvShortCutEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
  private
    //m_ShortCutList: TShortCutList;
    m_SrcItem: TListItem;
    m_CuttedItem: TListItem;
    m_Cutted: Boolean;

    function ExistListItem(itm: TListItem): Boolean;
    procedure LoadShortCutList;
    function IsValidCommandLine(strCommandLine: string): Boolean;
  public
    { Public declarations }
  end;

var
  ShortCutManForm: TShortCutManForm;

implementation
{$R *.dfm}

uses
  frmShortCut,
  frmInvalid;

procedure TShortCutManForm.actAddExecute(Sender: TObject);
var
  ShortCutForm: TShortCutForm;
  NewLine: string;
  ListItem: TListItem;
  ShortCutItem: TShortCutItem;
begin
  try
    ShortCutForm := TShortCutForm.Create(Self);
    with ShortCutForm do
    begin
      lbledtShortCut.Clear;
      lbledtName.Clear;
      lbledtCommandLine.Clear;
      rgParam.ItemIndex := 0;

      ShowModal;

      if ModalResult = mrCancel then Exit;

      ListItem := TListItem.Create(lvShortCut.Items);

      if (Trim(lbledtShortCut.Text) <> '') and (Trim(lbledtCommandLine.Text) <> '') then
      begin
        ListItem.Caption := lbledtShortCut.Text;
        ListItem.SubItems.Add(lbledtName.Text);
        ListItem.SubItems.Add(ShortCutMan.ParamTypeToString(TParamType(rgParam.ItemIndex)));
        ListItem.SubItems.Add(lbledtCommandLine.Text);
        ListItem.ImageIndex := Ord(siItem);
      end
      else
      begin
        ListItem.Caption := '';
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.ImageIndex := Ord(siInfo);
      end;

      //若有重复，则报错
      if ExistListItem(ListItem) then
      begin
        Application.MessageBox('This ShortCut has already existed!', PChar(resInfo),
          MB_OK + MB_ICONINFORMATION + MB_TOPMOST);

        ListItem.Free;
        Exit;
      end;

      //如果没有选中，就加到最后一行，否则就插入选中的位置
      if lvShortCut.ItemIndex < 0 then
        ListItem := lvShortCut.Items.AddItem(ListItem)
      else
        ListItem := lvShortCut.Items.AddItem(ListItem, lvShortCut.ItemIndex);

      //使其可见
      lvShortCut.SetFocus;
      ListItem.Selected := True;
      ListItem.MakeVisible(True);

      //如果Caption只是一个字母，如"a"，则当时不显示，只好处理一下才能刷新显示
      ListItem.Caption := lbledtShortCut.Text + ' ';
      ListItem.Caption := lbledtShortCut.Text;
    end;
  finally
    ShortCutForm.Free;
  end;
end;

procedure TShortCutManForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TShortCutManForm.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TShortCutManForm.actDeleteExecute(Sender: TObject);
begin
  if lvShortCut.ItemIndex < 0 then Exit;

  if lvShortCut.Selected.Caption = '' then
  begin
    if Application.MessageBox(PChar(resDeleteBlankLine),
      PChar(resInfo), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) = IDOK then
      lvShortCut.DeleteSelected;
  end
  else
  begin
    if Application.MessageBox(PChar(Format(PChar(resDeleteConfirm),
      [lvShortCut.Selected.Caption, lvShortCut.Selected.SubItems[0]])),
      PChar(resInfo), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) = IDOK then
      lvShortCut.DeleteSelected;
  end;
end;

procedure TShortCutManForm.actEditExecute(Sender: TObject);
var
  ShortCutForm: TShortCutForm;
  itm: TListItem;
  ParamType: TParamType;
  ShortCutItem: TShortCutItem;
begin
  if lvShortCut.ItemIndex < 0 then Exit;
  if lvShortCut.Selected.ImageIndex <> Ord(siItem) then Exit;

  try
    ShortCutForm := TShortCutForm.Create(Self);
    with ShortCutForm do
    begin
      lbledtShortCut.Text := lvShortCut.Selected.Caption;
      lbledtName.Text := lvShortCut.Selected.SubItems[0];
      lbledtCommandLine.Text := lvShortCut.Selected.SubItems[2];
      ShortCutMan.StringToParamType(lvShortCut.Selected.SubItems[1], ParamType);
      rgParam.ItemIndex := Ord(ParamType);

      ShowModal;

      if ModalResult = mrCancel then Exit;

      try
        itm := TListItem.Create(lvShortCut.Items);

        if (Trim(lbledtShortCut.Text) <> '') and (Trim(lbledtCommandLine.Text) <> '') then
        begin
          itm.Caption := lbledtShortCut.Text;
          itm.SubItems.Add(lbledtName.Text);
          itm.SubItems.Add(ShortCutMan.ParamTypeToString(TParamType(rgParam.ItemIndex)));
          itm.SubItems.Add(lbledtCommandLine.Text);
          itm.ImageIndex := Ord(siItem);
        end
        else
        begin
          itm.Caption := '';
          itm.SubItems.Add('');
          itm.SubItems.Add('');
          itm.SubItems.Add('');
          itm.ImageIndex := Ord(siInfo);
        end;

        //若有重复，则报错
        if ExistListItem(itm) then
        begin
          Application.MessageBox('This ShortCut has already existed!', PChar(resInfo),
            MB_OK + MB_ICONINFORMATION + MB_TOPMOST);

          Exit;
        end;

        lvShortCut.Selected.Caption := itm.Caption;
        lvShortCut.Selected.SubItems[0] := itm.SubItems[0];
        lvShortCut.Selected.SubItems[1] := itm.SubItems[1];
        lvShortCut.Selected.SubItems[2] := itm.SubItems[2];
        lvShortCut.Selected.ImageIndex := itm.ImageIndex;

        //使其可见
        lvShortCut.Selected.MakeVisible(True);
      finally
        itm.Free;
      end;
    end;
  finally
    ShortCutForm.Free;
  end;
end;

procedure TShortCutManForm.actHelpExecute(Sender: TObject);
begin
  //
end;

procedure TShortCutManForm.actValidateExecute(Sender: TObject);
var
  i: Cardinal;
  Item: TShortCutItem;
  InvalidForm: TInvalidForm;
  lvwitm: TListItem;
  CommandLine: string;
begin
  if lvShortCut.Items.Count = 0 then Exit;

  //看看是否真的需要
  if Application.MessageBox(PChar(resValidateConfirm), PChar(resInfo),
    MB_YESNO + MB_ICONQUESTION + MB_TOPMOST) = IDNO then
  begin
    Exit;
  end;

  try
    InvalidForm := TInvalidForm.Create(Self);

    Screen.Cursor := crHourGlass;

    for i := 0 to lvShortCut.Items.Count - 1 do
    begin
      //解析出快捷项
      CommandLine := lvShortCut.Items.Item[i].SubItems[2];

      if not IsValidCommandLine(CommandLine) then
      begin
        lvwitm := InvalidForm.lvShortCut.Items.Add;

        lvwitm.Caption := lvShortCut.Items.Item[i].Caption;
        lvwitm.SubItems.Add(lvShortCut.Items.Item[i].SubItems[0]);
        lvwitm.SubItems.Add(lvShortCut.Items.Item[i].SubItems[1]);
        lvwitm.SubItems.Add(lvShortCut.Items.Item[i].SubItems[2]);
        lvwitm.ImageIndex := Ord(siItem);
        lvwitm.Checked := True;

        //保存Index
        lvwitm.Data := Pointer(i);
      end;
    end;

    Screen.Cursor := crDefault;

    //若没有找到有问题的项目，则退出
    if InvalidForm.lvShortCut.Items.Count = 0 then
    begin
      Application.MessageBox(PChar(resNoInvalidShortCut), PChar(resInfo),
        MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
      Exit;
    end;

    InvalidForm.ShowModal;

    if InvalidForm.ModalResult = mrCancel then Exit;

    //将选中的都删除
    for i := InvalidForm.lvShortCut.Items.Count - 1 downto 0 do
    begin
      if not InvalidForm.lvShortCut.Items[i].Checked then Continue;

      lvShortCut.Items.Delete(Integer(InvalidForm.lvShortCut.Items[i].Data));
    end;
  finally
    InvalidForm.Free;
  end;
end;

function TShortCutManForm.IsValidCommandLine(strCommandLine: string): Boolean;
var
  BlankPos: Integer;
begin
  Result := True;

  //出现'\\'认为是网络相关，别做检查
  if Pos('\\', strCommandLine) > 0 then Exit;

  //出现'\'才认为是文件或文件夹，才去做检查
  if Pos('\', strCommandLine) = 0 then Exit;

  //替换环境变量
  strCommandLine := ShortCutMan.ReplaceEnvStr(strCommandLine);

  //有这个文件，当然没问题
  if FileExists(strCommandLine) then Exit;

  //有这个文件夹，当然没问题
  if DirectoryExists(strCommandLine) then Exit;

  //"C:\Program Files\D-Tools\daemon.exe" -lang 1033
  if Pos('"', strCommandLine) = 1 then Exit;

  //带参数的，都不检查
  if Pos(' ', strCommandLine) > 1 then Exit;

  //TODO: 其他的，都认为比较可疑，是否运行一下看看？
  Result := False;
end;

function TShortCutManForm.ExistListItem(itm: TListItem): Boolean;
var
  i: Cardinal;
begin
  Result := False;

  if lvShortCut.Items.Count = 0 then Exit;

  //若是空行
  if itm.Caption = '' then Exit;

  for i := 0 to lvShortCut.Items.Count - 1 do
    with lvShortCut.Items.Item[i] do
      if (itm.Caption = Caption) and
        (itm.SubItems[0] = SubItems[0]) and
        (itm.SubItems[1] = SubItems[1]) and
        (itm.SubItems[2] = SubItems[2]) then
      begin
        Result := True;
        Exit;
      end;
end;

procedure TShortCutManForm.FormCreate(Sender: TObject);
begin
  //mniCut.Enabled := False;
  //mniInsert.Enabled := False;
  //m_Cutted := False;

  Self.Caption := resShortCutManFormCaption;
  btnAdd.Caption := resBtnAdd;
  btnEdit.Caption := resBtnEdit;
  btnDelete.Caption := resBtnDelete;
  btnValidate.Caption := resBtnValidate;
  btnHelp.Caption := resBtnHelp;
  btnClose.Caption := resBtnClose;
  btnCancel.Caption := resBtnCancel;

  btnAdd.Hint := resBtnAddHint;
  btnEdit.Hint := resBtnEditHint;
  btnDelete.Hint := resBtnDeleteHint;
  btnValidate.Hint := resBtnValidateHint;
  btnHelp.Hint := resBtnHelpHint;
  btnClose.Hint := resBtnCloseHint;
  btnCancel.Hint := resBtnCancelHint;

  lvShortCut.Columns.Items[0].Caption := resShortCut;
  lvShortCut.Columns.Items[1].Caption := resName;
  lvShortCut.Columns.Items[2].Caption := resParamType;
  lvShortCut.Columns.Items[3].Caption := resCommandLine;

  DragAcceptFiles(Handle, True);
  LoadShortCutList;
end;

procedure TShortCutManForm.FormDestroy(Sender: TObject);
begin
  ManWinTop := Self.Top;
  ManWinLeft := Self.Left;
  ManWinWidth := Self.Width;
  ManWinHeight := Self.Height;

  SaveSettings;
end;

procedure TShortCutManForm.FormShow(Sender: TObject);
begin
  //设置窗体位置
  LoadSettings;

  if (ManWinTop = 0) and (ManWinLeft = 0) then
  begin
    try
      Self.Position := poScreenCenter;
    except
      //不用Except，就会蹦出来“Cannot change Visible in OnShow or OnHide”的报错
    end;
  end
  else
  begin
    Self.Top := ManWinTop;
    Self.Left := ManWinLeft;
    Self.Width := ManWinWidth;
    Self.Height := ManWinHeight;
  end;
end;

procedure TShortCutManForm.LoadShortCutList;
begin
  ShortCutMan.FillListView(lvShortCut);
end;

procedure TShortCutManForm.lvShortCutDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  tempItem1, tempItem2: TListItem;
  hit: THitTests;
begin
  //hit := lvShortCut.GetHitTestInfoAt(x, y);
  //if htOnLabel in hit then
  begin
    tempItem1 := lvShortCut.GetItemAt(x, y);
    tempItem2 := lvShortCut.Items.Insert(tempitem1.index);
    tempitem2.Caption := m_SrcItem.Caption;
    tempitem2.SubItems.Add(m_SrcItem.SubItems[0]);
    tempitem2.SubItems.Add(m_SrcItem.SubItems[1]);
    tempitem2.SubItems.Add(m_SrcItem.SubItems[2]);
    tempitem2.ImageIndex := m_SrcItem.ImageIndex;

    m_SrcItem.Delete;
    lvShortCut.Refresh;
  end;
end;

procedure TShortCutManForm.lvShortCutDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := True;
end;

procedure TShortCutManForm.lvShortCutEdited(Sender: TObject; Item: TListItem;
  var S: string);
begin
  btnOK.Default := True;
end;

procedure TShortCutManForm.lvShortCutEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  btnOK.Default := False;
end;

procedure TShortCutManForm.lvShortCutKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F2:
      actEditExecute(Sender);

    VK_INSERT:
      actAddExecute(Sender);

    VK_DELETE:
      actDeleteExecute(Sender);
  end;
end;

procedure TShortCutManForm.lvShortCutKeyPress(Sender: TObject; var Key: Char);
begin
  //回车
  //if Key = #13 then actEditExecute(Sender);
end;

procedure TShortCutManForm.lvShortCutMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_SrcItem := lvShortCut.GetItemAt(x, y);
  //mniCut.Enabled := True;
end;

procedure TShortCutManForm.MyDrag(var Msg: TWMDropFiles);
var
  hDrop: Cardinal;
  FileName: string;
  ListItem: TListItem;
  ShortCutItem: TShortCutItem;
begin
  hDrop := Msg.Drop;
  FileName := GetDragFileName(hDrop);

  ShortCutForm := TShortCutForm.Create(Self);
  ShortCutItem := TShortCutItem.Create;
  try
    with ShortCutForm do
    begin
      if not ShortCutMan.ExtractShortCutItemFromFileName(ShortCutItem, FileName) then
      begin
        Application.MessageBox('Can not get file name!', 'Info',
          MB_OK + MB_ICONINFORMATION + MB_TOPMOST);

        Exit;
      end;

      lbledtShortCut.Text := ShortCutItem.ShortCut;
      lbledtName.Text := ShortCutItem.Name;
      lbledtCommandLine.Text := ShortCutItem.CommandLine;
      rgParam.ItemIndex := 0;

      ShowModal;

      if ModalResult = mrCancel then
      begin
        ShortCutItem.Free;
        Exit;
      end;

      ListItem := TListItem.Create(lvShortCut.Items);

      if (Trim(lbledtShortCut.Text) <> '') and (Trim(lbledtCommandLine.Text) <> '') then
      begin
        ListItem.Caption := lbledtShortCut.Text;
        ListItem.SubItems.Add(lbledtName.Text);
        ListItem.SubItems.Add(ShortCutMan.ParamTypeToString(TParamType(rgParam.ItemIndex)));
        ListItem.SubItems.Add(lbledtCommandLine.Text);
        ListItem.ImageIndex := Ord(siItem);
      end
      else
      begin
        ListItem.Caption := '';
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add('');
        ListItem.ImageIndex := Ord(siInfo);
      end;

      //若有重复，则报错
      if ExistListItem(ListItem) then
      begin
        Application.MessageBox('This ShortCut has already existed!', PChar(resInfo),
          MB_OK + MB_ICONINFORMATION + MB_TOPMOST);

        ListItem.Free;
        Exit;
      end;

      //如果没有选中，就加到最后一行，否则就插入选中的位置
      if lvShortCut.ItemIndex < 0 then
        ListItem := lvShortCut.Items.AddItem(ListItem)
      else
        ListItem := lvShortCut.Items.AddItem(ListItem, lvShortCut.ItemIndex);

      //使其可见
      lvShortCut.SetFocus;
      ListItem.Selected := True;
      ListItem.MakeVisible(True);

      //如果Caption只是一个字母，如"a"，则当时不显示，只好处理一下才能刷新显示
      ListItem.Caption := lbledtShortCut.Text + ' ';
      ListItem.Caption := lbledtShortCut.Text;
    end;
  finally
    ShortCutForm.Free;
  end;

  DragFinish(hDrop);
  Msg.Result := 0;

end;

end.

