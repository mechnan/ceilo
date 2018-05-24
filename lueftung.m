%% Definieren einen Tag
clear all
clc

jahr = 2018;
monat = 03;
tag = 04;

%% Read all data 

% read Sonic Daten 

% Dateipfad
path='/Users/RemoSigg/polybox/ETH-ERDW/ERDW - 6.Semester/Praktikum Atmosphäre/Ceilometergruppe/CeilometerFS2018/data/Sonic';

% Zeitperiode
time_period = datenum(jahr,monat,tag,00,00,00):15/60/24:datenum(jahr,monat,tag+1,00,00,00);

% read sonic
sonic = read_sonic_run_from_files(time_period, path);

% read Messwagen 

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

% Pfad zu den Daten
filepath = '/Users/RemoSigg/polybox/ETH-ERDW/ERDW - 6.Semester/Praktikum Atmosphäre/Ceilometergruppe/CeilometerFS2018/data';
year = int2str(jahr);
month = int2str(monat);
day = int2str(tag);

if monat >= 0 && monat < 10
    if tag >= 0 && tag < 10
        filename= [filepath '/' 'Rov_ACRO400_' year '0' month '0' day '.dat'];
    else
        filename= [filepath '/' 'Rov_ACRO400_' year '0' month day '.dat'];
    end
else
    filename= [filepath '/' 'Rov_ACRO400_' year month day '.dat'];
end

disp(filename);

% Daten einlesen - zuerst Bestimmen, wieviele Kopfzeilen vorhanden sind
fid = fopen(filename);
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

% read Lueftungsdaten Vektor [Zeit, Ein oder Aus] alle 10min 

Startzeit1 = datenum(2018,03,01,00,05,00);
Endzeit1 = datenum(2018,03,25,01,55,00); 
% Verlorene Stunde beim Wechsel in die Sommerzeit
Startzeit2 = datenum(2018,03,25,03,05,00);
Endzeit2 = datenum(2018,03,31,23,55,00);

intervall1 = Startzeit1:1/(24*6):Endzeit1;
intervall2 = Startzeit2:1/(24*6):Endzeit2;
intervall = [intervall1 intervall2];
intervall = intervall.';

Lueftung = xlsread('Lueftungssystemdaten.xlsx','B3:B4460');
clear Endzeit1 Endzeit2 Startzeit1 Startzeit2 intervall1 intervall2
Lueftungsdaten = [intervall, Lueftung];

% Windkorrektur

windrichtung_sonic = mod(sonic(:,14)+135,360);
messwagen.WR = mod(messwagen.WR+180,360);
windgeschwindigkeit_sonic = sonic(:,8);

WindRose(windrichtung_sonic,windgeschwindigkeit_sonic,'anglenorth',0,'angleeast',90);
WindRose(messwagen.WR,messwagen.Wges,'anglenorth',0,'angleeast',90);


%% Plot Wind Sonic + Messwagen und Lueftungsdaten in Tageszeitreihen 

% Grenzen Zeitvektor 
Tagesbeginn = datenum(jahr,monat,tag,00,00,00);
Tagesende = datenum(jahr,monat,tag+1,00,00,00);

% Lueftungsdaten dieses Tages speichern
t1 = Tagesbeginn+1/(24*12);
t2 = Tagesende-1/(24*12);
i = find(Lueftungsdaten == t1);
j = find(Lueftungsdaten == t2);

daten = Lueftungsdaten(i:j,1:2);


figure;
subplot(3,1,3)
plot(datetime(daten(:,1),'ConvertFrom','datenum'),daten(:,2),'x')
ylim([-1 3])
yticks([-1 0 2 3])
yticklabels({'','Aus','Ein',''})
title('Status Lüftung alle 10min')
grid on
set(gca,'FontSize',14); 



% sonic Winddaten dieses Tages ploten
subplot(3,1,2)
[ax, h1, h2] = plotyy(datetime(sonic(:,1),'ConvertFrom','datenum'),windrichtung_sonic,datetime(sonic(:,1), ... 
    'ConvertFrom','datenum'),windgeschwindigkeit_sonic);
h1.Marker = '+';
ylabel(ax(1),'Windrichtung')
ylabel(ax(2),'Windgeschwindigkeit')
ylim(ax(1),[0 360])
ylim(ax(2),[0 4])
yticks(ax(1), [0 90 180 270 360])
yticks(ax(2), [0 1 2 3 4])
title('Sonic Winddaten (15min mittel)')
grid on
set(gca,'FontSize',14); 
set(ax(2),'FontSize',14); 


% 10 Minuten Mittel Messwagen berechnen
% Initialisiere 
date = [];
vel = []; 
wr = [];
time = [];

% 10 Minuten mittel berechnen
for dat=Tagesbeginn:1/(24*6):Tagesende-1/(24*6)
    % erster Wert 00:05 Uhr
    % letzter Wert 23:55 Uhr

  % Datum abspeichern
  date = [ date; dat+0.5/(24*6) ];
  
  % Index fuer Stundenperiode bestimmen
  mask_periode = ( messwagen.time>=dat(1) ) & ( messwagen.time<(dat(1)+1/(24*6)) ) ;
  % Index fuer korrekte Datenwerte
  mask_finite = isfinite(messwagen.Wges);

  % Mittelwert der Geschwindigkeit berechnen 
  vel = [ vel; mean( messwagen.Wges(mask_periode & mask_finite) )];
  
  % Mittlere Windrichtung berechnen
  wr = [ wr; mean( messwagen.WR(mask_periode & mask_finite) )];
  
end

% messwagen Winddaten dieses Tages ploten
subplot(3,1,1)
[axx, h11, h22] = plotyy(datetime(date,'ConvertFrom','datenum'),wr, ... 
   datetime(date,'ConvertFrom','datenum'),vel);
h11.Marker = '+';
ylabel(axx(1),'Windrichtung')
ylabel(axx(2),'Windgeschwindigkeit')
ylim(axx(1),[0 360])
ylim(axx(2),[0 4])
yticks(axx(1), [0 90 180 270 360])
yticks(axx(2), [0 1 2 3 4])
title('Messwagen Winddaten (10min mittel)')
grid on
set(gca,'FontSize',14); 
set(axx(2),'FontSize',14); 


%% Ueberpruefen ob Luft über Messwagen bzw. Sonic aus Luftschacht stammt 

comb = [date , daten(:,2) , vel , wr ];

% Winkelbereich bestimmen

range_start = 190;
range_end = 280;

% Kommt Luft von Luftschacht? (Messwagen)
dir = [];
for i=1:1:length(comb)
    if comb(i,2) == 2
        if comb(i,4)>=range_start && comb(i,4)<range_end
            dir = [ dir ; 1 ];
        else
            dir = [ dir ; 0 ];      
        end
    else
    dir = [ dir ; 0 ];    
    end
end


% Kommt Luft von Luftschacht? (Sonic)

% aus 15 min mittel 5 min mittel machen (konstante Werte über 15min)
sonic_vel = reshape(repmat(windgeschwindigkeit_sonic,1,3)',[],1);
sonic_wr = reshape(repmat(windrichtung_sonic,1,3)',[],1);
% begin 23:55 Uhr am Vortag
% Matrix auf 10 min skalieren
sonic_vel = sonic_vel(3:2:length(sonic_vel)-1);
sonic_wr = sonic_wr(3:2:length(sonic_wr)-1);
% erster Wert 00:05 Uhr (3), alle 10 min bis 23:55 Uhr (end-1)

sonic_dir = [];
for i=1:1:length(comb)
    if comb(i,2) == 2
        if sonic_wr(i)>=range_start && sonic_wr(i)<range_end
            sonic_dir = [ sonic_dir ; 1 ];
        else
            sonic_dir = [ sonic_dir ; 0 ];      
        end
    else
    sonic_dir = [ sonic_dir ; 0 ];    
    end
end

comb = [date , daten(:,2) , vel , wr , dir, sonic_wr , sonic_vel , sonic_dir  ];

figure;
subplot(3,1,1)
plot(datetime(comb(:,1),'ConvertFrom','datenum'),comb(:,2),'x')
ylim([-1 3])
yticks([-1 0 2 3])
yticklabels({'','Aus','Ein',''})
title('Status Lüftung (alle 10min)')
grid on
set(gca,'FontSize',14); 


subplot(3,1,2)
stairs(datetime(comb(:,1),'ConvertFrom','datenum'),comb(:,5),'-')
ylim([-1 2])
yticks([-1 0 1 2])
yticklabels({'','Nein','Ja',''})
title('Luft aus Luftschacht Richtung Roveredo Dorf (Messwagen)?')
grid on
set(gca,'FontSize',14); 


subplot(3,1,3)
title('Luft über Sonic aus Richtung Luftschacht?')
stairs(datetime(comb(:,1),'ConvertFrom','datenum'),comb(:,8),'-')
ylim([-1 2])
yticks([-1 0 1 2])
yticklabels({'','Nein','Ja',''})
title('Luft aus Luftschacht Richtung Roveredo Dorf (Sonic)?')
grid on
set(gca,'FontSize',14); 



% % nur Werte wenn Lüftung an ist
% comb_red = [];
% for i=1:1:length(comb)
%     k = find(comb(i,2)==2);
%     
%     if k == 1
%        m = i; % speichere Matrixzeilennummer  
%     end
%     
%     if m == i
%     comb_red = [comb_red ; comb(m,:)];
%     end
%     
% end


%% Luftqualitäts check

figure;
subplot(4,1,1)
plot(datetime(daten(:,1),'ConvertFrom','datenum'),daten(:,2),'x')
ylim([-1 3])
yticks([-1 0 2 3])
yticklabels({'','Aus','Ein',''})
title('Status Lüftung alle 10min')
grid on
set(gca,'FontSize',14); 

subplot(4,1,2)
stairs(datetime(comb(:,1),'ConvertFrom','datenum'),comb(:,5),'-')
ylim([-1 2])
yticks([-1 0 1 2])
yticklabels({'','Nein','Ja',''})
title('Luft aus Luftschacht Richtung Roveredo Dorf (Messwagen)?')
grid on
set(gca,'FontSize',14); 

subplot(4,1,3)
plot(datetime(messwagen.time,'ConvertFrom','datenum'),messwagen.PM10);
ylabel('PM10')
title('PM10 Messung Messwagen')
grid on
set(gca,'FontSize',14); 

subplot(4,1,4)
plot(datetime(messwagen.time,'ConvertFrom','datenum'),messwagen.NOX,'x');
ylabel('NOX')
ylim([0 20])
title('NOX Messung Messwagen')
grid on
set(gca,'FontSize',14); 

