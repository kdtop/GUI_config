unit ORFn;

{$OPTIMIZATION OFF}

interface  // --------------------------------------------------------------------------------

uses SysUtils, Windows, Messages, Classes, Controls, StdCtrls, ExtCtrls, ComCtrls, Forms,
     Graphics, Menus, RichEdit;

const
  U = '^';
  CRLF = #13#10;
  BOOLCHAR: array[Boolean] of Char = ('0', '1');
  UM_STATUSTEXT = (WM_USER + 302);               // used to send update status msg to main form
  COLOR_CREAM   = $F0FBFF;

type
  TFMDateTime = Double;
  TORIdleCallProc = procedure(Msg: string);

{ Date/Time functions }
function DateTimeToFMDateTime(ADateTime: TDateTime): TFMDateTime;
function FMDateTimeToDateTime(ADateTime: TFMDateTime): TDateTime;
function FMDateTimeOffsetBy(ADateTime: TFMDateTime; DaysDiff: Integer): TFMDateTime;
function FormatFMDateTime(AFormat: string; ADateTime: TFMDateTime): string;
function FormatFMDateTimeStr(const AFormat, ADateTime: string): string;
function IsFMDateTime(x: string): Boolean;
function MakeFMDateTime(const AString: string): TFMDateTime;
procedure SetListFMDateTime(AFormat: string; AList: TStringList; ADelim: Char;
                            PieceNum: Integer; KeepBad: boolean = FALSE);

{ Numeric functions }
function HigherOf(i, j: Integer): Integer;
function LowerOf(i, j: Integer): Integer;
function StrToFloatDef(const S: string; ADefault: Extended): Extended;
function RectContains(Rect: TRect; Point: TPoint): boolean; //kt added

{ String functions }
function CharAt(const x: string; APos: Integer): Char;
function ContainsAlpha(const x: string): Boolean;
function ContainsVisibleChar(const x: string): Boolean;
function ConvertSpecialStrings(const x: string): String;
function CRCForFile(AFileName: string): DWORD;
function CRCForStrings(AStringList: TStrings): DWORD;
procedure ExpandTabsFilter(AList: TStrings; ATabWidth: Integer);
function ExtractInteger(x: string): Integer;
function ExtractFloat(x: string): Extended;
function ExtractDefault(Src: TStrings; const Section: string): string;
procedure ExtractItems(Dest, Src: TStrings; const Section: string);
procedure ExtractText(Dest, Src: TStrings; const Section: string);
function FilteredString(const x: string; ATabWidth: Integer = 8): string;
procedure InvertStringList(AList: TStringList);
procedure LimitStringLength(var AList: TStringList; MaxLength: Integer);
function MixedCase(const x: string): string;
procedure MixedCaseList(AList: TStrings);
procedure MixedCaseByPiece(AList: TStrings; ADelim: Char; PieceNum: Integer);
function Piece(const S: string; Delim: char; PieceNum: Integer): string;  overload;     //kt 8/09 added 'overload'
function Piece(const S: string; Delim: string; PieceNum: Integer): string; overload;    //kt 8/09
function PieceNCS(const S: string; Delim: string; PieceNum: Integer): string; overload; //kt 8/09
function Pieces(const S: string; Delim: char; FirstNum, LastNum: Integer): string; overload;     //kt 8/09 added 'overload'
function Pieces(const S: string; Delim: string; PieceStart,PieceEnd: Integer): string; overload; //kt 8/09 added
function PiecesNCS(const S: string; Delim: string; PieceStart,PieceEnd: Integer): string;        //kt 8/09 added
function ComparePieces(P1, P2: string; Pieces: array of integer; Delim:
                       char = '^'; CaseInsensitive: boolean = FALSE): integer;
procedure PiecesToList(x: string; ADelim: Char; AList: TStrings);
function NumPieces(S : string; ADelim : String) : integer; //kt
function ReverseStr(const x: string): string;
procedure SetPiece(var x: string; Delim: Char; PieceNum: Integer; const NewPiece: string);
procedure SetPieces(var x: string; Delim: Char; Pieces: Array of Integer;
                                                FromString: string);
procedure SortByPiece(AList: TStringList; ADelim: Char; PieceNum: Integer);
function DelimCount(const Str, Delim: string): integer;
procedure QuickCopy(AFrom, ATo: TObject);
procedure FastAssign(source, destination: TStrings);
procedure FastAddStrings(source, destination: TStrings);
function ValidFileName(const InitialFileName: string): string;

{ Display functions }
procedure ForceInsideWorkArea( var Rect: TRect);
//procedure ClearControl(AControl: TControl);
function InfoBox(const Text, Caption: string; Flags: Word): Integer;
procedure LimitEditWidth(AControl: TWinControl; NumChars: Integer);
function MainFont: TFont;
function MainFontSize: Integer;
function MainFontWidth: Integer;
function MainFontHeight: Integer;
function BaseFont: TFont;
procedure RedrawSuspend(AHandle: HWnd);
procedure RedrawActivate(AHandle: HWnd);
//procedure ResetControl(AControl: TControl);
procedure ResetSelectedForList(AListBox: TListBox);
procedure ResizeFormToFont(AForm: TForm);
procedure ResizeAnchoredFormToFont( AForm: TForm);
function ResizeWidth( OldFont: TFont; NewFont: TFont; OldWidth: integer): integer;
function ResizeHeight( OldFont: TFont; NewFont: TFont; OldHeight: integer): integer;
procedure ResizeToFont(FontSize: Integer; var W, H: Integer);
procedure SetEqualTabStops(AControl: TControl; TabWidth: Integer = 8);
procedure StatusText(const S: string);
function ShowMsgOn(AnExpression: Boolean; const AMsg, ACaption: string): Boolean;
function TextWidthByFont(AFontHandle: THandle; const x: string): Integer;
function TextHeightByFont(AFontHandle: THandle; const x: string): Integer;
function WrappedTextHeightByFont(Canvas: TCanvas; NewFont: TFont; ItemText: string; var ARect: TRect): integer;
function NumCharsFitInWidth(AFontHandle: THandle; const x: string; const MaxLen: integer): Integer;
function PopupComponent(Sender: TObject; PopupMenu: TPopupMenu): TComponent;
procedure ReformatMemoParagraph(AMemo: TCustomMemo);
function ReadOnlyColor: TColor;

{ ListBox Grid functions }
procedure ListGridDrawCell(AListBox: TListBox; AHeader: THeaderControl; ARow, AColumn: Integer;
  const x: string; WordWrap: Boolean);
procedure ListGridDrawLines(AListBox: TListBox; AHeader: THeaderControl; Index: Integer;
  State: TOwnerDrawState);
function ListGridRowHeight(AListBox: TListBox; AHeader: THeaderControl; ARow, AColumn: Integer;
  const x: string): Integer;

{ Misc functions }
{ You MUST pass an address to an object variable to get KillObj to work }
procedure KillObj(ptr: Pointer; KillObjects: boolean = FALSE);

{ do NOT use CallWhenIdle to call RPCs.  Use CallRPCWhenIdle in ORNet }
procedure CallWhenIdle(CallProc: TORIdleCallProc; Msg: String);
procedure CallWhenIdleNotifyWhenDone(CallProc, DoneProc: TORIdleCallProc; Msg: String);
procedure menuHideAllBut(aMenuItem: tMenuItem; butItems: array of tMenuItem);
function TabIsPressed : Boolean;
function ShiftTabIsPressed : Boolean;

procedure ScrollControl(Window: TScrollingWinControl; ScrollingUp: boolean; Amount: integer = 40);

implementation  // ---------------------------------------------------------------------------

uses
  StrUtils,  //kt 8/09
  ORCtrls, Grids, Chart, CheckLst;

const
  { names of months used by FormatFMDateTime }
  MONTH_NAMES_SHORT: array[1..12] of string[3] =
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
  MONTH_NAMES_LONG:  array[1..12] of string[9] =
    ('January','February','March','April','May','June','July','August','September','October',
     'November', 'December');

     // ConvertSpecialStrings arrays
  SearchChars:  array[0..7] of String = (' Ii ',' Iii ',' Iv ',' Vi ',' Vii ',' Viii ',' Ix ','-Va');
  ReplaceChars: array[0..7] of String = (' II ',' III ',' IV ',' VI ',' VII ',' VIII ',' IX ','-VA');

  { table for calculating CRC values (DWORD is Integer in Delphi 3, Cardinal in Delphi 4}
  CRC32_TABLE: array[0..255] of DWORD =
    ($0,       $77073096, $EE0E612C, $990951BA, $76DC419,  $706AF48F, $E963A535, $9E6495A3,
    $EDB8832,  $79DCB8A4, $E0D5E91E, $97D2D988, $9B64C2B,  $7EB17CBD, $E7B82D07, $90BF1D91,
    $1DB71064, $6AB020F2, $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
    $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
    $2802B89E, $5F058808, $C60CD9B2, $B10BE924, $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
    $76DC4190, $1DB7106,  $98D220BC, $EFD5102A, $71B18589, $6B6B51F,  $9FBFE4A5, $E8B8D433,
    $7807C9A2, $F00F934,  $9609A88E, $E10E9818, $7F6A0DBB, $86D3D2D,  $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
    $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
    $5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
    $EDB88320, $9ABFB3B6, $3B6E20C,  $74B1D29A, $EAD54739, $9DD277AF, $4DB2615,  $73DC1683,
    $E3630B12, $94643B84, $D6D6A3E,  $7A6A5AA8, $E40ECF0B, $9309FF9D, $A00AE27,  $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB, $196C3671, $6E6B06E7,
    $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
    $CB61B38C, $BC66831A, $256FD2A0, $5268E236, $CC0C7795, $BB0B4703, $220216B9, $5505262F,
    $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
    $9B64C2B0, $EC63F226, $756AA39C, $26D930A,  $9C0906A9, $EB0E363F, $72076785, $5005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $CB61B38,  $92D28E9B, $E5D5BE0D, $7CDCEFB7, $BDBDF21,
    $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
    $A00AE278, $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB,
    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729, $23D967BF,
    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

    {Properties assigned to BaseFont}
    BaseFontSize = 8;
    BaseFontName = 'MS Sans Serif';
var
    FBaseFont: TFont;
type
    EFMDateTimeError = class(Exception);

    {TFontControl is an artifact used for font resizing.  Do not add virtual
    methods or class variables to it!}
    TFontControl = class(TControl)
    public
      property Font;
      property ParentFont;
    end;

{ Date/Time functions }

function DateTimeToFMDateTime(ADateTime: TDateTime): TFMDateTime;
{ converts a Delphi date/time type to a Fileman date/time (type double) }
var
  y, m, d, h, n, s, l: Word;
  DatePart,TimePart: Integer;
begin
  DecodeDate(ADateTime, y, m, d);
  DecodeTime(ADateTime, h, n, s, l);
  DatePart := ((y-1700)*10000) + (m*100) + d;
  TimePart := (h*10000) + (n*100) + s;
  Result :=  DatePart + (TimePart / 1000000);
end;

function FMDateTimeToDateTime(ADateTime: TFMDateTime): TDateTime;
{ converts a Fileman date/time (type double) to a Delphi date/time }
var
  ADate, ATime: TDateTime;
  DatePart, TimePart: string;
begin
  DatePart := Piece(FloatToStrF(ADateTime, ffFixed, 14, 6), '.', 1);
  TimePart := Piece(FloatToStrF(ADateTime, ffFixed, 14, 6), '.', 2) + '000000';
  if Length(DatePart) <> 7 then raise EFMDateTimeError.Create('Invalid Fileman Date');
  if Copy(TimePart, 1, 2) = '24' then TimePart := '23595959';
  ADate := EncodeDate(StrToInt(Copy(DatePart, 1, 3)) + 1700,
                      StrToInt(Copy(DatePart, 4, 2)),
                      StrToInt(Copy(DatePart, 6, 2)));
  ATime := EncodeTime(StrToInt(Copy(TimePart, 1, 2)),
                      StrToInt(Copy(TimePart, 3, 2)),
                      StrToInt(Copy(TimePart, 5, 2)), 0);
  Result := ADate + ATime;
end;

function FMDateTimeOffsetBy(ADateTime: TFMDateTime; DaysDiff: Integer): TFMDateTime;
{ adds / subtracts days from a Fileman date/time and returns the offset Fileman date/time }
var
  Julian: TDateTime;
begin
  Julian := FMDateTimeToDateTime(ADateTime);
  Result := DateTimeToFMDateTime(Julian + DaysDiff);
end;

function FormatFMDateTime(AFormat: string; ADateTime: TFMDateTime): string;
{ formats a Fileman Date/Time using (mostly) the same format string as Delphi FormatDateTime }
var
  x: string;
  y, m, d, h, n, s: Integer;

  function TrimFormatCount: Integer;
  { delete repeating characters and count how many were deleted }
  var
    c: Char;
  begin
    Result := 0;
    c := AFormat[1];
    repeat
      Delete(AFormat, 1, 1);
      Inc(Result);
    until CharAt(AFormat, 1) <> c;
  end;

begin {FormatFMDateTime}
  Result := '';
  if not (ADateTime > 0) then Exit;
  x := FloatToStrF(ADateTime, ffFixed, 15, 6) + '0000000';
  y := StrToIntDef(Copy(x,  1, 3), 0) + 1700;
  m := StrToIntDef(Copy(x,  4, 2), 0);
  d := StrToIntDef(Copy(x,  6, 2), 0);
  h := StrToIntDef(Copy(x,  9, 2), 0);
  n := StrToIntDef(Copy(x, 11, 2), 0);
  s := StrToIntDef(Copy(x, 13, 2), 0);
  while Length(AFormat) > 0 do
    case UpCase(AFormat[1]) of
    '"': begin                                                                 // literal
           Delete(AFormat, 1, 1);
           while not (CharAt(AFormat, 1) in [#0, '"']) do
           begin
             Result := Result + AFormat[1];
             Delete(AFormat, 1, 1);
           end;
           if CharAt(AFormat, 1) = '"' then Delete(AFormat, 1, 1);
         end;
    'D': case TrimFormatCount of                                               // day/date
         1: if d > 0 then Result := Result + IntToStr(d);
         2: if d > 0 then Result := Result + FormatFloat('00', d);
         end;
    'H': case TrimFormatCount of                                               // hour
         1: Result := Result + IntToStr(h);
         2: Result := Result + FormatFloat('00', h);
         end;
    'M': case TrimFormatCount of                                               // month
         1: if m > 0 then Result := Result + IntToStr(m);
         2: if m > 0 then Result := Result + FormatFloat('00', m);
         3: if m in [1..12] then Result := Result + MONTH_NAMES_SHORT[m];
         4: if m in [1..12] then Result := Result + MONTH_NAMES_LONG[m];
         end;
    'N': case TrimFormatCount of                                               // minute
         1: Result := Result + IntToStr(n);
         2: Result := Result + FormatFloat('00', n);
         end;
    'S': case TrimFormatCount of                                               // second
         1: Result := Result + IntToStr(s);
         2: Result := Result + FormatFloat('00', s);
         end;
    'Y': case TrimFormatCount of                                               // year
         2: if y > 0 then Result := Result + Copy(IntToStr(y), 3, 2);
         4: if y > 0 then Result := Result + IntToStr(y);
         end;
    else begin                                                                 // other
           Result := Result + AFormat[1];
           Delete(AFormat, 1, 1);
         end;
    end; {case}
end; {FormatFMDateTime}

function FormatFMDateTimeStr(const AFormat, ADateTime: string): string;
var
  FMDateTime: TFMDateTime;
begin
  Result := ADateTime;
  if IsFMDateTime(ADateTime) then
  begin
    FMDateTime := MakeFMDateTime(ADateTime);
    Result := FormatFMDateTime(AFormat, FMDateTime);
  end;
end;

function IsFMDateTime(x: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Length(x) < 7 then Exit;
  for i := 1 to 7 do if not (x[i] in ['0'..'9']) then Exit;
  if (Length(x) > 7) and (x[8] <> '.') then Exit;
  if (Length(x) > 8) and not (x[9] in ['0'..'9']) then Exit;
  Result := True;
end;

function MakeFMDateTime(const AString: string): TFMDateTime;
begin
  Result := -1;
  if (Length(AString) > 0) and IsFMDateTime(AString) then Result := StrToFloat(AString);
end;

procedure SetListFMDateTime(AFormat: string; AList: TStringList; ADelim: Char;
                            PieceNum: Integer; KeepBad: boolean = FALSE);
var
  i: Integer;
  s, x, x1: string;
  
begin
  for i := 0 to AList.Count - 1 do
  begin
    s := AList[i];
    x := Piece(s, ADelim, PieceNum);
    if Length(x) > 0 then
    begin
      x1 := FormatFMDateTime(AFormat, MakeFMDateTime(x));
      if(x1 <> '') or (not KeepBad) then
        x := x1; 
    end;
    SetPiece(s, ADelim, PieceNum, x);
    AList[i] := s;
  end;
end;

{ Numeric functions }

function HigherOf(i, j: Integer): Integer;
{ returns the greater of two integers }
begin
  Result := i;
  if j > i then Result := j;
end;

function LowerOf(i, j: Integer): Integer;
{ returns the lesser of two integers }
begin
  Result := i;
  if j < i then Result := j;
end;

function StrToFloatDef(const S: string; ADefault: Extended): Extended;
begin
  if not TextToFloat(PChar(S), Result, fvExtended) then
    Result := ADefault;
end;

{ String functions }

function CharAt(const x: string; APos: Integer): Char;
{ returns a character at a given position in a string or the null character if past the end }
begin
  if Length(x) < APos then Result := #0 else Result := x[APos];
end;

function ContainsAlpha(const x: string): Boolean;
{ returns true if the string contains any alpha characters }
var
  i: Integer;
begin
  Result := False;
  for i := 1 to Length(x) do if x[i] in ['A'..'Z','a'..'z'] then
  begin
    Result := True;
    break;
  end;
end;

function ContainsVisibleChar(const x: string): Boolean;
{ returns true if the string contains any printable characters }
var
  i: Integer;
begin
  Result := False;
  for i := 1 to Length(x) do if x[i] in ['!'..'~'] then  // ordinal values 33..126
  begin
    Result := True;
    break;
  end;
end;

function ConvertSpecialStrings(const x: string): string;
var i : Integer;
begin
   for i := 0 to Length(SearchChars)-1 do
    begin
       Result := StringReplace(Result,SearchChars[i], ReplaceChars[i],[rfReplaceAll]);
    end;
end;

function UpdateCrc32(Value: DWORD; var Buffer: array of Byte; Count: Integer): DWORD;
var
 i: integer;
begin
 Result:=Value;
 for i := 0 to Pred(Count) do
   Result := ((Result shr 8) and $00FFFFFF) xor
     CRC32_TABLE[(Result xor Buffer[i]) and $000000FF];
end;

function CRCForFile(AFileName: string): DWORD;
const
 BUF_SIZE = 16383;
type
 TBuffer = array[0..BUF_SIZE] of Byte;
var
 Buffer: Pointer;
 AHandle, BytesRead: Integer;
begin
 Result:=$FFFFFFFF;
 GetMem(Buffer, BUF_SIZE);
 AHandle := FileOpen(AFileName, fmShareDenyWrite);
 repeat
  BytesRead := FileRead(AHandle, Buffer^, BUF_SIZE);
  Result := UpdateCrc32(Result, TBuffer(Buffer^), BytesRead);
 until BytesRead <> BUF_SIZE;
 FileClose(AHandle);
 FreeMem(Buffer);
 Result := not Result;
end;

function CRCForStrings(AStringList: TStrings): DWORD;
{ returns a cyclic redundancy check for a list of strings }
var
  i, j: Integer;
begin
  Result:=$FFFFFFFF;
  for i := 0 to AStringList.Count - 1 do
    for j := 1 to Length(AStringList[i]) do
      Result:=((Result shr 8) and $00FFFFFF) xor
        CRC32_TABLE[(Result xor Ord(AStringList[i][j])) and $000000FF];
end;

function FilteredString(const x: string; ATabWidth: Integer = 8): string;
var
  i, j: Integer;
begin
  Result := '';
  for i := 1 to Length(x) do
    case x[i] of
            #9: for j := 1 to (ATabWidth - (Length(Result) mod ATabWidth)) do
                  Result := Result + ' ';
     #32..#127: Result := Result + x[i];
    #128..#159: Result := Result + '?';
  #10,#13,#160: Result := Result + ' ';
    #161..#255: Result := Result + x[i];
    end;
  if Copy(Result, Length(Result), 1) = ' ' then Result := TrimRight(Result) + ' ';
end;

procedure ExpandTabsFilter(AList: TStrings; ATabWidth: Integer);
var
  i, j, k: Integer;
  x, y: string;
begin
  with AList do for i := 0 to Count - 1 do
  begin
    x := Strings[i];
    y := '';
    for j := 1 to Length(x) do
      case x[j] of
                #9: for k := 1 to (ATabWidth - (Length(y) mod ATabWidth)) do y := y + ' ';
         #32..#127: y := y + x[j];
        #128..#159: y := y + '?';
              #160: y := y + ' ';
        #161..#255: y := y + x[j];
      end;
    if Copy(y, Length(y), 1) = ' ' then y := TrimRight(y) + ' ';
    Strings[i] := y;
    //Strings[i] := TrimRight(y) + ' ';
  end;
end;

function ExtractInteger(x: string): Integer;
{ strips leading & trailing alphas to return an integer }
var
  i: Integer;
begin
  while (Length(x) > 0) and not (x[1] in ['0'..'9']) do Delete(x, 1, 1);
  for i := 1 to Length(x) do if not (x[i] in ['0'..'9']) then break;
  Result := StrToIntDef(Copy(x, 1, i - 1), 0);
end;

function ExtractFloat(x: string): Extended;
{ strips leading & trailing alphas to return a float }
var
  i: Integer;
begin
  while (Length(x) > 0) and not (x[1] in ['0'..'9', '.']) do Delete(x, 1, 1);
  for i := 1 to Length(x) do if not (x[i] in ['0'..'9','.']) then break;
  Result := StrToFloatDef(Copy(x, 1, i - 1), 0);
end;

function ExtractDefault(Src: TStrings; const Section: string): string;
var
  i: Integer;
begin
  Result := '';
  i := -1;
  repeat Inc(i) until (i = Src.Count) or (Src[i] = '~' + Section);
  Inc(i);
  if (i < Src.Count) and (Src[i][1] <> '~') then repeat
    if Src[i][1] = 'd' then Result := Copy(Src[i], 2, MaxInt);
    Inc(i);
  until (i = Src.Count) or (Src[i][1] = '~') or (Length(Result) > 0);
end;

procedure ExtractItems(Dest, Src: TStrings; const Section: string);
var
  i: Integer;
begin
  i := -1;
  repeat Inc(i) until (i = Src.Count) or (Src[i] = '~' + Section);
  Inc(i);
  if (i < Src.Count) and (Src[i][1] <> '~') then repeat
    if Src[i][1] = 'i' then Dest.Add(Copy(Src[i], 2, MaxInt));
    Inc(i);
  until (i = Src.Count) or (Src[i][1] = '~');
end;

procedure ExtractText(Dest, Src: TStrings; const Section: string);
var
  i: Integer;
begin
  i := -1;
  repeat Inc(i) until (i = Src.Count) or (Src[i] = '~' + Section);
  Inc(i);
  if (i < Src.Count) and (Src[i][1] <> '~') then repeat
    if Src[i][1] = 't' then Dest.Add(Copy(Src[i], 2, MaxInt));
    Inc(i);
  until (i = Src.Count) or (Src[i][1] = '~');
end;

procedure InvertStringList(AList: TStringList);
var
  i: Integer;
begin
  with AList do for i := 0 to ((Count div 2) - 1) do Exchange(i, Count - i - 1);
end;

function MixedCase(const x: string): string;
var
  i: integer;
begin
  Result := x;
  for i := 2 to Length(x) do
     if (not (x[i-1] in [' ',',','-','.','/','^'])) and (x[i] in ['A'..'Z'])
 // save line    if (not (x[i-1] in [' ','''',',','-','.','/','^'])) and (x[i] in ['A'..'Z'])
      then Result[i] := Chr(Ord(x[i]) + 32)
     else if ((x[i-1] in [' ',',','-','.','/','^'])) and (x[i] in ['a'..'z'])
      then Result[i] := Chr(Ord(x[i]) - 32);
  //Call added to satisfy the need for special string handling(Roman Numerals II-XI) GRE-06/02
  Result := ConvertSpecialStrings(x);
end;

procedure MixedCaseList(AList: TStrings);
var
  i: integer;
begin
  for i := 0 to (AList.Count - 1) do AList[i] := MixedCase(AList[i]);
end;

procedure MixedCaseByPiece(AList: TStrings; ADelim: Char; PieceNum: Integer);
var
  i: Integer;
  x, p: string;
begin
  for i := 0 to (AList.Count - 1) do
  begin
    x := AList[i];
    p := MixedCase(Piece(x, ADelim, PieceNum));
    SetPiece(x, ADelim, PieceNum, p);
    AList[i] := x;
  end;
end;

function Piece(const S: string; Delim: char; PieceNum: Integer): string; overload; //kt 8/09 added 'overload;'
{ returns the Nth piece (PieceNum) of a string delimited by Delim }
var
  i: Integer;
  Strt, Next: PChar;
begin
  i := 1;
  Strt := PChar(S);
  Next := StrScan(Strt, Delim);
  while (i < PieceNum) and (Next <> nil) do
  begin
    Inc(i);
    Strt := Next + 1;
    Next := StrScan(Strt, Delim);
  end;
  if Next = nil then Next := StrEnd(Strt);
  if i < PieceNum then Result := '' else SetString(Result, Strt, Next - Strt);
end;

function PieceNCS(const S: string; Delim: string; PieceNum: Integer): string; overload;
//kt 8/09  Name means Piece-Not-Case-Sensitive, meaning match for Delim is not case sensitive.
//kt 8/09 Added entire function
var tempS : string;
begin
  tempS := AnsiReplaceText(S,Delim,UpperCase(Delim));
  Result := Piece(tempS,UpperCase(Delim),PieceNum);
end;

function Piece(const S: string; Delim: string; PieceNum: Integer): string; overload;
//kt 8/09 Added entire function
var Remainder : String;
    PieceLen,p : integer;
begin
  Remainder := S;
  Result := '';
  PieceLen := Length(Delim);
  while (PieceNum > 0) and (Length(Remainder) > 0) do begin
    p := Pos(Delim,Remainder);
    if p=0 then p := length(Remainder)+1;
    if PieceNum = 1 then Result := MidStr(Remainder,1,p-1);
    Remainder := MidStr(Remainder,p+PieceLen,9999);
    Dec(PieceNum);
  end;
end;

function Pieces(const S: string; Delim: string; PieceStart,PieceEnd: Integer): string; overload;
//kt 8/09 Added entire function
var Remainder : String;
    PieceNum : integer;
    PieceLen,p : integer;
begin
  Remainder := S;
  Result := '';
  PieceLen := Length(Delim);
  PieceNum := PieceStart;
  while (PieceNum > 1) and (Length(Remainder) > 0) do begin
    p := Pos(Delim,Remainder);
    if p=0 then p := length(Remainder)+1;
    Result := MidStr(Remainder,1,p-1);
    Remainder := MidStr(Remainder,p+PieceLen,9999);
    Dec(PieceNum);
  end;
  PieceNum := PieceEnd-PieceStart+1;
  Result := '';
  while (PieceNum > 0) and (Length(Remainder) > 0) do begin
    p := Pos(Delim,Remainder);
    if p=0 then p := length(Remainder)+1;
    if Result <> '' then Result := Result + Delim;
    Result := Result + MidStr(Remainder,1,p-1);
    Remainder := MidStr(Remainder,p+PieceLen,9999);
    Dec(PieceNum);
  end;
end;

function Pieces(const S: string; Delim: char; FirstNum, LastNum: Integer): string;
{ returns several contiguous pieces }
var
  PieceNum: Integer;
begin
  Result := '';
  for PieceNum := FirstNum to LastNum do Result := Result + Piece(S, Delim, PieceNum) + Delim;
  if Length(Result) > 0 then Delete(Result, Length(Result), 1);
end;

function PiecesNCS(const S: string; Delim: string; PieceStart,PieceEnd: Integer): string;
//kt 8/09  Name means Pieces-Not-Case-Sensitive, meaning match for Delim is not case sensitive.
//kt 8/09 Added entire function
var tempS : string;
begin
  tempS := AnsiReplaceText(S,Delim,UpperCase(Delim));
  Result := Pieces(tempS,UpperCase(Delim),PieceStart,PieceEnd);
end;

function ComparePieces(P1, P2: string; Pieces: array of integer; Delim:
                       char = '^'; CaseInsensitive: boolean = FALSE): integer;
var
  i: integer;

begin
  i := 0;
  Result := 0;
  while i <= high(Pieces) do
  begin
    if(CaseInsensitive) then
      Result := CompareText(Piece(P1, Delim, Pieces[i]),
                            Piece(P2, Delim, Pieces[i]))
    else
      Result := CompareStr(Piece(P1, Delim, Pieces[i]),
                           Piece(P2, Delim, Pieces[i]));
    if(Result = 0) then
      inc(i)
    else
      break;
  end;
end;

procedure PiecesToList(x: string; ADelim: Char; AList: TStrings);
{ adds each piece to a TStrings list, the list is cleared first }
var
  APiece: string;
begin
  AList.Clear;
  while Length(x) > 0 do
  begin
    APiece := Piece(x, ADelim, 1);
    AList.Add(APiece);
    Delete(x, 1, Length(APiece) + 1);
  end;
end;

function NumPieces(S : string; ADelim : String) : integer; //kt
//  A^B  -->  2 pieces  (mumps --> 2)
//  A^   -->  2 pieces  (mumps --> 2)
//  A    -->  1 pieces  (mumps --> 1)
var  P, Count : integer;
begin
  P := 1;
  Count := 0;
  repeat
    P := PosEx(ADelim,S,P);
    if P > 0 then begin
      inc(Count);
      inc(P);
    end;
  until (P=0);
  Result := Count + 1;
end;


function ReverseStr(const x: string): string;
var
  i, j: Integer;
begin
  SetString(Result, PChar(x), Length(x));
  i := 0;
  for j := Length(x) downto 1 do
  begin
    Inc(i);
    Result[i] := x[j];
  end;
end;

procedure SetPiece(var x: string; Delim: Char; PieceNum: Integer; const NewPiece: string);
{ sets the Nth piece (PieceNum) of a string to NewPiece, adding delimiters as necessary }
var
  i: Integer;
  Strt, Next: PChar;
begin
  i := 1;
  Strt := PChar(x);
  Next := StrScan(Strt, Delim);
  while (i < PieceNum) and (Next <> nil) do
  begin
    Inc(i);
    Strt := Next + 1;
    Next := StrScan(Strt, Delim);
  end;
  if Next = nil then Next := StrEnd(Strt);
  if i < PieceNum
    then x := x + StringOfChar(Delim, PieceNum - i) + NewPiece
    else x := Copy(x, 1, Strt - PChar(x)) + NewPiece + StrPas(Next);
end;

procedure SetPieces(var x: string; Delim: Char; Pieces: Array of Integer;
                                                FromString: string);
var
  i: integer;

begin
  for i := low(Pieces) to high(Pieces) do
    SetPiece(x, Delim, Pieces[i], Piece(FromString, Delim, Pieces[i]));
end;

procedure SortByPiece(AList: TStringList; ADelim: Char; PieceNum: Integer);
var
  i: integer;
begin
  for i := 0 to AList.Count - 1 do
    AList[i] := Piece(AList[i], ADelim, PieceNum) + ADelim + AList[i];
  AList.Sort;
  for i := 0 to AList.Count - 1 do
    AList[i] := Copy(AList[i], Pos(ADelim, AList[i]) + 1, MaxInt);
end;

function DelimCount(const Str, Delim: string): integer;
var
  i, dlen, slen: integer;

begin
  Result := 0;
  i := 1;
  dlen := length(Delim);
  slen := length(Str) - dlen + 1;
  while(i <= slen) do
  begin
    if(copy(Str,i,dlen) = Delim) then
    begin
      inc(Result);
      inc(i,dlen);
    end
    else
      inc(i);
  end;
end;

type
  TREStrings = class(TStrings)
  protected
    FPlainText: Boolean;
  public
    property PlainText: Boolean read FPlainText write FPlainText;
  end;

type
  QuickCopyError = class(Exception);

procedure QuickCopy(AFrom, ATo: TObject);
var
  ms: TMemoryStream;
  idx: integer;
  str: array[0..1] of TStrings;
  fix: array[0..1] of boolean;

  procedure GetStrings(obj: TObject);
  begin
    if (CompareText(obj.ClassName, 'TRichEditStrings') = 0) then
      raise QuickCopyError.Create('You must pass the TRichEdit object into QuickCopy, NOT it''s Lines property.');
    if obj is TStrings then
      str[idx] := TStrings(obj)
    else
    if obj is TMemo then
      str[idx] := TMemo(obj).Lines
    else
    if obj is TORListBox then
      str[idx] := TORListBox(obj).Items
    else
    if obj is TListBox then
      str[idx] := TListBox(obj).Items
    else
    if obj is TRichEdit then
    begin
      with TRichEdit(obj) do
      begin
        str[idx] := Lines;
        if not PlainText then
        begin
          fix[idx] := TRUE;
          PlainText := TRUE;
        end;
      end;
    end
    else
      raise QuickCopyError.Create('Unsupported object type (' + obj.ClassName +
                                  ') passed into QuickCopy.');
    inc(idx);
  end;


begin
  fix[0] := FALSE;
  fix[1] := FALSE;
  idx := 0;
  GetStrings(AFrom);
  GetStrings(ATo);
  ms := TMemoryStream.Create;
  try
    str[0].SaveToStream(ms);
    ms.Seek(0, soFromBeginning);
    str[1].LoadFromStream(ms);
  finally
    ms.Free;
  end;
  if fix[0] then TRichEdit(AFrom).PlainText := FALSE;
  if fix[1] then TRichEdit(ATo).PlainText := FALSE;
end;

function ValidFileName(const InitialFileName: string): string;
var
  i: integer;

begin
  Result := InitialFileName;
  i := 1;
  while i <= length(Result) do
  begin
    if Result[i] in ['a'..'z','A'..'Z','0'..'9',#32] then
      inc(i)
    else
      delete(Result,i,1);
  end;
end;

procedure LimitStringLength(var AList: TStringList; MaxLength: Integer);
var
  i, SpacePos: Integer;
  x: string;
  NewList: TStringList;
begin
  NewList := TStringList.Create;
  try
    for i := 0 to AList.Count - 1 do
    begin
      if Length(AList[i]) > MaxLength then
      begin
        x := AList[i];
        while Length(x) > MaxLength do
        begin
          SpacePos := MaxLength;
//          while SpacePos > 0 do                                              {**REV**}  removed after v11b
//            if (x[SpacePos] <> ' ') then Dec(SpacePos);                      {**REV**}  removed after v11b
          while (x[SpacePos] <> ' ') and (SpacePos > 1) do Dec(SpacePos);      {**REV**}  {changed 0 to 1}
          if SpacePos = 1 then SpacePos := MaxLength;                          {**REV**}  {changed 0 to 1}
          NewList.Add(Copy(x, 1, SpacePos ));  // CQ     PSI-05-040 change SpacePos-1 to SpacePos
          Delete(x, 1, SpacePos);
        end; {while Length(x)}
        if Length(x) > 0 then NewList.Add(x);
      end {then}
      else NewList.Add(AList[i]);
    end; {for i}
    AList.Clear;
    AList.Assign(NewList);
  finally
    NewList.Free;
  end;
end;

{ Display functions }

(*
procedure ClearControl(AControl: TControl);
{ clears a control, removes text and listbox items }
begin
  if AControl is TLabel then with TLabel(AControl) do Caption := ''
  else if AControl is TButton then with TButton(AControl) do Caption := ''
  else if AControl is TEdit then with TEdit(AControl) do Text := ''
  else if AControl is TMemo then with TMemo(AControl) do Clear
  else if AControl is TListBox then with TListBox(AControl) do Clear
  else if AControl is TORComboBox then with TORComboBox(AControl) do
  begin
    MItems.Clear;
    Text := '';
  end
  else if AControl is TComboBox then with TComboBox(AControl) do
  begin
    Clear;
    Text := '';
  end;
end;

procedure ResetControl(AControl: TControl);
{ clears text, deselects items, does not remove listbox or combobox items }
begin
  if AControl is TLabel then with TLabel(AControl) do Caption := ''
  else if AControl is TButton then with TButton(AControl) do Caption := ''
  else if AControl is TEdit then with TEdit(AControl) do Text := ''
  else if AControl is TMemo then with TMemo(AControl) do Clear
  else if AControl is TListBox then with TListBox(AControl) do ItemIndex := -1
  else if AControl is TORComboBox then with TORComboBox(AControl) do
  begin
    Text := '';
    ItemIndex := -1;
  end
  else if AControl is TComboBox then with TComboBox(AControl) do
  begin
    Text := '';
    ItemIndex := -1;
  end;
end;
*)

function InfoBox(const Text, Caption: string; Flags: Word): Integer;
{ wrap the messagebox object in case we want to modify it later }
begin
  Result := Application.MessageBox(PChar(Text), PChar(Caption), Flags or MB_TOPMOST);
end;

procedure LimitEditWidth(AControl: TWinControl; NumChars: Integer);
{ limits the editing area to be no more than N characters (also sets small left margin) }
const
  LEFT_MARGIN = 4;
var
  ARect: TRect;
  AHandle: DWORD;
  AWidth, i: Integer;
  x: string;
begin
  Inc(NumChars);
  SetString(x, nil, NumChars);
  for i := 1 to NumChars do x[i] := 'X';
  with AControl do
  begin
    AHandle := 0;
    if AControl is TEdit     then AHandle := TEdit(AControl).Font.Handle;
    if AControl is TMemo     then AHandle := TMemo(AControl).Font.Handle;
    if AControl is TRichEdit then AHandle := TRichEdit(AControl).Font.Handle;
    if AHandle = 0 then Exit;
    AWidth := TextWidthByFont(AHandle, x);
    ARect := Rect(LEFT_MARGIN, 0, AWidth + LEFT_MARGIN, ClientHeight);
    // set the editing rectangle to with with of NumChars
    SendMessage(Handle, EM_SETRECT, 0, Longint(@ARect));
    // turn on auto-scrolling for a rich edit
    if AControl is TRichEdit
      then SendMessage(Handle, EM_SETOPTIONS, ECOOP_OR, ECO_AUTOHSCROLL + ECO_AUTOVSCROLL);
  end;
end;

function BaseFont: TFont;
begin
  result := FBaseFont;
end;

function MainFont: TFont;
begin
  if Application.MainForm <> nil
    then Result := Application.MainForm.Font
    else Result := BaseFont;
end;

function MainFontSize: Integer;
{ return font size of the Main Form in the application }
begin
  Result := MainFont.Size;
end;

function FontWidthSubPixel( Font: TFont): real;
{ return in pixels the average character width of the font passed in FontHandle }
var
  TotalWidth: integer;
begin
  TotalWidth := TextWidthByFont( Font.Handle,
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
  result := TotalWidth / 52;
end;

function FontWidthPixel( Font: TFont): integer;
begin
  //Round() is too fancy to be correct here
  result := Trunc(FontWidthSubPixel(Font) + 0.5);
end;

function MainFontWidth: Integer;
begin
    Result := FontWidthPixel(MainFont);
end;

function MainFontHeight: Integer;
{ return font size of the Main Form in the application.
Note that TFont.Height is negative of what we want (see Delphi documentation)}
begin
  Result := Abs(MainFont.Height);
end;

procedure RedrawSuspend(AHandle: HWnd);
begin
  SendMessage(AHandle, WM_SETREDRAW, 0, 0);
end;

procedure RedrawActivate(AHandle: HWnd);
begin
  SendMessage(AHandle, WM_SETREDRAW, 1, 0);
  InvalidateRect(AHandle, nil, True);
end;

procedure ResetSelectedForList(AListBox: TListBox);
var
  i: Integer;
begin
  with AListBox do for i := 0 to Items.Count - 1 do Selected[i] := False;
end;

function ResizeWidth( OldFont: TFont; NewFont: TFont; OldWidth: integer): integer;
begin
  result := Trunc( OldWidth *FontWidthSubPixel(NewFont) / FontWidthSubPixel(OldFont)
    +0.5);
end;

function ResizeHeight( OldFont: TFont; NewFont: TFont; OldHeight: integer): integer;
begin
  result := Trunc( OldHeight *Abs(NewFont.Height) / Abs(OldFont.Height)
    +0.5);
end;

procedure ResizeToFont(FontSize: Integer; var W, H: Integer);
{ resizes form relative to the font size, assumes form designed with
DefaultFont (>MS Sans Serif 8pt<) }
var
  Font: TFont;
begin
  Font := TFont.Create;
  Font.Name := BaseFontName;
  Font.Size := FontSize;
  W := ResizeWidth( BaseFont, Font, W);
  H := ResizeHeight( BaseFont, Font, H);
end;

procedure ResizeHeaderControl( OldFont: TFont; NewFont: TFont; Control: THeaderControl);
{Tested against fOrders page.}
var
  i: integer;
begin
  for i := 0 to Control.Sections.Count-1 do
    Control.Sections[i].Width := ResizeWidth( OldFont, NewFont, Control.Sections[i].Width);
end;

procedure ResizeListView( OldFont: TFont; NewFont: TFont; Control: TListView);
var
  i: integer;
begin
  if not Assigned(Control.OnResize) then
    for i := 0 to Control.Columns.Count-1 do
      Control.Columns[i].Width := ResizeWidth( OldFont, NewFont, Control.Columns[i].Width);
end;

procedure ResizeComboBox( OldFont: TFont; NewFont: TFont; Control: TComboBox);
begin
  Control.ItemHeight := ResizeHeight( OldFont, NewFont, Control.ItemHeight);
end;

procedure ResizeListBox( OldFont: TFont; NewFont: TFont; Control: TListBox);
begin
  Control.ItemHeight := ResizeHeight( OldFont, NewFont, Control.ItemHeight);
end;

procedure ResizeCheckListBox( OldFont: TFont; NewFont: TFont; Control: TCheckListBox);
begin
  Control.ItemHeight := ResizeHeight( OldFont, NewFont, Control.ItemHeight);
end;

procedure ResizeDescendants( OldFont: TFont; NewFont: TFont; AControl: TWinControl);
var
  i: integer;
  Child: TControl;
  VisibleWidth, TotalWidth: integer;
  VisibleHeight, TotalHeight: integer;
begin
  if AControl.Align <> alNone then
    Application.ProcessMessages;
  AControl.DisableAlign;
  try
    //I think I finally got this next part right, so I will try to explain what
    //it is doing.
    //At this stage, the control is resized, but all of the childern are in
    //original size.
    //These children are corretly aligned to the visible part of the control,
    //but may not be correctly aligned in the underlying canvas if there are
    //scroll bars.
    //We wish to transform the children to have the correct new size and be
    //aligned to the new underlying canvas size.

    //For the widths, I have kept track of what parts of the screen we are
    //resizing.  The height will work the same way.
    //The notation is A[B]C, where A is the space to the left of the child
    //control, B is the space containing the child control, and C is the space
    //to the right.
    VisibleWidth := AControl.Width;
    VisibleHeight := AControl.Height;
    TotalWidth := VisibleWidth;
    TotalHeight := VisibleHeight;
    if AControl is TScrollingWinControl then
    begin
      TotalWidth := HigherOf(TotalWidth, TScrollingWinControl(AControl).HorzScrollBar.Range);
      TotalHeight := HigherOf(TotalHeight, TScrollingWinControl(AControl).VertScrollBar.Range);
    end;
    for i := 0 to AControl.ControlCount -1 do begin
      Child := AControl.Controls[i];
      //Tab sheets auto-size with their parents
      if not (Child is TTabSheet) then
        with Child do begin
          if [akLeft,akRight] <= Anchors then                 //X[.]X
            Width := TotalWidth - ResizeWidth( OldFont, NewFont, VisibleWidth - Width)
          else                                                //.[X].
            Width := ResizeWidth( OldFont, NewFont, Width);
          if not(akLeft in Anchors) then                      //.[X]X
            Left := TotalWidth - ResizeWidth( OldFont, NewFont, VisibleWidth - Left)
          else
            Left := ResizeWidth( OldFont, NewFont, Left);     //X[.].
          if [akTop,akBottom] <= Anchors then
            Height := TotalHeight - ResizeHeight( OldFont, NewFont, VisibleHeight - Height)
          else
            Height := ResizeHeight( OldFont, NewFont, Height);
          if not(akTop in Anchors) then
            Top := TotalHeight - ResizeHeight( OldFont, NewFont, VisibleHeight - Top)
          else
            Top := ResizeHeight( OldFont, NewFont, Top);
        end;
      //Recurse.  Let Auto-Size panels take care of themselves
      if (Child is TWinControl) and not (Child is TORAutoPanel) then
        ResizeDescendants( OldFont, NewFont, TWinControl(Child));
      if Child is TComboBox then
        ResizeComboBox( OldFont, NewFont, TComboBox(Child));
      if Child is TCheckListBox then
        ResizeCheckListBox( OldFont, NewFont, TCheckListBox(Child));
      if Child is THeaderControl then
        ResizeHeaderControl( OldFont, NewFont, THeaderControl(Child));
      if Child is TListBox then
        ResizeListBox( OldFont, NewFont, TListBox(Child));
      if Child is TListView then
        ResizeListView( OldFont, NewFont, TListView(Child));
      if Child is TDrawGrid then with TDrawGrid(Child) do
        //from Win32 "How to Calculate the Height of Edit Control..."
        DefaultRowHeight := Abs(NewFont.Height) * 3 div 2;
      if Child is TTabControl then with TTabControl(Child) do begin
        if Tabs.Count > 0 then
          TabWidth := ResizeWidth( OldFont, NewFont, TabWidth);
        Width := TabWidth * Tabs.Count +3;
      end;
    end;
  finally
    AControl.EnableAlign;
  end;
end;

procedure ResizeChartFonts( OldFont: TFont; NewFont: TFont; Control: TChart);
var
  i: integer;
begin
  with Control do begin
    if LeftAxis.Title.Font.Size = OldFont.Size then
      LeftAxis.Title.Font.Size := NewFont.Size;
    if LeftAxis.LabelsFont.Size = OldFont.Size then
      LeftAxis.LabelsFont.Size := NewFont.Size;
    if BottomAxis.Title.Font.Size = OldFont.Size then
      BottomAxis.Title.Font.Size := NewFont.Size;
    if BottomAxis.LabelsFont.Size = OldFont.Size then
      BottomAxis.LabelsFont.Size := NewFont.Size;
    if Legend.Font.Size = OldFont.Size then
      Legend.Font.Size := NewFont.Size;
    if Title.Font.Size = OldFont.Size then
      Title.Font.Size := NewFont.Size;
    for i := 0 to SeriesCount - 1 do
      if Series[i].Marks.Font.Size = OldFont.Size then
        Series[i].Marks.Font.Size := NewFont.Size;
  end;
end;

procedure ResizeFontsInDescendants( OldFont: TFont; NewFont: TFont; AControl: TWinControl);
var
  i: integer;
  Child: TControl;
  RESelectionStart: integer;
  RESelectionLength: integer;
begin
  for i := 0 to AControl.ControlCount -1 do begin
    Child := AControl.Controls[i];
    if Child is TRichEdit then begin
      with TRichEdit(Child) do
        if Font.Size = OldFont.Size then begin
          if not ParentFont then
            Font.Size := NewFont.Size;
          RESelectionStart := SelStart;
          RESelectionLength := SelLength;
          SelectAll;
          SelAttributes.Size := NewFont.Size;
          DefAttributes.Size := NewFont.Size;
          SelStart := RESelectionStart;
          SelLength := RESelectionLength;
        end
    end
    else
    if Child is TChart then
      ResizeChartFonts( OldFont, NewFont, TChart(Child))
    else
      with TFontControl(Child) do
        if (Font.Size = OldFont.Size) and not ParentFont then
          Font.Size := NewFont.Size;

    if  Child is TWinControl then
      ResizeFontsInDescendants( OldFont, NewFont, TWinControl(Child));
  end;
end;

procedure ForceInsideWorkArea( var Rect: TRect);
var
  Frame: TRect;
begin
  Frame := Screen.WorkAreaRect;
  {Veritcal version:}
  {Align bottom (preserving height) if needed}
  if Rect.Bottom > Frame.Bottom then
  begin
    Rect.Top := Rect.Top + Frame.Bottom - Rect.Bottom;
    Rect.Bottom := Frame.Bottom;
  end;
  {Then align top (preserving height) if needed}
  if Rect.Top < Frame.Top then
  begin
    Rect.Bottom := Rect.Bottom + Frame.Top - Rect.Top;
    Rect.Top := Frame.Top;
  end;
  {Now shrink (preserving top) if needed}
  if Rect.Bottom > Frame.Bottom then
    Rect.Bottom := Frame.Bottom;
  {Horizontal version:}
  if Rect.Right > Frame.Right then
  begin
    Rect.Left := Rect.Left + Frame.Right - Rect.Right;
    Rect.Right := Frame.Right;
  end;
  if Rect.Left < Frame.Left then
  begin
    Rect.Right := Rect.Right + Frame.Left - Rect.Left;
    Rect.Left := Frame.Left;
  end;
  if Rect.Right > Frame.Right then
    Rect.Right := Frame.Right;
end;

procedure ResizeFormToFont(AForm: TForm);
var
  Rect: TRect;
begin
  with AForm do begin
    ClientWidth := ResizeWidth( Font, MainFont, ClientWidth);
    ClientHeight := ResizeHeight( Font, MainFont, ClientHeight);
    HorzScrollBar.Range := ResizeWidth( Font, MainFont, HorzScrollBar.Range);
    VertScrollBar.Range := ResizeHeight( Font, MainFont, VertScrollBar.Range);
    Rect := BoundsRect;
    ForceInsideWorkArea(Rect);
    BoundsRect := Rect;
    ResizeFontsInDescendants( Font, MainFont, AForm);
    //Important: We are using the font to calculate everything, so don't
    //change font until now.
    Font.Size := MainFont.Size;
  end;
end;

procedure ResizeAnchoredFormToFont( AForm: TForm);
var
  Rect: TRect;
begin
  with AForm do begin
    ClientWidth  := ResizeWidth( Font, MainFont, ClientWidth);
    ClientHeight := ResizeHeight( Font, MainFont, ClientHeight);
    HorzScrollBar.Range := ResizeWidth( Font, MainFont, HorzScrollBar.Range);
    VertScrollBar.Range := ResizeHeight( Font, MainFont, VertScrollBar.Range);
    Rect := BoundsRect;
    ForceInsideWorkArea(Rect);
    BoundsRect := Rect;
    ResizeDescendants( Font, MainFont, AForm);
    ResizeFontsInDescendants( Font, MainFont, AForm);
    //Important: We are using the font to calculate everything, so don't
    //change font until now.
    Font.Size := MainFont.Size;
  end;
end;

procedure SetEqualTabStops(AControl: TControl; TabWidth: Integer = 8);
{ sets tab stops to match the width when the tab is replaced with TabWidth spaces }
const
  MAX_TABS = 10;
  POINTS_PER_INCH = 72;
var
  DC: HDC;
  i, HorzPixelsPerInch, PixelsPerTabWidth, PointsPerTabWidth: Integer;
begin
  if AControl is TRichEdit then with TRichEdit(AControl) do
  begin
    DC := GetDC(0);
    HorzPixelsPerInch := GetDeviceCaps(DC, LOGPIXELSX);
    ReleaseDC(0, DC);
    PixelsPerTabWidth := TextWidthByFont(Font.Handle, StringOfChar(' ', TabWidth));
    PointsPerTabWidth := Round((PixelsPerTabWidth / HorzPixelsPerInch) * POINTS_PER_INCH);
    for i := 0 to MAX_TABS do Paragraph.Tab[i] := PointsPerTabWidth * Succ(i);
  end;
end;

procedure StatusText(const S: string);
{ sends a user defined message to the main window of an application to display the text
  found in lParam.  Only useful if the main window has message event for this message }
begin
  if (Application.MainForm <> nil) and (Application.MainForm.HandleAllocated)
    then SendMessage(Application.MainForm.Handle, UM_STATUSTEXT, 0, Integer(PChar(S)));
end;

function ShowMsgOn(AnExpression: Boolean; const AMsg, ACaption: string): Boolean;
begin
  Result := AnExpression;
  if Result then InfoBox(AMsg, ACaption, MB_OK);
end;

function TextWidthByFont(AFontHandle: THandle; const x: string): Integer;
{ returns the width of a string in pixels, given a FONT handle and string }
var
  DC: HDC;
  SaveFont: HFont;
  TextSize: TSize;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, AFontHandle);
  GetTextExtentPoint32(DC, PChar(x), Length(x), TextSize);
  Result := TextSize.cx;
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
end;

function TextHeightByFont(AFontHandle: THandle; const x: string): Integer;
var
  DC: HDC;
  SaveFont: HFont;
  TextSize: TSize;

begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, AFontHandle);
  GetTextExtentPoint32(DC, PChar(x), Length(x), TextSize);
  Result := TextSize.cy;
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
end;

function WrappedTextHeightByFont(Canvas: TCanvas; NewFont: TFont; ItemText: string; var ARect: TRect): integer;
var
  MyTextMetric: TTextMetric;
  MyFontName: Array [0..31] of char;
  MyFontHandle, RealFontHandle: HFONT;
begin
  { The next bit is a bunch of Windows code to accomodate the DrawText calls
  inside the try..finally block.  The issue here comes when resizing the font.
  The Delphi font property is already set, but the DrawText call uses a
  Windows handle and the handle's font hasn't been set to the new value.}
  {This still has a vertical sizing bug when there is text that doesn't wrap but is too
  wide to display in the window (think long medicine names and 24 pt font on a
  640*480 screen)}
  MyFontHandle := 0;
  RealFontHandle := 0;
  if GetTextMetrics(Canvas.Handle, MyTextMetric) then
    if GetTextFace( Canvas.Handle, 32, @MyFontName) <> 0 then with MyTextMetric do
      MyFontHandle := CreateFont( NewFont.Height,
        tmAveCharWidth * Abs(NewFont.Height) div tmHeight,
        0,
        0,
        tmWeight,
        tmItalic,
        tmUnderlined,
        tmStruckOut,
        tmCharSet,
        OUT_DEFAULT_PRECIS,
        CLIP_DEFAULT_PRECIS,
        DEFAULT_QUALITY,
        FF_DONTCARE or DEFAULT_PITCH,
        @MyFontName);
  if MyFontHandle <> 0 then
    RealFontHandle := SelectObject( Canvas.Handle, MyFontHandle);
  try
    result := DrawText(Canvas.Handle, PChar(ItemText), Length(ItemText), ARect,
                 DT_CALCRECT or DT_LEFT or DT_NOPREFIX or DT_WORDBREAK) + 2;
  finally
    if MyFontHandle <> 0 then begin
      SelectObject( Canvas.Handle, RealFontHandle);
      DeleteObject( MyFontHandle );
    end;
  end;
end;

function NumCharsFitInWidth(AFontHandle: THandle; const x: string; const MaxLen: integer): Integer;
var
  DC: HDC;
  SaveFont: HFont;
  TextSize: TSize;
  TmpX: string;
  done: boolean;
  l,h: integer;

begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, AFontHandle);
  try
    h := length(x);
    l := 0;
    Result := h;
    repeat
      TmpX := copy(x, 1, Result);
      GetTextExtentPoint32(DC, PChar(TmpX), Length(TmpX), TextSize);
      if(TextSize.cx > MaxLen) then
      begin
        h := Result;
        Result := (l+h) div 2;
        done := (Result <= l);
      end
      else
      begin
        l := Result;
        Result := (l+h+1) div 2;
        done := (Result >= h);
      end;
    until(done);
  finally
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
  end;
end;

function PopupComponent(Sender: TObject; PopupMenu: TPopupMenu): TComponent;
begin
  if(assigned(PopupMenu) and assigned(Sender) and (Sender is TPopupMenu) and
     assigned(PopupMenu.PopupComponent)) then
    Result := PopupMenu.PopupComponent
  else
    Result := Screen.ActiveControl;
end;

procedure ReformatMemoParagraph(AMemo: TCustomMemo);
{ rewrap lines starting with current line until there is a line that starts with whitespace }
var
  ALine: Integer;
  x, OldText, NewText: string;
begin
  with AMemo do
  begin
    ALine := SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0);
    repeat
      Inc(ALine);
    until (ALine >= Lines.Count) or (Lines[ALine] = '') or (Ord(Lines[ALine][1]) <= 32);
    SelLength := SendMessage(Handle, EM_LINEINDEX, ALine, 0) - SelStart - 1;
    if SelLength < 1 then Exit;
    OldText := SelText;
    NewText := '';
    repeat
      x := Copy(OldText, 1, Pos(CRLF, OldText) - 1);
      if Length(x) = 0 then x := OldText;
      Delete(OldText, 1, Length(x) + 2);  {delete text + CRLF}
      if (NewText <> '') and (Copy(NewText, Length(NewText), 1) <> ' ') and
         (Copy(x, 1, 1) <> ' ') then NewText := NewText + ' ';
      NewText := NewText + x;
    until OldText = '';
    SelText := NewText;
  end;
end;

var
  uReadOnlyColor: TColor;
  uHaveReadOnlyColor: boolean = FALSE;

function ReadOnlyColor: TColor;
begin
  if not uHaveReadOnlyColor then
  begin
    uHaveReadOnlyColor := TRUE;
    if ColorToRGB(clWindow) = ColorToRGB(clWhite) then
      uReadOnlyColor := $00F0FBFF
    else
      uReadOnlyColor := clWindow;
  end;
  Result := uReadOnlyColor;
end;

{ ListBox Grid functions }

procedure ListGridDrawCell(AListBox: TListBox; AHeader: THeaderControl; ARow, AColumn: Integer;
  const x: string; WordWrap: Boolean);
var
  i, Format: Integer;
  ARect: TRect;
begin
  ARect := AListBox.ItemRect(ARow);
  ARect.Left := 0;
  for i := 0 to AColumn - 1 do ARect.Left := ARect.Left + AHeader.Sections[i].Width;
  Inc(ARect.Left, 2);
  ARect.Right := ARect.Left + AHeader.Sections[AColumn].Width - 6;
  if WordWrap
    then Format := (DT_LEFT or DT_NOPREFIX or DT_WORDBREAK)
    else Format := (DT_LEFT or DT_NOPREFIX);
  DrawText(AListBox.Canvas.Handle, PChar(x), Length(x), ARect, Format);
end;

procedure ListGridDrawLines(AListBox: TListBox; AHeader: THeaderControl; Index: Integer;
  State: TOwnerDrawState);
var
  i, RightSide: Integer;
  ARect: TRect;
begin
  with AListBox do
  begin
    ARect := ItemRect(Index);
    if odSelected in State then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clHighlightText
    end;
    Canvas.FillRect(ARect);
    Canvas.Pen.Color := clSilver;
    Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
    Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
    RightSide := -2;
    for i := 0 to AHeader.Sections.Count - 1 do
    begin
      RightSide := RightSide + AHeader.Sections[i].Width;
      Canvas.MoveTo(RightSide, ARect.Bottom - 1);
      Canvas.LineTo(RightSide, ARect.Top);
    end;
  end;
end;

function ListGridRowHeight(AListBox: TListBox; AHeader: THeaderControl; ARow, AColumn: Integer;
  const x: string): Integer;
var
  ARect: TRect;
begin
  ARect := AListBox.ItemRect(ARow);
  ARect.Right := AHeader.Sections[AColumn].Width - 6;
  Result := DrawText(AListBox.Canvas.Handle, PChar(x), Length(x), ARect,
    DT_CALCRECT or DT_LEFT or DT_NOPREFIX or DT_WORDBREAK) + 2;
end;

(*
procedure SetEditWidth(AMemo: TMemo; AWidth: Integer);
begin
  //SetString(x, nil, AWidth);
  //for i := 1 to AWidth do x[i] := 'X';
end;
*)

{ You MUST pass an address to an object variable to get KillObj to work }
procedure KillObj(ptr: Pointer; KillObjects: boolean = FALSE);
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
        for i := SLst.count-1 downto 0 do
          if assigned(SLst.Objects[i]) then
            SLst.Objects[i].Free;
      end;
    end;
    Obj.Free;
    TObject(ptr^) := nil;
  end;
end;

{ Idle Processing }

type
  TIdleCaller = class(TObject)
  private
    FTimerActive: boolean;
    FCallList: TStringList;
    FDoneList: TStringList;
    FOldIdler: TIdleEvent;
    FTimer: TTimer;
  protected
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure TimerDone(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(CallProc, DoneProc: TORIdleCallProc; Msg: string);
  end;

var
  IdleCaller: TIdleCaller = nil;

{ TIdleCaller }

constructor TIdleCaller.Create;
begin
  inherited;
  FCallList := TStringList.Create;
  FDoneList := TStringList.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := FALSE;
  FTimer.Interval := 2000; // 2 seconds
  FTimer.OnTimer := TimerDone;
  FTimerActive := FALSE;
  FOldIdler := Application.OnIdle;
  Application.OnIdle := AppIdle;
end;

destructor TIdleCaller.Destroy;
begin
  Application.OnIdle := FOldIdler;
  FTimer.Enabled := FALSE;
  KillObj(@FTimer);
  KillObj(@FDoneList);
  KillObj(@FCallList);
  inherited;
end;

procedure TIdleCaller.AppIdle(Sender: TObject; var Done: Boolean);
begin
  if(not FTimerActive) and (FCallList.Count > 0) then
  begin
    FTimer.Enabled := TRUE;
    FTimerActive := TRUE;
  end;
  if assigned(FOldIdler) then
    FOldIdler(Sender, Done);
end;

procedure TIdleCaller.Add(CallProc, DoneProc: TORIdleCallProc; Msg: string);
begin
  FCallList.AddObject(Msg, TObject(@CallProc));
  FDoneList.AddObject(Msg, TObject(@DoneProc));
end;

procedure TIdleCaller.TimerDone(Sender: TObject);
var
  CallProc, DoneProc: TORIdleCallProc;
  CallMsg, DoneMsg: string;

begin
  FTimer.Enabled := FALSE;
  CallProc := TORIdleCallProc(FCallList.Objects[0]);
  CallMsg := FCallList[0];
  DoneProc := TORIdleCallProc(FDoneList.Objects[0]);
  DoneMsg := FDoneList[0];
  FCallList.Delete(0);
  FDoneList.Delete(0);

  if(assigned(CallProc)) then
    CallProc(CallMsg);
  if(assigned(DoneProc)) then
    DoneProc(DoneMsg);

  FTimerActive := FALSE;
end;

{ do NOT use CallWhenIdle to call RPCs.  Use CallRPCWhenIdle in ORNet. }
procedure CallWhenIdle(CallProc: TORIdleCallProc; Msg: String);
begin
  if(not assigned(IdleCaller)) then              
    IdleCaller := TIdleCaller.Create;
  IdleCaller.Add(CallProc, nil, Msg);
end;

procedure CallWhenIdleNotifyWhenDone(CallProc, DoneProc: TORIdleCallProc; Msg: String);
begin
  if(not assigned(IdleCaller)) then
    IdleCaller := TIdleCaller.Create;
  IdleCaller.Add(CallProc, DoneProc, Msg);
end;

procedure menuHideAllBut(aMenuItem: tMenuItem; butItems: array of tMenuItem);
var
  aCount, bCount: integer;
  butFound: boolean;
begin
for aCount := 0 to (aMenuItem.count - 1) do      // Iterate through menu items.
  begin
    butFound := false;
    for bCount := 0 to (length(butItems) - 1) do // Check for match in exceptions array.
      begin
        if (aMenuItem.items[aCount] = butItems[bCount]) then
          begin
            butFound := true;
            break;
          end;
      end;
    if (not butFound) then
      aMenuItem.items[aCount].visible := false;  // Hide menu item if not an exception.
  end;
end;

function TabIsPressed : Boolean;
begin
  Result := Boolean(Hi(GetKeyState(VK_TAB))) and not Boolean(Hi(GetKeyState(VK_SHIFT)));
end;

function ShiftTabIsPressed : Boolean;
begin
  Result := Boolean(Hi(GetKeyState(VK_TAB))) and Boolean(Hi(GetKeyState(VK_SHIFT)));
end;

//--- added from newer version of ORFn
function RectContains(Rect: TRect; Point: TPoint): boolean;
begin
  Result := ((Point.X >= Rect.Left) and
             (Point.X <= Rect.Right) and
             (Point.Y >= Rect.Top) and
             (Point.Y <= Rect.Bottom));
end;

procedure ScrollControl(Window: TScrollingWinControl; ScrollingUp: boolean; Amount: integer = 40);
var
  Delta: integer;

  // This is needed to tell the child components that they are moving,
  // The TORCombo box, for example, needs to close a dropped down window when it moves.
  // If Delphi had used standard scroll bars, instead of the customized flat ones, this
  // code wouldn't be needed
  procedure SendMoveMessage(Ctrl: TWinControl);
  var
    i: integer;
  begin
    for i := 0 to Ctrl.ControlCount - 1 do
    begin
      if Ctrl.Controls[i] is TWinControl then with TWinControl(Ctrl.Controls[i]) do
      begin
        SendMessage(Handle, WM_MOVE, 0, (Top * 65536) + Left);
        SendMoveMessage(TWinControl(Ctrl.Controls[i]));
      end;
    end;
  end;
  
begin
  Delta := Amount;
  if ScrollingUp then
  begin
    if Window.VertScrollBar.Position < Delta then
      Delta := Window.VertScrollBar.Position;
    Delta := - Delta;
  end
  else
  begin
    if (Window.VertScrollBar.Range - Window.VertScrollBar.Position) < Delta then
      Delta := Window.VertScrollBar.Range - Window.VertScrollBar.Position;
  end;
  if Delta <> 0 then
  begin
    Window.VertScrollBar.Position := Window.VertScrollBar.Position + Delta;
    SendMoveMessage(Window);
  end;
end;


procedure FastAssign(source, destination: TStrings);
// do not use this with RichEdit Lines unless source is RichEdit with PlainText
var
  ms: TMemoryStream;
begin
  destination.Clear;
  if (source is TStringList) and (destination is TStringList) then
    destination.Assign(source)
  else
  if (CompareText(source.ClassName, 'TRichEditStrings') = 0) then
    destination.Assign(source)
  else
  begin
    ms := TMemoryStream.Create;
    try
      source.SaveToStream(ms);
      ms.Seek(0, soFromBeginning);
      destination.LoadFromStream(ms);
    finally
      ms.Free;
    end;
  end;
end;

procedure FastAddStrings(source, destination: TStrings);
// do not use this with RichEdit Lines unless source and destination are RichEdit with PlainText
var
  ms: TMemoryStream;
begin
  if (source is TStringList) and (destination is TStringList) then
    destination.AddStrings(source)
  else
  begin
    ms := TMemoryStream.Create;
    try
      destination.SaveToStream(ms);
      ms.Seek(0, soFromEnd);
      source.SaveToStream(ms);
      ms.Seek(0, soFromBeginning);
      destination.Clear;
      destination.LoadFromStream(ms);
    finally
      ms.Free;
    end;
  end;
end;




initialization
  FBaseFont := TFont.Create;
  FBaseFont.Name := BaseFontName;
  FBaseFont.Size := BaseFontSize;

finalization
  FBaseFont.Free;
  KillObj(@IdleCaller);

end.
