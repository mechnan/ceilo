% -----------------------------------------------------------------------
% read_GRONO_from_data
% Remo Sigg
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


%% test plot 2m temperature 

figure;


% whole time period
subplot(3,1,1)
plot(datetime(data.time,'ConvertFrom','datenum'),data.T91,'-r');
ylabel('2m Lufttemperatur (\circ C)');
title('Gesamte Zeitperiode der Daten (GRONO)')

% February until end of data - with daily mean

% set averaging area
startdate = datenum(2018,2,1,0,0,0);
enddate   = datenum(2018,3,4,23,50,0);
index_start=find(data.time==startdate);
index_end=find(data.time==enddate);

subplot(3,1,2)
plot(datetime(data.time(index_start:index_end),'ConvertFrom','datenum'),data.T91(index_start:index_end),'-','Color',[0.6 0.6 0.6]);
ylabel('2m Lufttemperatur (\circ C)');
set(gca,'XLim',[datetime(startdate,'ConvertFrom','datenum') datetime(enddate,'ConvertFrom','datenum')]);


% initialize daily mean 
hdat = [];
hvel = []; 

% calculate daily mean
for dat=startdate:24/24:enddate

  % store date
  hdat = [ hdat; dat+0.5/24 ];
  
  % index for daily mean 
  mask_periode = ( data.time>=dat ) & ( data.time<(dat+24/24) ) ;
  
  % index for true data values
  mask_finite = isfinite(data.T91);
  
  % index for "NaN" values
  mask_meaningful = data.T91 ~= 32767;

  mask_ok = mask_periode & mask_finite & mask_meaningful;
  
  % mean value temperature
  hvel = [ hvel; mean( data.T91(mask_ok) )];

end

% overlay daily mean
hold on
plot(datetime(hdat,'ConvertFrom','datenum'),hvel,'k-');
hold off

legend('Messung alle 10 min','Tagesmittel')
title('Daten ab Februar 2018 (GRONO)')

% 2m temperature on a day

% choose day
day = 4;
month = 3;
year = 2018;

% set averaging area
start_day = datenum(year,month,day,0,0,0);
end_day   = datenum(year,month,day,23,50,0);
index_start_day=find(data.time==start_day);
index_end_day=find(data.time==end_day);

subplot(3,1,3)
plot(datetime(data.time(index_start_day:index_end_day),'ConvertFrom','datenum'),data.T91(index_start_day:index_end_day),'r-');
ylabel('2m Lufttemperatur (\circ C)');
set(gca,'XLim',[datetime(start_day,'ConvertFrom','datenum') datetime(end_day,'ConvertFrom','datenum')]);
title('Tagesverlauf (GRONO)')



