program FileGenerator;

{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  System.Classes,
  TimeChecker in '..\Common\TimeChecker.pas';

const
  Imax = 500000000;
var
  i: int64;
  strList: TStringList;
  tch: TTimeChecker;
  s: string;
begin
  strList := TStringList.Create;
  tch := TTimeChecker.Create;
  try
    try
      tch.Start();
      strList := TStringList.Create;
      Randomize();
      for i := 0  to Imax do
      begin
        strList.Add(Format('%d. %s%d',[Random(65535),'test string',Random(65535)]));
      end;
      strList.SaveToFile('data.txt');
      tch.Stop();
      WriteLn(tch.Report());
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    FreeAndNil(strList);
    FreeAndNil(tch);
  end;
  Readln(s);
end.
