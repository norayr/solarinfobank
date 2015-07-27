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

      username = 'username@freenet.am';
      password = 'password';
      waittime = 1800000; // 30 minutes in milliseconds

implementation

end.

