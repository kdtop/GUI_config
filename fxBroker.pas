unit fxBroker;

//kt 9/11 made changes to **FORM** of this unit

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DateUtils, ORNet, ORFn, rMisc, ComCtrls, Buttons, ExtCtrls,
  ORCtrls, ORSystem, VA508AccessibilityManager;

type
  TfrmBroker = class(TForm)
    pnlTop: TORAutoPanel;
    lblMaxCalls: TLabel;
    txtMaxCalls: TCaptionEdit;
    cmdPrev: TBitBtn;
    cmdNext: TBitBtn;
    udMax: TUpDown;
    memData: TRichEdit;
    lblCallID: TStaticText;
    btnRLT: TButton;
    cboJumpTo: TComboBox;      //kt 9/11
    btnClear: TBitBtn;         //kt 9/11
    lblStoredCallsNum: TLabel; //kt 9/11
    btnFilter: TBitBtn;
    cbAlwaysShowLatest: TCheckBox;  //kt
    Timer1: TTimer;
    cbAlignResultPieces: TCheckBox;        //kt 9/11
    procedure btnFilterClick(Sender: TObject); //kt 9/11
    procedure btnClearClick(Sender: TObject);  //kt 9/11
    procedure cmdPrevClick(Sender: TObject);
    procedure cmdNextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnRLTClick(Sender: TObject);
    procedure cboJumpToDropDown(Sender: TObject);
    procedure cboJumpToChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbAlignResultPiecesClick(Sender: TObject);
  private
    { Private declarations }
    FRetained: Integer;
    FCurrent: Integer;
    procedure UpdateDisplay; //kt 9/11
    procedure JumpTocboIndex(Index: integer); //kt
    procedure UpdatecboDisplayText;  //kt
    procedure AlignResultPieces(SL : TStrings);  //kt
    procedure AlignPieces(SL : TStringList);  //kt
  public
    { Public declarations }
  end;

procedure ShowBroker;

var
  frmBroker: TfrmBroker;

implementation

{$R *.DFM}


uses
  fMemoEdit;  //kt 9/11added

procedure ShowBroker;
//var
  //frmBroker: TfrmBroker;
begin
  frmBroker := TfrmBroker.Create(Application);
  //frmMemoEdit := TfrmMemoEdit.Create(frmBroker);
  try
    ResizeAnchoredFormToFont(frmBroker);
    with frmBroker do begin
      FRetained := RetainedRPCCount - 1;
      FCurrent := FRetained;
      UpdateDisplay; //kt
      { //kt 9/11 moved to UpdateDisplay
      LoadRPCData(memData.Lines, FCurrent);
      memData.SelStart := 0;
      lblCallID.Caption := 'Last Call Minus: ' + IntToStr(FRetained - FCurrent);
      }
      ShowModal;
    end;
  finally
    //FreeAndNil(frmMemoEdit);
    frmBroker.Release;
  end;
end;

procedure TfrmBroker.cmdPrevClick(Sender: TObject);
begin
  cbAlwaysShowLatest.Checked := false;  //kt
  FCurrent := HigherOf(FCurrent - 1, 0);
  UpdateDisplay; //kt 9/11
  { //kt 9/11 moved to UpdateDisplay
  LoadRPCData(memData.Lines, FCurrent);
  memData.SelStart := 0;
  lblCallID.Caption := 'Last Call Minus: ' + IntToStr(FRetained - FCurrent);
  }
end;

procedure TfrmBroker.cmdNextClick(Sender: TObject);
begin
  cbAlwaysShowLatest.Checked := false;  //kt
  FRetained := RetainedRPCCount - 1;  //kt
  FCurrent := LowerOf(FCurrent + 1, FRetained);
  UpdateDisplay; //kt 9/11
  { //kt 9/11 moved to UpdateDisplay
  LoadRPCData(memData.Lines, FCurrent);
  memData.SelStart := 0;
  lblCallID.Caption := 'Last Call Minus: ' + IntToStr(FRetained - FCurrent);
  }
end;

procedure TfrmBroker.UpdateDisplay; //kt 9/11 added
begin
  LoadRPCData(memData.Lines, FCurrent);
  memData.SelStart := 0;
  lblCallID.Caption := 'Last Call Minus: ' + IntToStr(FRetained - FCurrent);
  UpdatecboDisplayText; //kt
  if cbAlignResultPieces.Checked then begin
    AlignResultPieces(MemData.Lines);
  end;  
end;

procedure TfrmBroker.AlignResultPieces(SL : TStrings);
//kt added
//SL is assumed to be the lines from the RPCResult memo
var i : integer;
    ResultsFound : boolean;
    ResultsStartIndex : integer;
    AlignSL : TStringList;
const RESULT_START = 'Results -----------------'; //not full line
      RESULTS_END  = 'Elapsed Time: ';
begin
  AlignSL := TStringList.Create;
  ResultsFound := false;
  for i := 0 to SL.Count-1 do begin
    if Pos(RESULT_START,SL[i])>0 then begin
      ResultsFound := true;
      ResultsStartIndex := i+1;
      continue;
    end;
    if not ResultsFound then continue;
    if Pos(RESULTS_END,SL[i])>0 then break;
    if Trim(SL[i]) = '' then break;
    AlignSL.Add(SL[i]);
  end;
  AlignPieces(AlignSL);
  for i := 0 to AlignSL.count - 1 do begin
    SL[i+ResultsStartIndex] := AlignSL[i];
  end;
  AlignSL.Free;
end;


procedure TfrmBroker.AlignPieces(SL : TStringList);
//kt added
//Assumes that all entries in SL are to be aligned

  function GetMaxWidth(PieceNum : integer) : integer;
  var i : integer;
      s : string;
      OneLen : integer;
  begin
    Result := 0;
    for i := 0 to SL.Count-1 do begin
      s := Piece(SL[i],'^',PieceNum);
      oneLen := Length(s);
      if OneLen>Result then Result := OneLen;
    end;
  end;

  procedure SetPieceWidth(PieceNum, Width : integer);
  var i : integer;
      newLine,s : string;
  begin
    for i := 0 to SL.Count-1 do begin
      s := Piece(SL[i],'^',PieceNum);
      if (s='') and (PieceNum > NumPieces(SL[i],'^')) then continue;
      while length(s) < Width do s := s + ' ';
      newLine := SL[i];
      SetPiece(newLine,'^',PieceNum,s);
      SL[i] := newLine;
    end;
  end;

  function GetMaxNumPieces : integer;
  var i : integer;
      np : integer;
  begin
    Result := 0;
    for i := 0 to SL.count-1 do begin
      np := NumPieces(SL[i],'^');
      if np > Result then Result := np;
    end;
  end;

var MaxWidth, MaxNumPieces : integer;
    i : integer;
begin
  MaxNumPieces := GetMaxNumPieces;
  for i := 1 to MaxNumPieces do begin
    MaxWidth := GetMaxWidth(i);
    if MaxWidth>0 then inc(MaxWidth);
    SetPieceWidth(i,MaxWidth);
  end;
end;


procedure TfrmBroker.cboJumpToDropDown(Sender: TObject);
//kt 9/11 added
var i : integer;
    s : string;
    Info : TStringList;   //Not owned here...
begin
  cboJumpTo.Items.Clear;
  for i := 0 to RetainedRPCCount - 1 do begin
    Info := AccessRPCData(i);
    if Info.Count < 2 then continue;
    s := Info.Strings[1];
    s := piece(s,'Called at: ',2);
    s := s + ':  ' + Info.Strings[0];
    cboJumpTo.Items.Insert(0,s);
  end;
end;

procedure TfrmBroker.cboJumpToChange(Sender: TObject);
//kt 9/11 added
begin
  JumpTocboIndex(cboJumpTo.ItemIndex);
  {
  if cboJumpTo.Items.count > 0 then begin
    FCurrent := (cboJumpTo.Items.count-1) - cboJumpTo.ItemIndex;
    UpdateDisplay;
  end;
  }
end;

procedure TfrmBroker.JumpTocboIndex(Index: integer);  //kt added
var PriorCurrent : integer;
begin
  if cboJumpTo.Items.count > 0 then begin
    PriorCurrent := FCurrent;
    FCurrent := (cboJumpTo.Items.count-1) - Index; //cboJumpTo.ItemIndex;
    if FCurrent <> PriorCurrent then begin
      UpdatecboDisplayText; //kt
      //cboJumpTo.Text := cboJumpTo.Items.Strings[Index];
      UpdateDisplay;
    end;
  end;
end;

procedure TfrmBroker.UpdatecboDisplayText;
//kt added
var Index : integer;
begin
  Index := (cboJumpTo.Items.count-1) - FCurrent;
  cboJumpTo.Text := cboJumpTo.Items.Strings[Index];
end;



procedure TfrmBroker.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetRetainedRPCMax(StrToIntDef(txtMaxCalls.Text, 5));
  Timer1.Enabled := false; //kt
end;

procedure TfrmBroker.FormResize(Sender: TObject);
begin
  Refresh;
end;

procedure TfrmBroker.FormCreate(Sender: TObject);
begin
  udMax.Position := GetRPCMax;
end;

procedure TfrmBroker.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TfrmBroker.btnFilterClick(Sender: TObject);
//kt 9/11 added entire unit
begin
  inherited;
  frmMemoEdit.lblMessage.Caption := 'Add / Delete / Edit list of FILTERED RPC calls:';
  frmMemoEdit.memEdit.Lines.Assign(ORNet.FilteredRPCCalls);
  frmMemoEdit.ShowModal;
  ORNet.FilteredRPCCalls.Assign(frmMemoEdit.memEdit.Lines);
end;

procedure TfrmBroker.btnRLTClick(Sender: TObject);
var
  startTime, endTime: tDateTime;
  clientVer, serverVer, diffDisplay: string;
  theDiff: integer;
const
  TX_OPTION  = 'OR CPRS GUI CHART';
  disclaimer = 'NOTE: Strictly relative indicator:';
begin
  clientVer := clientVersion(Application.ExeName); // Obtain before starting.

  // Check time lapse between a standard RPC call:
  startTime := now;
  serverVer :=  serverVersion(TX_OPTION, clientVer);
  endTime := now;
  theDiff := milliSecondsBetween(endTime, startTime);
  diffDisplay := intToStr(theDiff);

  // Show the results:
  infoBox('Lapsed time (milliseconds) = ' + diffDisplay + '.', disclaimer, MB_OK);
end;


procedure TfrmBroker.btnClearClick(Sender: TObject);
//kt 9/11 added
begin
  ORNet.RPCCallsClear;
  memData.Lines.Clear; //kt 4/15/10
  cboJumpTo.Text := '-- Select a call to jump to --';
  FCurrent := 0;
  FRetained := RetainedRPCCount - 1;
  cmdNextClick(Sender);
end;

procedure TfrmBroker.FormShow(Sender: TObject);
begin
  cbAlwaysShowLatest.Checked := true;  //kt
  Timer1.Enabled := true; //kt
end;

procedure TfrmBroker.Timer1Timer(Sender: TObject);
begin
  if not cbAlwaysShowLatest.Checked then exit; //kt
  cboJumpToDropDown(self);
  JumpTocboIndex(0);
end;

procedure TfrmBroker.cbAlignResultPiecesClick(Sender: TObject);
begin
  if cbAlignResultPieces.Checked then begin
    memData.Font.Name := 'Fixedsys';
    AlignResultPieces(MemData.Lines);
  end else begin
    memData.Font.Name := 'Arial';
  end;
end;

end.
