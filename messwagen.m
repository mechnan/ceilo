  
function messwagen = messwagen(fid)
% -- Daten einlesen -----------------------------------------------------

% Initialisiere die Daten
messwagen.O3       = [];
messwagen.SO2      = [];
messwagen.CO       = [];
messwagen.NO       = [];
messwagen.NOX      = [];
messwagen.NO2      = [];
messwagen.Staub    = [];
messwagen.ITemp    = [];
messwagen.PM10     = [];
messwagen.WR       = [];
messwagen.Wges     = [];
messwagen.Temp     = [];
messwagen.Humid    = [];
messwagen.Irrad    = [];
messwagen.year     = []; 
messwagen.month    = [];
messwagen.day      = [];
messwagen.hour     = [];
messwagen.min      = [];
messwagen.sec      = [];

% Dateiname erstellen



% Daten einlesen - zuerst Bestimmen, wieviele Kopfzeilen vorhanden sind
c_hl = textscan(fid,'%d',1);
frewind(fid);
c = textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Headerlines',c_hl{1});
fclose(fid);

% Speichere alle Daten in einer Matlab-Struktur
messwagen.O3    = [ messwagen.O3;    c{ 2} ];
messwagen.SO2   = [ messwagen.SO2;   c{ 3} ];
messwagen.CO    = [ messwagen.CO;    c{ 4} ];
messwagen.NO    = [ messwagen.NO;    c{ 5} ];
messwagen.NOX   = [ messwagen.NOX;   c{ 6} ];
messwagen.NO2   = [ messwagen.NO2;   c{ 7} ];
messwagen.Staub = [ messwagen.Staub; c{ 8} ];
messwagen.ITemp = [ messwagen.ITemp; c{ 9} ];
messwagen.PM10  = [ messwagen.PM10;  c{10} ];
messwagen.WR    = [ messwagen.WR;    c{11} ];
messwagen.Wges  = [ messwagen.Wges;  c{12} ];
messwagen.Temp  = [ messwagen.Temp;  c{13} ];
messwagen.Humid = [ messwagen.Humid; c{14} ];
messwagen.Irrad = [ messwagen.Irrad; c{15} ];

% Extrahiere das Datum aus der ersten Spalte
datestring    = char ( c{1} );
messwagen.year  = [ messwagen.year;  str2num( datestring(:,1:4)  ) ];
messwagen.month = [ messwagen.month; str2num( datestring(:,5:6)  ) ];
messwagen.day   = [ messwagen.day;   str2num( datestring(:,7:8)  ) ];
messwagen.hour  = [ messwagen.hour;  str2num( datestring(:,9:10) ) ];
messwagen.min   = [ messwagen.min;   str2num( datestring(:,11:12)) ];
messwagen.sec   = [ messwagen.sec;   str2num( datestring(:,13:14)) ];


% Setze das 'serial date time' für jede Messung
messwagen.time = datenum(messwagen.year,messwagen.month,messwagen.day,messwagen.hour,messwagen.min,messwagen.sec);
end