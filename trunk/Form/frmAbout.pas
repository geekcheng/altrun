unit frmAbout;

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
  ShellAPI,
  ExtCtrls,
  pngimage,
  untALTRunOption,
  RxGIF;

type
  TAboutForm = class(TForm)
    mmoAbout: TMemo;
    btnOK: TBitBtn;
    imgIcon: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure imgIconClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    m_Png: TPngObject;
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.FormCreate(Sender: TObject);

begin
  m_Png := TPngObject.Create;
  m_Png.LoadFromResourceName(Hinstance,'BannerPic'); 
  imgIcon.Picture.Assign(m_Png);
  btnOK.Caption := resBtnOK;

  if FileExists(ExtractFilePath(Application.ExeName) + 'About.' + Lang) then
    mmoAbout.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'About.' + Lang);
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
  m_Png.Free;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then ModalResult := mrCancel;

end;

procedure TAboutForm.imgIconClick(Sender: TObject);
begin
  ShellExecute(0, nil, UPGRADE_URL, nil, nil, SW_SHOWNORMAL);
end;

end.

