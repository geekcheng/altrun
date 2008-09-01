unit frmALTRun;

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
  AppEvnts,
  untALTRunOption,
  untUtilities,
  CoolTrayIcon,
  ActnList,
  Menus,
  HotKeyManager,
  untShortCutMan,
  ExtCtrls,
  Buttons,
  frmParam,
  ImgList,
  MMSystem,
  jpeg,
  ShellAPI;

type
  TALTRunForm = class(TForm)
    lblShortCut: TLabel;
    edtShortCut: TEdit;
    lstShortCut: TListBox;
    evtMain: TApplicationEvents;
    ntfMain: TCoolTrayIcon;
    pmMain: TPopupMenu;
    actlstMain: TActionList;
    actShow: TAction;
    actShortCut: TAction;
    actConfig: TAction;
    actClose: TAction;
    hkmMain: THotKeyManager;
    actAbout: TAction;
    Show1: TMenuItem;
    ShortCut1: TMenuItem;
    Config1: TMenuItem;
    About1: TMenuItem;
    Close1: TMenuItem;
    actExecute: TAction;
    actSelectChange: TAction;
    imgBackground: TImage;
    actHide: TAction;
    pmList: TPopupMenu;
    actAddItem: TAction;
    actEditItem: TAction;
    actDeleteItem: TAction;
    mniAddItem: TMenuItem;
    mniEditItem: TMenuItem;
    mniDeleteItem: TMenuItem;
    tmrHide: TTimer;
    ilHotRun: TImageList;
    btnShortCut: TSpeedButton;
    btnClose: TSpeedButton;
    edtHint: TEdit;
    edtCommandLine: TEdit;
    mniN1: TMenuItem;
    actOpenDir: TAction;
    mniOpenDir: TMenuItem;
    tmrExit: TTimer;

    procedure WndProc(var Msg: TMessage); override;
    procedure edtShortCutChange(Sender: TObject);
    procedure edtShortCutKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure evtMainIdle(Sender: TObject; var Done: Boolean);
    procedure evtMainMinimize(Sender: TObject);
    procedure actShowExecute(Sender: TObject);
    procedure actConfigExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure hkmMainHotKeyPressed(HotKey: Cardinal; Index: Word);
    procedure FormDestroy(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure edtShortCutKeyPress(Sender: TObject; var Key: Char);
    procedure actSelectChangeExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure lstShortCutKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actHideExecute(Sender: TObject);
    procedure actShortCutExecute(Sender: TObject);
    procedure btnShortCutClick(Sender: TObject);
    procedure actAddItemExecute(Sender: TObject);
    procedure actEditItemExecute(Sender: TObject);
    procedure actDeleteItemExecute(Sender: TObject);
    procedure lblShortCutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgBackgroundMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrHideTimer(Sender: TObject);
    procedure evtMainDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ntfMainDblClick(Sender: TObject);
    procedure lstShortCutMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure edtShortCutMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure lblShortCutMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure edtCommandLineKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actOpenDirExecute(Sender: TObject);
    procedure lstShortCutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pmListPopup(Sender: TObject);
    procedure tmrExitTimer(Sender: TObject);
  private
    m_HotKeyVar: Cardinal;
    m_IsShow: Boolean;
    m_IsFirstShow: Boolean;
    m_IsFirstDblClickIcon: Boolean;
    m_LastShortCutPointerList: array[0..9] of Pointer;
    m_LastShortCutCmdIndex: Integer;
    m_LastShortCutListCount: Integer;
    m_LastKeyIsNumKey: Boolean;
    m_LastActiveTime: Cardinal;

    function ApplyHotKey: Boolean;
    procedure GetLastCmdList;
    procedure RestartTimer(Delay: Integer);
    procedure StopTimer;
    function DirAvailable: Boolean;
    procedure RefreshOperationHint;
    function GetLangList(List: TStringList): Boolean;
    procedure RestartMe;
    procedure DisplayShortCutItem(Item: TShortCutItem);
  public
    { Public declarations }
  end;

var
  ALTRunForm: TALTRunForm;

implementation
{$R *.dfm}

uses
  frmConfig,
  frmAbout,
  frmShortCut,
  frmShortCutMan,
  frmLang;

procedure TALTRunForm.actAboutExecute(Sender: TObject);
var
  AboutForm: TAboutForm;
begin
  TraceMsg('actAboutExecute()');

  try
    AboutForm := TAboutForm.Create(Self);
    AboutForm.Caption := Format('%s %s %s', [resAbout, TITLE, ALTRUN_VERSION]);
    AboutForm.ShowModal;
  finally
    AboutForm.Free;
  end;
end;

procedure TALTRunForm.actAddItemExecute(Sender: TObject);
var
  Item: TShortCutItem;
begin
  TraceMsg('actAddItemExecute()');

  ShortCutMan.AddFileShortCut(edtShortCut.Text);
  if m_IsShow then edtShortCutChange(Self);
end;

procedure TALTRunForm.actCloseExecute(Sender: TObject);
begin
  TraceMsg('actCloseExecute()');

  //保存窗体位置
  if m_IsShow then
  begin
    WinTop := Self.Top;
    WinLeft := Self.Left;
  end;

  SaveSettings;

  //若保留此行，在右键添加后，直接退出本程序，此新添快捷项将丢失
  //ShortCutMan.SaveShortCutList;

  Application.Terminate;
end;

procedure TALTRunForm.actConfigExecute(Sender: TObject);
var
  ConfigForm: TConfigForm;
  lg: longint;
  i: Cardinal;
  LangList: TStringList;
  IsNeedRestart: Boolean;
begin
  TraceMsg('actConfigExecute()');

  try
    //取消HotKey以免冲突
    hkmMain.ClearHotKeys;

    ConfigForm := TConfigForm.Create(Self);

    IsNeedRestart := False;

    //调用当前配置
    with ConfigForm do
    begin
      DisplayHotKey(HotKeyStr);

      //AutoRun
      chklstConfig.Checked[0] := AutoRun;
      //AddToSendTo
      chklstConfig.Checked[1] := AddToSendTo;
      //EnableRegex
      chklstConfig.Checked[2] := EnableRegex;
      //MatchAnywhere
      chklstConfig.Checked[3] := MatchAnywhere;
      //EnableNumberKey
      chklstConfig.Checked[4] := EnableNumberKey;
      //IndexFrom0to9
      chklstConfig.Checked[5] := IndexFrom0to9;
      //RememberFavouratMatch
      chklstConfig.Checked[6] := RememberFavouratMatch;
      //ShowOperationHint
      chklstConfig.Checked[7] := ShowOperationHint;
      //ShowCommandLine
      chklstConfig.Checked[8] := ShowCommandLine;
      //ShowStartNotification
      chklstConfig.Checked[9] := ShowStartNotification;
      //ShowTopTen
      chklstConfig.Checked[10] := ShowTopTen;
      //PlayPopupNotify
      chklstConfig.Checked[11] := PlayPopupNotify;
      //ExitWhenExecute
      chklstConfig.Checked[12] := ExitWhenExecute;
      //ShowSkin
      chklstConfig.Checked[13] := ShowSkin;
      //ShowMeWhenStart
      chklstConfig.Checked[14] := ShowMeWhenStart;
      //edtBGFileName.Text := BGFileName;

      StrToFont(TitleFontStr, lblTitleSample.Font);
      StrToFont(KeywordFontStr, lblKeywordSample.Font);
      StrToFont(ListFontStr, lblListSample.Font);

      for i := Low(ListFormatList) to High(ListFormatList) do
        cbbListFormat.Items.Add(ListFormatList[i]);

      if cbbListFormat.Items.IndexOf(ListFormat) < 0 then
        cbbListFormat.Items.Add(ListFormat);

      cbbListFormat.ItemIndex := cbbListFormat.Items.IndexOf(ListFormat);
      cbbListFormatChange(Sender);

      lstAlphaColor.Selected := AlphaColor;
      seAlpha.Value := Alpha;

      //语言
      try
        cbbLang.Items.Add(DEFAULT_LANG);
        cbbLang.ItemIndex := 0;

        LangList := TStringList.Create;
        if not GetLangList(LangList) then Exit;

        if LangList.Count > 0 then
        begin
          for i := 0 to LangList.Count - 1 do
            if cbbLang.Items.IndexOf(LangList.Strings[i]) < 0 then
              cbbLang.Items.Add(LangList.Strings[i]);

          for i := 0 to cbbLang.Items.Count - 1 do
            if cbbLang.Items[i] = Lang then
            begin
              cbbLang.ItemIndex := i;
              Break;
            end;
        end;
      finally
        LangList.Free;
      end;

      ShowModal;

      //如果确认
      case ModalResult of
        mrOk:
          begin
            HotKeyStr := GetHotKey;

            AutoRun := chklstConfig.Checked[0];
            AddToSendTo := chklstConfig.Checked[1];
            EnableRegex := chklstConfig.Checked[2];
            MatchAnywhere := chklstConfig.Checked[3];
            EnableNumberKey := chklstConfig.Checked[4];
            IndexFrom0to9 := chklstConfig.Checked[5];
            RememberFavouratMatch := chklstConfig.Checked[6];
            ShowOperationHint := chklstConfig.Checked[7];
            ShowCommandLine := chklstConfig.Checked[8];
            ShowStartNotification := chklstConfig.Checked[9];
            ShowTopTen := chklstConfig.Checked[10];
            PlayPopupNotify := chklstConfig.Checked[11];
            ExitWhenExecute := chklstConfig.Checked[12];
            ShowSkin := chklstConfig.Checked[13];
            ShowMeWhenStart := chklstConfig.Checked[14];

            TitleFontStr := FontToStr(lblTitleSample.Font);
            KeywordFontStr := FontToStr(lblKeywordSample.Font);
            ListFontStr := FontToStr(lblListSample.Font);

            ListFormat := cbbListFormat.Text;

            if not IsNeedRestart then IsNeedRestart := (AlphaColor <> lstAlphaColor.Selected);
            AlphaColor := lstAlphaColor.Selected;

            if not IsNeedRestart then IsNeedRestart := (Alpha <> seAlpha.Value);
            Alpha := seAlpha.Value;

            if not IsNeedRestart then IsNeedRestart := (Lang <> cbbLang.Text);
            Lang := cbbLang.Text;

            //不让修改背景图片的文件名
            //BGFileName := edtBGFileName.Text;
            //if BGFileName <> '' then
            //begin
            //  if FileExists(BGFileName) then
            //    Self.imgBackground.Picture.LoadFromFile(BGFileName)
            //  else if FileExists(ExtractFilePath(Application.ExeName) + BGFileName) then
            //    Self.imgBackground.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + BGFileName)
            //  else
            //    Application.MessageBox(PChar(Format('File %s does not exist!',
            //      [BGFileName])), resInfo, MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
            //end;

            //保存新的项目
            ShortCutMan.SaveShortCutList;
            ShortCutMan.LoadShortCutList;
          end;

        mrRetry:
          begin
            DeleteFile(ExtractFilePath(Application.ExeName) + TITLE + '.ini');
            LoadSettings;
            IsNeedRestart := True;
          end;

      else
        ApplyHotKey;
        Exit;
      end;

      //应用修改的配置
      if (ModalResult = mrOk) or (ModalResult = mrRetry) then
      begin
        SetAutoRun(TITLE, Application.ExeName, AutoRun);
        AddMeToSendTo(TITLE, AddToSendTo);

        StrToFont(TitleFontStr, Self.lblShortCut.Font);
        StrToFont(KeywordFontStr, Self.edtShortCut.Font);
        StrToFont(ListFontStr, Self.lstShortCut.Font);

        //应用快捷键
        ApplyHotKey;
        ntfMain.Hint := Format(resMainHint, [TITLE, ALTRUN_VERSION, #13#10, HotKeyStr]);

        if ShowCommandLine then
          Self.Height := 250
        else
          Self.Height := 230;

        if ShowSkin then
          imgBackground.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + BGFileName)
        else
          imgBackground.Picture := nil;

        //半透明效果
        lg := getWindowLong(Handle, GWL_EXSTYLE);
        lg := lg or WS_EX_LAYERED;
        SetWindowLong(handle, GWL_EXSTYLE, lg);
        SetLayeredWindowAttributes(handle, AlphaColor, Alpha, LWA_ALPHA or LWA_COLORKEY);

        //圆角矩形窗体
        SetWindowRgn(Handle, CreateRoundRectRgn(0, 0, Width, Height, 25, 25), True);

        //应用语言修改
        SetActiveLanguage;

        SaveSettings;

        if IsNeedRestart then
        begin
          Application.MessageBox(PChar(resRestartMeInfo),
            PChar(resInfo), MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
          RestartMe;
        end;
      end;
    end;
  finally
    ConfigForm.Free;
  end;
end;

procedure TALTRunForm.actDeleteItemExecute(Sender: TObject);
var
  itm: TShortCutItem;
  Index: Integer;
begin
  TraceMsg('actDeleteItemExecute(%d)', [lstShortCut.ItemIndex]);

  if lstShortCut.ItemIndex < 0 then Exit;

  itm := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]);

  if Application.MessageBox(PChar(Format('%s %s(%s)?', [resDelete, itm.ShortCut, itm.Name])),
    PChar(resInfo), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) = IDOK then
  begin
    Index := ShortCutMan.GetShortCutItemIndex(itm);
    ShortCutMan.DeleteShortCutItem(Index);

    //刷新
    edtShortCutChange(Sender);
  end;
end;

procedure TALTRunForm.actEditItemExecute(Sender: TObject);
var
  ShortCutForm: TShortCutForm;
  itm: TShortCutItem;
  Index: Integer;
begin
  TraceMsg('actEditItemExecute(%d)', [lstShortCut.ItemIndex]);

  if lstShortCut.ItemIndex < 0 then Exit;

  itm := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]);
  Index := ShortCutMan.GetShortCutItemIndex(itm);

  try
    ShortCutForm := TShortCutForm.Create(Self);
    with ShortCutForm do
    begin
      lbledtShortCut.Text := itm.ShortCut;
      lbledtName.Text := itm.Name;
      lbledtCommandLine.Text := itm.CommandLine;
      rgParam.ItemIndex := Ord(itm.ParamType);

      ShowModal;

      if ModalResult = mrCancel then Exit;

      //取得新的项目
      itm.ShortCutType := scItem;
      itm.ShortCut := lbledtShortCut.Text;
      itm.Name := lbledtName.Text;
      itm.CommandLine := lbledtCommandLine.Text;
      itm.ParamType := TParamType(rgParam.ItemIndex);

      //保存新的项目
      ShortCutMan.SaveShortCutList;
      ShortCutMan.LoadShortCutList;

      //刷新
      edtShortCutChange(Sender);
    end;
  finally
    ShortCutForm.Free;
  end;
end;

procedure TALTRunForm.actExecuteExecute(Sender: TObject);
var
  cmd: string;
  ret: Integer;
  ShortCutForm: TShortCutForm;
  Item: TShortCutItem;
  ShellApplication: Variant;
  i: Cardinal;
  ch: Char;
begin
  TraceMsg('actExecuteExecute(%d)', [lstShortCut.ItemIndex]);

  //若下面有选中某项
  if lstShortCut.Count > 0 then
  begin
    //cmd := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]).CommandLine;
    //if cmd = '' then Exit;

    evtMainMinimize(Self);

    //WINEXEC//调用可执行文件
    //winexec('command.com /c copy *.* c:\',SW_Normal);
    //winexec('start abc.txt');
    //ShellExecute或ShellExecuteEx//启动文件关联程序
    //function executefile(const filename,params,defaultDir:string;showCmd:integer):THandle;
    //ExecuteFile('C:\abc\a.txt','x.abc','c:\abc\',0);
    //ExecuteFile('http://tingweb.yeah.net','','',0);
    //ExecuteFile('mailto:tingweb@wx88.net','','',0);
    //如果WinExec返回值小于32，就是失败，那就使用ShellExecute来搞

    //这种发送键盘的方法并不太好，所以屏蔽掉
    //    for i := 1 to Length(cmd) do
    //    begin
    //      ch := UpCase(cmd[i]);
    //      case ch of
    //        'A'..'Z': PostKeyEx32(ORD(ch), [], FALSE);
    //        '0'..'9': PostKeyEx32(ORD(ch), [], FALSE);                  R
    //        '.': PostKeyEx32(VK_DECIMAL, [], FALSE);
    //        '+': PostKeyEx32(VK_ADD, [], FALSE);
    //        '-': PostKeyEx32(VK_SUBTRACT, [], FALSE);
    //        '*': PostKeyEx32(VK_MULTIPLY, [], FALSE);
    //        '/': PostKeyEx32(VK_DIVIDE, [], FALSE);
    //        ' ': PostKeyEx32(VK_SPACE, [], FALSE);
    //        ';': PostKeyEx32(186, [], FALSE);
    //        '=': PostKeyEx32(187, [], FALSE);
    //        ',': PostKeyEx32(188, [], FALSE);
    //        '[': PostKeyEx32(219, [], FALSE);
    //        '\': PostKeyEx32(220, [], FALSE);
    //        ']': PostKeyEx32(221, [], FALSE);
    //      else
    //        ShowMessage(ch);
    //      end;
    //      //sleep(50);
    //    end;
    //
    //    PostKeyEx32(VK_RETURN, [], FALSE);

    //下面这种方法也不好
    //如果一种方式无法运行，就换一种
    //if WinExec(PChar(cmd), SW_SHOWNORMAL) < 33 then
    //begin
    //  if ShellExecute(0, 'open', PChar(cmd), nil, nil, SW_SHOWNORMAL) < 33 then
    //  begin
    //    //写批处理的这招，先不用
    //    //WriteLineToFile('D:\My\Code\Delphi\HotRun\Bin\shit.bat', cmd);
    //    //if ShellExecute(0, 'open', 'D:\My\Code\Delphi\HotRun\Bin\shit.bat', nil, nil, SW_HIDE) < 33 then
    //    Application.MessageBox(PChar(Format('Can not execute "%s"', [cmd])), 'Warning', MB_OK + MB_ICONWARNING);
    //  end;
    //end;

    //ShortCutMan.Execute(cmd);
    ShortCutMan.Execute(TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]), edtShortCut.Text);

    //下面的方法，有时候键盘序列会发到其他窗口
    //打开“开始/运行”对话框，发送键盘序列
    //ShellApplication := CreateOleObject('Shell.Application');
    //ShellApplication.FileRun;
    //sleep(500);
    //SendKeys(PChar(cmd), False, True);
    //SendKeys('~', True, True);                         //回车

    //如果需要执行完就退出
    if ExitWhenExecute then tmrExit.Enabled := True;
  end
  else
    if Application.MessageBox(
      PChar(Format(resNoItemAndAdd, [edtShortCut.Text])),
      PChar(resInfo), MB_OKCANCEL + MB_ICONQUESTION) = IDOK then actAddItemExecute(Sender);
end;

procedure TALTRunForm.actHideExecute(Sender: TObject);
begin
  TraceMsg('actHideExecute()');

  evtMainMinimize(Sender);
end;

procedure TALTRunForm.actOpenDirExecute(Sender: TObject);
var
  itm: TShortCutItem;
  Index: Integer;
  cmdobj: TCmdObject;
begin
  TraceMsg('actOpenDirExecute(%d)', [lstShortCut.ItemIndex]);

  if lstShortCut.ItemIndex < 0 then Exit;

  itm := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]);
  Index := ShortCutMan.GetShortCutItemIndex(itm);

  if not (FileExists(itm.CommandLine) or DirectoryExists(itm.CommandLine)) then Exit;

  cmdobj := TCmdObject.Create;
  cmdobj.Param := '';
  cmdobj.Command := ExtractFileDir(itm.CommandLine);

  if (Pos('.\', itm.CommandLine) > 0) or (Pos('..\', itm.CommandLine) > 0) then
    cmdobj.WorkingDir := ExtractFilePath(Application.ExeName)
  else if FileExists(itm.CommandLine) then
    cmdobj.WorkingDir := ExtractFileDir(itm.CommandLine)
  else
    cmdobj.WorkingDir := '';

  ShortCutMan.Execute(cmdobj);
end;

procedure TALTRunForm.actSelectChangeExecute(Sender: TObject);
begin
  TraceMsg('actSelectChangeExecute(%d)', [lstShortCut.ItemIndex]);

  if lstShortCut.ItemIndex = -1 then Exit;

  lblShortCut.Caption := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]).Name;
  lblShortCut.Hint := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]).CommandLine;
  //edtCommandLine.Hint := lblShortCut.Hint;
  edtCommandLine.Text := resCMDLine + lblShortCut.Hint;

  if DirAvailable then lblShortCut.Caption := '[' + lblShortCut.Caption + ']';
end;

procedure TALTRunForm.actShortCutExecute(Sender: TObject);
const
  TEST_ITEM_COUNT = 10;
  Test_Array: array[0..TEST_ITEM_COUNT - 1] of Integer = (3, 0, 8, 2, 8, 6, 1, 3, 0, 8);

var
  ShortCutManForm: TShortCutManForm;
  StringList: TStringList;
  i: Cardinal;
  str: string;
  Item: TShortCutItem;
begin
  TraceMsg('actShortCutExecute()');

  if DEBUG_MODE then
  begin
    //Randomize;
    //StringList := TStringList.Create;
    //try
    //  TraceMsg('- Before QuickSort');
    //
    //  for i := 0 to TEST_ITEM_COUNT - 1 do
    //  begin
    //    Item := TShortCutItem.Create;
    //    with Item do
    //    begin
    //      ShortCutType := scItem;
    //      Freq := Test_Array[i];                       //Random(TEST_ITEM_COUNT);
    //      Rank := Freq;
    //      Name := IntToStr(Rank);
    //      ParamType := ptNone;
    //
    //      TraceMsg('  - [%d] = %d', [i, Freq]);
    //    end;
    //
    //    StringList.AddObject(Item.Name, Item);
    //  end;
    //
    //  ShortCutMan.QuickSort(StringList, 0, TEST_ITEM_COUNT - 1);
    //
    //  TraceMsg('- After QuickSort');
    //
    //  for i := 0 to TEST_ITEM_COUNT - 1 do
    //  begin
    //    Item := TShortCutItem(StringList.Objects[i]);
    //    with Item do
    //    begin
    //      TraceMsg('  - [%d] = %d', [i, Freq]);
    //    end;
    //
    //    Item.Free;
    //  end;
    //
    //  TraceMsg('- End QuickSort');
    //finally
    //  StringList.Free;
    //end;

    //Exit;
  end;

  try
    ShortCutManForm := TShortCutManForm.Create(Self);
    with ShortCutManForm do
    begin
      StopTimer;
      ShowModal;

      if ModalResult = mrOk then
      begin
        //刷新快捷项列表
        ShortCutMan.LoadFromListView(lvShortCut);
        ShortCutMan.SaveShortCutList;

        if m_IsShow then
        begin
          edtShortCutChange(Sender);
          edtShortCut.SetFocus;
        end;
      end;

      RestartTimer(HideDelay);
    end;
  finally
    ShortCutManForm.Free;
  end;
end;

procedure TALTRunForm.actShowExecute(Sender: TObject);
var
  lg: longint;
  WinMediaFileName, PopupFileName: string;
begin
  TraceMsg('actShowExecute()');

  if ParamForm <> nil then
    ParamForm.ModalResult := mrCancel;

  ShortCutMan.LoadShortCutList;

  if edtShortCut.Text = '' then
    edtShortCutChange(Sender)
  else
    edtShortCut.Text := '';

  Self.Show;

  if m_IsFirstShow then
  begin
    m_IsFirstShow := False;

    //设置窗体位置
    if (WinTop <= 0) or (WinLeft <= 0) then
    begin
      Self.Position := poScreenCenter;
    end
    else
    begin
      Self.Top := WinTop;
      Self.Left := WinLeft;
    end;

    //字体
    StrToFont(TitleFontStr, lblShortCut.Font);
    StrToFont(KeywordFontStr, edtShortCut.Font);
    StrToFont(ListFontStr, lstShortCut.Font);

    //修改背景图
    if not FileExists(ExtractFilePath(Application.ExeName) + BGFileName) then
      imgBackground.Picture.SaveToFile(ExtractFilePath(Application.ExeName) + BGFileName);

    if ShowSkin then
      imgBackground.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + BGFileName)
    else
      imgBackground.Picture := nil;

    //半透明效果
    lg := getWindowLong(Handle, GWL_EXSTYLE);
    lg := lg or WS_EX_LAYERED;
    SetWindowLong(handle, GWL_EXSTYLE, lg);

    //第二个参数是指定透明颜色
    //第二个参数若为0则使用第四个参数设置alpha值，从0到255
    SetLayeredWindowAttributes(handle, AlphaColor, Alpha, LWA_ALPHA or LWA_COLORKEY);

    //圆角矩形窗体
    SetWindowRgn(Handle, CreateRoundRectRgn(0, 0, Width, Height, 25, 25), True);
  end;

  Application.Restore;
  SetForegroundWindow(Application.Handle);
  m_IsShow := True;
  edtShortCut.SetFocus;
  GetLastCmdList;
  RestartTimer(HideDelay);

  //保存窗体位置
  WinTop := Self.Top;
  WinLeft := Self.Left;

  //取得最近一次击键时间
  m_LastActiveTime := GetTickCount;

  //播放声音
  if PlayPopupNotify then
  begin
    PopupFileName := ExtractFilePath(Application.ExeName) + 'Popup.wav';
    //WinMediaFileName := GetEnvironmentVariable('windir') + '\Media\ding.wav';
    if not FileExists(PopupFileName) then
      //CopyFile(PChar(WinMediaFileName), PChar(PopupFileName), True);
      ExtractRes('WAVE', 'PopupWav', 'Popup.wav');

    if FileExists(PopupFileName) then
      PlaySound(PChar(PopupFileName), 0, snd_ASYNC)
    else
      PlaySound(PChar('PopupWav'), HInstance, snd_ASYNC or SND_RESOURCE);
  end;
end;

function TALTRunForm.ApplyHotKey: Boolean;
begin
  Result := False;

  TraceMsg('ApplyHotKey(%s)', [HotKeyStr]);

  m_HotKeyVar := TextToHotKey(HotKeyStr, LOCALIZED_KEYNAMES);

  if (m_HotKeyVar = 0) or (hkmMain.AddHotKey(m_HotKeyVar) = 0) then
  begin
    Application.MessageBox(PChar(Format(resHotKeyError, [HotKeyStr])),
      PChar(resWarning), MB_OK + MB_ICONWARNING);

    Exit;
  end;

  Result := True;
end;

procedure TALTRunForm.btnShortCutClick(Sender: TObject);
begin
  TraceMsg('btnShortCutClick()');

  if DEBUG_MODE then
  begin
    if ShortCutMan.Test then
      ShowMessage('True')
    else
      ShowMessage('False');
  end
  else
  begin
    actShortCutExecute(Sender);
    if m_IsShow then edtShortCut.SetFocus;
  end;
end;

function TALTRunForm.DirAvailable: Boolean;
var
  itm: TShortCutItem;
  Index: Integer;
begin
  Result := False;

  if lstShortCut.ItemIndex < 0 then Exit;

  itm := TShortCutItem(lstShortCut.Items.Objects[lstShortCut.ItemIndex]);
  Index := ShortCutMan.GetShortCutItemIndex(itm);

  if Pos('\\', itm.CommandLine) > 0 then Exit;

  Result := (FileExists(itm.CommandLine) or DirectoryExists(itm.CommandLine));

  if Result then
    TraceMsg('DirAvailable(%s) = True', [itm.CommandLine])
  else
    TraceMsg('DirAvailable(%s) = False', [itm.CommandLine]);
end;

procedure TALTRunForm.DisplayShortCutItem(Item: TShortCutItem);
begin
  TraceMsg('DisplayShortCutItem()');

  lblShortCut.Caption := Item.Name;
  lblShortCut.Hint := Item.CommandLine;
  edtCommandLine.Text := resCMDLine + Item.CommandLine;
  if DirAvailable then lblShortCut.Caption := '[' + Item.Name + ']';
end;

procedure TALTRunForm.edtCommandLineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TraceMsg('edtCommandLineKeyDown( #%d = %s )', [Key, Chr(Key)]);

  if not ((ssShift in Shift) or (ssAlt in Shift) or (ssCtrl in Shift)) then
    case Key of
      //回车
      13: ;

      VK_PRIOR, VK_NEXT: ;
    else
      if m_IsShow then
      begin
        //传到这里的键，都转发给edtShortCut
        PostMessage(edtShortCut.Handle, WM_KEYDOWN, Key, 0);
        edtShortCut.SetFocus;
      end;
    end;
end;

procedure TALTRunForm.edtShortCutChange(Sender: TObject);
var
  i, j, k: Cardinal;
  Rank, ExistRank: Integer;
  IsInserted: Boolean;
  StringList: TStringList;
  HintIndex: Integer;
begin
  TraceMsg('edtShortCutChange(%s)', [edtShortCut.Text]);

  lblShortCut.Caption := '';
  lblShortCut.Hint := '';
  lstShortCut.Hint := '';
  edtCommandLine.Text := '';

  lstShortCut.Clear;

  //更新列表
  try
    StringList := TStringList.Create;

    //lstShortCut.Hide;

    if ShortCutMan.FilterKeyWord(edtShortCut.Text, StringList) then
    begin
      if ShowTopTen then
      begin
        for i := 0 to 9 do
          if i >= StringList.Count then
            Break
          else
            lstShortCut.Items.AddObject(StringList[i], StringList.Objects[i])
      end
      else
        lstShortCut.Items.Assign(StringList);
    end;

    //lstShortCut.Show;
  finally
    StringList.Free;
  end;

  //显示第一项
  if lstShortCut.Count = 0 then
  begin
    lblShortCut.Caption := '';
    lblShortCut.Hint := '';
    lstShortCut.Hint := '';
    edtCommandLine.Text := '';

    //看最后一个字符是否是数字0-9
    if EnableNumberKey and m_LastKeyIsNumKey then
      if (edtShortCut.Text[Length(edtShortCut.Text)] in ['0'..'9']) then
      begin
        k := StrToInt(edtShortCut.Text[Length(edtShortCut.Text)]);

        if IndexFrom0to9 then
        begin
          if k <= m_LastShortCutListCount - 1 then
          begin
            evtMainMinimize(Self);
            ShortCutMan.Execute(TShortCutItem(m_LastShortCutPointerList[k]),
              Copy(edtShortCut.Text, 1, Length(edtShortCut.Text) - 1));
          end;
        end
        else
        begin
          if k = 0 then k := 10;

          if k <= m_LastShortCutListCount - 1 then
          begin
            evtMainMinimize(Self);
            ShortCutMan.Execute(TShortCutItem(m_LastShortCutPointerList[k - 1]),
              Copy(edtShortCut.Text, 1, Length(edtShortCut.Text) - 1));
          end;
        end;
      end;

    //最后一个如果是空格
    if (edtShortCut.Text <> '') and (edtShortCut.Text[Length(edtShortCut.Text)] in [' ']) then
    begin
      if (m_LastShortCutListCount > 0)
        and (m_LastShortCutCmdIndex >= 0)
        and (m_LastShortCutCmdIndex < m_LastShortCutListCount) then
      begin
        evtMainMinimize(Self);
        ShortCutMan.Execute(TShortCutItem(m_LastShortCutPointerList[m_LastShortCutCmdIndex]),
          Copy(edtShortCut.Text, 1, Length(edtShortCut.Text) - 1));
      end;
    end;
  end
  else
  begin
    lstShortCut.ItemIndex := 0;
    lblShortCut.Caption := TShortCutItem(lstShortCut.Items.Objects[0]).Name;
    lblShortCut.Hint := TShortCutItem(lstShortCut.Items.Objects[0]).CommandLine;
    edtCommandLine.Text := resCMDLine + lblShortCut.Hint;
  end;

  //如果可以打开文件夹，标记下
  if DirAvailable then lblShortCut.Caption := '[' + lblShortCut.Caption + ']';

  //刷新上一次的列表
  GetLastCmdList;

  //刷新提示
  RefreshOperationHint;
end;

procedure TALTRunForm.edtShortCutKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Index: Integer;
begin
  TraceMsg('edtShortCutKeyDown( #%d = %s )', [Key, Chr(Key)]);

  m_LastKeyIsNumKey := False;

  case Key of
    VK_UP:
      with lstShortCut do
        if Visible then
        begin
          //为了防止向上键导致光标位置移动，故吞掉之
          Key := VK_NONAME;

          //列表上下走
          if ItemIndex = -1 then
            ItemIndex := Count - 1
          else
            if ItemIndex = 0 then
              ItemIndex := Count - 1
            else
              ItemIndex := ItemIndex - 1;

          DisplayShortCutItem(TShortCutItem(Items.Objects[ItemIndex]));
        end;

    VK_DOWN:
      with lstShortCut do
        if Visible then
        begin
          //为了防止向下键导致光标位置移动，故吞掉之
          Key := VK_NONAME;

          //列表上下走
          if ItemIndex = -1 then
            ItemIndex := 0
          else
            if ItemIndex = Count - 1 then
              ItemIndex := 0
            else
              ItemIndex := ItemIndex + 1;

          DisplayShortCutItem(TShortCutItem(Items.Objects[ItemIndex]));
        end;

    VK_PRIOR:
      with lstShortCut do
      begin
        Key := VK_NONAME;
        PostMessage(lstShortCut.Handle, WM_KEYDOWN, VK_PRIOR, 0);
      end;

    VK_NEXT:
      with lstShortCut do
      begin
        Key := VK_NONAME;
        PostMessage(lstShortCut.Handle, WM_KEYDOWN, VK_NEXT, 0);
      end;

    //数字键0-9，和小键盘数字键. ALT+Num 或 CTRL+Num 都可以执行
    48..57, 96..105:
      begin
        m_LastKeyIsNumKey := True;

        if (ssCtrl in Shift) or (ssAlt in Shift) then
        begin
          if Key >= 96 then
            Index := Key - 96
          else
            Index := Key - 48;

          //看看数字是否超出已有总数
          if IndexFrom0to9 and (Index > lstShortCut.Count - 1) then Exit;
          if (not IndexFrom0to9) and (Index > lstShortCut.Count) then Exit;

          evtMainMinimize(Self);

          if IndexFrom0to9 then
            ShortCutMan.Execute(TShortCutItem(lstShortCut.Items.Objects[Index]), edtShortCut.Text)
          else
            ShortCutMan.Execute(TShortCutItem(lstShortCut.Items.Objects[(Index + 9) mod 10]), edtShortCut.Text);
        end;
      end;

    //CTRL+D，打开文件夹
    68:
      begin
        m_LastKeyIsNumKey := True;

        if (ssCtrl in Shift) then
        begin
          if not DirAvailable then Exit;

          evtMainMinimize(Self);
          actOpenDirExecute(Sender);
        end;
      end;

    VK_ESCAPE:
      begin
        //如果不为空，就清空，否则隐藏
        if edtShortCut.Text = '' then
          evtMainMinimize(Self)
        else
          edtShortCut.Text := '';
      end;
  end;

  if ShowOperationHint
    and (lstShortCut.ItemIndex > 0)
    and (Length(edtShortCut.Text) < 10)
    and (lstShortCut.Items[lstShortCut.ItemIndex][2] in ['0'..'9']) then
    edtHint.Text := Format(resRunNum,
      [lstShortCut.Items[lstShortCut.ItemIndex][2],
      lstShortCut.Items[lstShortCut.ItemIndex][2]]);
end;

procedure TALTRunForm.edtShortCutKeyPress(Sender: TObject; var Key: Char);
begin
  TraceMsg('edtShortCutKeyPress(%d)', [Key]);

  //如果回车，就执行程序
  if Key = #13 then
  begin
    Key := #0;
    actExecuteExecute(Sender);
  end;
end;

procedure TALTRunForm.edtShortCutMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
  TraceMsg('edtShortCutMouseActivate()');

  RestartTimer(HideDelay);
end;

procedure TALTRunForm.evtMainDeactivate(Sender: TObject);
begin
  TraceMsg('evtMainDeactivate(%d)', [GetTickCount - m_LastActiveTime]);

  //如果失去焦点，且离上一次击键超过一定时间，就隐藏
  if (GetTickCount - m_LastActiveTime) > 1000 then
    evtMainMinimize(Sender)
  else
  begin
    Application.BringToFront;
    RestartTimer(1);
  end;
end;

procedure TALTRunForm.evtMainIdle(Sender: TObject; var Done: Boolean);
begin
  ReduceWorkingSize;
end;

procedure TALTRunForm.evtMainMinimize(Sender: TObject);
begin
  inherited;

  TraceMsg('evtMainMinimize()');

  m_IsShow := False;
  self.Hide;
  StopTimer;
end;

procedure TALTRunForm.FormActivate(Sender: TObject);
begin
  TraceMsg('FormActivate()');

  RestartTimer(HideDelay);
end;

procedure TALTRunForm.FormCreate(Sender: TObject);
var
  lg: longint;
  LangForm: TLangForm;
  LangList: TStringList;
  i: Cardinal;
begin
  //初始化不显示图标
  ntfMain.IconVisible := False;

  //窗体防闪
  Self.DoubleBuffered := True;

  //Load 配置
  LoadSettings;

  //如果是第一次使用，提示选择语言
  if IsRunFirstTime then
  begin
    try
      LangForm := TLangForm.Create(Self);

      LangForm.cbbLang.Items.Add(DEFAULT_LANG);
      LangForm.cbbLang.ItemIndex := 0;

      LangList := TStringList.Create;
      if GetLangList(LangList) then
      begin
        if LangList.Count > 0 then
        begin
          for i := 0 to LangList.Count - 1 do
            if LangForm.cbbLang.Items.IndexOf(LangList.Strings[i]) < 0 then
              LangForm.cbbLang.Items.Add(LangList.Strings[i]);

          for i := 0 to LangForm.cbbLang.Items.Count - 1 do
            if LangForm.cbbLang.Items[i] = Lang then
            begin
              LangForm.cbbLang.ItemIndex := i;
              Break;
            end;
        end;
      end;

      if LangList.Count > 0 then
      begin
        LangForm.ShowModal;

        if LangForm.ModalResult = mrOk then
        begin
          Lang := LangForm.cbbLang.Text;
          SetActiveLanguage;
        end;
      end;

    finally
      LangList.Free;
      LangForm.Free;
    end;
  end
  else
    SetActiveLanguage;

  //Load 快捷方式
  ShortCutMan := TShortCutMan.Create;
  ShortCutMan.LoadShortCutList;

  //初始化上次列表
  m_LastShortCutCmdIndex := -1;
  m_LastKeyIsNumKey := False;

  //若有参数，则判断之
  if ParamStr(1) <> '' then
  begin
    if ParamStr(1) = RESTART_FLAG then
    begin
      Sleep(2000);
    end
    else if ParamStr(1) = CLEAN_FLAG then
    begin
      if Application.MessageBox(PChar(resCleanConfirm), PChar(resInfo),
        MB_YESNO + MB_ICONQUESTION + MB_TOPMOST) = IDYES then
      begin
        SetAutoRun(TITLE, '', False);
        AddMeToSendTo(TITLE, False);
      end;

      Application.Terminate;
      Exit;
    end
    else
    begin
      ShortCutMan.AddFileShortCut(ParamStr(1));
      Application.Terminate;
      Exit;
    end;
  end;

  if IsRunningInstance('ALTRUN_MUTEX') then
  begin
    Application.Terminate;
    Exit;
  end;

  //LOG
  InitLogger;

  //Trace
  TraceMsg('FormCreate()');

  //干掉老的HotRun的启动项和SendTo
  if LowerCase(ExtractFilePath(GetAutoRunItemPath('HotRun')))
    = LowerCase(ExtractFilePath(Application.ExeName)) then
    SetAutoRun('HotRun', '', False);

  if LowerCase(ExtractFilePath(GetAutoRunItemPath('HotRun.exe')))
    = LowerCase(ExtractFilePath(Application.ExeName)) then
    SetAutoRun('HotRun.exe', '', False);

  if LowerCase(ExtractFilePath(ResolveLink(GetSendToDir + '\HotRun.lnk')))
    = LowerCase(ExtractFilePath(Application.ExeName)) then
    AddMeToSendTo('HotRun', False);

  if FileExists(ExtractFilePath(Application.ExeName) + 'HotRun.ini') then
    RenameFile(ExtractFilePath(Application.ExeName) + 'HotRun.ini',
      ExtractFilePath(Application.ExeName) + TITLE + '.ini');

  if LowerCase(ExtractFilePath(GetAutoRunItemPath('ALTRun.exe')))
    = LowerCase(ExtractFilePath(Application.ExeName)) then
    SetAutoRun('ALTRun.exe', '', False);

  //配置设置
  ApplyHotKey;

  //配置菜单语言
  actShow.Caption := resMenuShow;
  actShortCut.Caption := resMenuShortCut;
  actConfig.Caption := resMenuConfig;
  actAbout.Caption := resMenuAbout;
  actClose.Caption := resMenuClose;

  //配置Hint
  btnShortCut.Hint := resBtnShortCutHint;
  btnClose.Hint := resBtnFakeCloseHint;
  edtShortCut.Hint := resEdtShortCutHint;

  //先删除后增加，目的是防止有人放到别的目录运行，导致出现多个启动项
  SetAutoRun(TITLE, Application.ExeName, False);

  //如果是第一次使用，提示是否添加到自动启动
  if IsRunFirstTime then
    AutoRun := (Application.MessageBox(PChar(resAutoRunWhenStart),
      PChar(resInfo), MB_YESNO + MB_ICONQUESTION + MB_TOPMOST) = IDYES);
  SetAutoRun(TITLE, Application.ExeName, AutoRun);

  AddMeToSendTo(TITLE, False);

  //如果是第一次使用，提示是否添加到发送到
  if IsRunFirstTime then
    AddToSendTo := (Application.MessageBox(PChar(resAddToSendToMenu),
      PChar(resInfo), MB_YESNO + MB_ICONQUESTION + MB_TOPMOST) = IDYES);

  AddMeToSendTo(TITLE, AddToSendTo);

  SaveSettings;

  //第一次显示
  m_IsFirstShow := True;

  //第一次双击图标
  m_IsFirstDblClickIcon := True;

  //显示图标
  ntfMain.IconVisible := True;

  //提示
  if ShowStartNotification then
    ntfMain.ShowBalloonHint(resInfo,
      Format(resStarted + #13#10 + resPressKeyToShowMe,
      [TITLE, ALTRUN_VERSION, HotKeyStr]), bitInfo, 5);

  //浮动提示
  ntfMain.Hint := Format(resMainHint, [TITLE, ALTRUN_VERSION, #13#10, HotKeyStr]);

  if ShowMeWhenStart then actShowExecute(Sender);
end;

procedure TALTRunForm.FormDestroy(Sender: TObject);
begin
  ShortCutMan.Free;
end;

procedure TALTRunForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TraceMsg('FormKeyDown( #%d = %s )', [Key, Chr(Key)]);

  //取得最近一次击键时间
  m_LastActiveTime := GetTickCount;

  //重起Timer
  RestartTimer(HideDelay);

  //如果命令行获得焦点，就什么也不管
  if edtCommandLine.Focused then Exit;

  case Key of
    VK_UP:
      with lstShortCut do
      begin
        //为了防止向上键导致光标位置移动，故吞掉之
        Key := VK_NONAME;

        if Count = 0 then Exit;

        //列表上下走
        if ItemIndex = -1 then
          ItemIndex := Count - 1
        else
          if ItemIndex = 0 then
            ItemIndex := Count - 1
          else
            ItemIndex := ItemIndex - 1;

        DisplayShortCutItem(TShortCutItem(Items.Objects[ItemIndex]));
        m_LastShortCutCmdIndex := ItemIndex;
      end;

    VK_DOWN:
      with lstShortCut do
      begin
        //为了防止向下键导致光标位置移动，故吞掉之
        Key := VK_NONAME;

        if Count = 0 then Exit;

        //列表上下走
        if ItemIndex = -1 then
          ItemIndex := 0
        else
          if ItemIndex = Count - 1 then
            ItemIndex := 0
          else
            ItemIndex := ItemIndex + 1;

        DisplayShortCutItem(TShortCutItem(Items.Objects[ItemIndex]));
        m_LastShortCutCmdIndex := ItemIndex;
      end;

    VK_F1:
      begin
        Key := VK_NONAME;
        actAboutExecute(Sender);
      end;

    VK_F2:
      begin
        Key := VK_NONAME;
        actEditItemExecute(Sender);
      end;

    VK_INSERT:
      begin
        Key := VK_NONAME;
        actAddItemExecute(Sender);
      end;

    VK_DELETE:
      begin
        Key := VK_NONAME;
        actDeleteItemExecute(Sender);
      end;

    VK_ESCAPE:
      begin
        Key := VK_NONAME;

        //如果不为空，就清空，否则隐藏
        if edtShortCut.Text = '' then
          evtMainMinimize(Self)
        else
          edtShortCut.Text := '';
      end;

    //ALT+S
    $53:
      begin
        if (ssAlt in Shift) then actShortCutExecute(Sender);
      end;
  else
    begin
      if m_IsShow then
        edtShortCut.SetFocus;
    end;
  end;
end;

procedure TALTRunForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  TraceMsg('FormKeyPress(%s)', [Key]);

  case Key of
    //如果回车，就执行程序
    #13:
      begin
        Key := #0;
        if Self.Visible then actExecuteExecute(Sender);
      end;

    //如果ESC，就吞掉
    #27:
      begin
        Key := #0;
      end;
  end;
end;

function TALTRunForm.GetLangList(List: TStringList): Boolean;
var
  i: Cardinal;
  FileList: TStringList;
begin
  TraceMsg('GetLangList()');

  Result := False;

  try
    FileList := TStringList.Create;
    List.Clear;

    if GetFileListInDir(FileList, ExtractFileDir(Application.ExeName), 'lang', False) then
    begin
      if FileList.Count > 0 then
        for i := 0 to FileList.Count - 1 do
          List.Add(Copy(FileList.Strings[i], 1, Length(FileList.Strings[i]) - 5));

      Result := True;
    end
    else
      Result := False;
  finally
    FileList.Free;
  end;
end;

procedure TALTRunForm.GetLastCmdList;
var
  i, n: Cardinal;
  ShortCutItem: TShortCutItem;
begin
  TraceMsg('GetLastCmdList()');

  m_LastShortCutListCount := 0;
  m_LastShortCutCmdIndex := -1;

  if lstShortCut.Count > 0 then
  begin
    m_LastShortCutCmdIndex := lstShortCut.ItemIndex;

    if lstShortCut.Count > 10 then
      n := 10
    else
      n := lstShortCut.Count;

    for i := 0 to n - 1 do
    begin
      if lstShortCut.Items.Objects[i] <> nil then
      begin
        m_LastShortCutPointerList[m_LastShortCutListCount] := Pointer(lstShortCut.Items.Objects[i]);
        Inc(m_LastShortCutListCount);
      end;
    end;
  end;
end;

procedure TALTRunForm.hkmMainHotKeyPressed(HotKey: Cardinal; Index: Word);
begin
  TraceMsg('hkmMainHotKeyPressed()');

  if DEBUG_SORT then
  begin
    actShortCutExecute(Self);
    Exit;
  end;

  if m_IsShow then
    actHideExecute(Self)
  else
    actShowExecute(Self);
end;

procedure TALTRunForm.imgBackgroundMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TALTRunForm.lblShortCutMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
  TraceMsg('lblShortCutMouseActivate()');

  RestartTimer(HideDelay);
end;

procedure TALTRunForm.lblShortCutMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TALTRunForm.lstShortCutKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  TraceMsg('lstShortCutKeyDown( #%d = %s )', [Key, Chr(Key)]);

  case Key of
    //    VK_F2:
    //      actEditItemExecute(Sender);
    //
    //    VK_INSERT:
    //      actAddItemExecute(Sender);
    //
    //    VK_DELETE:
    //      actDeleteItemExecute(Sender);

    //回车
    13: ;

    VK_PRIOR, VK_NEXT: ;
  else
    if m_IsShow then
    begin
      //传到这里的键，都转发给edtShortCut
      PostMessage(edtShortCut.Handle, WM_KEYDOWN, Key, 0);
      edtShortCut.SetFocus;
    end;
  end;
end;

procedure TALTRunForm.lstShortCutMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
  TraceMsg('lstShortCutMouseActivate()');

  RestartTimer(HideDelay);
end;

procedure TALTRunForm.lstShortCutMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TraceMsg('lstShortCutMouseDown()');

  //右键点击，就选中该项
  if Button = mbRight then lstShortCut.Perform(WM_LBUTTONDOWN, 0, (y shl 16) + x);
end;

procedure TALTRunForm.ntfMainDblClick(Sender: TObject);
begin
  TraceMsg('ntfMainDblClick()');

  if m_IsFirstDblClickIcon then
  begin
    m_IsFirstDblClickIcon := False;

    Application.MessageBox(
      PChar(Format(resShowMeByHotKey, [HotKeyStr])),
      PChar(resInfo), MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
  end;

  if m_IsShow then
    actHideExecute(Self)
  else
    actShowExecute(Self);
end;

procedure TALTRunForm.pmListPopup(Sender: TObject);
begin
  mniOpenDir.Visible := DirAvailable;
  mniN1.Visible := mniOpenDir.Visible
end;

procedure TALTRunForm.RefreshOperationHint;
var
  HintIndex: Integer;
begin
  TraceMsg('RefreshOperationHint()');

  //刷新提示
  if not ShowOperationHint then
    edtHint.Hide
  else
  begin
    edtHint.Show;
    if Length(edtShortCut.Text) = 0 then
    begin
      //随机挑选一个提示显示出来
      Randomize;

      repeat
        HintIndex := Random(Length(HintList));
      until Trim(HintList[HintIndex]) <> '';

      edtHint.Text := HintList[HintIndex];
    end
    else if Length(edtShortCut.Text) < 10 then
    begin
      if lstShortCut.Count = 0 then
      begin
        edtHint.Text := resKeyToAdd;
      end
      else if DirAvailable then
        edtHint.Text := resKeyToOpenFolder
      else
        edtHint.Text := resKeyToRun;
    end
    else
      edtHint.Hide;
  end;
end;

procedure TALTRunForm.RestartMe;
begin
  TraceMsg('RestartMe()');

  ShellExecute(0, nil, PChar(Application.ExeName), RESTART_FLAG, nil, SW_SHOWNORMAL);
  actCloseExecute(Self);
end;

procedure TALTRunForm.RestartTimer(Delay: Integer);
begin
  TraceMsg('RestartTimer()');

  if m_IsShow then
  begin
    tmrHide.Enabled := False;
    tmrHide.Interval := Delay * 1000;
    tmrHide.Enabled := True;
  end;
end;

procedure TALTRunForm.StopTimer;
begin
  TraceMsg('StopTimer()');

  tmrHide.Enabled := False;
end;

procedure TALTRunForm.tmrExitTimer(Sender: TObject);
begin
  TraceMsg('tmrExitTimer()');

  tmrExit.Enabled := False;
  actCloseExecute(Sender);
end;

procedure TALTRunForm.tmrHideTimer(Sender: TObject);
begin
  TraceMsg('tmrHideTimer()');

  evtMainMinimize(Sender);
end;

procedure TALTRunForm.WndProc(var Msg: TMessage);
begin
  case msg.Msg of
    WM_SYSCOMMAND:                                     //点击关闭按钮
      if Msg.WParam = SC_CLOSE then
        if DEBUG_MODE then
          actCloseExecute(Self)                        //如果Debug模式，可以Alt-F4关闭
        else
          evtMainMinimize(Self)                        //正常模式，仅仅隐藏
      else
        inherited;

    WM_QUERYENDSESSION, WM_ENDSESSION:                 //系统关机
      begin
        TraceMsg('System shutdown');
        actCloseExecute(Self);

        inherited;
      end;
  else
    inherited;
  end;
end;

end.

