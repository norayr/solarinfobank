uses strutils;


var str, str1 : string;
dlm : set of char;
begin

str := '                <p class="word1">Today Energy</p>';
str1 := '                <p class="word2" id="displaytotaldayenergy">20.7<span>kWh</span>';
dlm := ['<', '>'];
//WriteLn(strutils.ExtractWord(5, str, strutils.StdWordDelims));
WriteLn(strutils.ExtractWord(3, str, dlm));
WriteLn(strutils.ExtractWord(3, str1, dlm));

end.
