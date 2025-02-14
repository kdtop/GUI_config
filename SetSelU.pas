unit SetSelU;
   (* 
   WorldVistA Configuration Utility
   (c) 8/2008 Kevin Toppenberg
   Programmed by Kevin Toppenberg, Eddie Hagood  
   
   Family Physicians of Greeneville, PC
   1410 Tusculum Blvd, Suite 2600
   Greeneville, TN 37745
   kdtop@yahoo.com
                                                 
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
  *)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,
  ORNet, ORFn, ComCtrls, ToolWin, Grids, ORCtrls;

type
  TSetSelForm = class(TForm)
    ComboBox: TComboBox;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    function GetSelValue : string;
  public
    { Public declarations }
    procedure PrepForm(setDef : string; InitialValue : string);
    property SelectedValue : string read GetSelValue;
  end;

//var
//  SetSelForm: TSetSelForm;

implementation
{$R *.dfm}

const
  DEL_ENTRY = '<none/delete>';

  procedure TSetSelForm.PrepForm(setDef : string; InitialValue : string);
  var  oneOption : string;
  begin
    ComboBox.Items.Clear;
    ComboBox.Items.Add(DEL_ENTRY);
    ComboBox.Text := '';
    oneOption := 'x';
    while (setDef <> '') and (oneOption <> '') do begin
      oneOption := piece(setDef,';',1);
      setDef := pieces(setDef,';',2,32);
      oneOption := piece(oneOption,':',2);
      if oneOption <> '' then begin
        ComboBox.Items.Add(oneOption);
      end;
    end;
    if ComboBox.Items.Count > 0 then begin
//      ComboBox.Text := ComboBox.Items[0];
      if ComboBox.Items.IndexOf(InitialValue) > -1 then begin
        ComboBox.SelText := InitialValue;
      end else begin
        ComboBox.SelText := ComboBox.Items[0];
      end;
    end else begin
      ComboBox.Text := '(none defined)';
    end;
  end;

  function TSetSelForm.GetSelValue : string;
  begin
    Result := Self.ComboBox.Text;
    if Result = DEL_ENTRY then begin
      Result := '';
    end;
  end;

  procedure TSetSelForm.FormShow(Sender: TObject);
    var mousePos : TPoint;
  begin
    GetCursorPos(mousePos);
    Top := mousePos.Y - 39;
    Left := mousePos.X - 15;
    if Left + Width > Screen.DesktopWidth then begin
      Left := Screen.DesktopWidth - Width;
    end;
    ComboBox.SetFocus;
  end;

end.

