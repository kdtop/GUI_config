unit fPtSelDemog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ORCtrls;

type
  TfrmPtSelDemog = class(TForm)
    orapnlMain: TORAutoPanel;
    lblSSN: TStaticText;
    lblPtSSN: TStaticText;
    lblDOB: TStaticText;
    lblPtDOB: TStaticText;
    lblPtSex: TStaticText;
    lblPtVet: TStaticText;
    lblPtSC: TStaticText;
    lblLocation: TStaticText;
    lblPtRoomBed: TStaticText;
    lblPtLocation: TStaticText;
    lblRoomBed: TStaticText;
    lblPtName: TStaticText;
    Memo: TCaptionMemo;
    lblPtHRN: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FLastDFN: string;
    FOldWinProc :TWndMethod;
    procedure NewWinProc(var Message: TMessage);
  public
    procedure ClearIDInfo;
    procedure ShowDemog(ItemID: string);
    procedure ToggleMemo;
  end;

var
  frmPtSelDemog: TfrmPtSelDemog;

implementation

uses rCore;

{$R *.DFM}

const
{ constants referencing the value of the tag property in components }
  TAG_HIDE     =  1;                             // labels to be hidden
  TAG_CLEAR    =  2;                             // labels to be cleared

procedure TfrmPtSelDemog.ClearIDInfo;
{ clears controls with patient ID info (controls have '2' in their Tag property }
var
  i: Integer;
begin
  FLastDFN := '';
  with orapnlMain do
  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i].Tag = TAG_HIDE then Controls[i].Visible := False;
    if Controls[i].Tag = TAG_CLEAR then with Controls[i] as TStaticText do Caption := '';
  end;
  Memo.Clear;
end;

procedure TfrmPtSelDemog.ShowDemog(ItemID: string);
{ gets a record of patient indentifying information from the server and displays it }
var
  PtRec: TPtIDInfo;
  i: Integer;

begin
  if ItemID = FLastDFN then Exit;
  Memo.Clear;
  FLastDFN := ItemID;
  PtRec := GetPtIDInfo(ItemID);
  with PtRec do
  begin
    Memo.Lines.Add(Name);
    Memo.Lines.Add(lblSSN.Caption + ' ' + SSN + '.');
    Memo.Lines.Add(lblDOB.Caption + ' ' + DOB + '.');
    if Sex <> '' then
      Memo.Lines.Add(Sex + '.');
    if Vet <> '' then
      Memo.Lines.Add(Vet + '.');
    if SCsts <> '' then
      Memo.Lines.Add(SCsts + '.');
    if Location <> '' then
      Memo.Lines.Add(lblLocation.Caption + ' ' + Location + '.');
    if RoomBed <> '' then
      Memo.Lines.Add(lblRoomBed.Caption + ' ' + RoomBed + '.');

    lblPtName.Caption     := Name;
    lblPtSSN.Caption      := SSN;
    lblPtDOB.Caption      := DOB;
    lblPtSex.Caption      := Sex {+ ', age ' + Age};
    lblPtSC.Caption       := SCSts;
    lblPtVet.Caption      := Vet;
    lblPtLocation.Caption := Location;
    lblPtRoomBed.Caption  := RoomBed;
    //VWPT
    {if HRN <> '' then lblPtHRN.Caption      := 'HRN: '+HRN
    else}    lblPtHRN.Caption :=''  ;
  end;
  with orapnlMain do for i := 0 to ControlCount - 1 do
    if Controls[i].Tag = TAG_HIDE then Controls[i].Visible := True;
  if lblPtLocation.Caption = '' then
    lblLocation.Hide
  else
    lblLocation.Show;
  if lblPtRoomBed.Caption = ''  then
    lblRoomBed.Hide
  else
    lblRoomBed.Show;
  Memo.SelectAll;
end;

procedure TfrmPtSelDemog.ToggleMemo;
begin
  if Memo.Visible then
  begin
    Memo.Hide;
  end
  else
  begin
    Memo.Show;
    Memo.BringToFront;
  end;
end;

procedure TfrmPtSelDemog.FormCreate(Sender: TObject);
begin
  FOldWinProc := orapnlMain.WindowProc;
  orapnlMain.WindowProc := NewWinProc;
end;

procedure TfrmPtSelDemog.NewWinProc(var Message: TMessage);
const
  Gap = 4;

begin
  if(assigned(FOldWinProc)) then FOldWinProc(Message);
  if(Message.Msg = WM_Size) then
  begin
    if(lblPtSSN.Left < (lblSSN.Left+lblSSN.Width+Gap)) then
      lblPtSSN.Left := (lblSSN.Left+lblSSN.Width+Gap);
    if(lblPtDOB.Left < (lblDOB.Left+lblDOB.Width+Gap)) then
      lblPtDOB.Left := (lblDOB.Left+lblDOB.Width+Gap);
    if(lblPtSSN.Left < lblPtDOB.Left) then
      lblPtSSN.Left := lblPtDOB.Left
    else
      lblPtDOB.Left := lblPtSSN.Left;

    if(lblPtLocation.Left < (lblLocation.Left+lblLocation.Width+Gap)) then
      lblPtLocation.Left := (lblLocation.Left+lblLocation.Width+Gap);
    if(lblPtRoomBed.Left < (lblRoomBed.Left+lblRoomBed.Width+Gap)) then
      lblPtRoomBed.Left := (lblRoomBed.Left+lblRoomBed.Width+Gap);
    if(lblPtLocation.Left < lblPtRoomBed.Left) then
      lblPtLocation.Left := lblPtRoomBed.Left
    else
      lblPtRoomBed.Left := lblPtLocation.Left;
  end;
end;

procedure TfrmPtSelDemog.FormDestroy(Sender: TObject);
begin
  orapnlMain.WindowProc := FOldWinProc;
end;

end.
