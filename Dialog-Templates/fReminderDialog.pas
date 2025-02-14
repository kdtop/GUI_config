unit fReminderDialog;

//vefa -- needs port

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ORFn, StdCtrls, ComCtrls, Buttons, ORCtrls, uReminders, uConst,
  ORClasses, fRptBox, Menus, rPCE, uTemplates {, fBase508Form,}
  {VA508AccessibilityManager,  fMHTest, fFrame};

type
  TfrmRemDlg = class(TForm)
    sb1: TScrollBox;
    sb2: TScrollBox;
    splTxtData: TSplitter;
    pnlFrmBottom: TPanel;
    pnlBottom: TPanel;
    splText: TSplitter;
    reData: TRichEdit;
    reText: TRichEdit;
    pnlButtons: TORAutoPanel;
    btnClear: TButton;
    btnBack: TButton;
    btnCancel: TButton;
    btnNext: TButton;
    btnFinish: TButton;
    btnClinMaint: TButton;
    btnVisit: TButton;
    lblFootnotes: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbResize(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ProcessReminderFromNodeStr(value: string);
    procedure btnNextClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnFinishClick(Sender: TObject);
    procedure btnClinMaintClick(Sender: TObject);
    procedure btnVisitClick(Sender: TObject);
    procedure KillDlg(ptr: Pointer; ID: string; KillObjects: boolean = FALSE);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean); //AGP Change 24.8
  private
    FSCCond: TSCConditions;
    FSCPrompt: boolean;
    FVitalsDate: TFMDateTime;
    FSCRelated: integer;
    FAORelated: integer;
    FIRRelated: integer;
    FECRelated: integer;
    FMSTRelated: integer;
    FHNCRelated: integer;
    FCVRelated: integer;
    FSHDRelated: integer;
    FLastWidth: integer;
    FUseBox2: boolean;
    FExitOK: boolean;
    FReminderDlg: TReminderDialog;   //kt renamed FReminder --> FReminderDlg
    CurReminderList: TORStringList;
    //kt FClinMainBox: TfrmReportBox;
    FOldClinMaintOnDestroy: TNotifyEvent;
    FProcessingTemplate: boolean;
    FSilent: boolean;
  protected
    procedure RemindersChanged(Sender: TObject);
    procedure ClearControls(All: boolean = FALSE);
    procedure BuildControls;
    function GetBox(Other: boolean = FALSE): TScrollBox;
    function KillAll: boolean;
    procedure ResetProcessing(Wipe: string = ''); //AGP CHANGE 24.8;
    procedure BoxUpdateDone;
    procedure ControlsChanged(Sender: TObject);
    procedure UMResyncRem(var Message: TMessage); message UM_RESYNCREM;
    procedure UpdateText(Sender: TObject);
    function GetCurReminderList: integer;
    function NextReminder: string;
    function BackReminder: string;
    procedure UpdateButtons;
    procedure PositionTrees(NodeID: string);
    procedure ClinMaintDestroyed(Sender: TObject);
    procedure ProcessTemplate(Template: TTemplate);
    //procedure ClearMHTest(Rien: string);
  public
    procedure TMGHighlightControl(IEN : string);  //kt added
    procedure TMGSetCBValueForControl(IEN : String; Checked : boolean); //kt added
    procedure ProcessReminder(ARemData: string; NodeID: string);
    procedure ForceRenderDlg(DialogIEN, PrintName: string); //kt added
    procedure SetFontSize;
    property ReminderDlg : TReminderDialog read FReminderDlg; //kt added
  end;

procedure TMGViewReminderDialog(ReminderDialogIEN, PrintName: string; InitDlg: boolean = TRUE);
procedure ViewReminderDialog(RemNode: TORTreeNode; InitDlg: boolean = TRUE);
procedure ViewReminderDialogTemplate(TempNode: TORTreeNode; InitDlg: boolean = TRUE);
procedure ViewRemDlgTemplateFromForm(OwningForm: TForm; Template: TTemplate;
                                     InitDlg, IsTemplate: boolean);
procedure HideReminderDialog;
procedure UpdateReminderFinish;
procedure KillReminderDialog(frm: TForm);
procedure NotifyWhenProcessingReminderChanges(Proc: TNotifyEvent);
procedure RemoveNotifyWhenProcessingReminderChanges(Proc: TNotifyEvent);
function ReminderDialogActive: boolean;
function CurrentReminderInDialog: TReminderDialog;

var
  frmRemDlg: TfrmRemDlg = nil;
  RemDlgSpltr1: integer = 0;
  RemDlgSpltr2: integer = 0;
  RemDlgLeft: integer = 0;
  RemDlgTop: integer = 0;
  RemDlgWidth: integer = 0;
  RemDlgHeight: integer = 0;

const
  RemDlgName = 'frmRemDlg';
  RemDlgSplitters = 'frmRemDlgSplitters';

implementation

uses {fNotes,} uPCE, {uOrders,} rOrders, uCore, rMisc, rReminders,
  MainU, //kt
  fReminderTree, uVitals, {rVitals,} RichEdit, {fConsults,} fTemplateDialog,
  uTemplateFields, {fRemVisitInfo,} rCore {, uVA508CPRSCompatibility,
  VA508AccessibilityRouter}, VAUtils, fNotes;

{$R *.DFM}

var
  PositionList: TORNotifyList = nil;
  ClinRemTextLocation: integer = -77;
  ClinRemTextStr: string = '';

const
  REQ_TXT = 'The following required items must be entered:' + CRLF;
  REQ_HDR = 'Required Items Missing';

function ClinRemText: string;
begin
  if(ClinRemTextLocation <> Encounter.Location) then
  begin
    ClinRemTextLocation := Encounter.Location;
    ClinRemTextStr := GetProgressNoteHeader;
  end;
  Result := ClinRemTextStr;
end;


procedure NotifyWhenProcessingReminderChanges(Proc: TNotifyEvent);
begin
  if(not assigned(PositionList)) then
    PositionList := TORNotifyList.Create;
  PositionList.Add(Proc);
end;

procedure RemoveNotifyWhenProcessingReminderChanges(Proc: TNotifyEvent);
begin
  if(assigned(PositionList)) then
    PositionList.Remove(Proc);
end;

function ReminderDialogActive: boolean;
begin
  Result := assigned(frmRemDlg);
end;

function CurrentReminderInDialog: TReminderDialog;
begin
  Result := nil;
  if(assigned(frmRemDlg)) then
    Result := frmRemDlg.FReminderDlg;
end;

var
  uRemDlgStarting: boolean = False;

procedure ViewRemDlgFromForm(OwningForm: TForm;
                             RemNode: TORTreeNode;
                             Template: TTemplate;
                             InitDlg, IsTemplate: boolean);
var
  Update: boolean;
  Err: string;

begin
  if uRemDlgStarting then exit;  // CQ#16219 - double click started reminder creation twice
  uRemDlgStarting := True;
  try
    Err := '';
    if assigned(frmRemDlg) then begin
      if IsTemplate then begin
        Err := 'Can not process template while another reminder dialog is being processed.'
      end else if frmRemDlg.FProcessingTemplate then begin
        Err := 'Can not process reminder while a reminder dialog template is being processed.';
      end;
    end;
    Update := FALSE;
    if Err = '' then begin
      if(RemForm.Form <> OwningForm) then begin
        if(assigned(RemForm.Form)) then begin
          Err := 'Reminders currently begin processed on another tab.'
        end else begin
          if(OwningForm = frmNotes) then begin
            frmNotes.AssignRemForm;
            if FutureEncounter(RemForm.PCEObj) then Err := 'Can not process a reminder dialog for a future encounter date.';
          {end else if(OwningForm = frmConsults) then begin
            frmConsults.AssignRemForm  }
          end else begin
            Err := 'Can not process reminder dialogs on this tab.';
          end;
          Update := TRUE;
        end;
      end;
    end;
    if (Err = '') and (FutureEncounter(RemForm.PCEObj)) then begin
       Err := 'Can not process a reminder dialog for a future encounter date.';
    end;
    if Err <> '' then begin
      InfoBox(Err, 'Reminders in Process', MB_OK or MB_ICONERROR);
      exit;
    end;

    if(InitDlg and (not assigned(frmRemDlg))) then begin
      //(AGP add) Check for a bad encounter date
      if RemForm.PCEObj.DateTime < 0 then begin
        InfoBox('The parent note has an invalid encounter date. Please contact IRM support for assistance.','Warning',MB_OK);
        exit;
      end;
      frmRemDlg := TfrmRemDlg.Create(Application);
      frmRemDlg.SetFontSize;
      Update := TRUE;
    end;
    if(assigned(frmRemDlg)) then begin
      if Update then begin
        frmRemDlg.FSCRelated  := RemForm.PCEObj.SCRelated;
        frmRemDlg.FAORelated  := RemForm.PCEObj.AORelated;
        frmRemDlg.FIRRelated  := RemForm.PCEObj.IRRelated;
        frmRemDlg.FECRelated  := RemForm.PCEObj.ECRelated;
        frmRemDlg.FMSTRelated := RemForm.PCEObj.MSTRelated;
        frmRemDlg.FHNCRelated := RemForm.PCEObj.HNCRelated;
        frmRemDlg.FCVRelated  := RemForm.PCEObj.CVRelated;
        frmRemDlg.FSHDRelated := RemForm.PCEObj.SHADRelated;
      end;
      UpdateReminderFinish;
      if IsTemplate then begin
        frmRemDlg.ProcessTemplate(Template)
      end else if assigned(RemNode) then begin
        frmRemDlg.ProcessReminder(RemNode.StringData, RemNode.TreeView.GetNodeID(RemNode, 1, IncludeParentID));
      end;
    end;
  finally
    uRemDlgStarting := False;
  end;
end;

procedure TMGViewRemDlgFromNotes(DialogIEN, PrintName : string;
                                InitDlg : boolean = true);
//kt added procedure, copied and modified from ViewRemDlgFromForm
var
  Update: boolean;
  Err: string;
  OwningForm: TForm;

begin
  if uRemDlgStarting then exit;
  OwningForm := frmNotes;
  uRemDlgStarting := True;
  try
    Err := '';
    Update := FALSE;
    if(RemForm.Form <> OwningForm) then begin
      if (assigned(RemForm.Form)) then begin
        Err := 'Reminders currently begin processed on another tab.'
      end else begin
        frmNotes.AssignRemForm;
        if FutureEncounter(RemForm.PCEObj) then begin
          Err := 'Can not process a reminder dialog for a future encounter date.';
        end;
        Update := TRUE;
      end;
    end;
    if (Err = '') and (FutureEncounter(RemForm.PCEObj)) then begin
      Err := 'Can not process a reminder dialog for a future encounter date.';
    end;
    if Err <> '' then begin
      InfoBox(Err, 'Reminders in Process', MB_OK or MB_ICONERROR);
      exit;
    end;

    if(InitDlg and (not assigned(frmRemDlg))) then begin
      if RemForm.PCEObj.DateTime < 0 then begin
        InfoBox('The parent note has an invalid encounter date. Please contact IRM support for assistance.','Warning',MB_OK);
        exit;
      end;
      frmRemDlg := TfrmRemDlg.Create(Application);
      frmRemDlg.SetFontSize;    //--> BuildControls inside
      Update := TRUE;
    end;
    if(assigned(frmRemDlg)) then begin
      if Update then begin
        frmRemDlg.FSCRelated  := RemForm.PCEObj.SCRelated;
        frmRemDlg.FAORelated  := RemForm.PCEObj.AORelated;
        frmRemDlg.FIRRelated  := RemForm.PCEObj.IRRelated;
        frmRemDlg.FECRelated  := RemForm.PCEObj.ECRelated;
        frmRemDlg.FMSTRelated := RemForm.PCEObj.MSTRelated;
        frmRemDlg.FHNCRelated := RemForm.PCEObj.HNCRelated;
        frmRemDlg.FCVRelated  := RemForm.PCEObj.CVRelated;
        frmRemDlg.FSHDRelated := RemForm.PCEObj.SHADRelated;
      end;
      UpdateReminderFinish;
      frmRemDlg.ForceRenderDlg(DialogIEN, PrintName); //kt added
    end;
  finally
    uRemDlgStarting := False;
  end;
end;



procedure ViewRemDlg(RemNode: TORTreeNode; InitDlg, IsTemplate: boolean);
var
  own: TComponent;

begin
  if assigned(RemNode) then begin
    own := RemNode.TreeView.Owner.Owner; // Owner is the Drawers, Owner.Owner is the Tab
    if(not (own is TForm)) then begin
      InfoBox('ViewReminderDialog called from an unsupported location.',
              'Reminders in Process', MB_OK or MB_ICONERROR)
    end else begin
      ViewRemDlgFromForm(TForm(own), RemNode, TTemplate(RemNode.Data), InitDlg, IsTemplate);
    end;
  end;
end;

procedure ViewReminderDialog(RemNode: TORTreeNode; InitDlg: boolean = TRUE);
begin
  if(assigned(RemNode)) then begin
    ViewRemDlg(RemNode, InitDlg, FALSE)
  end else begin
    HideReminderDialog;
  end;
end;

procedure TMGViewReminderDialog(ReminderDialogIEN, PrintName: string; InitDlg: boolean = TRUE);
//kt added
begin
  if (ReminderDialogIEN <> '') then begin
    //ViewRemDlgFromForm(fNotes, RemNode, TTemplate(RemNode.Data), InitDlg, FALSE);
    TMGViewRemDlgFromNotes(ReminderDialogIEN, PrintName, InitDlg);
  end else begin
    HideReminderDialog;
  end;
end;


procedure ViewReminderDialogTemplate(TempNode: TORTreeNode; InitDlg: boolean = TRUE);
begin
  if(assigned(TempNode) and
    (assigned(TempNode.Data)) and
    (TTemplate(TempNode.Data).IsReminderDialog)) then begin
    ViewRemDlg(TempNode, InitDlg, TRUE)
  end else begin
    KillReminderDialog(nil);
  end;
end;

procedure ViewRemDlgTemplateFromForm(OwningForm: TForm; Template: TTemplate; InitDlg, IsTemplate: boolean);
begin
  if(assigned(OwningForm) and
     assigned(Template) and
     Template.IsReminderDialog) then begin
    ViewRemDlgFromForm(OwningForm, nil, Template, InitDlg, IsTemplate)
  end else begin
    KillReminderDialog(nil);
  end;
end;

procedure HideReminderDialog;
begin
  if(assigned(frmRemDlg)) then
    frmRemDlg.Hide;
end;

procedure UpdateReminderFinish;
begin
  if(assigned(frmRemDlg)) and (assigned(RemForm.Form)) then begin
    //kt frmRemDlg.btnFinish.Enabled := RemForm.CanFinishProc;  //kt <--- looks if progress notes editing index > -1
    frmRemDlg.btnFinish.Enabled := true;
    frmRemDlg.UpdateButtons;
  end;
end;

procedure KillReminderDialog(frm: TForm);
begin
  if(assigned(frm) and (assigned(RemForm.Form)) and
    (frm <> RemForm.Form)) then exit;
  if(assigned(frmRemDlg)) then
  begin
    frmRemDlg.FExitOK := TRUE;
    frmRemDlg.ResetProcessing;
  end;
  KillObj(@frmRemDlg);
end;

{ TfrmRemDlg }

procedure TfrmRemDlg.ProcessReminder(ARemData: string; NodeID: string);
var
  Rem: TReminder;
  TmpList: TStringList;
  Msg: string;
  Flds, Abort: boolean;

begin
  FProcessingTemplate := FALSE;
  Rem := GetReminder(ARemData);
  if(FReminderDlg <> Rem) then
  begin
    if(assigned(FReminderDlg)) then
    begin
      Abort := FALSE;
      Flds := FALSE;
      TmpList := TStringList.Create;
      try
        FReminderDlg.FinishProblems(TmpList, Flds);
        if(TmpList.Count > 0) or Flds then
        begin
          TmpList.Insert(0, '   Reminder: ' + FReminderDlg.PrintName);
          if Flds then
            TmpList.Add('      ' + MissingFieldsTxt);
          Msg := REQ_TXT + TmpList.Text + CRLF +
                 ' Ignore required items and continue processing?';
          Abort := (InfoBox(Msg, REQ_HDR, MB_YESNO or MB_DEFBUTTON2) = IDNO);
        end;
      finally
        TmpList.Free;
      end;
      if(Abort) then exit;
    end;
    ClearControls(TRUE);
    FReminderDlg := Rem;
    Rem.PCEDataObj := RemForm.PCEObj;
    BuildControls;
    UpdateText(nil);
  end;
  PositionTrees(NodeID);
  UpdateButtons;
  Show;
end;


procedure TfrmRemDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  KillObj(@ReminderDialogInfo, TRUE);  //kt added
end;

procedure TfrmRemDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if(not FExitOK) then begin
    CanClose := KillAll;
  end;
end;

procedure TfrmRemDlg.FormCreate(Sender: TObject);
begin
 // reData.Color := ReadOnlyColor;
//  reText.Color := ReadOnlyColor;
  FSCCond := EligbleConditions;
 (* FSCRelated  := SCC_NA;
  FAORelated  := SCC_NA;
  FIRRelated  := SCC_NA;       AGP Change 25.2
  FECRelated  := SCC_NA;
  FMSTRelated := SCC_NA;
  FHNCRelated := SCC_NA;
  FCVRelated  := SCC_NA;
  with FSCCond do
    FSCPrompt := (SCAllow or AOAllow or IRAllow or ECAllow or MSTAllow or HNCAllow or CVAllow); *)
  NotifyWhenRemindersChange(RemindersChanged);
  {RemForm.Drawers.NotifyWhenRemTreeChanges(RemindersChanged);}
  KillReminderDialogProc := KillReminderDialog;
  sb1.Color := DlgBackgroundColor; //kt added
  sb2.Color := DlgBackgroundColor; //kt added
end;

procedure TfrmRemDlg.FormDestroy(Sender: TObject);
begin
  if FProcessingTemplate then begin
    KillObj(@FReminderDlg);
  end;  
  //kt KillObj(@FClinMainBox);
  //Save the Position and Size of the Reminder Dialog
  RemDlgLeft := Self.Left;
  RemDlgTop := Self.Top;
  RemDlgWidth := Self.Width;
  RemDlgHeight := Self.Height;
  RemDlgSpltr1 := pnlBottom.Height;
  RemDlgSpltr2 := reData.Height;
//  SaveDialogSplitterPos(Name + 'Splitters', pnlBottom.Height, reData.Height);
  {RemForm.Drawers.RemoveNotifyWhenRemTreeChanges(RemindersChanged);}
  RemoveNotifyRemindersChange(RemindersChanged);
  KillReminderDialogProc := nil;
  ClearControls(TRUE);
  frmRemDlg := nil;
  if(assigned(frmReminderTree)) then begin
    frmReminderTree.EnableActions;
  end;
  RemForm.Form := nil;
end;

procedure TfrmRemDlg.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  box: TScrollBox;
begin
  box := GetBox(TRUE);
  If RectContains(box.BoundsRect, box.ScreenToClient(MousePos)) then
  begin
    ScrollControl(box, (WheelDelta > 0));
    Handled := True;
  end;
end;

procedure TfrmRemDlg.ClearControls(All: boolean = FALSE);

  procedure WipeOutControls(const Ctrl: TWinControl);
  var
    i: integer;

  begin
    for i := Ctrl.ControlCount-1 downto 0 do begin
      if(Ctrl.Controls[i].Owner = Self) then begin
        if(Ctrl.Controls[i] is TWinControl) then begin
          WipeOutControls(TWinControl(Ctrl.Controls[i]));
        end;
        if assigned(FReminderDlg) then FReminderDlg.TMGForgetControl(Ctrl.Controls[i]);  //kt added
        Ctrl.Controls[i].Free;
      end;
    end;
  end;

begin
  if(All) then begin
    WipeOutControls(sb1);
    WipeOutControls(sb2);
  end else begin
    WipeOutControls(GetBox);
  end;
end;

procedure TfrmRemDlg.TMGHighlightControl(IEN : string);
//kt added
begin
  FReminderDlg.TMGHighlightControl(IEN);
end;

procedure TfrmRemDlg.TMGSetCBValueForControl(IEN : String; Checked : boolean);
//kt added
begin
  FReminderDlg.TMGSetCBValueForControl(IEN, Checked);
end;

{procedure TfrmRemDlg.ClearMHTest(Rien: string);
var
MHKillArray: TStringList;
i,idx, j: integer;
TestName: string;
begin
  MHKillArray := TStringList.Create;
  idx := RemindersInProcess.IndexOf(RIEN);
  //Find All MH Test in the current Reminders and stored them in a temp Array
  if idx > -1 then
    begin
       if (TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray <> nil) and
       (TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Count > 0) then
         begin
           for j := 0 to TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Count - 1 do
             begin
               TestName := Piece(TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Strings[j], U, 1);
               //TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Delete(j);
               MHKillArray.Add(TestName);
             end;
         end;
       if Assigned(TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray) then
          TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Free;
      (* if (TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray <> nil) and
       (TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Count = 0) then
          TReminderDialog(TReminder(RemindersInProcess.Objects[idx])).MHTestArray.Free; *)
    end;
  //Check to see if other reminders contains any of the MH test in the temp Array if so set entry to null
  if (MHKillArray.Count > 0) and (RemindersInProcess.Count > 1) then
    begin
      for I := 0 to RemindersInProcess.Count - 1 do
        begin
          if (TReminderDialog(TReminder(RemindersInProcess.Objects[i])).IEN <> RIEN) and
             (TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray <> nil) and
             (TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray.Count > 0) then
               begin
                  for j := 0 to TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray.Count - 1 do
                    begin
                      TestName := Piece(TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray.Strings[j], U, 1);
                      idx := MHKillArray.IndexOf(TestName);
                      if idx > -1 then MHKillArray.Strings[idx] := '';
                    end;
               end;
        end;
    end;
  //Delete the temp file stored in the MH dll for any MH tests names left in the temp array
  if MHKillArray.Count > 0 then
    begin
      for I := 0 to MHKillArray.Count - 1 do
        begin
          if MHKillArray.Strings[i] <> '' then RemoveMHTest(MHKillArray.Strings[i]);
        end;
    end;
  if Assigned(MHKillArray) then FreeandNil(MHKillArray);
end;   }

procedure TfrmRemDlg.BuildControls;
var
  i, CtrlIdx, Y, ParentWidth: integer;
  AutoCtrl, Active, Ctrl: TWinControl;
  LastCB, LastObjCnt: integer;
  Box: TScrollBox;
  txt: string;

  function IsOnBox(Component: TComponent): boolean;
  var
    Prnt: TWinControl;
  begin
    Result := FALSE;
    if(Component is TWinControl) then begin
      Prnt := TWinControl(Component).Parent;
      while(assigned(Prnt)) and (not Result) do begin
        Result := (Prnt = Box);
        Prnt := Prnt.Parent;
      end;
    end;
  end; //IsOnBox

  procedure SetActiveVars(ActCtrl: TWinControl);
  var
    i: integer;

  begin
    LastObjCnt := 0;
    LastCB := 0;
    Active := ActCtrl;
    while(assigned(Active) and (Active.Owner <> Self)) do begin
      if(assigned(Active.Owner) and (Active.Owner is TWinControl)) then begin
        Active := TWinControl(Active.Owner)
      end else begin
        Active := nil;
      end;
    end;
    Ctrl := Active;
    if(assigned(Ctrl) and IsOnBox(Ctrl)) then begin
      if(Active is TORCheckBox) then
        LastCB := Active.Tag;
      if(LastCB = 0) then begin
        CtrlIdx := -1;
        for i := 0 to ComponentCount-1 do begin
          if(IsOnBox(Components[i])) then begin
            Ctrl := TWinControl(Components[i]);
            if(Ctrl is TORCheckBox) and (Ctrl.Tag <> 0) then
              CtrlIdx := i;
            if(Ctrl = Active) and (CtrlIdx >= 0) then begin
              LastCB := Components[CtrlIdx].Tag;
              LastObjCnt := (i - CtrlIdx);
              break;
            end;
          end;
        end;
      end;
    end;
  end;  //SetActiveVars

begin  //TfrmRemDlg.BuildControls
  if(assigned(FReminderDlg)) then begin
    Box := GetBox(TRUE);
    if Box.ControlCount > 0 then ClearControls; //AGP Change 26.1 this change should
                                                //resolve the problem with Duplicate CheckBoxes
                                                //appearing on some reminder dialogs CQ #2843
    Y := Box.VertScrollBar.Position;
    GetBox.VertScrollBar.Position := 0;
    if FProcessingTemplate then
      txt := 'Reminder Dialog Template'
    else
      txt := 'Reminder Resolution';
    Caption := txt + ': ' + FReminderDlg.PrintName;
    FReminderDlg.OnNeedRedraw := nil;
    ParentWidth := Box.Width - ScrollBarWidth - 6;
    SetActiveVars(ActiveControl);
    AutoCtrl := FReminderDlg.BuildControls(ParentWidth, GetBox, Self);
    GetBox.VertScrollBar.Position := Y;
    BoxUpdateDone; 
    if(LastCB <> 0) then begin
      Box := GetBox(TRUE);
      if(assigned(AutoCtrl)) then begin
        AutoCtrl.SetFocus;
        if(AutoCtrl is TORComboBox) then begin
          TORComboBox(AutoCtrl).DroppedDown := TRUE;
        end;
      end else for i := 0 to ComponentCount-1 do begin
        if(IsOnBox(Components[i])) then begin
          Ctrl := TWinControl(Components[i]);
          if(Ctrl is TORCheckBox) and (Ctrl.Tag = LastCB) then begin
            if((i + LastObjCnt) < ComponentCount) and
              (Components[i + LastObjCnt] is TWinControl) then begin
              TWinControl(Components[i + LastObjCnt]).SetFocus;
            end;
            break;
          end;
        end;
      end;
    end;

    ClearControls;

    FReminderDlg.OnNeedRedraw := ControlsChanged;
    FReminderDlg.OnTextChanged := UpdateText;
  end;
end;  //TfrmRemDlg.BuildControls

function TfrmRemDlg.GetBox(Other: boolean = FALSE): TScrollBox;
begin
  if(FUseBox2 xor Other) then
    Result := sb2
  else
    Result := sb1;
end;

procedure TfrmRemDlg.BoxUpdateDone;
begin
  sb2.Visible := FUseBox2;
  sb1.Visible := not FUseBox2;
  FUseBox2 := not FUseBox2;
  ClearControls;
  {if ScreenReaderSystemActive then
    amgrMain.RefreshComponents;}
  Application.ProcessMessages; // allows new ScrollBox to repaint
end;

procedure TfrmRemDlg.ControlsChanged(Sender: TObject);
begin
  FLastWidth := GetBox(TRUE).ClientWidth;
{ This routine is fired as a result of clicking a checkbox.  If we destroy
  the checkbox here we get access violations because the checkbox code is
  still processing the click event after calling this routine.  By posting
  a message we can guarantee that the checkbox is no longer processing the
  click event when the message is handled, preventing access violations. }
  PostMessage(Handle, UM_RESYNCREM, 0 ,0);
end;

procedure TfrmRemDlg.UMResyncRem(var Message: TMessage);
begin
  BuildControls;   
end;

procedure TfrmRemDlg.sbResize(Sender: TObject);
begin
{ If you remove this logic you will get an infinite loop in some cases }
  if(FLastWidth <> GetBox(TRUE).ClientWidth) then
    ControlsChanged(Sender);
end;

procedure TfrmRemDlg.UpdateText(Sender: TObject);
const
  BadType = TPCEDataCat(-1);

var
  TopIdx, i, LastPos, CurPos, TxtStart: integer;
  Cat, LastCat: TPCEDataCat;
  Rem: TReminderDialog;
  TmpData: TORStringList;
  Bold: boolean;
  tmp: string;

begin
  RedrawSuspend(reText.Handle);
  try
    TopIdx := SendMessage(reText.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
    reText.Clear;
    LastPos := reText.SelStart;
    reText.SelAttributes.Style := reText.SelAttributes.Style - [fsBold];
    i := 0;
    repeat
      if FProcessingTemplate then begin
        Rem := FReminderDlg
      end else begin
        Rem := TReminder(RemindersInProcess.Objects[i]);
      end;
      Rem.AddText(reText.Lines);
      reText.SelStart := MaxInt;
      CurPos := reText.SelStart;
      if(Rem = FReminderDlg) then begin
        reText.SelStart := LastPos;
        reText.SelLength := CurPos - LastPos;
        reText.SelAttributes.Style := reText.SelAttributes.Style + [fsBold];
        reText.SelLength := 0;
        reText.SelStart := CurPos;
        reText.SelAttributes.Style := reText.SelAttributes.Style - [fsBold];
      end;
      LastPos := CurPos;
      inc(i);
    until(FProcessingTemplate or (i >= RemindersInProcess.Count));
    if((not FProcessingTemplate) and (reText.Lines.Count > 0)) then begin
      reText.Lines.Insert(0, ClinRemText);
      reText.SelStart := 0;
      reText.SelLength := length(ClinRemText);
      reText.SelAttributes.Style := reText.SelAttributes.Style - [fsBold];
      reText.SelLength := 0;
      reText.SelStart := MaxInt;
    end;
    SendMessage(reText.Handle, EM_LINESCROLL, 0, TopIdx);
  finally
    RedrawActivate(reText.Handle);
  end;

  TmpData := TORStringList.Create;
  try
    reData.Clear;
    LastCat := BadType;
    tmp := RemForm.PCEObj.StrVisitType(FSCRelated, FAORelated, FIRRelated,
                          FECRelated, FMSTRelated, FHNCRelated, FCVRelated,FSHDRelated);
    if FProcessingTemplate then begin
      i := GetReminderData(FReminderDlg, TmpData)
    end else begin
      i := GetReminderData(TmpData);
    end;
    if(tmp = '') and (i = 0) then begin
      reData.Lines.insert(0,TX_NOPCE);
    end;
    TmpData.Sort;
    RedrawSuspend(reData.Handle);
    try
      TopIdx := SendMessage(reData.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
      reData.SelAttributes.Style := reData.SelAttributes.Style - [fsBold];
      if tmp <> '' then begin
        reData.SelText := tmp + CRLF;
      end;
      i := 0;
      while i < TmpData.Count do begin
        tmp := TmpData[i];
        TxtStart := 2;
        Bold := FALSE;
        Cat := TPCEDataCat(ord(tmp[1]) - ord('A'));
        if(LastCat <> Cat) or (Cat = pdcVital) then begin
          if(Cat = pdcVital) then begin
            inc(TxtStart);
          end;
          if(LastCat <> BadType) then begin
            reData.SelText := CRLF;
            reData.SelStart := MaxInt;
          end;
          reData.SelText := PCEDataCatText[Cat];
          reData.SelStart := MaxInt;
          LastCat := Cat;
        end else begin
          reData.SelText := ', ';
          reData.SelStart := MaxInt;
        end;
        repeat
          if(TRemData(TmpData.Objects[i]).Parent.Reminder = FReminderDlg) then begin
            Bold := TRUE;
          end;
          inc(i);
        until (i >= TmpData.Count) or (TmpData[i] <> tmp);
        if(Bold) then begin
          reData.SelAttributes.Style := reData.SelAttributes.Style + [fsBold];
        end;
        reData.SelText := copy(tmp, TxtStart, MaxInt);
        reData.SelStart := MaxInt;
        if(Bold) then begin
          reData.SelAttributes.Style := reData.SelAttributes.Style - [fsBold];
        end;
      end;
      SendMessage(reData.Handle, EM_LINESCROLL, 0, TopIdx);
    finally
      RedrawActivate(reData.Handle);
    end;
  finally
    TmpData.Free;
  end;
end;

procedure TfrmRemDlg.btnClearClick(Sender: TObject);
var
  Tmp, TmpNode: string;
  i: integer;
  OK: boolean;

begin
  if(assigned(FReminderDlg)) then begin
    try
    self.btnClear.Enabled := false;
    i := RemindersInProcess.IndexOf(FReminderDlg.IEN);
    if(i >= 0) then begin
      if(FReminderDlg.Processing) then begin
        OK := (InfoBox('Clear all reminder resolutions for ' + FReminderDlg.PrintName,
               'Clear Reminder Processing', MB_YESNO or MB_DEFBUTTON2) = ID_YES)
      end else begin
        OK := TRUE;
      end;
      if(OK) then begin
        {ClearMHTest(FReminderDlg.IEN);}
        RemindersInProcess.Delete(i);
        Tmp := (FReminderDlg as TReminder).RemData; // clear should never be active if template
        TmpNode := (FReminderDlg as TReminder).CurrentNodeID;
        KillObj(@FReminderDlg);
        ProcessReminder(Tmp, TmpNode);
      end;
    end;
    finally
      self.btnClear.Enabled := true;
    end;
  end;
end;

procedure TfrmRemDlg.btnCancelClick(Sender: TObject);
begin
  try
    self.btnCancel.Enabled := false;
  if(KillAll) then begin
    FExitOK := TRUE;
    frmRemDlg.Release;
    frmRemDlg := nil;
  end;
  finally
    self.btnCancel.Enabled := true;
  end;
end;

function TfrmRemDlg.KillAll: boolean;
var
  i, cnt: integer;
  msg, RemWipe: string;
  //ClearMH: boolean;

begin
 //AGP 25.11 Added RemWipe section to cancel button to
 //flag the patient specific dialog to be destroy if not in process.
 RemWipe := '';
 //ClearMH := false;
  {if frmFrame.TimedOut = True then
     begin
       result := True;
       Exit;
     end; }
  Result := TRUE;  //kt added
  if FProcessingTemplate or FSilent then begin
    Result := TRUE;
    if FReminderDlg.RemWipe = 1 then RemWipe := Piece(FReminderDlg.DlgData,U,1);
    if (FProcessingTemplate) and (FReminderDlg.Processing) then begin
      msg := msg + '  ' + FReminderDlg.PrintName + CRLF;
      msg := 'The Following Reminders are being processed:' + CRLF + CRLF + msg;
      msg := msg + CRLF + 'Canceling will cause all processing information to be lost.' + CRLF +
                    'Do you still want to cancel out of reminder processing?';
      //kt Result := (InfoBox(msg, 'Cancel Reminder Processing', MB_YESNO or MB_DEFBUTTON2) = ID_YES);
    end;
  end else begin
    msg := '';
    cnt := 0;
    for i := 0 to RemindersInProcess.Count-1 do begin
      if TReminderDialog(TReminder(RemindersInProcess.Objects[i])).RemWipe = 1 then begin
        if RemWipe ='' then RemWipe := TReminder(RemindersInProcess.Objects[i]).IEN
        else RemWipe := RemWipe + U + TReminder(RemindersInProcess.Objects[i]).IEN
      end;
      if(TReminder(RemindersInProcess.Objects[i]).Processing) then begin
        msg := msg + '  ' + TReminder(RemindersInProcess.Objects[i]).PrintName + CRLF;
        inc(cnt);
      end;
    end;
    if(msg <> '') then begin
      if(cnt > 1) then begin
        msg := 'The Following Reminders are being processed:' + CRLF + CRLF + msg
      end else begin
        msg := 'The Following Reminder is being processed: ' + CRLF + CRLF + msg;
      end;
      msg := msg + CRLF + 'Canceling will cause all processing information to be lost.' + CRLF +
                          'Do you still want to cancel out of reminder processing?';
      //kt Result := (InfoBox(msg, 'Cancel Reminder Processing', MB_YESNO or MB_DEFBUTTON2) = ID_YES);
    end else begin
      Result := TRUE;
    end;
  end;
  if(Result) then begin
    if FProcessingTemplate or FSilent then begin
      if (FReminderDlg.MHTestArray <> nil) and (FReminderDlg.MHTestArray.Count > 0) then begin
       (* if ClearMH = false then
          begin
            RemoveMHTest('');
            ClearMH := true;
          end; *)
        {RemoveMHTest('');
        FReminderDlg.MHTestArray.Free;}
      end;
    end else begin
      for i := 0 to RemindersInProcess.Count - 1 do begin
        if (TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray <> nil) and
           (TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray.Count > 0) then begin
          {if ClearMH = false then
            begin
              RemoveMHTest('');
              ClearMH := true;
            end;
          RemoveMHTest(''); }
          TReminderDialog(TReminder(RemindersInProcess.Objects[i])).MHTestArray.Free;
        end;
      end;
    end;
    ResetProcessing(RemWipe);
  end;
end;

function TfrmRemDlg.GetCurReminderList: integer;
var
  Sel, Node: TORTreeNode;
  Data: string;
  NodeCheck, Cur: boolean;

begin
  Result := -1;
  CurReminderList := TORStringList.Create;
  Sel := TORTreeNode(RemForm.Drawers.tvReminders.Selected);
  NodeCheck := (assigned(Sel) and assigned(FReminderDlg) and
               (Piece(Sel.StringData,U,1) = RemCode +FReminderDlg.IEN));
  Node := TORTreeNode(RemForm.Drawers.tvReminders.Items.GetFirstNode);
  while assigned(Node) do
  begin
    Data := TORTreeNode(Node).StringData;
    if(copy(Data, 1, 1) = RemCode) then
    begin
      delete(Data,1,1);
      Data := Node.TreeView.GetNodeID(Node, 1, IncludeParentID) + U + Data;
      if(NodeCheck) then
        Cur := (Node = Sel)
      else
        Cur := (assigned(FReminderDlg)) and (FReminderDlg.IEN = Piece(Data,U,1));
      if(Cur) then
        Result := CurReminderList.Add(Data)
      else
      if(Piece(Data, U , 8) = '1') then
        CurReminderList.Add(Data);
    end;
    Node := TORTreeNode(Node.GetNextVisible);
  end;
end;

function TfrmRemDlg.NextReminder: string;
var
  idx: integer;

begin
  Result := '';
  idx := GetCurReminderList;
  try
    inc(idx);
    if(idx < CurReminderList.Count) then
      Result := CurReminderList[idx];
  finally
    KillObj(@CurReminderList);
  end;
end;

function TfrmRemDlg.BackReminder: string;
var
  idx: integer;

begin
  Result := '';
  idx := GetCurReminderList;
  try
    dec(idx);
    if(idx >= 0) then
      Result := CurReminderList[idx];
  finally
    KillObj(@CurReminderList);
  end;
end;

procedure TfrmRemDlg.ProcessReminderFromNodeStr(value: string);
var
  NodeID: string;
  Data: string;
  i: integer;

begin
  if(Value = '') then
  begin
    UpdateButtons;
    exit;
  end;
  Data := Value;
  i := pos(U, Data);
  if(i = 0) then i := length(Data);
  NodeID :=copy(Data,1,i-1);
  delete(Data,1,i);
  Data := RemCode + Data;
  ProcessReminder(Data, NodeID);
end;

procedure TfrmRemDlg.btnNextClick(Sender: TObject);
begin
  ProcessReminderFromNodeStr(NextReminder);
end;

procedure TfrmRemDlg.btnBackClick(Sender: TObject);
begin
  ProcessReminderFromNodeStr(BackReminder);
end;

procedure TfrmRemDlg.UpdateButtons;
begin
  if(assigned(frmRemDlg)) and (not FProcessingTemplate) then begin
    btnBack.Enabled := btnFinish.Enabled and (BackReminder <> '');
    btnNext.Enabled := btnFinish.Enabled and (NextReminder <> '');
    //kt btnClinMaint.Enabled := (not assigned(FClinMainBox));
  end;
end;

procedure TfrmRemDlg.PositionTrees(NodeID: string);
begin
  exit; //kt added
  if(assigned(PositionList)) and (not FProcessingTemplate) then
  begin
    if(assigned(FReminderDlg)) then
      (FReminderDlg as TReminder).CurrentNodeID := NodeID;
    PositionList.Notify(FReminderDlg);
  end;
end;

procedure TfrmRemDlg.btnFinishClick(Sender: TObject);
var
  i, cnt, lcnt,OldRemCount, OldCount, T: integer;
  CurDate, CurLoc: string;
  LastDate, LastLoc: string;
  Rem: TReminderDialog;
  Reminder: TReminder;
 // Prompt: TRemPrompt;
  RData: TRemData;
  TmpData: TORStringList;
  OrderList: TStringList;
  TmpText: TStringList;
  TmpList: TStringList;
  VitalList: TStringList;
  MHList: TStringList;
  WHList: TStringList;
  MSTList: TStringList;
  HistData, PCEObj: TPCEData;
  Cat: TPCEDataCat;
  VisitParent, Msg, tmp: string;
  DelayEvent: TOrderDelayEvent;
  Hist: boolean;
  v: TVitalType;
  UserStr: string;
  BeforeLine, AfterTop: integer;
  GAFScore: integer;
  TestDate: TFMDateTime;
  TestStaff: Int64;
  DoOrders, Done, Kill, Flds: boolean;
  TR: TEXTRANGE;
  buf: array[0..3] of char;
  AddLine: boolean;
  Process, StoreVitals: boolean;
  PCEType: TPCEType;
  WHNode,WHPrint,WHResult,WHTmp, WHValue: String;
  WHType: TStrings;
  //Test: String;
  MHLoc, WHCnt,x: Integer;
  WHArray: TStringlist;
  GecRemIen, GecRemStr, RemWipe: String;

  procedure Add(PCEItemClass: TPCEItemClass);  // in TfrmRemDlg.btnFinishClick
  var
    itm: TPCEItem;
    tmp: string;

  begin
    if(Cat in MSTDataTypes) then begin
      tmp := piece(TmpData[i],U,pnumMST);
      if (tmp <> '') then begin
        MSTList.Add(tmp);
        tmp := TmpData[i];
        setpiece(tmp,U,pnumMST,'');
        TmpData[i] := tmp;
      end;
    end;
    itm := PCEItemClass.Create;
    try
      itm.SetFromString(copy(TmpData[i], 2, MaxInt));
      TmpList.AddObject('',itm);
      if Cat = pdcHF then itm.FGecRem := GecRemStr;
      case Cat of
        pdcDiag: PCEObj.SetDiagnoses(TmpList, FALSE);
        pdcProc: PCEObj.SetProcedures(TmpList, FALSE);
        pdcImm:  PCEObj.SetImmunizations(TmpList, FALSE);
        pdcSkin: PCEObj.SetSkinTests(TmpList, FALSE);
        pdcPED:  PCEObj.SetPatientEds(TmpList, FALSE);
        pdcHF:   PCEObj.SetHealthFactors(TmpList, FALSE);
        pdcExam: PCEObj.SetExams(TmpList, FALSE);
      end;
      itm.Free;
      TmpList.Clear;
    except
      itm.free;
    end;
  end;  //Add(PCEItemClass: TPCEItemClass);  // in TfrmRemDlg.btnFinishClick

  procedure SaveMSTData(MSTVal: string);  // in TfrmRemDlg.btnFinishClick
  var vdate, s1, s2, prov, FType, FIEN: string;

  begin
    if MSTVal <> '' then begin
      s1    := piece(MSTVal, ';', 1);
      vdate := piece(MSTVal, ';', 2);
      prov  := piece(MSTVal, ';', 3);
      FIEN  := piece(MSTVal, ';', 4);
      if FIEN <> '' then begin
        s2 := s1;
        s1 := '';
        FType := RemDataCodes[dtExam];
      end else begin
        s2 := '';
        FType := RemDataCodes[dtHealthFactor];
      end;
      SaveMSTDataFromReminder(vdate, s1, Prov, FType, FIEN, s2);
    end;
  end; //SaveMSTData(MSTVal: string);  // in TfrmRemDlg.btnFinishClick

begin //TfrmRemDlg.btnFinishClick
  Kill := FALSE;
  GecRemIen := '0';
  WHList := nil;
  Rem := nil;
  RemWipe := '';   //AGP CHANGE 24.8
  try
    self.btnFinish.Enabled := false;
    OldRemCount := ProcessedReminders.Count;
    if not FProcessingTemplate then
      ProcessedReminders.Notifier.BeginUpdate;
    try
      TmpList := TStringList.Create;
      try
        i := 0;
        repeat
        //AGP Added RemWipe section this section will determine if the Dialog is a patient specific
          if FProcessingTemplate or (i < RemindersInProcess.Count) then begin
            if FProcessingTemplate then begin
              Rem := FReminderDlg;
              if Rem.RemWipe = 1 then begin
                RemWipe := Piece(Rem.DlgData,U,1);
              end;
            end else begin
              Rem := TReminder(RemindersInProcess.Objects[i]);
              if TReminderDialog(TReminder(RemindersInProcess.Objects[i])).RemWipe = 1 then begin
                if RemWipe ='' then RemWipe := TReminder(RemindersInProcess.Objects[i]).IEN
                else RemWipe := RemWipe + U + TReminder(RemindersInProcess.Objects[i]).IEN;
              end;
            end;

            Flds := FALSE;
            OldCount := TmpList.Count;
            Rem.FinishProblems(TmpList, Flds);
            if(OldCount <> TmpList.Count) or Flds then begin
              TmpList.Insert(OldCount, '');
              if not FProcessingTemplate then begin
                TmpList.Insert(OldCount+1, '   Reminder: ' + Rem.PrintName);
              end;
              if Flds then begin
                TmpList.Add('      ' + MissingFieldsTxt);
              end;
            end;
            inc(i);
          end;
        until(FProcessingTemplate or (i >= RemindersInProcess.Count));

        if FProcessingTemplate then
          PCEType := ptTemplate
        else
          PCEType := ptReminder;

        Process := TRUE;
        if(TmpList.Count > 0) then begin
          Msg := REQ_TXT + TmpList.Text;
          InfoBox(Msg, REQ_HDR, MB_OK);
          Process := FALSE;
        end else begin
          TmpText := TStringList.Create;
          try
            if (not FProcessingTemplate) and (not InsertRemTextAtCursor) then begin
              RemForm.NewNoteRE.SelStart := MaxInt; // Move to bottom of note
            end;
            AddLine := FALSE;
            BeforeLine := SendMessage(RemForm.NewNoteRE.Handle, EM_EXLINEFROMCHAR, 0, RemForm.NewNoteRE.SelStart);
            if (SendMessage(RemForm.NewNoteRE.Handle, EM_LINEINDEX, BeforeLine, 0) <> RemForm.NewNoteRE.SelStart) then begin
              RemForm.NewNoteRE.SelStart := SendMessage(RemForm.NewNoteRE.Handle, EM_LINEINDEX, BeforeLine+1, 0);
              inc(BeforeLine);
            end;
            if(RemForm.NewNoteRE.SelStart > 0) then begin
              if(RemForm.NewNoteRE.SelStart = 1) then begin
                AddLine := TRUE
              end else begin
                TR.chrg.cpMin := RemForm.NewNoteRE.SelStart-2;
                TR.chrg.cpMax := TR.chrg.cpMin+2;
                TR.lpstrText := @buf;
                SendMessage(RemForm.NewNoteRE.Handle, EM_GETTEXTRANGE, 0, LPARAM(@TR));
                if(buf[0] <> #13) or (buf[1] <> #10) then begin
                  AddLine := TRUE;
                end;
              end;
            end;
            if FProcessingTemplate then begin
              FReminderDlg.AddText(TmpText)
            end else begin
              for i := 0 to RemindersInProcess.Count-1 do begin
                TReminder(RemindersInProcess.Objects[i]).AddText(TmpText);
              end;
            end;
            if(TmpText.Count > 0) then begin
              if not FProcessingTemplate then begin
                tmp := ClinRemText;
                if(tmp <> '') then begin
                  i := RemForm.NewNoteRE.Lines.IndexOf(tmp);
                  if(i < 0) or (i > BeforeLine) then begin
                    TmpText.Insert(0, tmp);
                    if(RemForm.NewNoteRE.SelStart > 0) then begin
                      TmpText.Insert(0, '');
                    end;
                    if(BeforeLine < RemForm.NewNoteRE.Lines.Count) then begin
                      TmpText.Add('');
                    end;
                  end;
                end;
              end;
              if AddLine then
                TmpText.Insert(0, '');
              CheckBoilerplate4Fields(TmpText, 'Unresolved template fields from processed Reminder Dialog(s)');
              if TmpText.Count = 0 then begin
                Process := FALSE
              end else begin
                if RemForm.PCEObj.NeedProviderInfo and MissingProviderInfo(RemForm.PCEObj, PCEType) then begin
                  Process := FALSE
                end else begin
                  RemForm.NewNoteRE.SelText := TmpText.Text;
                  //SpeakTextInserted;
                end;
              end;
            end;
            if(Process) then begin
              SendMessage(RemForm.NewNoteRE.Handle, EM_SCROLLCARET, 0, 0);
              AfterTop := SendMessage(RemForm.NewNoteRE.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
              SendMessage(RemForm.NewNoteRE.Handle, EM_LINESCROLL, 0, -1 * (AfterTop - BeforeLine));
            end;
          finally
            TmpText.Free;
          end;
        end;
        if(Process) then begin
          PCEObj := RemForm.PCEObj;
        (* AGP CHANGE 23.2 Remove this section base on the Clinical Workgroup decision
          if FSCPrompt and (ndSC in PCEObj.NeededPCEData) then
            btnVisitClick(nil);
          PCEObj.SCRelated  := FSCRelated;
          PCEObj.AORelated  := FAORelated;
          PCEObj.IRRelated  := FIRRelated;
          PCEObj.ECRelated  := FECRelated;
          PCEObj.MSTRelated := FMSTRelated;
          PCEObj.HNCRelated := FHNCRelated;
          PCEObj.CVRelated  := FCVRelated; *)
          if not FProcessingTemplate then begin
            for i := 0 to RemindersInProcess.Count-1 do begin
              Reminder := TReminder(RemindersInProcess.Objects[i]);
              if(Reminder.Processing) and (ProcessedReminders.IndexOf(Reminder.RemData) < 0) then begin
                ProcessedReminders.Add(Copy(Reminder.RemData,2,MaxInt));
              end;
            end;
          end;
          OrderList := TStringList.Create;
          try
            MHList := TStringList.Create;
            try
              StoreVitals := TRUE;
              VitalList := TStringList.Create;
              try
                WHList := TStringList.Create;
                try
                  MSTList := TStringList.Create;
                  try
                    TmpData := TORStringList.Create;
                    try
                      UserStr := '';
                      LastDate := U;
                      LastLoc := U;
                      VisitParent := '';
                      HistData := nil;
                      for Hist := FALSE to TRUE do begin
                        TmpData.Clear;
                        if FProcessingTemplate then begin
                          i := GetReminderData(FReminderDlg, TmpData, TRUE, Hist)
                        end else begin
                          GetReminderData(TmpData, TRUE, Hist);
                        end;
                        if(TmpData.Count > 0) then begin
                          if Hist then
                            TmpData.SortByPieces([pnumVisitDate, pnumVisitLoc])
                          else
                            TmpData.Sort;
                          TmpData.RemoveDuplicates;
                          TmpList.Clear;
                          for i := 0 to TmpData.Count-1 do begin
                            if(Hist) then begin
                              CurDate := Piece(TmpData[i], U, pnumVisitDate);
                              CurLoc := Piece(TmpData[i], U, pnumVisitLoc);
                              if(CurDate = '') then CurDate := FloatToStr(Encounter.DateTime);
                              if(LastDate <> CurDate) or (LastLoc <> CurLoc) then begin
                                if(assigned(HistData)) then begin
                                  HistData.Save;
                                  HistData.Free;
                                end;
                                LastDate := CurDate;
                                LastLoc := CurLoc;
                                HistData := TPCEData.Create;
                                HistData.DateTime := MakeFMDateTime(CurDate);
                                HistData.VisitCategory := 'E';
                                if(VisitParent = '') then
                                  VisitParent := GetVisitIEN(RemForm.NoteList.ItemIEN);
                                HistData.Parent := VisitParent;
                                if(StrToIntDef(CurLoc,0) = 0) then
                                  CurLoc := '0' + U + CurLoc;
                                HistData.HistoricalLocation := CurLoc;
                                PCEObj := HistData;
                              end;
                            end;
                            Cat := TPCEDataCat(ord(TmpData[i][1]) - ord('A'));
                            //check this for multiple process
                            //RData := TRemData(TmpData.Objects[i]);
                            if Cat = pdcHF then begin
                              if not FProcessingTemplate and
                                (GecRemIen <> TRemData(TmpData.Objects[i]).Parent.Reminder.IEN) then begin
                                GecRemIen := TRemData(TmpData.Objects[i]).Parent.Reminder.IEN;
                                GecRemStr := CheckGECValue('R' + GecRemIen, PCEObj.NoteIEN);
                                //SetPiece(TmpData.Strings[i],U,11,GecRemStr);
                              end;
                              if FProcessingTemplate then begin
                                if GecRemIen <> Rem.IEN then begin
                                  GecRemIen := Rem.IEN;
                                  GecRemStr := CheckGECValue(Rem.IEN, PCEObj.NoteIEN)
                                end;
                              end;
                            end;
                            case Cat of
                      //        pdcVisit:
                              pdcDiag:  Add(TPCEDiag);
                              pdcProc:  Add(TPCEProc);
                              pdcImm:   Add(TPCEImm);
                              pdcSkin:  Add(TPCESkin);
                              pdcPED:   Add(TPCEPat);
                              pdcHF:    Add(TPCEHealth);
                              pdcExam:  Add(TPCEExams);


                              pdcVital:
                                if (StoreVitals) then begin
                                  Tmp := Piece(TmpData[i], U, 2);
                                  for v := low(TValidVitalTypes) to high(TValidVitalTypes) do begin
                                    if(Tmp = VitalCodes[v]) then begin
                                      if(UserStr = '') then
                                        UserStr := GetVitalUser;

                                      if(FVitalsDate = 0) then begin
                                        FVitalsDate := TRemData(TmpData.Objects[i]).Parent.VitalDateTime;
                                        StoreVitals := ValidVitalsDate(FVitalsDate, TRUE, FALSE);  //AGP Change 26.1
                                        if (not StoreVitals) then break;
                                      end;

                                      Tmp := GetVitalStr(v, Piece(TmpData[i], U, 3), '', UserStr, FloatToStr(FVitalsDate));
                                      if(Tmp <> '') then
                                        VitalList.Add(Tmp);
                                      break;
                                    end;
                                  end;
                                end;

                              pdcOrder: OrderList.Add(TmpData[i]);
                              pdcMH:    MHList.Add(TmpData[i]);
                              pdcWHR:
                                 begin
                                   WHNode := TmpData.Strings[i];
                                   SetPiece(WHNode,U,11,TRemData(TmpData.Objects[i]).Parent.WHResultChk);
                                   WHList.Add(WHNode);
                                 end;

                              pdcWH:
                                  begin
                                     WHPrint := TRemData(TmpData.Objects[i]).Parent.WHPrintDevice;
                                     WHNode := TmpData.Strings[i];
                                     SetPiece(WHNode,U,11,TRemData(TmpData.Objects[i]).Parent.WHResultNot);
                                     SetPiece(WHNode,U,12,Piece(WHPrint,U,1));
                                     SetPiece(WHNode,U,13,TRemData(TmpData.Objects[i]).Parent.Reminder.WHReviewIEN); //AGP CHANGE 23.13
                                     WHList.Add(WHNode);
                                   end;
                            end; //case
                          end; //for loop
                          if(Hist) then begin
                            if(assigned(HistData)) then begin
                              HistData.Save;
                              HistData.Free;
                              HistData := nil;
                            end;
                          end else begin
                            while RemForm.PCEObj.NeedProviderInfo do
                              MissingProviderInfo(RemForm.PCEObj, PCEType);
                            RemForm.PCEObj.Save;
                            VisitParent := GetVisitIEN(RemForm.NoteList.ItemIEN);
                          end;
                        end;
                      end;

                    finally
                      TmpData.Free;
                    end;

                    for i := 0 to MSTList.Count-1 do
                      SaveMSTData(MSTList[i]);

                  finally
                    MSTList.Free;
                  end;

                  if(StoreVitals) and (VitalList.Count > 0) then begin
                    VitalList.Insert(0, VitalDateStr     + FloatToStr(FVitalsDate));
                    VitalList.Insert(1, VitalPatientStr  + Patient.DFN);
                    if IntToStr(Encounter.Location) <> '0' then //AGP change 26.9
                       VitalList.Insert(2, VitalLocationStr + IntToStr(Encounter.Location))
                    else
                       VitalList.Insert(2, VitalLocationStr + IntToStr(RemForm.PCEObj.Location));;
                    {Tmp := ValAndStoreVitals(VitalList);
                    if (Tmp <> 'True') then
                      ShowMsg(Tmp);}
                  end;

                finally
                  VitalList.Free;
                end;

                if(MHList.Count > 0) then begin
                  TestDate := 0;
                  for i := 0 to MHList.Count-1 do begin
                    try
                      TestDate := StrToFloat(Piece(MHList[i],U,4));
                    except
                      on EConvertError do
                        TestDate := 0
                      else
                        raise;
                    end;
                    if(TestDate > 0) then begin
                      TestStaff := StrToInt64Def(Piece(MHList[i],U,5), 0);
                      if TestStaff <= 0 then begin
                        TestStaff := User.DUZ;
                      end;
                      if (Piece(MHList[i],U,3) = '1') and (MHDLLFound = false) then begin
                        GAFScore := StrToIntDef(Piece(MHList[i],U,6),0);
                        if(GAFScore > 0) then begin
                          SaveGAFScore(GAFScore, TestDate, TestStaff);
                        end;
                      end else begin
                        if Piece(MHLIst[i],U,6) = 'New MH dll' then begin
                          //The dll take date and time the original code took only date.
                          if Encounter.Location <> FReminderDlg.PCEDataObj.Location then begin
                            MHLoc := FReminderDlg.PCEDataObj.Location
                          end else MHLoc := Encounter.Location;
                          {saveMHTest(Piece(MHList[i],U,2), FloattoStr(FReminderDlg.PCEDataObj.VisitDateTime), InttoStr(MHLoc));}
                        end else begin
                          SaveMentalHealthTest(Piece(MHList[i],U,2), TestDate, TestStaff,
                                               Piece(MHList[i],U,6));
                        end;
                      end;
                    end;
                  end;
                end;

              finally
                MHList.Free;
                if (FReminderDlg.MHTestArray <> nil) and (FReminderDlg.MHTestArray.Count > 0) then FReminderDlg.MHTestArray.Free;
              end;

              if(WHList.Count > 0) then begin
                WHResult :='';
                for i :=0 to WHList.Count-1 do begin
                  WHNode := WHList.Strings[i];
                  if (Pos('N', Piece(WHNode,U,1)) <> 0) then begin
                    SetPiece(WHResult,U,1,'WHIEN:'+Piece(WHNode,U,2));
                    SetPiece(WHResult,U,2,'DFN:'+Patient.DFN);
                    SetPiece(WHResult,U,3,'WHRES:'+Piece(WHNode,U,11));
                    SetPiece(WHResult,U,4,'Visit:'+Encounter.VisitStr);
                    if (not assigned(WHArray)) then WHArray := TStringList.Create;
                    WHArray.Add(WHResult);
                  end;
                  if (Pos('O', Piece(WHNode,U,1)) <> 0) then begin
                    SetPiece(WHResult,U,1,'WHPur:'+Piece(WHNode,U,2));
                    SetPiece(WHResult,U,2,Piece(WHNode,U,11));
                    SetPiece(WHResult,U,3,Piece(WHNode,U,12));
                    SetPiece(WHResult,U,4,'DFN:'+Patient.DFN);
                    SetPiece(WHResult,U,5,Piece(WHNode,U,13)); //AGP CHANGE 23.13
                    if (not assigned(WHArray)) then WHArray := TStringList.Create;
                    WHArray.Add(WHResult);
                  end;
                end;
              end;
              SaveWomenHealthData(WHArray);
            finally
            WHList.Free;
            end;

            ResetProcessing(RemWipe);
            Hide;
            Kill := TRUE;
            RemForm.DisplayPCEProc;

            // Process orders after PCE data saved in case of user input
            if(OrderList.Count > 0) then begin
              DelayEvent.EventType := 'C';
              DelayEvent.Specialty := 0;
              DelayEvent.Effective := 0;
              DelayEvent.PtEventIFN :=0;
              DelayEvent.EventIFN  := 0;
              DoOrders := TRUE;
              {
              repeat
                Done := TRUE;
                if not ReadyForNewOrder(DelayEvent) then begin //kt added different ReadyForNewOrder function
                  if(InfoBox('Unable to place orders.','Retry Orders?',
                             MB_RETRYCANCEL or MB_ICONWARNING) = IDRETRY) then begin
                    Done := FALSE
                  end else begin
                    DoOrders := FALSE;
                    ShowMsg('No Orders Placed.');
                  end;
                end;
              until(Done);
              }
              if(DoOrders) then begin
                if(OrderList.Count = 1) then begin
                  //kt start mod ----
                  MessageDlg('Here I place order.  '+#13#10+
                             'Order string='+OrderList[0]+#13#10+
                             'Code='+CharAt(Piece(OrderList[0], U, 3), 1)+#13#10+
                             'Number='+Piece(OrderList[0], U, 2)+#13#10,
                             mtInformation,[mbOK],0);
                  //kt --- end mod
                  {//kt case CharAt(Piece(OrderList[0], U, 3), 1) of
                    'A':      ActivateAction(     Piece(OrderList[0], U, 2), RemForm.Form, 0);
                    'D', 'Q': ActivateOrderDialog(Piece(OrderList[0], U, 2), DelayEvent, RemForm.Form, 0);
                    'M':      ActivateOrderMenu(  Piece(OrderList[0], U, 2), DelayEvent, RemForm.Form, 0);
                    'O':      ActivateOrderSet(   Piece(OrderList[0], U, 2), DelayEvent, RemForm.Form, 0);
                  end;}
                end else begin
                  for i := 0 to OrderList.Count-1 do begin
                    tmp := Pieces(OrderList[i], U, 2, 4);
                    OrderList[i] := tmp;
                  end;
                  MessageDlg('Here I would order multiple orders:'+#13#10+
                             OrderList.Text, mtInformation, [mbOK], 0);  //kt added
                  {//kt ActivateOrderList(OrderList, DelayEvent, RemForm.Form, 0, '', '');}
                end;
              end;
            end;
          finally
            OrderList.Free;
          end;
        end;
      finally
        TmpList.Free;
      end;
    finally
      if not FProcessingTemplate then begin
        ProcessedReminders.Notifier.EndUpdate(ProcessedReminders.Count <> OldRemCount);
      end;
    end;
  finally
    self.btnFinish.Enabled := true;
    if(Kill) then begin
      FExitOK := TRUE;
      Close;
    end;
  end;
end;  //TfrmRemDlg.btnFinishClick

procedure TfrmRemDlg.ResetProcessing(Wipe: string = ''); //AGP CHANGE 24.8
var
  i: integer;
  RemWipeArray : TStringlist;

begin
  if FProcessingTemplate then begin
    KillObj(@FReminderDlg)
  end else begin
    while(RemindersInProcess.Count > 0) do begin
      RemindersInProcess.Notifier.BeginUpdate;
      try
        RemindersInProcess.KillObjects;
        RemindersInProcess.Clear;
      finally
        FReminderDlg := nil;
        RemindersInProcess.Notifier.EndUpdate(TRUE);
      end;
    end;
  end;
  ClearControls(TRUE);
  PositionTrees('');
  //AGP Change 24.8 Add wipe section for reminder wipe
  If Wipe <> '' then begin
    RemWipeArray := TStringlist.Create;
    if pos(U,Wipe)>0 then begin
      for i:=0 to ReminderDialogInfo.Count-1 do begin
        if pos(ReminderDialogInfo.Strings[i],Wipe)>0 then begin
          RemWipeArray.Add(ReminderDialogInfo.Strings[i]);
        end;
      end;
    end else begin
      RemWipeArray.Add(Wipe);
    end;
    if assigned(RemWipeArray) then begin
      for i:=0 to RemWipeArray.Count-1 do begin
        KillDlg(@ReminderDialogInfo, RemWipeArray.Strings[i], True);
      end;
    end;
    if (assigned(RemWipeArray)) then begin
      RemWipeArray.Clear ;
      RemWipeArray.Free;
    end;
  end;
end;


procedure TfrmRemDlg.RemindersChanged(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TfrmRemDlg.btnClinMaintClick(Sender: TObject);
begin
  {//kt
  if(not assigned(FClinMainBox)) then
  begin
    FClinMainBox := ModelessReportBox(DetailReminder(StrToIntDef(FReminderDlg.IEN,0)),
                    ClinMaintText + ': ' + FReminderDlg.PrintName, TRUE);
    FOldClinMaintOnDestroy := FClinMainBox.OnDestroy;
    FClinMainBox.OnDestroy := ClinMaintDestroyed;
    UpdateButtons;
  end;
  }
end;

procedure TfrmRemDlg.ClinMaintDestroyed(Sender: TObject);
begin
  if(assigned(FOldClinMaintOnDestroy)) then
    FOldClinMaintOnDestroy(Sender);
  //kt FClinMainBox := nil;
  UpdateButtons;
end;

procedure TfrmRemDlg.btnVisitClick(Sender: TObject);
{var
  frmRemVisitInfo: TfrmRemVisitInfo;
  VitalsDate: TFMDateTime;}

begin
  {if FVitalsDate = 0 then
    VitalsDate := FMNow  //AGP Change 26.1
  else
    VitalsDate := FVitalsDate;
  frmRemVisitInfo := TfrmRemVisitInfo.Create(Self);
  try
    frmRemVisitInfo.fraVisitRelated.InitAllow(FSCCond);
    frmRemVisitInfo.fraVisitRelated.InitRelated(FSCRelated, FAORelated,
                FIRRelated, FECRelated, FMSTRelated, FHNCRelated, FCVRelated, FSHDRelated);
    frmRemVisitInfo.dteVitals.FMDateTime := VitalsDate;
    frmRemVisitInfo.ShowModal;
    if frmRemVisitInfo.ModalResult = mrOK then
    begin
      VitalsDate := frmRemVisitInfo.dteVitals.FMDateTime;
      if VitalsDate <= FMNow then
        FVitalsDate := VitalsDate;
      frmRemVisitInfo.fraVisitRelated.GetRelated(FSCRelated, FAORelated,
                FIRRelated, FECRelated, FMSTRelated, FHNCRelated, FCVRelated, FSHDRelated);
      FSCPrompt := FALSE;
      UpdateText(nil);
    end;
  finally
    frmRemVisitInfo.Free;
  end;}
end;
procedure TfrmRemDlg.ForceRenderDlg(DialogIEN, PrintName: string);
//kt added function, copied from ProcessTemplate
begin
  FProcessingTemplate  := TRUE;
  btnClear.Visible     := FALSE;
  btnClinMaint.Visible := FALSE;
  btnBack.Visible      := FALSE;
  btnNext.Visible      := FALSE;
  btnVisit.Visible     := FALSE; //kt added
  FReminderDlg := TReminderDialog.Create(DialogIEN + U + PrintName + U + '0');
  ClearControls(TRUE);
  FReminderDlg.PCEDataObj := RemForm.PCEObj;
  BuildControls;
  UpdateText(nil);
  UpdateButtons;
  Show;   //kt causes hang --> ShowModal;
end;


procedure TfrmRemDlg.ProcessTemplate(Template: TTemplate);
begin
  FProcessingTemplate  := TRUE;
  btnClear.Visible     := FALSE;
  btnClinMaint.Visible := FALSE;
  btnBack.Visible      := FALSE;
  btnNext.Visible      := FALSE;
  FReminderDlg := TReminderDialog.Create(Template.ReminderDialogIEN + U + Template.PrintName + U +
                  Template.ReminderWipe);  //AGP CHANGE      24.8
  ClearControls(TRUE);
  FReminderDlg.PCEDataObj := RemForm.PCEObj;
  BuildControls;
  UpdateText(nil);
  UpdateButtons;
  Show;
end;

procedure TfrmRemDlg.SetFontSize;
begin
  ResizeAnchoredFormToFont(frmRemDlg);
  {//kt
  if Assigned(FClinMainBox) then
    ResizeAnchoredFormToFont(FClinMainBox);
  }
  BuildControls;
end;


{ AGP Change 24.8 You MUST pass an address to an object variable to get KillObj to work }
procedure TfrmRemDlg.KillDlg(ptr: Pointer; ID: string; KillObjects: boolean = FALSE);
var
  Obj: TObject;
  Lst: TList;
  SLst: TStringList;
  i: integer;

begin
  Obj := TObject(ptr^);
  if(assigned(Obj)) then
  begin
    if(KillObjects) then
    begin
      if(Obj is TList) then
      begin
        Lst := TList(Obj);
        for i := Lst.count-1 downto 0 do
          if assigned(Lst[i]) then
            TObject(Lst[i]).Free;
      end
      else
      if(Obj is TStringList) then
      begin
        SLst := TStringList(Obj);
        //Check to see if the Reminder IEN is in the of IEN to be wipe out
        for i := SLst.count-1 downto 0 do
          if assigned(SLst.Objects[i]) and (pos(Slst.Strings[i],ID)>0) then
            SLst.Objects[i].Free;
      end;
    end;
    Obj.Free;
    TObject(ptr^) := nil;
  end;
end;

procedure TfrmRemDlg.FormShow(Sender: TObject);
begin
  //Set The form to it's Saved Position
  Left := RemDlgLeft;
  Top := RemDlgTop;
  Width := RemDlgWidth;
  Height := RemDlgHeight;
  pnlFrmBottom.Height := RemDlgSpltr1 + lblFootnotes.Height;
  reData.Height := RemDlgSpltr2;
end;

initialization

finalization
  KillReminderDialog(nil);
  KillObj(@PositionList);

end.
