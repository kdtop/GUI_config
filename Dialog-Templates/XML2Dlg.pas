unit XML2Dlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls,
  Dialogs, StdCtrls, StrUtils, ORFn,
  RemDlgCreator, XMLDoc, XMLIntf;

type
  TXMLDlg = class(TObject)
  private
    FRoot : TVirtDlgElement;
    FResults : TStringList;
    FSender : TComponent;
    FXMLFile : String;
    procedure ChangeXMLFile(Value : String);
    procedure CreateDlgFromXML(Filename : String);
  public
    property XMLFile : string read FXMLFile write ChangeXMLFile;
    constructor Create(Sender: TComponent);
    destructor Destroy;
    function GetDlgFromXML: TStrings;            //Note: User should not destroy object
    function GetResults(IEN: integer): TStrings; //Note: User should not destroy object
  end;

implementation

  constructor TXMLDlg.Create(Sender: TComponent);
  begin
    FRoot := TVirtDlgElement.Create(nil);
    FSender := Sender;
    FResults := TStringList.Create;
  end;

  destructor TXMLDlg.Destroy;
  begin
    FRoot.Free;
    FResults.Free;
    inherited Destroy;
  end;

  procedure TXMLDlg.ChangeXMLFile(Value : String);
  begin
    if Value = FXMLFile then exit;
    FXMLFile := Value;
    CreateDlgFromXML(FXMLFile);
  end;

  function TXMLDlg.GetDlgFromXML : TStrings;
  begin
    FRoot.OutputDefToSL(FResults);
    Result := FResults
  end;

  function TXMLDlg.GetResults(IEN: integer): TStrings;
  begin
    FRoot.OutputResultsToSL(IEN,FResults);
    Result := FResults;
  end;

  procedure TXMLDlg.CreateDlgFromXML(Filename : String);
  var
    XMLDoc : TXMLDocument;
    nd : IXMLNode;
    i :integer;
    AChild : TVirtDlgElement;
    Parent : TVirtDlgElement;
    TempResult : TStrings;

    procedure ProcessItem(node : IXMLNode;AChild : TVirtDlgElement)  ;
    var
      title : string;
      ANewChild : TVirtDlgElement;
    begin
      node := node.ChildNodes.First;
      while node <> nil do begin
        ANewChild := AChild.CreateChild;
        ANewChild.Caption := node.NodeName;
        ANewChild.DrawBox := True;
        ANewChild.IndentNum := AChild.IndentNum + 1;
        if node.IsTextElement then ANewChild.Text.Text := node.Text;
        ProcessItem(node,ANewChild);
        node := node.NextSibling;
      end;
    end;

  begin
    FRoot.Clear;
    if Filename = '' then exit;
    XMLDoc := TXMLDocument.Create(FSender);
    XMLDoc.LoadFromFile(Filename);
    XMLDoc.Active := True;

    nd := XMLDoc.DocumentElement.ChildNodes.First;
    nd := nd.ChildNodes.First;

    while nd <> nil do begin
      AChild := Froot.CreateChild;
      AChild.IndentNum := 0;
      AChild.Caption := nd.NodeName;
      AChild.DrawBox := True;
      if nd.IsTextElement then AChild.Text.Text := nd.Text else AChild.Text.Text := 'BLOCK';
      ProcessItem(nd,AChild);
      nd := nd.NextSibling;
    end;
    XMLDoc.Active := False;
    XMLDoc.Free;
  end;



end.

