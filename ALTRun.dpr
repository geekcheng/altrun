program ALTRun;

{$R 'Res\ALTRun.res' 'Res\ALTRun.rc'}

uses
  CnMemProf,
  Forms,
  SysUtils,
  pngimage,
  frmALTRun in 'Form\frmALTRun.pas' {ALTRunForm},
  frmConfig in 'Form\frmConfig.pas' {ConfigForm},
  frmShortCut in 'Form\frmShortCut.pas' {ShortCutForm},
  HotLog in '3rdUnit\HotLog\HotLog.pas',
  untUtilities in 'Unit\untUtilities.pas',
  untALTRunOption in 'Unit\untALTRunOption.pas',
  frmShortCutMan in 'Form\frmShortCutMan.pas' {ShortCutManForm},
  untShortCutMan in 'Unit\untShortCutMan.pas',
  frmAbout in 'Form\frmAbout.pas' {AboutForm},
  frmParam in 'Form\frmParam.pas' {ParamForm},
  frmHelp in 'Form\frmHelp.pas' {HelpForm},
  frmInvalid in 'Form\frmInvalid.pas' {InvalidForm},
  frmLang in 'Form\frmLang.pas' {LangForm};

{$R *.res}

begin
  //----- 内存泄漏管理
  mmPopupMsgDlg := DEBUG_MODE;
  mmShowObjectInfo := DEBUG_MODE;
  mmUseObjectList := DEBUG_MODE;
  mmSaveToLogFile := DEBUG_MODE;

  //----- 主程序开始
  Application.Initialize;

  IsRunFirstTime := not FileExists(ExtractFilePath(Application.ExeName) + TITLE + '.ini');
  LoadSettings;

  Application.Title := TITLE;
  Application.CreateForm(TALTRunForm, ALTRunForm);
  Application.CreateForm(TParamForm, ParamForm);
  Application.ShowMainForm := False;
  Application.OnMinimize := ALTRunForm.evtMainMinimize;
  Application.Run;

  SaveSettings;
end.

