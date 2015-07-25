unit extractor;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

type SolarData = record
   TodayEnergy : string;
   TotalEnergy : string;
   CurrentPower: string;
   CO2Reduction: string
   end;

   solarinfodata = record
      date : TDateTime;
      kw    : real{extended}
      end;

   chartdata = array of solarinfodata;

procedure ExtractData(source : String; var sd: SolarData);
procedure ExtractCSVData(source: string; var data: chartdata);
procedure ExtractJsonData(AFileName: string; var chd: chartdata);

implementation
uses Dialogs, strutils, fpjson, jsonparser;

procedure ExtractData(source : String; var sd: SolarData);
var
   f : TextFile;
   str: String;
   dlm : set of char;
begin
     dlm := ['<', '>'];

  Assign(f, source);
  reset(f);
  while not Eof(f) do
  begin
    readln(f, str);
    if  strutils.ExtractWord(3, str, dlm) =  'Today Energy' then
    begin
      readln(f, str);
       sd.TodayEnergy := strutils.ExtractWord(3, str, dlm);
    end;

    if  strutils.ExtractWord(3, str, dlm) =  'Total Energy' then
    begin
      readln(f, str);
       sd.TotalEnergy := strutils.ExtractWord(3, str, dlm);
    end;

    if  strutils.ExtractWord(3, str, dlm) =  'Current Power' then
    begin
      readln(f, str);
       sd.CurrentPower := strutils.ExtractWord(3, str, dlm);
    end;

    if  strutils.ExtractWord(3, str, dlm) =  'CO₂ Reduction' then
    begin
      readln(f, str);
       sd.CO2Reduction := strutils.ExtractWord(3, str, dlm);
    end;
  end;
  close(f);
end;



procedure ExtractJsonData(AFileName: string; var chd: chartdata);
var
  J0, J1, J2, J3: TJSONData;
  Parser: TJSONParser;
  Stream: TFileStream;
  i,j, k : integer;
  str : string;
  dlm : set of char;
  hh,mm,dd: string;
begin

  Stream := TFileStream.Create(AFileName, fmOpenRead);
  Parser := TJSONParser.Create(Stream);
  J0 := Parser.Parse;
  Stream.Free;
  Parser.Free;

  J1 := J0.GetPath('series');
  J2 :=J1.Items[0];
  J3 := J2.GetPath('data');
  k := J0.FindPath('categories').Count;
  setlength(chd, k+2);

  i := 0; j := 0;
  repeat
     str := J0.FindPath('categories').Items[i].AsString;
     dlm := ['/', ',', ':'];
     hh := strutils.ExtractWord(1, str, dlm);
     mm := strutils.ExtractWord(2, str, dlm);
     dd :=strutils.ExtractWord(3, str, dlm);


     if dd <> '00' then
     begin

        chd[j].date := StrToDateTime(dd + ' ' + hh + ':' + mm);
        if j3.Items[i].IsNull then
        begin
          //Memo1.Lines.Add('null');
          chd[j].kw:= 0.0;
        end
       else
        begin
           //Memo1.Lines.Add(J3.Items[i].AsString);
           chd[j].kw:= J3.Items[i].AsFloat;
        end;
        inc(j);
     end;
     inc(i);
     //with this i have confirmed that json indeed sometimes contains '00' as day
     //if i > j then begin ShowMessage('i=' + IntToStr(i) + ' j=' + IntToStr(j) + ' dd=' + dd + 'hh=' + hh + ' mm=' + mm  ) end;
  until i = k;
  setlength(chd, j);
 end;

procedure ExtractCSVData(source: string; var data: chartdata);
var
   f : TextFile;
   str: String;
   dlm : set of char;
   hh,mm,dd: string;
   kw: string;
   i : integer;

begin
   assign (f, source);
   reset(f);
   i := 0;
   repeat
      readln(f, str);
      inc(i);
   until eof(f);

   setlength(data, i); //not i + 1 because we'll ignore the first line

   i := 0;

   reset(f);
   readln(f, str);
   repeat
      readln(f, str);
      dlm := ['/', ',', ':'];
      hh := strutils.ExtractWord(1, str, dlm);
      mm := strutils.ExtractWord(2, str, dlm);
      dd :=strutils.ExtractWord(3, str, dlm);

      kw :=strutils.ExtractWord(4, str, dlm);
      if dd <> '00' then //sometimes file contains 00:00/00 string which cannot be converted to datetime
      begin
         data[i].date:= StrToDateTime(dd + ' ' + hh + ':' + mm);
         if (kw = '') or (kw = 'None') then
         begin
            data[i].kw:= 0.0
         end
        else
         begin
            data[i].kw:= StrToFloat(kw)
         end;
      inc(i)
      end;
   until eof(f);
   setlength(data, i);
   close(f);
end;

end.

