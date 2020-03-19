unit FileSorterHelper;

interface
uses
  Generics.Collections, Generics.Defaults;

const
  MaxLengthOfTempFiles = 1000000; // максимальный объем временных файлов
  //MaxLengthOfTempFiles =   1000000; // максимальный объем временных файлов ~1Mb
  //MaxLengthOfTempFiles =   2000000; // максимальный объем временных файлов ~1Mb
  MaxLengthOfTempFiles = 200000000; // максимальный объем временных файлов ~200Mb
type
  TTmpFileManager = class
  private
    _head: string;
    _fileName: String;
    _fileDesc : TextFile;
  public
    property Head: string read _head write _head;
    property FileDesc: TextFile read _fileDesc;
    property FileName: String read _fileName write _fileName;
    constructor Create(fName: String);
    destructor Destroy(); override;

    procedure OpenFile();
    procedure First;
    procedure Next;
    function IsEOF :Boolean;

  end;

  TFileSorterHelper = class
  private
    _src: String;
    _dest: String;
    _flist: TObjectList<TTmpFileManager>;
  public
    constructor Create(const aSrc: string; const aDest: String );
    destructor Destroy(); override;
    procedure Sort();
    procedure Sort2();
  private
    property Sorce: String read _src;
    property Destination: String read _dest;
    property FList: TObjectList<TTmpFileManager> read _flist;

    procedure SplitSorce;
    procedure MergeTmp;
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
function CompareStr2(aFirst, aSecond: String): Integer;
var
  suf1, suf2 : string;
  pref1, pref2: string;
  pos1, pos2: integer;
begin
  pos1:=Pos('.',aFirst);
  pos2:=Pos('.',aSecond);

  suf1:= Copy(aFirst,Pos1+1,Length(aFirst)-1);
  suf2:= Copy(aSecond,Pos2+1,Length(aSecond)-1);
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
    pref1 := Copy(aFirst, 0, Pos1-1);
    pref2 := Copy(aSecond, 0, Pos2-1);
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
  _flist := TObjectList<TTmpFileManager>.Create();
end;

procedure TFileSorterHelper.Sort2;
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
destructor TFileSorterHelper.Destroy;
begin
  FreeAndNil(_flist);
  inherited;
end;

procedure TFileSorterHelper.MergeTmp;
var
  i: integer;
  fDest: TextFile;
  minStr: String;
  minInd: Integer;
begin
  // открыть все файлы на чтение. Прочитать первую строку
  for i:= 0 to FList.Count-1 do
  begin
    FList[i].OpenFile();
    FList[i].First();
  end;
  // открыть результирующий файл на запись
  AssignFile(fDest, Destination);
  Rewrite(fDest);

  while FList.Count>0 do
  begin
    // найти самую маленькую строку
    minInd:=0;
    minStr:=FList[minInd].Head;
    for i := 0 to FList.Count-1 do
    begin
      //if minStr>FList[i].Head then
      if CompareStr2(minStr, FList[i].Head)>0 then
      begin
        minStr :=FList[i].Head;
        minInd := i;
      end;
    end;
    // записать ее в destination файл
    WriteLn(fDest, minStr);
    // если eof - удалить тмп файл из списка
    if FList[minInd].IsEOF then
      FList.Delete(minInd)
    else  // прочитать из temp файла новую строку
      FList[minInd].Next;
  end;
  CloseFile(fDest);
end;

procedure TFileSorterHelper.Sort;
begin
  // 1. Разбить исходный файл на более мелкие.
  SplitSorce;
  // 3. Слить все файлы в один - результирующий
  MergeTmp;
end;
procedure TFileSorterHelper.SplitSorce;
var
  f : TextFile;
  tmpStr:String;
  strList: TStringList;
  curTmpLength: Int64;
  curTmpNumber: Int64;

begin
  // Открыть файл на чтение.
  strList := TStringList.Create;

  AssignFile(f, Sorce);
  Reset(f);
  curTmpLength:=0;
  curTmpNumber:=1;
  // Читать строки по одной в лист, пока общая длина не превысит Макс
  while not Eof(f) do
  begin
    ReadLn(f,tmpStr);
    if MaxLengthOfTempFiles < (curTmpLength + Length(tmpStr)) then
    begin
      strList.CustomSort(CompareStr);
      strList.SaveToFile(Format('%dtmp.txt',[curTmpNumber]));
      Flist.Add(TTmpFileManager.Create(Format('%dtmp.txt',[curTmpNumber])));
      strList.Clear;
      curTmpNumber:=curTmpNumber+1;
      curTmpLength:=0
    end;
    strList.Add(tmpStr);
    curTmpLength := curTmpLength+Length(tmpStr);
  end;
  CloseFile(f);

  strList.CustomSort(CompareStr);
  strList.SaveToFile(Format('%dtmp.txt',[curTmpNumber]));
  Flist.Add(TTmpFileManager.Create(Format('%dtmp.txt',[curTmpNumber])));
  strList.Free;
  // Сохранить лист во временный файл и продолжить чтение, пока не конец файла
end;




{ TTmpFileManager }

constructor TTmpFileManager.Create(fName: String);
begin
  _fileName := fName;
end;

destructor TTmpFileManager.Destroy;
begin
  CloseFile(FileDesc);
  inherited;
end;

function TTmpFileManager.IsEOF: Boolean;
begin
  Result := EOF(FileDesc);
end;

procedure TTmpFileManager.First;
begin
  Reset(FileDesc);
  Next;
end;

procedure TTmpFileManager.Next;
var
  tmp: string;
begin
  Readln(FileDesc, tmp);
  Head := tmp;
end;

procedure TTmpFileManager.OpenFile;
begin
  AssignFile(FileDesc, FileName);
  //Reset(FileDesc);
end;

end.
