program FileGenerator;

{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  System.Classes,
  TimeChecker in '..\Common\TimeChecker.pas';

const
  Imax = 500000000; // Количество строк в файле
  defaultDest ='RandomData.txt';  // Имя файла по умолчанию

var
  i: int64;
  tch: TTimeChecker;
  s: string;
  strm: TBufferedFileStream;
  buf: AnsiString;
  destFile: String;

begin

  strm := TBufferedFileStream.Create('data.txt',fmCreate);
  tch := TTimeChecker.Create;
  try
    try
      WriteLn('Генерация файла...');

      destFile := ParamStr(1);
      if destFile = '' then destFile := defaultDest;

      tch.Start();
      Randomize();

      for i := 0  to Imax do
      begin
        buf :=Format('%d. %s%d',[Random(65535),'test string',Random(65535)])+#13#10;
        strm.Write(buf[1],Length(Buf));
      end;
      strm.FlushBuffer;
      tch.Stop();
      WriteLn(tch.Report());
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    FreeAndNil(tch);
    FreeAndNil(strm);
  end;
  Readln(s);
end.
