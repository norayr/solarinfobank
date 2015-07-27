unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, syncobjs, worker;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
    Chart2: TChart;
    CurrentPower: TImage;
    CO2Reduction: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    STCOReduction: TStaticText;
    STTodayEnergy: TStaticText;
    STTotalEnergy: TStaticText;
    STCurrentPower: TStaticText;
    Timer1: TTimer;
    TotalEnergy: TImage;
    TodayEnergy: TImage;
    StatusBar1: TStatusBar;



    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure drawChart;
    procedure updateData;
    procedure Timer1Timer(Sender: TObject);



  private
    { private declarations }


  public
    { public declarations }
        MyThread: worker.TMyThread;
        startEvent, stopEvent: TEvent;


  end;

var
  Form1: TForm1;

  //MyCriticalSection: TRTLCriticalSection;

implementation
   uses  TAIntervalSources{for TDateTimeIntervalChartSource}, TAChartUtils{for smsLable}, FPCanvas{for psClear}, extractor, strconstants;
{$R *.lfm}
   var inProcess : boolean;
    { TForm1 }
       MySeries, MySeries2: TAreaSeries;
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

  //moment : double;
begin

//  extractor.ExtractCSVData(worker.outcsvfile, data);
    inProcess := true;
    extractor.ExtractJsonData(outjsonfile, data) ;
    extractor.ExtractJsonData(outmjsonfile, datam) ;

    for i := 0 to high(data) do
      begin
   // MySeries.AddXY(i/(3600*24),5*sin(i/100));

     //MySeries.AddXY(StrToDateTime(dd + ' ' + hh + ':' + mm),StrToFloat(kw));
     MySeries.AddXY(data[i].date, data[i].kw);
        // moment := now;
        // MySeries.AddXY(moment, data[i].kw);

      end;

  for i := 0 to high(datam) do
      begin
       MySeries2.AddXY(datam[i].date, datam[i].kw);
      end;
     inProcess := false;
  setlength(data, 0);
  setlength(datam, 0);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (inProcess = false) and (StatusBar1.SimpleText = strconstants.statusDataReady) then
   begin
      if Chart1.Visible then
       begin
          Chart1.Visible:= false;
          Chart2.Visible:= true;
          Chart2.BringToFront;
       end
      else
       begin
           Chart1.Visible:= true;
           Chart2.Visible:= false;
           Chart1.BringToFront;
       end;
   end;
end;

procedure TForm1.updateData;
begin
      Form1.STTodayEnergy.Caption:= worker.sd.TodayEnergy + ' kWh';
      Form1.STTotalEnergy.Caption:= worker.sd.TotalEnergy + ' kWh';
      Form1.STCurrentPower.Caption := worker.sd.CurrentPower + ' kW';
      Form1.STCOReduction.Caption:= worker.sd.CO2Reduction + ' t';

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


     startEvent.SetEvent;
    { repeat

     until MyThread.Terminated;
     }
    // repeat
        r := stopEvent.WaitFor(infinite);
    // until r = TWaitResult.wrSignaled;
     //sleep(2000);
  //   end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  inherited;


  TodayEnergy.Picture.LoadFromFile('images/robotik.png');
  TotalEnergy.Picture.LoadFromFile('images/robotik.png');
  CurrentPower.Picture.LoadFromFile('images/gauge.png');
  CO2Reduction.Picture.LoadFromFile('images/co2.png');


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
  MySeries.AreaContourPen.Color:= clRed;
  MySeries.SeriesColor:=clYellow;
  MySeries.AreaLinesPen.Style:= TFPPenStyle.psClear;

  MySeries2:=TAreaSeries.Create (Form1.Chart1);
  //MySeries.AreaBrush.Color:= clBlue;
  MySeries2.AreaContourPen.Color:= clRed;
  MySeries2.SeriesColor:=clYellow;
  MySeries2.AreaLinesPen.Style:= TFPPenStyle.psClear;

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
  Form1.Chart2.Margins.Top := 23;
  Form1.Chart2.Margins.Left := 0;
  Form1.Chart2.Margins.Bottom := 0;

  Form1.Chart1.BackColor:= clWhite;
  Form1.Chart2.BackColor:= clWhite;

  Chart2.Left:= Chart1.Left;
  Chart2.Top:= Chart1.Top;
  Chart2.Width:= Chart1.Width;
  Chart2.Height:= Chart1.Height;
  Chart2.Visible:= false;
  Chart1.BringToFront;


  StatusBar1.SimpleText:= strconstants.statusBegin;

    Button1.Visible:= false; //following is moved from click code


    startEvent:= TEvent.Create(nil, false, false, 'startEvent');
    stopEvent:= TEvent.Create(nil, false, false, 'stopEvent');

     {    if (StatusBar1.SimpleText = worker.statusDataReady) or
              (StatusBar1.SimpleText = worker.statusBegin) then
          begin
             MyThread := worker.TMyThread.Create(true);
             MyThread.OnShowStatus:= @ShowStatus;
             MyThread.Resume;
          end;
      }
      MyThread := worker.TMyThread.Create(false);

      startEvent.SetEvent; //run thread

         Timer1.Interval := 10000;
         Timer1.Enabled:= false;
         inProcess := true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //MyThread.Terminate;
  //DeleteCriticalSection(MyCriticalSection);
  startEvent.Free;
  stopEvent.Free;
  inherited;

end;



end.

