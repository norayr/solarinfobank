unit worker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, extractor;

type


TMyThread = class(TThread)
    private
       fStatusText : string;
       procedure ShowStatus;
    protected
      procedure Execute; override;
    public
      Constructor Create(CreateSuspended : boolean);

      property Terminated;
    end;

var
    sd: extractor.SolarData;
implementation
uses Unit1, strconstants, syncobjs, dateutils, strutils, requestor;

constructor TMyThread.Create(CreateSuspended : boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure TMyThread.ShowStatus;
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  Form1.StatusBar1.SimpleText:= fStatusText;
  if fStatusText = strconstants.statusDataReady then
   begin
      Form1.updateData;
      Form1.Timer1.Enabled:= true;
   end
  else
   begin
    Form1.Timer1.Enabled:= false;
   end;
end;



procedure TMyThread.Execute;
var
  newStatus : string;
  Location, loginContent, plant: string;
  s0, s1, s2 : boolean;
  tm: TDateTime;
  dlm : set of char;
  str, day, tday, month, tmonth, year, tyear: string;
begin

  Location := 'http://solarinfobank.com';

  fStatusText := 'TMyThread Starting...';
  Synchronize(@ShowStatus);

  loginContent := 'localZone=&username=' + requestor.HTTPEncode(strconstants.username) +  '&password=' + requestor.HTTPEncode(strconstants.password) + '&autologin=true&autologin=false';

  while (not Terminated) {and ([any condition required])} do
    begin

      //here goes the code of the main thread loop
      //EnterCriticalSection(MyCriticalSection);
     // try
     repeat
        requestor.Init;


          fStatusText:='connecting...';
          if not Terminated then Synchronize(@ShowStatus);
          //requestor.Work('http://solarinfobank.com', outfile);


          requestor.SendRequest(Location);


           WriteLn('Sending Login and Password...');
           Location:= 'http://solarinfobank.com/home/index';

           fStatusText:='logging in...';
           if not Terminated then  Synchronize(@ShowStatus);


           requestor.SendLoginPassword(Location, loginContent);

           while (HTTP.ResultCode = 301) or (HTTP.ResultCode = 302) do
           begin
             fStatusText:='processing redirect...';
             if not Terminated then  Synchronize(@ShowStatus);
             DoMoved;
           end;


           //until HTTP.ResultCode < 303;

            WriteLn('getting farm info...');
            Location := 'http://solarinfobank.com/plant/includeoverview/' + strconstants.farm;

            fStatusText:='getting farm info...';
                       if not Terminated then Synchronize(@ShowStatus);

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
                         if not Terminated then Synchronize(@ShowStatus);
            //SendPostRequest('http://solarinfobank.com/DataExport/ExportChart', 'filename=20150722AGBU-Yerevan&type=text%2Fcsv&width=800&svg=&serieNo=23035042155');

            plant := 'pid=' + strconstants.farm + '&startYYYYMMDDHH=2015072400&endYYYYMMDDHH=2015072523&chartType=area&intervalMins=5';

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

            plant := 'pid=' + strconstants.farm + '&startYYYYMMDDHH=20' + year + month + day + '00&endYYYYMMDDHH=20' + tyear + tmonth + tday + '23&chartType=area&intervalMins=5';

            s1 := false;
            requestor.SendPostRequest('http://solarinfobank.com/plantchart/PlantDayChart', plant);
            s1 := requestor.HTTP.ResultCode = 200;

            requestor.HTTP.Document.SaveToFile(outjsonfile);

            if s1 then
              begin
              fStatusText := 'chart data downloaded, getting monthly chart data'
              end
             else
             begin
               fStatusText := 'failed to download chart data';
             end;
                      if not Terminated then Synchronize(@ShowStatus);


            //plant := 'id=3096&startYYYYMMDD=20150701&endYYYYMMDD=20150731&chartType=column';


            //plant := 'id=3096&startYYYYMMDD=20' + tyear + tmonth + '01&endYYYYMMDD=20' + tyear + tmonth + inttostr(daysinmonth(now)) + '&chartType=column';
            //plant := 'pid=3096&startYYYYMMDDHH=2015070100&endYYYYMMDDHH=2015072531&chartType=area&intervalMins=60';
            //their api can return only data for current month.
            plant := 'pid=' + strconstants.farm + '&startYYYYMMDDHH=20' + tyear + tmonth + '0100&endYYYYMMDDHH=20' + tyear + tmonth + inttostr(daysinmonth(now)) + '23&chartType=area&intervalMins=60';

            s2 := false;
            requestor.SendPostRequest('http://solarinfobank.com/plantchart/PlantDayChart', plant);
            s2 := requestor.HTTP.ResultCode = 200;

            if s2 then
              begin
              fStatusText := 'monthly chart data downloaded'
              end
             else
             begin
                fStatusText := 'failed to download monthly chart data';
             end;

                         if not Terminated then  Synchronize(@ShowStatus);




            requestor.HTTP.Document.SaveToFile(outmjsonfile);
                      //       sleep (1000); // 1 secs, to watch the status
            requestor.Uninit;

          until s0 and s1 and s2;
           extractor.ExtractData(outfile, sd);
           fStatusText := statusDataReady;
                      if not Terminated then Synchronize(@ShowStatus);



           //Sleep(60000); //1 minute in milliseconds
           //Sleep(1800000); {30 minutes}
           //Sleep(30000)
           Form1.waitEvent.WaitFor(strconstants.waittime)
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

