unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, worker;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
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
    TotalEnergy: TImage;
    TodayEnergy: TImage;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure drawChart;

  private
    { private declarations }

    procedure ShowStatus(Status: string);
  public
    { public declarations }
        MyThread: worker.TMyThread;
  end;

var
  Form1: TForm1;

  //MyCriticalSection: TRTLCriticalSection;

implementation
   uses  TAIntervalSources{for TDateTimeIntervalChartSource}, TAChartUtils{for smsLable}, FPCanvas{for psClear}, extractor;
{$R *.lfm}

    { TForm1 }

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
  MySeries: TAreaSeries;
  MyScaleXMarks: TDateTimeIntervalChartSource;

  i : integer;
  data : extractor.chartdata;

  //moment : double;
begin
  MyScaleXMarks:=TDateTimeIntervalChartSource.Create(Self);
  //MyScaleXMarks.Params.Count:=5;
  //MyScaleXMarks.Params.Options:=[aipUseCount,aipUseNiceSteps];
  //MyScaleXMarks.Steps:=[dtsHour,dtsMinute,dtsSecond,dtsMillisecond];
  MyScaleXMarks.Steps:=[{dtsDay,} dtsHour];
   //MyScaleXMarks.Params
  MyScaleXMarks.DateTimeFormat:='hh';
   // MyScaleXMarks.DateTimeFormat:='dd/hh';
  //Form1.Chart1.BottomAxis.Marks.Format:='%2:h';
  Form1.Chart1.BottomAxis.Marks.Source:=MyScaleXMarks;
  Form1.Chart1.BottomAxis.Marks.Style:=TSeriesMarksStyle.smsLabel;
  MySeries:=TAreaSeries.Create (Form1.Chart1);
  //MySeries.AreaBrush.Color:= clBlue;
  MySeries.AreaContourPen.Color:= clRed;
  MySeries.SeriesColor:=clYellow;
  MySeries.AreaLinesPen.Style:= TFPPenStyle.psClear;

  Form1.Chart1.AddSeries(MySeries);
  Form1.Chart1.Extent.UseYMin := true; // for zero
  Form1.Chart1.Extent.YMin := 0;
  Form1.Chart1.Margins.Left := 0;
  Form1.Chart1.Margins.Bottom := 0;

//  extractor.ExtractCSVData(worker.outcsvfile, data);
    extractor.ExtractJsonData(outjsonfile, data) ;
  for i := 0 to high(data) do
      begin
   // MySeries.AddXY(i/(3600*24),5*sin(i/100));

     //MySeries.AddXY(StrToDateTime(dd + ' ' + hh + ':' + mm),StrToFloat(kw));
       MySeries.AddXY(data[i].date, data[i].kw);
        // moment := now;
        // MySeries.AddXY(moment, data[i].kw);

      end;

  setlength(data, 0);

end;

procedure updateData;
begin
      Form1.STTodayEnergy.Caption:= worker.sd.TodayEnergy + ' kWh';
      Form1.STTotalEnergy.Caption:= worker.sd.TotalEnergy + ' kWh';
      Form1.STCurrentPower.Caption := worker.sd.CurrentPower + ' kW';
      Form1.STCOReduction.Caption:= worker.sd.CO2Reduction + ' t';

      Form1.drawChart;

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if MyThread <> nil then begin
     if MyThread.Terminated <> true then begin
     StatusBar1.SimpleText:='Terminating threads';
     Application.ProcessMessages;
     MyThread.Terminate;



     repeat

     until MyThread.Terminated;
     sleep(2000);
     end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  inherited;


  TodayEnergy.Picture.LoadFromFile('images/robotik.png');
  TotalEnergy.Picture.LoadFromFile('images/robotik.png');
  CurrentPower.Picture.LoadFromFile('images/gauge.png');
  CO2Reduction.Picture.LoadFromFile('images/co2.png');

   Form1.Chart1.BackColor:= clWhite;
//   Form1.Chart1.Color:=;

  StatusBar1.SimpleText:= worker.statusBegin;

    Button1.Visible:= false; //following is moved from click code

         if (StatusBar1.SimpleText = worker.statusDataReady) or
              (StatusBar1.SimpleText = worker.statusBegin) then
          begin
             MyThread := worker.TMyThread.Create(true);
             MyThread.OnShowStatus:= @ShowStatus;
             MyThread.Resume;
          end;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //MyThread.Terminate;
  //DeleteCriticalSection(MyCriticalSection);
  inherited;
end;

procedure TForm1.ShowStatus(Status: string);
begin
      StatusBar1.SimpleText:= Status;
      if Status = worker.statusDataReady then begin updateData end;
end;




end.

