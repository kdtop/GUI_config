unit DrawersUnit;

//Unit removed.....  Not used....

interface
  uses Classes, Controls, ORCtrls, ComCtrls, uCore;


type
  TPseudoDrawers = class (TObject)
  private
    FtvReminders : TORTreeView;
    procedure tvRemindersMouseUp(Sender: TObject; Button: TMouseButton;
                                 Shift: TShiftState; X, Y: Integer);
  public
    procedure LoadReminders(tvReminders : TORTreeView);
  end;

var
  PseudoDrawers : TPseudoDrawers;


implementation

  uses
    fReminderdialog,
    fEncnt, uConst,
    uReminders, dShared, fPtSel;

  //-----------------------------------------------------
  //-----------------------------------------------------


  procedure TPseudoDrawers.tvRemindersMouseUp(Sender: TObject;
                                              Button: TMouseButton;
                                              Shift: TShiftState;
                                              X, Y: Integer);
  begin
    if(Button = mbLeft) and
    (assigned(FtvReminders)) and
    (assigned(FtvReminders.Selected)) and
    (htOnItem in FtvReminders.GetHitTestInfoAt(X, Y)) then begin
      ViewReminderDialog(ReminderNode(FtvReminders.Selected));
    end;
  end;

  procedure TPseudoDrawers.LoadReminders(tvReminders : TORTreeView);
  var
    UserCancelled: boolean;
    debugForcePickPt : boolean;
  begin
    debugForcePickPt := false;
    if (Patient.DFN = '') or debugForcePickPt then begin
      SelectPatient(false, 11, UserCancelled);
      if UserCancelled then exit;
      UpdateEncounter(NPF_PROVIDER);
      RemindersStarted := TRUE;
      LoadReminderData;
    end;
    FtvReminders := tvReminders;
    BuildReminderTree(FtvReminders);
    FtvReminders.OnMouseUp := tvRemindersMouseUp;
  end;

initialization
  PseudoDrawers := TPseudoDrawers.Create;

finalization
  PseudoDrawers.Free;

end.
