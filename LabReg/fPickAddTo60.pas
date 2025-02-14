unit fPickAddTo60;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ORCtrls,
  uSrchHelper;

type
  TDataNameMode = (dnHide, dnPick, dnAdd);
  TResultMode = (rmNone, rmExistingTest, rmPanel, rmNonPanelExistingDN, rmNonPanelNewDN);

  TfrmPickAdd60 = class(TForm)
    rgSelectMode: TRadioGroup;
    pnlMain: TPanel;
    pnlBottom: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pnlPick: TPanel;
    pnlAdd: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblLabName: TLabel;
    edtLabSrch: TEdit;
    lbLabSrch: TListBox;
    rgIsPanel: TRadioGroup;
    rgDataName: TRadioGroup;
    pnlPickDN: TPanel;
    pnlNewTest: TPanel;
    edtDNSrch: TEdit;
    lbDNSrch: TListBox;
    Label3: TLabel;
    pnlAddDN: TPanel;
    Label5: TLabel;
    edtNewDNName: TEdit;
    Label4: TLabel;
    edtAbrvDNName: TEdit;
    Label7: TLabel;
    edtNewLabTestName: TEdit;
    Label6: TLabel;
    lblLabType: TLabel;
    Image1: TImage;
    procedure edtAbrvDNNameChange(Sender: TObject);
    procedure edtNewLabTestNameChange(Sender: TObject);
    procedure edtNewDNNameChange(Sender: TObject);
    procedure rgDataNameClick(Sender: TObject);
    procedure rgIsPanelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgSelectModeClick(Sender: TObject);
  private
    { Private declarations }
    Mode : string;  //'R' or result-type or 'O' or order-type
    AlertHandle : string;
    TestName : string;
    DataNameVisibilityMode : TDataNameMode;
    LabSrchHelper : TSrchHelper;
    DNSrchHelper : TSrchHelper;
    StorageLoc63d04 : string;
    ResultMode : TResultMode;
    procedure HandleLabSrchSelected(Sender : TObject);
    procedure HandleDNSrchSelected(Sender : TObject);
    procedure SetDataNamePickVisibility(Mode : TDataNameMode);
    procedure SetOKButtonEnable;
    function ReadyForOKButton : boolean;
  public
    { Public declarations }
    ResultIEN60 : string;
    ResultIEN60Name : string;
    procedure Initialize(AlertHandle, TestName : string; Mode : string);
  end;

//var frmPickAdd60: TfrmPickAdd60;

implementation

{$R *.dfm}

  uses
    rHL7RPCsU, ORFn;

  procedure TfrmPickAdd60.edtAbrvDNNameChange(Sender: TObject);
  begin
    SetOKButtonEnable;
  end;

  procedure TfrmPickAdd60.edtNewDNNameChange(Sender: TObject);
  begin
    SetOKButtonEnable;
  end;

  procedure TfrmPickAdd60.edtNewLabTestNameChange(Sender: TObject);
  begin
    SetOKButtonEnable;
  end;

  procedure TfrmPickAdd60.FormCreate(Sender: TObject);
  begin
    LabSrchHelper := TSrchHelper.Create(Self);
    LabSrchHelper.Initialize(edtLabSrch, lbLabSrch, '60');  //this will set up TComboBox to work like a search box.
    LabSrchHelper.OnSelectedChange := HandleLabSrchSelected;

    DNSrchHelper := TSrchHelper.Create(Self);
    DNSrchHelper.Initialize(edtDNSrch, lbDNSrch, '63.04');  //this will set up TComboBox to work like a search box.
    DNSrchHelper.ServerCustomizerFn := '$$CUSTDN^TMGHL7R2';
    DNSrchHelper.OnSelectedChange := HandleDNSrchSelected;
    DataNameVisibilityMode := dnHide;
  end;

  procedure TfrmPickAdd60.FormDestroy(Sender: TObject);
  begin
    LabSrchHelper.Free;
    DNSrchHelper.Free;
  end;

  procedure TfrmPickAdd60.Initialize(AlertHandle, TestName : string; Mode : string);
  //TestName -- name of the test from the HL7 message (perhaps shortened by user to 30 chars)
  //Mode -- O = order-type tests (from OBR segment in HL7), or R = resulting-type tests (from OBX in Hl7)
  begin
    ResultIEN60 := '';
    ResultIEN60Name := '';
    Self.AlertHandle := AlertHandle;
    Self.TestName := TestName;
    Self.Mode := Mode;
    if Mode = 'O' then begin
      lblLabType.Caption := 'Name of test ORDERED by provider';
    end else if Mode = 'R' then begin
      lblLabType.Caption := 'Name of test RESULTED by lab';
    end else begin
      lblLabType.Caption := Mode;
    end;
    StorageLoc63d04 := '';
    lblLabName.Caption := TestName;
    btnOK.Enabled := false;
    rgSelectMode.ItemIndex := 0;  //default to Select existing lab.
    rgSelectModeClick(self);
    edtNewDNName.Text := TestName;
    edtNewLabTestName.Text := TestName;
  end;

  procedure TfrmPickAdd60.HandleLabSrchSelected(Sender : TObject);
  begin
    ResultIEN60 := LabSrchHelper.SelectedIEN;
    ResultIEN60Name := LabSrchHelper.SelectedName;
    SetOKButtonEnable;
  end;

  procedure TfrmPickAdd60.HandleDNSrchSelected(Sender : TObject);
  //Called by search helper when DN search has selected term.
  begin
    StorageLoc63d04 := DNSrchHelper.SelectedIEN;
    SetOKButtonEnable;    
  end;

  procedure TfrmPickAdd60.SetDataNamePickVisibility(Mode : TDataNameMode);
  begin
    case Mode of
      dnHide: begin
                pnlAddDN.Visible := false;
                pnlPickDN.Visible := false;
                pnlPickDN.Align := alNone;
              end;
      dnPick: begin
                pnlAddDN.Visible := false;
                pnlPickDN.Visible := true;
                pnlPickDN.Align := alTop;
                pnlPickDN.Height := pnlAdd.Height div 2;
              end;
      dnAdd: begin
                pnlPickDN.Visible := false;
                pnlAddDN.Visible := true;
                pnlAddDN.Align := alTop;
                //pnlAddDN.Height := pnlAdd.Height div 2;
             end;
    end;
    pnlNewTest.Align := alClient;
  end;

  procedure TfrmPickAdd60.rgDataNameClick(Sender: TObject);
  var NewDataName : boolean;
  begin
    NewDataName := (rgDataName.ItemIndex = 1);
    if NewDataName then begin
      SetDataNamePickVisibility(dnAdd);
    end else begin
      SetDataNamePickVisibility(dnPick);
    end;
    SetOKButtonEnable;    
  end;

  procedure TfrmPickAdd60.rgIsPanelClick(Sender: TObject);
  var IsPanel : boolean;
  begin
    IsPanel := (rgIsPanel.ItemIndex = 0);
    rgDataName.Visible := not IsPanel;
    if IsPanel then begin
      SetDataNamePickVisibility(dnHide);
    end else begin
      rgDataNameClick(self);
    end;
    SetOKButtonEnable;
  end;

  procedure TfrmPickAdd60.rgSelectModeClick(Sender: TObject);
  var AddNew : boolean;
      OrderTypeTest : boolean;
  begin
    //Change view based on which selected.
    AddNew := (rgSelectMode.ItemIndex = 1);
    if AddNew then begin
      rgDataName.Visible := true;
      OrderTypeTest := (Self.Mode = 'O');
      if OrderTypeTest then begin
        rgIsPanel.Visible := true;
        rgDataName.Left := rgIsPanel.Left + rgIsPanel.Width + 5;
        rgIsPanelClick(nil);
      end else begin  //result-type tests are never panels
        rgIsPanel.Visible := false;
        rgDataName.Left := rgIsPanel.Left;
        rgDataNameClick(nil);
        rgIsPanel.ItemIndex := 1;  //force to labs is NOT panel
      end;
      pnlAdd.Visible := true;
      pnlPick.Visible := false;
      pnlAdd.Align := alClient;
    end else begin
      pnlPick.Visible := true;
      pnlAdd.Visible := false;
      pnlPick.Align := alClient;
      rgIsPanel.Visible := false;
      //pnlMain.Top := rgIsPanel.Top;
      rgDataName.Visible := false;
      SetDataNamePickVisibility(dnHide);
    end;
    pnlMain.Height := pnlBottom.Top - pnlMain.Top - 2;
    SetOKButtonEnable;
  end;

  procedure TfrmPickAdd60.SetOKButtonEnable;
  begin
    btnOK.Enabled := ReadyForOKButton;
  end;

  function TfrmPickAdd60.ReadyForOKButton : boolean;
  var NamesOK : boolean;
  begin
    ResultMode := rmNone;
    NamesOK := false;
    Result := false;
    if rgSelectMode.ItemIndex = 0 then begin //'Select and existing lab test'
      Result := ((ResultIEN60 <> '') and (ResultIEN60Name <> ''));
      ResultMode := rmExistingTest;
    end else begin
      NamesOK := ((edtNewLabTestName.Text <> '') and (edtAbrvDNName.Text <> ''));
      if rgIsPanel.ItemIndex = 0 then begin  //'Lab is a PANEL'
        Result := NamesOK;
        ResultMode := rmPanel;
      end else begin  //'Lab is a NOT a panel
        if rgDataName.ItemIndex = 0 then begin //Select an existing storage location
          Result := ((StorageLoc63d04 <> '') and NamesOK);
          ResultMode := rmNonPanelExistingDN;
        end else begin  //'Add a new storage location
          Result := ((edtNewDNName.Text <> '') and NamesOK);
          ResultMode := rmNonPanelNewDN;
        end;
      end;
    end;
  end;

  procedure TfrmPickAdd60.btnOKClick(Sender: TObject);
  //NOTE: before this could be called, ReadyForOKButton must have returned TRUE
  var CloseOK : boolean;
      Temp : string;
  begin
    CloseOK := false;
    if ResultMode = rmExistingTest then begin
      if MessageDlg('Are you sure you want to store lab results for:' + lblLabName.Caption +  #13#10 +
                    'with other VistA lab results for:' + ResultIEN60Name + '?',
                    mtConfirmation, [mbOK,mbCancel], 0) <> mrOK then begin
        //user aborting
        exit;
      end;
      // ResultIEN60 and ResultIEN60Name are already set.
      CloseOK := true;
    end else begin
      if ResultMode = rmNonPanelNewDN then begin
        if MessageDlg('Add a new lab storage location named:' + #13#10 +
                   edtNewDNName.Text + '?' + #13#10 +
                   'NOTE: this can not be undone', mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then begin
          //user aborting
          exit;
        end;
        StorageLoc63d04 := AutoAddDataName(edtNewDNName.Text);
        if StorageLoc63d04 = '' then exit;
      end;
      if MessageDlg('Add a new lab test name:' + #13#10 +
                 edtNewLabTestName.Text + '?' + #13#10 +
                 'NOTE: this can not be undone', mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then begin
        //user aborting
        exit;
      end;
      Temp := AddLabTest60(AlertHandle, edtNewLabTestName.Text, edtAbrvDNName.Text, StorageLoc63d04);
      if Temp = '' then exit;
      ResultIEN60 := piece(Temp, '^', 1);
      ResultIEN60Name := piece(Temp, '^', 2);
      Link60ToDataName(AlertHandle, ResultIEN60, StorageLoc63d04); //ignore results for now...
      CloseOK := true;
    end;
    if CloseOK then Self.ModalResult := mrOK;
  end;
end.

