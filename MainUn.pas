unit MainUn;

interface

uses
  TypesAndVars, data.Model, draw.Structures, draw.Model, View, Screen,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.Actions, Vcl.ActnList, Vcl.Imaging.pngimage;

type
  TFlowchart_Manager = class(TForm)
    pnlMemoTree: TPanel;
    trMainTree: TTreeView;
    splMemoTree: TSplitter;
    MainMenu: TMainMenu;
    scrMain: TScrollBox;
    pbMain: TPaintBox;
    dlgOpenFile: TOpenDialog;
    alMain: TActionList;
    fileOpen: TAction;
    fileSavePNG: TAction;
    fileSaveBMP: TAction;
    File1: TMenuItem;
    fileOpen1: TMenuItem;
    fileSavePNG1: TMenuItem;
    fileSaveBMP1: TMenuItem;
    btnTemp: TButton;
    dlgSaveFlowchart: TSaveDialog;
    mmoInput: TMemo;
    reMainEdit: TRichEdit;
    procedure StartRoutine();
    procedure createtree();
    procedure FormDestroy(Sender: TObject);
    procedure RecTreeConstructor(const shift: Integer; TempTreeStructure: PTreeStructure);
    procedure btnTempClick(Sender: TObject);
    procedure pbMainPaint(Sender: TObject);
    procedure scrMainMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure scrMainMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure fileOpenExecute(Sender: TObject);
    function saveFile(mode: TFileMode):string;

    procedure savePNGFile;
    procedure saveBMPFile;
    procedure fileSavePNGExecute(Sender: TObject);
    procedure fileSaveBMPExecute(Sender: TObject);
    procedure pbMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  Flowchart_Manager: TFlowchart_Manager;
  FileUsed: TextFile;
  TempNode: TTreeNode;
  CurrentMaxNode: Integer;

implementation

{$R *.dfm}

procedure TFlowchart_Manager.FormDestroy(Sender: TObject);
begin
strList.Free;
if TreeStructure <> nil then
  EraseTree(TreeStructure);
if DrawList <> nil then
  EraseDrawList(DrawList);
end;

procedure TFlowchart_Manager.pbMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  a,b, temp:integer;
  i: Integer;
begin
  RestoreDafault();
  reMainEdit.SelStart:=0;
  reMainEdit.SelLength:=0;
  for i := 0 to reMainEdit.Lines.Count - 1 do
    begin
      reMainEdit.SelLength:=reMainEdit.SelLength + Length(reMainEdit.Lines[i]);
    end;
  reMainEdit.SelAttributes.Color := clBlack;

  a:=-1;
  b:=-1;
  FindAndBlue(X,Y,a,b);
  temp:=0;
  for i := 0 to a-1 do
    begin
      temp:=temp+length(reMainEdit.Lines[i]);
    end;
  reMainEdit.SelStart:=temp;
  reMainEdit.SelLength:=0;
  for i := a to b do
    begin
      reMainEdit.SelLength:=reMainEdit.SelLength + Length(reMainEdit.Lines[i]);
    end;
  reMainEdit.SelAttributes.Color := clBlue;

  pbMain.Repaint;
end;

procedure TFlowchart_Manager.pbMainPaint(Sender: TObject);
begin
  if DrawList <> nil then
    screenUpdate(Flowchart_Manager,pbMain);
end;

procedure TFlowchart_Manager.RecTreeConstructor(const shift: Integer; TempTreeStructure: PTreeStructure);
var
  i: Integer;
  tempI: Integer;
begin
  i := 1;
  while i <= TempTreeStructure^.NumberOfChildren do
    begin
    inc(currentMaxNode);
    trMainTree.Items.AddChild(trMainTree.Items[shift], TempTreeStructure^.Children[i-1]^.BlockName);

    if TempTreeStructure^.Children[i-1]^.NumberOfChildren > 0 then
      begin
      tempI := CurrentMaxNode;
      RecTreeConstructor(tempI, TempTreeStructure^.Children[i-1]);
      end;
    inc(i);
    end;
end;

procedure TFlowchart_Manager.scrMainMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  (Sender as TScrollBox).VertScrollBar.Position := (Sender as TScrollBox).VertScrollBar.Position - (Sender as TScrollBox).VertScrollBar.Increment;
end;

procedure TFlowchart_Manager.scrMainMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  (Sender as TScrollBox).VertScrollBar.Position := (Sender as TScrollBox).VertScrollBar.Position + (Sender as TScrollBox).VertScrollBar.Increment;
end;

procedure TFlowchart_Manager.btnTempClick(Sender: TObject);
begin
//  drawTerminator(pbMain,50,50,100,50);
//  drawFunctionalBlock(pbMain, 50,50,100,50);
//  drawBinaryChoice(pbMain,50,50,100,50);
//  drawLoop(pbMain,50,50,100,50,400)
//  drawDataBlock(pbMain,50,50,100,50);
end;

procedure TFlowchart_Manager.CreateTree();
begin
trMainTree.Items.Clear;
trMainTree.Items.Add(nil, StrList[0]);
CurrentMaxNode := 0;
RecTreeConstructor(0, TreeStructure);
end;

procedure TFlowchart_Manager.fileOpenExecute(Sender: TObject);
begin

  dlgOpenFile.Filter := 'Pascal files (*.pas, *.dpr)|*.PAS;*.DPR| Text files (*.txt)|*.TXT|';
  if dlgOpenFile.Execute then
  begin
    CurrentFile := dlgOpenFile.FileName;
    clearScreen(Flowchart_Manager,pbMain);
    TreeStructure := nil;
    StartRoutine();

    CreatingDataModel();
    createtree;

    clearScreen(Flowchart_Manager,pbMain);
    if TreeStructure <> nil then
      CreatingDrawModel(Flowchart_Manager, pbMain);

    fileSavePNG.Enabled:=true;
    fileSaveBMP.Enabled:=true;
  end;
end;

procedure TFlowchart_Manager.fileSaveBMPExecute(Sender: TObject);
begin
  saveBMPFile;
end;

procedure TFlowchart_Manager.fileSavePNGExecute(Sender: TObject);
begin
  savePNGFile;
end;

procedure TFlowchart_Manager.StartRoutine();
var
  S,tmpS:string;
  Posit:Integer;
begin
reMainEdit.Lines.Clear;
if FileExists(currentFile) then
  reMainEdit.Lines. LoadFromFile(currentFile);

AssignFile(FileUsed, currentFile);
Reset(FileUsed);

StrList:=TStringList.Create;
StrList.Sorted:=False;
StrList.Duplicates:=dupAccept;

while not Eof(FileUsed) do
  begin
  Readln(FileUsed, S);
  if checkStr(S,'exit') or checkStr(S,'break') or checkStr(S,'continue') or checkStr(S,'case')then
    begin
    ShowMessage('Warning! Non-structural algorithm');
    end;
  Posit:=AnsiPos('//', S);
  Delete(S,Posit,length(s)-Posit+1);

  if AnsiPos('{', S) <> 0 then
    begin
      Posit:=AnsiPos('{', S);
      Delete(S,Posit,length(s)-Posit+1);
      StrList.Add(S);
      repeat
      Readln(FileUsed,S)
      until  (AnsiPos('', S) = 0) or Eof(FileUsed);
      Posit:=AnsiPos('', S);
      Delete(S,1,Posit);
    end;

  Posit:=AnsiPos('//', S);
  Delete(S,Posit,length(s)-Posit+1);

  StrList.Add(S);
  end;

CloseFile(FileUsed);
end;

function TFlowchart_Manager.saveFile(mode: TFileMode):string;
begin
  Result := '';
  case mode of
    FBrakh:
    begin
      dlgSaveFlowchart.FileName := 'FlowChart.brakh';
      dlgSaveFlowchart.Filter := 'Source-File|*.brakh';
      dlgSaveFlowchart.DefaultExt := 'brakh';
    end;
    FBmp:
    begin
      dlgSaveFlowchart.FileName := 'FlowChart.bmp';
      dlgSaveFlowchart.Filter := 'Bitmap Picture|*.bmp';
      dlgSaveFlowchart.DefaultExt := 'bmp';
    end;
    FPng:
     begin
      dlgSaveFlowchart.FileName := 'FlowChart.png';
      dlgSaveFlowchart.Filter := 'PNG|*.png';
      dlgSaveFlowchart.DefaultExt := 'png';
    end;
  end;
  if dlgSaveFlowchart.Execute then
  begin
    Result := dlgSaveFlowchart.FileName;
  end;

end;

procedure TFlowchart_Manager.saveBMPFile;
var
  path: string;
  oldScale: real;
  tempWidth, tempHeight: Integer;
const
  ExportScale = 4;
begin
//  oldScale := FScale;
  path := saveFile(FBmp);
  if path <> '' then
  begin
 //   ClickFigure := nil;
    with TBitMap.Create do
    begin
      Height := maxBit;
      Width := maxBit;
//      FScale := ExportScale;
      tempWidth := 0;
      tempHeight := 0;
      drawModel(Canvas, tempWidth, tempHeight);
      Width := tempWidth;
      Height := tempHeight;
//      FScale := oldScale;
      SaveToFile(path);
      free;
    end;
  end;
end;

procedure TFlowchart_Manager.savePNGFile;
var
  path: string;
  oldScale: real;
  png : TPngImage;
  bitmap: TBitmap;
  tempWidth, tempHeight: Integer;
const
  ExportScale = 4;
begin
  oldScale := FScale;
  path := saveFile(FPng);
  if path <> '' then
  begin
//    ClickFigure := nil;
    try
      bitmap := TBitMap.Create;
      bitmap.Height := maxBit;
      bitmap.Width := maxBit;
      with bitmap do
      begin
        png := TPNGImage.Create;
   //     FScale := ExportScale;
        tempWidth := 0;
        tempHeight := 0;
        drawModel(Canvas, tempWidth, tempHeight);
        Width := tempWidth;
        Height := tempHeight;
   //     FScale := oldScale;
      end;
        png.Assign(bitmap);
        png.Draw(bitmap.Canvas, Rect(0, 0, bitmap.Width, bitmap.Height));
        png.SaveToFile(path)
     finally
        bitmap.free;
        png.free;
    end;
  end;
end;


end.
