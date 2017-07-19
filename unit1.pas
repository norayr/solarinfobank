unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, syncobjs, worker;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    Chart2: TChart;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    STCOReduction: TStaticText;
    STTodayEnergy: TStaticText;
    STTotalEnergy: TStaticText;
    STCurrentPower: TStaticText;
    Timer1: TTimer;
    StatusBar1: TStatusBar;



    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure drawChart;
    procedure FormShow(Sender: TObject);
    //procedure Image1Click(Sender: TObject);
    //procedure Label1Click(Sender: TObject);
    procedure updateData;
    procedure Timer1Timer(Sender: TObject);



  private
    { private declarations }


  public
    { public declarations }
        MyThread: worker.TMyThread;
        waitEvent: TEvent;
        

  end;

var
  Form1: TForm1;

  //MyCriticalSection: TRTLCriticalSection;

implementation
   uses  TAIntervalSources{for TDateTimeIntervalChartSource}, TAChartUtils{for smsLable}, FPCanvas{for psClear}, extractor, strutils, strconstants;
{$R *.lfm}
   var inProcess : boolean;
    { TForm1 }
       MySeries{, MySeries2}: TAreaSeries;
       MySeries2 : TBarSeries;
       MyScaleXMarks, MyScaleXMarks2: TDateTimeIntervalChartSource;

    procedure TForm1.Button1Click(Sender: TObject);

    begin
      {
          if (StatusBar1.SimpleText = worker.statusDataReady) or
              (StatusBar1.SimpleText = worker.statusBegin) then
          begin
             MyThread := worker.TMyThread.Create(true);
             MyThread.OnShowStatus:= @ShowStatus;
             MyThread.Resume;
          end;
       }
    end;



procedure TForm1.drawChart;
var
  i : integer;
  data, datam : extractor.chartdata;
  kwh : array [1..31] of real;
   ki : integer;
  //moment : double;
begin
   for ki := low(kwh) to high(kwh) do
   begin
       kwh[ki] := 0.0;
   end;
//  extractor.ExtractCSVData(worker.outcsvfile, data);
    inProcess := true;
    extractor.ExtractJsonData(outjsonfile, data, kwh) ;
    extractor.ExtractJsonData(outmjsonfile, datam, kwh) ;

    MySeries.Clear;

    for i := 0 to high(data) do
      begin
   // MySeries.AddXY(i/(3600*24),5*sin(i/100));

     //MySeries.AddXY(StrToDateTime(dd + ' ' + hh + ':' + mm),StrToFloat(kw));
     MySeries.AddXY(data[i].date, data[i].kw);
        // moment := now;
        // MySeries.AddXY(moment, data[i].kw);

      end;
  {
  for i := 0 to high(datam) do
      begin
       MySeries2.AddXY(datam[i].date, datam[i].kw);
      end;
      }

   MySeries2.Clear; 

// for i := low(kwh) to high(kwh) do
// begin
      MySeries2.AddArray(kwh);
//      MySeries2.AddXY(i, kwh[i]);
// end;
       inProcess := false;
  setlength(data, 0);
  setlength(datam, 0);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  MyThread.Resume;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
//var
//   td: TDateTime;
//   tdstr: String;
begin

//   td:= Now;
//   tdstr := DateTimeToStr(td);
//   Form1.StaticText5.Caption:='Today: ' + tdstr;

  if (inProcess = false) and (StatusBar1.SimpleText = strconstants.statusDataReady) then
   begin
      if Chart1.Visible then
       begin
          Chart1.Visible:= false;
          Chart2.Visible:= true;
          Chart2.BringToFront;
//          Form1.StaticText6.Caption:='[KWh]';
//          Form1.StaticText7.Caption:='[Day of Month]';
          Form1.StaticText6.Caption:='[ԿՎտ֊ժ]';
          Form1.StaticText7.Caption:='[Ամսաթիւ]';
       end
      else
       begin
           Chart1.Visible:= true;
           Chart2.Visible:= false;
           Chart1.BringToFront;
//           Form1.StaticText6.Caption:='[KW]';
//           Form1.StaticText7.Caption:='[Hour of Day]';
           Form1.StaticText6.Caption:='[ԿՎտ]';
           Form1.StaticText7.Caption:='[Ժամ]';
       end;
   end;
end;

procedure TForm1.updateData;
var
   td: TDateTime;
   tdstr, tdday, tdmonth, almonth, tdyear: String;
   tddlm : set of char;
   monthname : array[1..12] of String;
   tdmonthnum : Integer;
begin

{
      Form1.STTodayEnergy.Caption:= worker.sd.TodayEnergy + ' KWh';
      Form1.STTotalEnergy.Caption:= worker.sd.TotalEnergy + ' KWh';
      Form1.STCurrentPower.Caption := worker.sd.CurrentPower + ' KW';
      Form1.STCOReduction.Caption:= worker.sd.CO2Reduction + ' Ton';
}

      Form1.STTodayEnergy.Caption:= worker.sd.TodayEnergy + ' ԿՎտ֊Ժ';
      Form1.STTotalEnergy.Caption:= worker.sd.TotalEnergy + ' ԿՎտ֊Ժ';
      Form1.STCurrentPower.Caption := worker.sd.CurrentPower + ' ԿՎտ';
      Form1.STCOReduction.Caption:= worker.sd.CO2Reduction + ' Տոննա';

      td:= Now;
      tdstr := DateTimeToStr(td);
      tddlm := ['-', ' ', ':'];
      tdday := strutils.ExtractWord(1, tdstr, tddlm);
      tdmonth := strutils.ExtractWord(2, tdstr, tddlm);
      tdyear := strutils.ExtractWord(3, tdstr, tddlm);
{
      monthname[1] := 'January';
      monthname[2] := 'February';
      monthname[3] := 'March';
      monthname[4] := 'April';
      monthname[5] := 'May';
      monthname[6] := 'June';
      monthname[7] := 'July';
      monthname[8] := 'August';
      monthname[9] := 'September';
      monthname[10] := 'October';
      monthname[11] := 'November';
      monthname[12] := 'December';
}
      monthname[1] := 'Յունւար';
      monthname[2] := 'Փետրւար';
      monthname[3] := 'Մարտ';
      monthname[4] := 'Ապրիլ';
      monthname[5] := 'Մայիս';
      monthname[6] := 'Յունիս';
      monthname[7] := 'Յուլիս';
      monthname[8] := 'Օգոստոս';
      monthname[9] := 'Սեպտեմբեր';
      monthname[10] := 'Հոկտեմբեր';
      monthname[11] := 'Նոյեմբեր';
      monthname[12] := 'Դեկտեմբեր';


      tdmonthnum := StrToInt(tdmonth);
      almonth := monthname[tdmonthnum];

      Form1.StaticText5.Caption := tdday + '  ' + almonth + ',  20' + tdyear;


      Form1.drawChart;

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
   r : TWaitResult;
begin
  if MyThread <> nil then begin
    // if MyThread.Terminated <> true then begin
        StatusBar1.SimpleText:='Terminating threads';
        Application.ProcessMessages;
        MyThread.Terminate;


     waitEvent.SetEvent;
    { repeat

     until MyThread.Terminated;
     }

     MyThread.WaitFor;
     // repeat
      //  r := stopEvent.WaitFor(infinite);
    // until r = TWaitResult.wrSignaled;
     //sleep(2000);
  //   end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  inherited;


  //TodayEnergy.Picture.LoadFromFile('images/robotik.png');
  //TotalEnergy.Picture.LoadFromFile('images/robotik.png');
  //CurrentPower.Picture.LoadFromFile('images/gauge.png');
  //CO2Reduction.Picture.LoadFromFile('images/co2.png');


    MyScaleXMarks:=TDateTimeIntervalChartSource.Create(Self);
  MyScaleXMarks2:=TDateTimeIntervalChartSource.Create(Self);
  //MyScaleXMarks.Params.Count:=5;
  //MyScaleXMarks.Params.Options:=[aipUseCount,aipUseNiceSteps];
  //MyScaleXMarks.Steps:=[dtsHour,dtsMinute,dtsSecond,dtsMillisecond];
  MyScaleXMarks.Steps:=[{dtsDay,} dtsHour];
  MyScaleXMarks2.Steps:=[dtsDay];
   //MyScaleXMarks.Params
  MyScaleXMarks.DateTimeFormat:='hh';
  MyScaleXMarks2.DateTimeFormat:='dd';
  // MyScaleXMarks.DateTimeFormat:='dd/hh';
  //Form1.Chart1.BottomAxis.Marks.Format:='%2:h';

  MySeries:=TAreaSeries.Create (Form1.Chart1);
  //MySeries.AreaBrush.Color:= clBlue;
  MySeries.AreaContourPen.Color:= $004DD612;
  MySeries.SeriesColor:=$004DD612;
  MySeries.AreaLinesPen.Style:= TFPPenStyle.psClear;

  //MySeries2:=TAreaSeries.Create (Form1.Chart1);
  MySeries2:=TBarSeries.Create (Form1.Chart1);
  //MySeries.AreaBrush.Color:= clBlue;

  MySeries2.BarPen.Style := TFPPenStyle.psClear;
  MySeries2.BarPen.Color:=$002424FC;
  //MySeries2.BarContourPen.Color:= $002424FC;
  MySeries2.SeriesColor:=$002424FC;
  //MySeries2.BarLinesPen.Style:= TFPPenStyle.psClear;

  Form1.Chart1.BottomAxis.Marks.Source:=MyScaleXMarks;
  Form1.Chart1.BottomAxis.Marks.Style:=TSeriesMarksStyle.smsLabel;
  Form1.Chart1.AddSeries(MySeries);
  Form1.Chart1.Extent.UseYMin := true; // for zero
  Form1.Chart1.Extent.YMin := 0;
  Form1.Chart1.Margins.Top := 23;
  Form1.Chart1.Margins.Left := 0;
  Form1.Chart1.Margins.Bottom := 0;

  Form1.Chart2.BottomAxis.Marks.Source:=MyScaleXMarks2;
  Form1.Chart2.BottomAxis.Marks.Style:=TSeriesMarksStyle.smsLabel;
  Form1.Chart2.AddSeries(MySeries2);
  Form1.Chart2.Extent.UseYMin := true; // for zero
  Form1.Chart2.Extent.YMin := 0;
  Form1.Chart2.Extent.UseXMin := False; // for zero
  Form1.Chart2.Extent.XMin := 1;
//  Form1.Chart2.Extent.Visible:=False;
  Form1.Chart2.Margins.Top := 23;
  Form1.Chart2.Margins.Left := 0;
  Form1.Chart2.Margins.Bottom := 0;

  Form1.Chart1.BackColor:= $00C5E0EA;
  Form1.Chart2.BackColor:= $00C5E0EA;

  Chart2.Left:= Chart1.Left;
  Chart2.Top:= Chart1.Top;
  Chart2.Width:= Chart1.Width;
  Chart2.Height:= Chart1.Height;
  Chart2.Visible:= false;
  Chart1.BringToFront;

  //Form1.Label1.Font.Color:=$00808000;

{
  Form1.StaticText1.Caption:='Today Energy';
  Form1.StaticText2.Caption:='Total Energy';
  Form1.StaticText3.Caption:='Current Power';
  Form1.StaticText4.Caption:='CO₂ Reduction';
}

  Form1.StaticText1.Caption:='Օրւայ Եռանդուժ';
  Form1.StaticText2.Caption:='Ընդհանուր Եռանդուժ';
  Form1.StaticText3.Caption:='Ընթացիկ Հզօրութիւն';
  Form1.StaticText4.Caption:='Ածխաթթւի Կրճատում';


  StatusBar1.SimpleText:= strconstants.statusBegin;


    waitEvent:= TEvent.Create(nil, false, false, 'startEvent');

     {    if (StatusBar1.SimpleText = worker.statusDataReady) or
              (StatusBar1.SimpleText = worker.statusBegin) then
          begin
             MyThread := worker.TMyThread.Create(true);
             MyThread.OnShowStatus:= @ShowStatus;
             MyThread.Resume;
          end;
      }
      MyThread := worker.TMyThread.Create(true);

         Timer1.Interval := 30000;
         Timer1.Enabled:= false;
         inProcess := true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //MyThread.Terminate;
  //DeleteCriticalSection(MyCriticalSection);
  waitEvent.Free;
  inherited;

end;



end.

