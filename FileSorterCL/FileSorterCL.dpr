program FileSorterCL;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FileSorterHelper in 'FileSorterHelper.pas',
  TimeChecker in '..\Common\TimeChecker.pas';

var
  tmp: string;
  srcFile: string;
  destFile: string;
  helper: TFileSorterHelper;
  tch: TTimeChecker;

begin
  try
    try
      tch := TTimeChecker.Create;
      tch.Start;
      srcFile := 'c:\Work\Altium-test\FileGenerator\Win32\Debug\data1.txt';
      destFile := 'SortedData.txt';
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
