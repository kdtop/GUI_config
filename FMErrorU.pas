unit FMErrorU;
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
  Dialogs, StdCtrls;

type
  TFMErrorForm = class(TForm)
    Memo: TMemo;
    OKBtn: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PrepMessage;
  end;

var
  FMErrorForm: TFMErrorForm;

implementation

{$R *.dfm}

uses
  ORFn, StrUtils;
  
  procedure TFMErrorForm.PrepMessage;
  var
    s, text : string;
  begin

    if Memo.Lines.Count=1 then begin
      s := Memo.Lines.Strings[0];
      if piece(s,'^',1)='-1' then begin
        Memo.Lines.Strings[0] := MidStr(s, 3,length(s));
      end;
    end else if Memo.Lines.Count>1 then begin
      if piece(Memo.Lines.Strings[0],'^',1)='-1' then begin
        Memo.Lines.Delete(0);
        text := Memo.Lines.Text;
        text := AnsiReplaceStr(text, ' [', #13+'[');
        text := AnsiReplaceStr(text, 'Fileman says:', 'Database error message:'+#13);
        Memo.Lines.Text := text;
      end;
    end;
  end;

end.

