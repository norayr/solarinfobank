unit requestor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, httpsend;

var
   HTTP: httpsend.THTTPSend;
   Cookies: TStrings;


procedure Init;
procedure UnInit;
procedure Work(ALocation: String; outfile: String);
procedure DoMoved;
procedure SendRequest(ALocation: String);
procedure SendPostRequest(ALocation, postData: String);
procedure SendLoginPassword(ALocation, loginContent: String);
function HTTPEncode(const AStr: String): String;

implementation

function HTTPEncode(const AStr: String): String;
const
  HTTPAllowed = ['A'..'Z','a'..'z',
                 '*','@','.','_','-',
                 '0'..'9',
                 '$','!','''','(',')'];

var
  SS, S, R: PChar;
  H: String[2];
  L: Integer;
begin
  L:= Length(AStr);
  SetLength(Result, L*3); // Worst case scenario
  if (L = 0) then
    exit;
  R:= PChar(Result);
  S:= PChar(AStr);
  SS:= S; // Avoid #0 limit !!
  while ((S - SS) < L) do
  begin
    if S^ in HTTPAllowed then
      R^:=S^
    else if (S^=' ') then
      R^:='+'
    else begin
      R^:= '%';
      H:= HexStr(Ord(S^), 2);
      Inc(R);
      R^:= H[1];
      Inc(R);
      R^:= H[2];
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;

procedure SendLoginPassword(ALocation, loginContent: String);
var
  S: TStringStream;
begin
  WriteLn('POST ' + ALocation);
  HTTP.Clear;
  HTTP.MimeType:= 'application/x-www-form-urlencoded';
  HTTP.Cookies.Assign(Cookies);
  S:= TStringStream.Create(loginContent);
  try
    try
      HTTP.Document.LoadFromStream(S);
    except
      raise;
    end;
  finally
    S.Free;
  end;
  HTTP.HTTPMethod('POST', ALocation);
  Cookies.Assign(HTTP.Cookies);
  WriteLn(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
end;


procedure SendRequest(ALocation: String);
begin
  WriteLn('GET ' + ALocation);
  HTTP.Clear;
  HTTP.Cookies.Assign(Cookies);
  HTTP.HTTPMethod('GET', ALocation);
  Cookies.Assign(HTTP.Cookies);
  WriteLn(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
end;


procedure SendPostRequest(ALocation, postData: String);
var
   S : TStringStream;
begin
  S := TStringStream.Create(postData);
  WriteLn('POST ' + ALocation);
  HTTP.Clear;
  HTTP.MimeType:= 'application/x-www-form-urlencoded';
  HTTP.Cookies.Assign(Cookies);
  HTTP.Document.LoadFromStream(S);
  HTTP.HTTPMethod('POST', ALocation);
  Cookies.Assign(HTTP.Cookies);
  WriteLn(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
end;

function ReadSection(AStrings: TStrings; ASection: String): String;
var
  i: integer;
  p: integer;
begin
  Result:= EmptyStr;
  for i:= 0 to AStrings.Count - 1 do
  begin
    p:= Pos(ASection, UpperCase(AStrings[i]));
    if p > 0 then
    begin
      Result:= Trim(Copy(AStrings[i], p + Length(ASection), Length(AStrings[i]) - p - Length(ASection) + 1));
      Break;
    end;
  end;
end;


procedure DoMoved;
var
  NextLocation: String;
begin
  NextLocation:= ReadSection(HTTP.Headers, 'LOCATION:');
  if (NextLocation <> EmptyStr) then
  begin
    WriteLn('moved');
    WriteLn('GET ' + NextLocation);
    HTTP.Clear;
    HTTP.MimeType:= 'text/html';
    HTTP.Cookies.Assign(Cookies);
    HTTP.HTTPMethod('GET', NextLocation);
    Cookies.Assign(HTTP.Cookies);
    WriteLn(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
  end;
end;


procedure Init;
begin
HTTP:= THTTPSend.Create;
HTTP.UserAgent:= 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:14.0) Gecko/20100101 Firefox/14.0.1';
Cookies:= TStringList.Create;

end;

procedure UnInit;
begin

HTTP.Free;
end;

procedure Work(ALocation: String; outfile: String);
  var Location: String;
begin
 {  SendRequest(ALocation);

   while (HTTP.ResultCode = 301) or (HTTP.ResultCode = 302) do
   begin
        DoMoved;
   end;

   WriteLn('Sending Login and Password...');
   Location:= 'http://solarinfobank.com/home/index';
   SendLoginPassword(Location);

      while (HTTP.ResultCode = 301) or (HTTP.ResultCode = 302) do
      begin
        DoMoved;
      end;

      WriteLn('getting farm info...');
      Location := 'http://solarinfobank.com/plant/includeoverview/3096';

      SendRequest(Location);
      HTTP.Document.SaveToFile(outfile);

      SendPostRequest('http://solarinfobank.com/DataExport/ExportChart', 'filename=20150722AGBU-Yerevan&type=text%2Fcsv&width=800&svg=&serieNo=23035042155');
      HTTP.Document.SaveToFile('/tmp/artin.csv');
      }
end; //Work
end.

