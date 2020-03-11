unit FileSorterHelper;

interface

type
  TFileSorterHelper = class
  private
    _src: String;
    _dest: String;
  public
    constructor Create(const aSrc: string; const aDest: String );
    procedure Sort();
  private
    property Sorce: String read _src;
    property Destination: String read _dest;
  end;

implementation

{ TFileSorterHelper }
uses
  System.IOUtils, System.Classes, SysUtils;
function CompareStr(List: TStringList; Index1, Index2: Integer): Integer;
var
  suf1, suf2 : string;
  pref1, pref2: string;
  pos1, pos2: integer;
begin
  pos1:=Pos('.',List[Index1]);
  pos2:=Pos('.',List[Index2]);

  suf1:= Copy(List[Index1],Pos1+1,Length(List[Index1])-1);
  suf2:= Copy(List[Index2],Pos2+1,Length(List[Index2])-1);
  // Сначала сравним строки после точки.
  if Suf1>Suf2 then
    Result := 1
  else if Suf1=Suf2 then
    Result := 0
  else
    Result := -1;
  // Если равны - сравним строки до точки.
  if Result=0 then
  begin
    // сначала длинну числа (чтобы сократить число вызовов StrToInt)
    if pos1>pos2 then
      Result := 1
    else if pos1<pos2 then
      Result := -1
  end;
  if Result=0 then
  begin
    // если дина чисел равна (одинаковое число разрядов), то сравниваем сами строки.
    pref1 := Copy(List[Index1], 0, Pos1-1);
    pref2 := Copy(List[Index2], 0, Pos2-1);
    if pref1>pref2 then
      Result := 1
    else if pref1<pref2 then
      Result := -1;
  end;
end;

constructor TFileSorterHelper.Create(const aSrc, aDest: String);
begin
  _src := aSrc;
  _dest := aDest;
end;

procedure TFileSorterHelper.Sort;
var
  StrList: TStringList;
begin
  StrList:= TStringList.Create;
  try
    StrList.Sorted := false;
    StrList.LoadFromFile(Sorce);
    StrList.CustomSort(CompareStr);
    StrList.SaveToFile(Destination);
  finally
    FreeAndNil(StrList);
  end;

end;
end.
