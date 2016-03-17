unit DockForm1Unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLProc, LResources, Forms, Controls, Graphics, Dialogs,
  FileUtil, DockForm2Unit, Buttons, Menus, LDockCtrl, XMLPropStorage, StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    TwoSiblingsButton: TButton;
    SpiralButton: TButton;
    ThreePagesButton: TButton;
    ClearLayoutsButton: TButton;
    TwoPagesButton: TButton;
    CreateLayoutGroupBox: TGroupBox;
    SaveLayoutButton: TButton;
    CreateNewFormButton: TButton;
    MainPopupMenu: TPopupMenu;
    procedure ClearLayoutsButtonClick(Sender: TObject);
    procedure CreateNewFormButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure SaveLayoutButtonClick(Sender: TObject);
    procedure SpiralButtonClick(Sender: TObject);
    procedure ThreePagesButtonClick(Sender: TObject);
    procedure TwoPagesButtonClick(Sender: TObject);
    procedure TwoSiblingsButtonClick(Sender: TObject);
  private
    function CreateNewForm: TCustomForm;
    procedure ClearLayout;
  public
    ControlDocker1: TLazControlDocker;
    DockingManager: TLazDockingManager;
  end;

var
  MainForm: TMainForm;

implementation

{ TMainForm }

procedure TMainForm.FormPaint(Sender: TObject);
begin
  if Sender=nil then ;
  PaintBoundaries(Self,clBlue);
end;

procedure TMainForm.SaveLayoutButtonClick(Sender: TObject);
var
  Config: TXMLConfigStorage;
begin
  Config:=TXMLConfigStorage.Create('config.xml',false);
  DockingManager.SaveToConfig(Config);
  Config.WriteToDisk;
  Config.Free;
end;

procedure TMainForm.SpiralButtonClick(Sender: TObject);
var
  Form1: TCustomForm;
  Form2: TCustomForm;
  Form3: TCustomForm;
  Form4: TCustomForm;
  Form5: TCustomForm;
begin
  debugln;
  ClearLayout;

  Form1:=CreateNewForm;
  with Form1 do SetBounds(Left,Top,600,450);
  Form2:=CreateNewForm;
  with Form2 do SetBounds(Left,Top,150,150);
  DockingManager.Manager.InsertControl(Form2,alRight,Form1);
  Form3:=CreateNewForm;
  with Form3 do SetBounds(Left,Top,150,150);
  DockingManager.Manager.InsertControl(Form3,alLeft,Form1);
  Form4:=CreateNewForm;
  with Form4 do SetBounds(Left,Top,150,150);
  DockingManager.Manager.InsertControl(Form4,alTop,Form1);
  DockingManager.Manager.EnlargeControl(Form4,akLeft);
  Form5:=CreateNewForm;
  with Form5 do SetBounds(Left,Top,150,150);
  DockingManager.Manager.InsertControl(Form5,alBottom,Form1);
  DockingManager.Manager.EnlargeControl(Form5,akRight);
end;

procedure TMainForm.ThreePagesButtonClick(Sender: TObject);
var
  Form1: TCustomForm;
  Form2: TCustomForm;
  Form3: TCustomForm;
begin
  debugln;
  ClearLayout;

  Form1:=CreateNewForm;
  Form1.Width:=500;
  Form2:=CreateNewForm;
  DockingManager.Manager.InsertControl(Form2,alClient,Form1);
  Form3:=CreateNewForm;
  DockingManager.Manager.InsertControl(Form3,alClient,Form1);
end;

procedure TMainForm.TwoPagesButtonClick(Sender: TObject);
var
  Form1: TCustomForm;
  Form2: TCustomForm;
begin
  debugln;
  ClearLayout;
  
  Form1:=CreateNewForm;
  with Form1 do SetBounds(Left,Top,400,200);
  Form2:=CreateNewForm;
  DockingManager.Manager.InsertControl(Form2,alClient,Form1);
end;

procedure TMainForm.TwoSiblingsButtonClick(Sender: TObject);
var
  Form1: TCustomForm;
  Form2: TCustomForm;
begin
  debugln;
  ClearLayout;

  Form1:=CreateNewForm;
  with Form1 do SetBounds(Left,Top,400,200);
  Form2:=CreateNewForm;
  DockingManager.Manager.InsertControl(Form2,alRight,Form1);
end;

function TMainForm.CreateNewForm: TCustomForm;
var
  DockForm: TDockFormX;
begin
  // create a form with a TLazControlDocker
  DockForm:=TDockFormX.Create(Self);
  Result:=DockForm;
  // connect the TLazControlDocker of the new form to our DockingManager
  // this will automatically create a unique name for the forms layout.
  DockForm.Docker.Manager:=DockingManager;

  // assign the unique name, so that the user can distinguish the forms
  // This is only done here for demonstration purpose.
  DockForm.Name:=DockForm.Docker.DockerName;
  DockForm.Caption:=DockForm.Name;
  DockForm.Docker.Name:='Docker'+DockForm.Name;

  // finally: show the form
  // If a form with this layout was already shown in the past, then
  // the DockingManager will automatically restore the layout.
  DockForm.Visible:=true;
  DebugLn('TMainForm.CreateNewForm ',DockForm.Name,' ',DockingManager.FindDockerByControl(DockForm,nil).DockerName,' ',DockingManager.GetControlConfigName(DockForm));
end;

procedure TMainForm.ClearLayout;
var
  i: Integer;
begin
  // free all forms and layouts
  for i:=ComponentCount-1 downto 0 do begin
    if Components[i] is TDockFormX then
      Components[i].Free;
  end;
  DockingManager.ClearConfigs;
end;

procedure TMainForm.CreateNewFormButtonClick(Sender: TObject);
begin
  if Sender=nil then ;
  CreateNewForm;
end;

procedure TMainForm.ClearLayoutsButtonClick(Sender: TObject);
begin
  ClearLayout;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Form2: TCustomForm;
  Form3: TCustomForm;
  Config: TXMLConfigStorage;
  UseConfig: Boolean;
begin
  Form2:=nil;
  Form3:=nil;
  DockingManager:=TLazDockingManager.Create(Self);
  
  UseConfig:=FileExistsUTF8('config.xml');
  if UseConfig then begin
    Config:=TXMLConfigStorage.Create('config.xml',true);
    DockingManager.LoadFromConfig(Config);
    Config.Free;
  end;
  
  ControlDocker1:=TLazControlDocker.Create(Self);
  ControlDocker1.Name:='DockerForm1';
  ControlDocker1.Manager:=DockingManager;
  
  DockingManager.WriteDebugReport;

  Form2:=CreateNewForm;
  DebugLn(['TMainForm.FormCreate =============================================================']);
  //Form3:=CreateNewForm;

  if not UseConfig then begin
    DebugLn(['TMainForm.FormCreate Creating default docking layout']);
    if Form2<>nil then begin
      DebugLn(['TMainForm.FormCreate AAA1 Form2=',dbgs(Form2.BoundsRect)]);
      DockingManager.Manager.InsertControl(Form2,alLeft,Self);
      DebugLn(['TMainForm.FormCreate AAA2 Form2=',dbgs(Form2.BoundsRect)]);
    end;
    if Form3<>nil then
      DockingManager.Manager.InsertControl(Form3,alBottom,Self);
  end;
  
  //DockingManager.WriteDebugReport;
  //ControlDocker1.GetLayoutFromControl;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DockingManager.Free;
end;

initialization
  {$I dockform1unit.lrs}

end.

