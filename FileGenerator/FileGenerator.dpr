program FileGenerator;

{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  System.Classes,
  TimeChecker in '..\Common\TimeChecker.pas';

const
  Imax = 100;
var
  i: integer;
  s: string;
  strList: TStringList;
begin
  try
    try
      TTimeChecker.Start();
      strList := TStringList.Create;
      Randomize();
      for i := 0  to Imax do
      begin
        strList.Add(Format('%d. %s%d',[Random(65535),'test string',Random(65535)]));
      end;
      strList.SaveToFile('data.txt');
      TTimeChecker.Stop();
      WriteLn(TTimeChecker.)
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    FreeAndNil(strList);
  end;
end.
