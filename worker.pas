unit worker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, extractor;

const statusDataReady = 'data is ready';
      statusBegin = 'application initialized';
      outfile = '/tmp/solarinfo.txt';
      //not necessary anymore
      //outcsvfile = '/tmp/solarinfo.csv';
      outjsonfile = '/tmp/solarinfo.json';
type
TShowStatusEvent = procedure(Status: String) of Object;

TMyThread = class(TThread)
    private
      FOnShowStatus: TShowStatusEvent;
      procedure ShowStatus;
    protected
      procedure Execute; override;
    public
      fStatusText : string;
      Constructor Create(CreateSuspended : boolean);
      property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
      property Terminated;
    end;

var
    sd: extractor.SolarData;
implementation
uses dateutils, strutils, requestor;

constructor TMyThread.Create(CreateSuspended : boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure TMyThread.ShowStatus;
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  if Assigned(FOnShowStatus) then
    begin
      FOnShowStatus(fStatusText);
    end;

end;


procedure TMyThread.Execute;
var
  newStatus : string;
  Location, loginContent, plant: string;
  s0, s1 : boolean;
  tm: TDateTime;
  dlm : set of char;
  str, day, tday, month, tmonth, year, tyear: string;
begin

  Location := 'http://solarinfobank.com';
  loginContent := 'localZone=&username=USERNAME%40FREENET.AM&password=PASSWORD&autologin=true&autologin=false';

  fStatusText := 'TMyThread Starting...';
  Synchronize(@Showstatus);

  while (not Terminated) {and ([any condition required])} do
    begin

      //here goes the code of the main thread loop
      //EnterCriticalSection(MyCriticalSection);
     // try
          repeat
           requestor.Init;
           fStatusText:='connecting...';
           Synchronize(@Showstatus);
           //requestor.Work('http://solarinfobank.com', outfile);


           requestor.SendRequest(Location);


            WriteLn('Sending Login and Password...');
            Location:= 'http://solarinfobank.com/home/index';

            fStatusText:='logging in...';
            Synchronize(@Showstatus);

            //repeat
            requestor.SendLoginPassword(Location, loginContent);

            while (HTTP.ResultCode = 301) or (HTTP.ResultCode = 302) do
            begin
               fStatusText:='processing redirect...';
               Synchronize(@Showstatus);
               DoMoved;
            end;
            //until HTTP.ResultCode < 303;;

            WriteLn('getting farm info...');
            Location := 'http://solarinfobank.com/plant/includeoverview/3096';

            fStatusText:='getting farm info...';
            Synchronize(@Showstatus);

            s0 := false;
            requestor.SendRequest(Location);
            requestor.HTTP.Document.SaveToFile(outfile);
            s0 := requestor.HTTP.ResultCode = 200;


            if s0 then
              begin
                 fStatusText:='received data, now getting chart data...';
              end
             else
              begin
                 fStatusText:='failed to receive data';
              end;
              Synchronize(@Showstatus);
            //SendPostRequest('http://solarinfobank.com/DataExport/ExportChart', 'filename=20150722AGBU-Yerevan&type=text%2Fcsv&width=800&svg=&serieNo=23035042155');

            plant := 'pid=3096&startYYYYMMDDHH=2015072400&endYYYYMMDDHH=2015072523&chartType=area&intervalMins=5';

            tm := Yesterday;
            str := DateTimeToStr(tm);
            dlm := ['-', ' ', ':'];
            day := strutils.ExtractWord(1, str, dlm);
            month := strutils.ExtractWord(2, str, dlm);
            year := strutils.ExtractWord(3, str, dlm);
            if length(day) < 2 then begin day := '0' + day end;
            if length(month) < 2 then begin month := '0' + month end;
            tm := Now;
            str := DateTimeToStr(tm);
            tday := strutils.ExtractWord(1, str, dlm);
            tmonth := strutils.ExtractWord(2, str, dlm);
            tyear := strutils.ExtractWord(3, str, dlm);
            if length(tday) < 2 then begin tday := '0' + tday end;
            if length(tmonth) < 2 then begin tmonth := '0' + tmonth end;

            plant := 'pid=3096&startYYYYMMDDHH=20' + year + month + day + '00&endYYYYMMDDHH=20' + tyear + tmonth + tday + '23&chartType=area&intervalMins=5';
            s1 := false;
            requestor.SendPostRequest('http://solarinfobank.com/plantchart/PlantDayChart', plant);
            s1 := requestor.HTTP.ResultCode = 200;

            requestor.HTTP.Document.SaveToFile(outjsonfile);

            if s1 then
              begin
              fStatusText := 'chart data downloaded'
              end
             else
             begin
               fStatusText := 'failed to download chart data';
             end;
            Synchronize(@Showstatus);


            requestor.Uninit;

          until s0 and s1;
           extractor.ExtractData(outfile, sd);
           fStatusText := statusDataReady;
           Synchronize(@ShowStatus);

           //Sleep(60000); //1 minute in milliseconds
           Sleep(1800000); {30 minutes}
      //  finally
      //  LeaveCriticalSection(MyCriticalSection);
       end;
      // end of the main thread work
      {if NewStatus <> fStatusText then
        begin
          fStatusText := newStatus;
          Synchronize(@Showstatus);
        end;}
    //end;

end;


end.

