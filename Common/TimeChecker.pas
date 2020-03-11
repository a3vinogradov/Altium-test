unit TimeChecker;

interface
uses
  SysUtils, System.DateUtils;

type
  TTimeChecker = class
  private
    _timeStart: TDateTime;
    _timeStop: TDateTime;
    _active: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    procedure Start;
    procedure Stop;
    function Report: String;
  published
    property TimeStart: TDateTime read _timeStart write _timeStart;
    property TimeStop: TDateTime read _timeStop write _timeStop;
    property Active: Boolean read _active write SetActive;
  end;
implementation

{ TTimeChecker }

function TTimeChecker.Report: String;
begin
  Result := Format('Время выполнения %d секунд.', [SecondsBetween(TimeStop, TimeStart)]);
end;

procedure TTimeChecker.SetActive(const Value: Boolean);
begin
  _active := Value;
end;

procedure TTimeChecker.Start;
begin
  TimeStart := Now();
end;

procedure TTimeChecker.Stop;
begin
  TimeStop := Now();
end;

end.
