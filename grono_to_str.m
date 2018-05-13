function data = grono_to_str()

% -----------------------------------------------------------------------
% addapded from read_GRONO_from_data by killian brennan
% original by Remo Sigg
% FS2018
% -----------------------------------------------------------------------

% clear workspace and command window
clear;
%clc

% -- read data -----------------------------------------------------

% initialize the data (# 19 (25) Parameter)
data.STA    = []; % Stationsnummer
data.year   = []; % Jahr
data.month  = []; % Monat
data.day    = []; % Tag
data.hour   = []; % Stunde
data.min    = []; % Minute
data.T91    = []; % 91 Lufttemperatur 2 m �ber Boden; Momentanwert [�C]
data.T727   = []; % 727 Lufttemperatur 2 m �ber Boden; Halbtagesmaximum [�C]
data.T728   = []; % 728 Lufttemperatur 2 m �ber Boden; Halbtagesminimum [�C]
data.P90    = []; % 90  Luftdruck auf Stationsh�he (QFE); Momentanwert [hPa]
data.U101   = []; % 101 B�enspitze (Sekundenb�e); Maximum [m/s]
data.N93    = []; % 93 Niederschlag; Zehnminutensumme [mm]
data.N1022  = []; % 1022 Niederschlag; gleitende Stundensumme (�ber 6 Zehnminutenintervalle) [mm]
data.N1872  = []; % 1872 Niederschlagsdauer; Zehnminutensumme [min]
data.B99    = []; % 99 Nahblitze (Entfernung weniger als 3 km); Zehnminutensumme [No]
data.B100   = []; % 100 Fernblitze (Entfernung 3 - 30 km); Zehnminutensumme [No]
data.S94    = []; % 94 Sonnenscheindauer; Zehnminutensumme [min]
data.S197   = []; % 197 Windrichtung [°]
data.U196   = []; % 196 Windgeschwindigkeit skalar; Zehnminutenmittel [m/s]
data.P968   = []; % 968 Luftdruck reduziert auf Meeresniveau (QFF); Momentanwert [hPa]
data.P967   = []; % 967 Luftdruck reduziert auf Meeresniveau mit Standardatmosph�re (QNH); Momentanwert [hPa]
data.S96    = []; % 96 Globalstrahlung; Zehnminutenmittel [W/m]
data.T92    = []; % 92 Lufttemperatur 5 cm �ber Gras; Momentanwert [�C]
data.TP194  = []; % 194 Taupunkt 2 m �ber Boden; Momentanwert [�C]
data.S97    = []; % 97 Helligkeit; Momentanwert [mV]

% path to data
filepath = pwd;
filename = [filepath '/' 'GRONO_SWISSMETNET_all.dat'];

disp(filename);

% read data - first determining headerlines
fid = fopen(filename);
frewind(fid);
c = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ','Headerlines',27);
fclose(fid);

% store all data in Matlab structure
data.STA    = [data.STA;   c{ 1}];
data.year   = [data.year;  c{ 2}]; 
data.month  = [data.month; c{ 3}];
data.day    = [data.day;   c{ 4}]; 
data.hour   = [data.hour;  c{ 5}]; 
data.min    = [data.min;   c{ 6}]; 
data.T91    = [data.T91;   c{ 7}]; 
data.T727   = [data.T727;  c{ 8}]; 
data.T728   = [data.T728;  c{ 9}]; 
data.P90    = [data.P90;   c{10}]; 
data.U101   = [data.U101;  c{11}]; 
data.N93    = [data.N93;   c{12}]; 
data.N1022  = [data.N1022; c{13}]; 
data.N1872  = [data.N1872; c{14}]; 
data.B99    = [data.B99;   c{15}]; 
data.B100   = [data.B100;  c{16}]; 
data.S94    = [data.S94;   c{17}]; 
data.S197   = [data.S197;  c{18}]; 
data.U196   = [data.U196;  c{19}]; 
data.P968   = [data.P968;  c{20}]; 
data.P967   = [data.P967;  c{21}]; 
data.S96    = [data.S96;   c{22}]; 
data.T92    = [data.T92;   c{23}]; 
data.TP194  = [data.TP194; c{24}]; 
data.S97    = [data.S97;   c{25}]; 

% set 'serial date time' for each messurement
data.time = datenum(data.year,data.month,data.day,data.hour,data.min,0);

end