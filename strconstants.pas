unit strconstants;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
const statusDataReady = 'data is ready';
      statusBegin = 'application initialized';
      outfile = '/tmp/solarinfo.txt';
      //not necessary anymore
      //outcsvfile = '/tmp/solarinfo.csv';
      outjsonfile = '/tmp/solarinfo.json';
      outmjsonfile = '/tmp/solarinfom.json';

      username = 'noch0@freenet.am';
      password = 'password';
      farm = '3096'   ;
      waittime = 1800000; // 30 minutes in milliseconds
implementation

end.

