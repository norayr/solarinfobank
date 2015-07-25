uses sysutils;

Procedure TestStr (S : String);

begin
  Writeln (S,' : ',DateTimeToStr(StrToDateTime(S)));
end;

Begin

  Writeln ('ShortDateFormat ',ShortDateFormat);
  TestStr(DateTimeToStr(Now));
  TestStr('05-05-1999 15:50');
  TestStr('5-5 13:30');
  TestStr('5 1:30PM');
  TestStr('23 22:15');
End.
