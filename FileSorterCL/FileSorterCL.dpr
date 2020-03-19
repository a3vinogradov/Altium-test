program FileSorterCL;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FileSorterHelper in 'FileSorterHelper.pas',
  TimeChecker in '..\Common\TimeChecker.pas';

const
  defaultSrc ='RandomData.txt';
  defaultDest = 'SortedData.txt';

var
  tmp: string;
  srcFile: string;
  destFile: string;
  helper: TFileSorterHelper;
  tch: TTimeChecker;

begin
  try
    try
      WriteLn('Сортировка файла...');

      tch := TTimeChecker.Create;
      tch.Start;

      srcFile := ParamStr(1);
      if srcFile = '' then srcFile := defaultSrc;

      destFile := ParamStr(2);
      if destFile = '' then destFile := defaultDest;

      helper := TFileSorterHelper.Create(srcFile,destFile);
      helper.Sort();
      tch.Stop;

      WriteLn(tch.Report);
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    FreeAndNil(tch);
    FreeAndNil(helper);
  end;
  WriteLn('Работа программы завершена.');
  ReadLn(tmp);
end.
