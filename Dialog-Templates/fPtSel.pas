unit fPtSel;
{ Allows patient selection using various pt lists.  Allows display & processing of alerts. }

{$OPTIMIZATION OFF}                              // REMOVE AFTER UNIT IS DEBUGGED

{$define VAA}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ORCtrls, ExtCtrls, ORFn, ORNet, ORDtTmRng, Gauges, Menus, ComCtrls,
  UBAGlobals, UBACore;

type
  TfrmPtSel = class(TForm)
    pnlPtSel: TORAutoPanel;
    cboPatient: TORComboBox;
    lblPatient: TLabel;
    cmdOK: TButton;
    cmdCancel: TButton;
    popNotifications: TPopupMenu;
    mnuProcess: TMenuItem;
    mnuRemove: TMenuItem;
    mnuForward: TMenuItem;
    N1: TMenuItem;
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure cboPatientChange(Sender: TObject);
    procedure cboPatientKeyPause(Sender: TObject);
    procedure cboPatientMouseClick(Sender: TObject);
    procedure cboPatientEnter(Sender: TObject);
    procedure cboPatientExit(Sender: TObject);
    procedure cboPatientNeedData(Sender: TObject; const StartFrom: string;
      Direction, InsertAt: Integer);
    procedure cboPatientDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnlPtSelResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cboPatientKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function DupLastSSN(const DFN: string): Boolean;
    procedure lstFlagsClick(Sender: TObject);
    procedure lstFlagsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    FsortCol: integer;
    FLastPt: string;
    FUserCancelled: boolean;
    procedure AdjustFormSize(ShowNotif: Boolean; FontSize: Integer);
    procedure ClearIDInfo;
    procedure ShowIDInfo;
    procedure ShowFlagInfo;
    procedure AlertList;
  public
    procedure Loaded; override;
  end;

procedure SelectPatient(ShowNotif: Boolean; FontSize: Integer; var UserCancelled: boolean);

var
  frmPtSel: TfrmPtSel;
  FDfltSrc, FDfltSrcType: string;
  IsRPL, RPLJob, DupDFN: string;                 // RPLJob stores server $J job number of RPL pt. list.
  RPLProblem: boolean;                           // Allows close of form if there's an RPL problem.
  PtStrs: TStringList;
  SortViaKeyboard: boolean;

implementation

{$R *.DFM}

uses rCore, uCore, {fDupPts, fPtSens,} fPtSelDemog, { fPtSelOptns, fPatientFlagMulti,}
     {uOrPtf,} {fAlertForward,} rMisc  {fFrame, fPtAdd};

const
  TX_DGSR_ERR    = 'Unable to perform sensitive record checks';
  TC_DGSR_ERR    = 'Error';
  TC_DGSR_SHOW   = 'Restricted Record';
  TC_DGSR_DENY   = 'Access Denied';
  TX_DGSR_YESNO  = CRLF + 'Do you want to continue processing this patient record?';
  AliasString = ' -- ALIAS';

procedure SelectPatient(ShowNotif: Boolean; FontSize: Integer; var UserCancelled: boolean);
{ displays patient selection dialog (with optional notifications), updates Patient object }
var
  frmPtSel: TfrmPtSel;
begin
  frmPtSel := TfrmPtSel.Create(Application);
  RPLProblem := false;
  try
    with frmPtSel do
    begin
      AdjustFormSize(ShowNotif, FontSize);           // Set initial form size
      FDfltSrc := DfltPtList;
      FDfltSrcType := Piece(FDfltSrc, U, 2);
      FDfltSrc := Piece(FDfltSrc, U, 1);
      if (IsRPL = '1') then                          // Deal with restricted patient list users.
        FDfltSrc := '';
      //frmPtSelOptns.SetDefaultPtList(FDfltSrc);
      if RPLProblem then
         begin
          frmPtSel.Release;
          Exit;
        end;
      //kt Notifications.Clear;
      FsortCol := -1;
      //kt AlertList;
      ClearIDInfo;
      FUserCancelled := FALSE;
      ShowModal;
      UserCancelled := FUserCancelled;
    end;
  finally
    frmPtSel.Release;
  end;
end;

procedure TfrmPtSel.AdjustFormSize(ShowNotif: Boolean; FontSize: Integer);
{ Adjusts the initial size of the form based on the font used & if notifications should show. }
var
  Rect: TRect;
begin
  ResizeAnchoredFormToFont(self);
  // Make the form bigger (140%) to show notifications and show notification controls.
  if ShowNotif then begin
//    TheFormHeight := Round(TheFormHeight * 2.4);
//    pnlDivide.Height := lblNotifications.Height + 4;
    pnlPtSel.BevelOuter := bvRaised;
//    ClientHeight := TheFormHeight;
  end else begin
//    ClientHeight := TheFormHeight;
//    pnlPtSel.Anchors := [akLeft,akRight,akTop,akBottom];
  end;
//  ClientHeight := TheFormHeight;
//  VertScrollBar.Range := TheFormHeight;

  //After all of this calcualtion, we still use the saved preferences when possible
  SetFormPosition(self);
  Rect := BoundsRect;
  ForceInsideWorkArea(Rect);
  BoundsRect := Rect;
end;


{ List Source events: }

(*
procedure TfrmPtSel.SetPtListTop(IEN: Int64);
{ Sets top items in patient list according to list source type and optional list source IEN. }
var
  NewTopList: string;
  FirstDate, LastDate: string;
begin
  // NOTE:  Some pieces in RPC returned arrays are rearranged by ListPtByDflt call in rCore!
  IsRPL := User.IsRPL;
  if (IsRPL = '') then // First piece in ^VA(200,.101) should always be set (to 1 or 0).
    begin
      InfoBox('Patient selection list flag not set.', 'Incomplete User Information', MB_OK);
      RPLProblem := true;
      Exit;
    end;
  // FirstDate := 0; LastDate := 0; // Not req'd, but eliminates hint.
  // Assign list box TabPosition, Pieces properties according to type of list to be displayed.
  // (Always use Piece "2" as the first in the list to assure display of patient's name.)
  cboPatient.pieces := '2,3'; // This line and next: defaults set - exceptions modifield next.
  cboPatient.tabPositions := '20,28';
  if ((frmPtSelOptns.SrcType = TAG_SRC_DFLT) and (FDfltSrc = 'Combination')) then
    begin
      cboPatient.pieces := '2,3,4,5,9';
      cboPatient.tabPositions := '20,28,35,45';
    end;
  if ((frmPtSelOptns.SrcType = TAG_SRC_DFLT) and
      (FDfltSrcType = 'Ward')) or (frmPtSelOptns.SrcType = TAG_SRC_WARD) then
    cboPatient.tabPositions := '35';
  if ((frmPtSelOptns.SrcType = TAG_SRC_DFLT) and
      (AnsiStrPos(pChar(FDfltSrcType), 'Clinic') <> nil)) or (frmPtSelOptns.SrcType = TAG_SRC_CLIN) then
    begin
      cboPatient.pieces := '2,3,9';
      cboPatient.tabPositions := '24,45';
    end;
  NewTopList := IntToStr(frmPtSelOptns.SrcType) + U + IntToStr(IEN); // Default setting.
  if (frmPtSelOptns.SrcType = TAG_SRC_CLIN) then with frmPtSelOptns.cboDateRange do
    begin
      if ItemID = '' then Exit;                        // Need both clinic & date range.
      FirstDate := Piece(ItemID, ';', 1);
      LastDate  := Piece(ItemID, ';', 2);
      NewTopList := IntToStr(frmPtSelOptns.SrcType) + U + IntToStr(IEN) + U + ItemID; // Modified for clinics.
    end;
  if NewTopList = frmPtSelOptns.LastTopList then Exit; // Only continue if new top list.
  frmPtSelOptns.LastTopList := NewTopList;
  RedrawSuspend(cboPatient.Handle);
  ClearIDInfo;
  cboPatient.ClearTop;
  cboPatient.Text := '';
  if (IsRPL = '1') then                                // Deal with restricted patient list users.
    begin
      RPLJob := MakeRPLPtList(User.RPLList);           // MakeRPLPtList is in rCore, writes global "B" x-ref list.
      if (RPLJob = '') then
        begin
          InfoBox('Assignment of valid OE/RR Team List Needed.', 'Unable to build Patient List', MB_OK);
          RPLProblem := true;
          Exit;
        end;
    end
  else
    begin
      case frmPtSelOptns.SrcType of
      TAG_SRC_DFLT: ListPtByDflt(cboPatient.Items);
      TAG_SRC_PROV: ListPtByProvider(cboPatient.Items, IEN);
      TAG_SRC_TEAM: ListPtByTeam(cboPatient.Items, IEN);
      TAG_SRC_SPEC: ListPtBySpecialty(cboPatient.Items, IEN);
      TAG_SRC_CLIN: ListPtByClinic(cboPatient.Items, frmPtSelOptns.cboList.ItemIEN, FirstDate, LastDate);
      TAG_SRC_WARD: ListPtByWard(cboPatient.Items, IEN);
      TAG_SRC_ALL:  ListPtTop(cboPatient.Items);
      end;
    end;
  if frmPtSelOptns.cboList.Visible then
    lblPatient.Caption := 'Patients (' + frmPtSelOptns.cboList.Text + ')';
  if frmPtSelOptns.SrcType = TAG_SRC_ALL then
    lblPatient.Caption := 'Patients (All Patients)';
  with cboPatient do if ShortCount > 0 then
    begin
      Items.Add(LLS_LINE);
      Items.Add(LLS_SPACE);
    end;
  cboPatient.Caption := lblPatient.Caption;
  cboPatient.InitLongList('');
  RedrawActivate(cboPatient.Handle);
end;
*)

{ Patient Select events: }

procedure TfrmPtSel.cboPatientEnter(Sender: TObject);
begin
  cmdOK.Default := True;
  if cboPatient.ItemIndex >= 0 then
  begin
    ShowIDInfo;
    ShowFlagInfo;
  end;
end;

procedure TfrmPtSel.cboPatientExit(Sender: TObject);
begin
  cmdOK.Default := False;
end;

procedure TfrmPtSel.cboPatientChange(Sender: TObject);

    procedure ShowMatchingPatients;
    begin
      with cboPatient do
        begin
          ClearIDInfo;
          if ShortCount > 0 then
            begin
              if ShortCount = 1 then
                begin
                  ItemIndex := 0;
                  ShowIDInfo;
                  ShowFlagInfo;
                end;
              Items.Add(LLS_LINE);
              Items.Add(LLS_SPACE);
            end;
          InitLongList('');
        end;
    end;

begin
  with cboPatient do
    {
    if frmPtSelOptns.IsLast5(Text) then begin
        if (IsRPL = '1') then
          ListPtByRPLLast5(Items, Text)
        else
          ListPtByLast5(Items, Text);
        ShowMatchingPatients;
      end
    else if frmPtSelOptns.IsFullSSN(Text) then
      begin
        if (IsRPL = '1') then
           ListPtByRPLFullSSN(Items, Text)
        else
           ListPtByFullSSN(Items, Text);
        ShowMatchingPatients;
      end;
   }
end;

procedure TfrmPtSel.cboPatientKeyPause(Sender: TObject);
begin
  if Length(cboPatient.ItemID) > 0 then  //*DFN*
  begin
    ShowIDInfo;
    ShowFlagInfo;
  end else
  begin
    ClearIDInfo;
  end;
end;

procedure TfrmPtSel.cboPatientMouseClick(Sender: TObject);
begin
  if Length(cboPatient.ItemID) > 0 then   //*DFN*
  begin
    ShowIDInfo;
    ShowFlagInfo;
  end else
  begin
    ClearIDInfo;
  end;
end;

procedure TfrmPtSel.cboPatientDblClick(Sender: TObject);
begin
  if Length(cboPatient.ItemID) > 0 then cmdOKClick(Self);  //*DFN*
end;


procedure TfrmPtSel.cboPatientNeedData(Sender: TObject; const StartFrom: string;
  Direction, InsertAt: Integer);
var
  i: Integer;
  NoAlias, Patient: String;
  PatientList: TStringList;
begin

  NoAlias := StartFrom;
  with Sender as TORComboBox do
    if Items.Count > ShortCount then
      NoAlias := Piece(Items[Items.Count-1], U, 1) + U + NoAlias;
  if pos(AliasString, NoAlias)> 0 then
    NoAlias := Copy(NoAlias, 1, pos(AliasString, NoAlias)-1);
  PatientList := TStringList.Create;
  try
    begin
      if (IsRPL  = '1') then // Restricted patient lists uses different feed for long list box:
        PatientList.Assign(ReadRPLPtList(RPLJob, NoAlias, Direction))
      else
      begin
        PatientList.Assign(SubSetOfPatients(NoAlias, Direction));
        for i := 0 to PatientList.Count-1 do  // Add " - Alias" to alias names:
        begin
          Patient := PatientList[i];
          // Piece 6 avoids display problems when mixed with "RPL" lists:
          if (Uppercase(Piece(Patient, U, 2)) <> Uppercase(Piece(Patient, U, 6))) then
          begin
            SetPiece(Patient, U, 2, Piece(Patient, U, 2) + AliasString);
            PatientList[i] := Patient;
          end;
        end;
      end;
      cboPatient.ForDataUse(PatientList);
    end;
  finally
    PatientList.Free;
  end;
end;

procedure TfrmPtSel.ClearIDInfo;
begin
  frmPtSelDemog.ClearIDInfo;
end;

procedure TfrmPtSel.ShowIDInfo;
begin
  if frmPtSelDemog.Left=0 then pnlPtSelResize(Self);  //kt added to correct positioning.
  frmPtSelDemog.ShowDemog(cboPatient.ItemID);
end;

{ Command Button events: }

procedure TfrmPtSel.cmdOKClick(Sender: TObject);
{ Checks for restrictions on the selected patient and sets up the Patient object. }
const
  DLG_CANCEL = False;
  DGSR_FAIL = -1;
  DGSR_NONE =  0;
  DGSR_SHOW =  1;
  DGSR_ASK  =  2;
  DGSR_DENY =  3;
var
  NewDFN, AMsg: string;  //*DFN*
  AccessStatus: Integer;
  DateDied: TFMDateTime;
begin
  if not (Length(cboPatient.ItemID) > 0) then begin //*DFN*
    InfoBox('A patient has not been selected.', 'No Patient Selected', MB_OK);
    Exit;
  end;
  NewDFN := cboPatient.ItemID;  //*DFN*
  if FLastPt <> cboPatient.ItemID then begin
    //kt HasActiveFlg(FlagList, HasFlag, cboPatient.ItemID);
    flastpt := cboPatient.ItemID;
  end;

  CheckSensitiveRecordAccess(NewDFN, AccessStatus, AMsg);
  case AccessStatus of
    DGSR_FAIL: begin
                 InfoBox(TX_DGSR_ERR, TC_DGSR_ERR, MB_OK);
                 Exit;
               end;
    DGSR_NONE: { Nothing - allow access to the patient. };
    DGSR_SHOW: InfoBox(AMsg, TC_DGSR_SHOW, MB_OK);
    DGSR_ASK:  if InfoBox(AMsg + TX_DGSR_YESNO, TC_DGSR_SHOW, MB_YESNO or MB_ICONWARNING or
                 MB_DEFBUTTON2) = IDYES then LogSensitiveRecordAccess(NewDFN) else Exit;
    else       begin
                 InfoBox(AMsg, TC_DGSR_DENY, MB_OK);
                 Exit;
               end;
  end; {case}
  DateDied := DateOfDeath(NewDFN);
  if (DateDied > 0) and (InfoBox('This patient died ' + FormatFMDateTime('mmm dd,yyyy hh:nn', DateDied) + CRLF +
     'Do you wish to continue?', 'Deceased Patient', MB_YESNO or MB_DEFBUTTON2) = ID_NO) then begin
    Exit;
  end;
  Patient.DFN := NewDFN;     // The patient object in uCore must have been created already!
  Encounter.Clear;
  Changes.Clear;             // An earlier call to ReviewChanges should have cleared this.
  if Patient.Inpatient then begin
    Encounter.Inpatient := True;
    Encounter.Location := Patient.Location;
    Encounter.DateTime := Patient.AdmitTime;
    Encounter.VisitCategory := 'H';
  end;
  if User.IsProvider then Encounter.Provider := User.DUZ;
  FUserCancelled := FALSE;
  Close;
end;

procedure TfrmPtSel.cmdCancelClick(Sender: TObject);
begin
  // Leave Patient object unchanged
  FUserCancelled := TRUE;
  Close;
end;

procedure TfrmPtSel.FormDestroy(Sender: TObject);
begin
  SaveUserBounds(Self);
  //kt frmFrame.EnduringPtSelSplitterPos := pnlPtSel.Height;
 end;

procedure TfrmPtSel.pnlPtSelResize(Sender: TObject);
begin
  frmPtSelDemog.Left := cboPatient.Left + cboPatient.Width + 9;
  frmPtSelDemog.Width := pnlPtSel.Width - frmPtSelDemog.Left - 2;
  //kt frmPtSelOptns.Width := cboPatient.Left-8;
  frmPtSelDemog.Top := cmdCancel.Top + cmdCancel.Height + 10; //kt added
  pnlPtSel.RefreshSizes;  //kt added
end;

procedure TfrmPtSel.Loaded;
begin
  inherited;
// This needs to be in Loaded rather than FormCreate or the TORAutoPanel resize logic breaks.
  frmPtSelDemog := TfrmPtSelDemog.Create(Self);  // Was application - kcm
  with frmPtSelDemog do begin
    parent := pnlPtSel;
    Top := 65;
    Left := cboPatient.Left + cboPatient.Width + 9;
    Width := pnlPtSel.Width - Left - 2;
    TabOrder := cmdCancel.TabOrder + 1;  //Place after cancel button
    Show;
    SendToBack;  //kt added to keep from writing over other "In-Depth" component
  end;
  FLastPt := '';
end;

procedure TfrmPtSel.FormClose(Sender: TObject; var Action: TCloseAction);
begin

if (IsRPL = '1') then                          // Deal with restricted patient list users.
  KillRPLPtList(RPLJob);                       // Kills server global data each time.
                                               // (Global created by MakeRPLPtList in rCore.)
end;

procedure TfrmPtSel.cboPatientKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('D')) and (ssCtrl in Shift) then begin
    Key := 0;
    frmPtSelDemog.ToggleMemo;
  end;
end;

function ConvertDate(var thisList: TStringList; listIndex: integer) : string;
{
 Convert date portion from yyyy/mm/dd to mm/dd/yyyy
}
var
  //thisListItem: TListItem;
  thisDateTime: string[16];
  tempDt: string;
  tempYr: string;
  tempTime: string;
  newDtTime: string;
  k: byte;
  piece1: string;
  piece2: string;
  piece3: string;
  piece4: string;
  piece5: string;
  piece6: string;
  piece7: string;
  piece8: string;
  piece9: string;
  piece10: string;
  piece11: string;
begin
  piece1 := '';
  piece2 := '';
  piece3 := '';
  piece4 := '';
  piece5 := '';
  piece6 := '';
  piece7 := '';
  piece8 := '';
  piece9 := '';
  piece10 := '';
  piece11 := '';

  piece1 := Piece(thisList[listIndex],U,1);
  piece2 := Piece(thisList[listIndex],U,2);
  piece3 := Piece(thisList[listIndex],U,3);
  piece4 := Piece(thisList[listIndex],U,4);
  //piece5 := Piece(thisList[listIndex],U,5);
  piece6 := Piece(thisList[listIndex],U,6);
  piece7 := Piece(thisList[listIndex],U,7);
  piece8 := Piece(thisList[listIndex],U,8);
  piece9 := Piece(thisList[listIndex],U,9);
  piece10 := Piece(thisList[listIndex],U,1);

  thisDateTime := Piece(thisList[listIndex],U,5);

  tempYr := '';
  for k := 1 to 4 do
   tempYr := tempYr + thisDateTime[k];

  tempDt := '';
  for k := 6 to 10 do
   tempDt := tempDt + thisDateTime[k];

  tempTime := '';
  //Use 'Length' to prevent stuffing the control chars into the date when a trailing zero is missing
  for k := 11 to Length(thisDateTime) do //16 do
   tempTime := tempTime + thisDateTime[k];

  newDtTime := '';
  newDtTime := newDtTime + tempDt + '/' + tempYr + tempTime;
  piece5 := newDtTime;

  Result := piece1 +U+ piece2 +U+ piece3 +U+ piece4 +U+ piece5 +U+ piece6 +U+ piece7 +U+ piece8 +U+ piece9 +U+ piece10 +U+ piece11;
end;

procedure TfrmPtSel.AlertList;
begin
end;

function TfrmPtSel.DupLastSSN(const DFN: string): Boolean;
var
  i: integer;
  //frmPtDupSel: tForm;
begin
  Result := False;

  // Check data on server for duplicates:
  CallV('DG CHK BS5 XREF ARRAY', [DFN]);
  if (RPCBrokerV.Results[0] <> '1') then // No duplicates found.
    Exit;
  Result := True;
  PtStrs := TStringList.Create;
  with RPCBrokerV do if Results.Count > 0 then
  begin
    for i := 1 to Results.Count - 1 do
    begin
      if Piece(Results[i], U, 1) = '1' then
        PtStrs.Add(Piece(Results[i], U, 2) + U + Piece(Results[i], U, 3) + U +
                   FormatFMDateTimeStr('mmm dd,yyyy', Piece(Results[i], U, 4)) + U +
                   Piece(Results[i], U, 5));
    end;
  end;

  // Call form to get user's selection from expanded duplicate pt. list (resets DupDFN variable if applicable):
  DupDFN := DFN;
  {
  frmPtDupSel:= TfrmDupPts.Create(Application);
  with frmPtDupSel do
    begin
      try
        ShowModal;
      finally
        frmPtDupSel.Release;
      end;
    end;
  }
end;

procedure TfrmPtSel.ShowFlagInfo;
begin
  if (Pos('*SENSITIVE*',frmPtSelDemog.lblPtSSN.Caption)>0) then
  begin
//    pnlPrf.Visible := False;
    Exit;
  end;
  if (flastpt <> cboPatient.ItemID) then
  begin
    //kt HasActiveFlg(FlagList, HasFlag, cboPatient.ItemID);
    flastpt := cboPatient.ItemID;
  end;
  if HasFlag then
  begin
//    lstFlags.Items.Assign(FlagList);
//    pnlPrf.Visible := True;
  end
  //else pnlPrf.Visible := False;
end;

procedure TfrmPtSel.lstFlagsClick(Sender: TObject);
begin
{  if lstFlags.ItemIndex >= 0 then
     ShowFlags(lstFlags.ItemID); }
end;

procedure TfrmPtSel.lstFlagsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    lstFlagsClick(Self);
end;

procedure TfrmPtSel.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
{
var
  keyValue: word;
}  
begin{
  keyValue := MapVirtualKey(Key,2);
  if keyValue = VK_RETURN then
     cmdProcessClick(Sender);
}
end;

procedure TfrmPtSel.FormShow(Sender: TObject);
begin
  //kt TMGcmdAdd.Enabled := (frmPtAdd <> nil);  //kt  Disable button when first starting up...
  //kt added  ---------
  cboPatient.InitLongList('A');
  //kt end mod ----------
end;

Initialization
  SortViaKeyboard := false;

end.
