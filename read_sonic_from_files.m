% -------------------------------------------------------------------------
% Sonic Analysis
% Patrick Stierli, 2013
% HS, 16.03.2014
% Yann Poltera 2018
% -------------------------------------------------------------------------
function Messdatenq = read_sonic_from_files(time_period, path)
% alle Variablen löschen
clear

% addpath('/Users/sharald/Documents/MATLAB/SwissFluxNet/');
addpath('./SwissFluxNet/');

% Pfad Datenfiles
%path='C:\Users\yann\Desktop\iacweb.ethz.ch\staff\krieger\data\FS18\Sonic';


% Konstanten festlegen
rho=1.293;                      % kg m-3
cp=1004.832;                    % J kg-1 K-1
K=0.4;                          % Karman-Konstante
g=9.81;
T0=273.15;


% Zeitperiode
% time_period = datenum(2018,01,22,00,00,00):15/60/24:now;%datenum(2018,01,24,00,00,00);
% Datenmatrix
Messdaten = NaN(length(time_period),4);

% Schleife für alle Tage
for l=1:length(time_period)
    
    dv = datevec(time_period(l));
    
    % get the file name
    filename=sprintf('%s/ec_%4d-%02d-%02d_%02d-%02d.txt', path,dv(1),dv(2),dv(3),dv(4),dv(5));
    
    if ~exist(filename,'file')
        disp(['Datei nicht gefunden: ' filename]);
        [um,vm,wm] = deal(NaN);
    else
        disp(filename);
        
        fid = fopen(filename);
        data = cell2mat(textscan(fid,'%f %f %f %f %f %f %f'));
        
        % Daten zuweisen und berechnen
        u=data(:,2);
        v=data(:,3);
        w=data(:,4);
        
        % unrealistische Werte filtern
        u(abs(u)>50) = NaN;
        v(abs(v)>50) = NaN;
        w(abs(w)>50) = NaN;
        
        % Mittelwerte der Periode berechnen
        um=nanmean(u);
        vm=nanmean(v);
        wm=nanmean(w);
        
        fclose(fid);
    end
    
    % Werte in Messdatentabelle schreiben
    Messdaten(l,1)=datenum(dv(1),dv(2),dv(3),dv(4),dv(5),00);
    Messdaten(l,2)=um;
    Messdaten(l,3)=vm;
    Messdaten(l,4)=wm;
    
end

% Windmessungen speichern als mat-File
Windmessdaten=[Messdaten(:,1),Messdaten(:,2),Messdaten(:,3),Messdaten(:,4)];
save(['Windmessdaten_' datestr(time_period(1),'yyyymmddHHMMSS') '_' datestr(time_period(1),'yyyymmddHHMMSS') '.mat'],'Windmessdaten');

%% Berechne planar fit coefficients

% lade aktuellste ganze Zeitreihe von Windmessdaten seit Messungsbeginn
list = dir('./Windmessdaten_*.mat');
if ~isempty(list)

    fname = fullfile(list(end).folder,list(end).name);
    disp(fname);
    load(fname,'Windmessdaten');
end

Windmessdaten(Windmessdaten(:,1) == 0,:) = [];% leere Zeilen entfernen
um=Windmessdaten(:,2);
vm=Windmessdaten(:,3);
wm=Windmessdaten(:,4);

% Planar-Fit-Methode Bestimmung z: Einheitsvektor z-Achse und tilt-Koeffizienten b0,b1,b2
i_ok = isfinite(um) & isfinite(vm) & isfinite(wm);
[z,b] = getPlanarFitCoeffs(um(i_ok),vm(i_ok),wm(i_ok));

%%

% Pfad Datenfiles
path='/Users/killian/Polybox/ETH/Atmosphere/Praktikum Atmosphäre und Klima/Ceilometer/Data/Sonic Data';

% Konstanten festlegen
rho=1.293;                      % kg m-3
cp=1004.832;                    % J kg-1 K-1
K=0.4;                          % Karman-Konstante
g=9.81;
T0=273.15;

% Zeitperiode
time_period = datenum(2018,01,22,00,00,00):15/60/24:datenum(2018,02,26,00,00,00);

% Datenmatrizen
Messdatenq = NaN(length(time_period),15);

% Schleife für alle Tage
for l=1:length(time_period)
    
    dv = datevec(time_period(l));
    
    % get the file name
    filename=sprintf('%s/ec_%4d-%02d-%02d_%02d-%02d.txt', path,dv(1),dv(2),dv(3),dv(4),dv(5));
    
    if ~exist(filename,'file')
        disp(['Datei nicht gefunden: ' filename]);
        [H,ssp,um,vm,wm,Tm,Um,Tm_C,E,qm,vel_ssp,zeta,theta,FCO2] = deal(NaN);
    else
        disp(filename);
        
        fid = fopen(filename);
        data = cell2mat(textscan(fid,'%f %f %f %f %f %f %f'));

        % Daten zuweisen und berechnen
        u=data(:,2);
        v=data(:,3);
        w=data(:,4);
        T=(data(:,5)./20.055).^2;           % Temperatur aus Schallgeschwindigkeit
        U=sqrt(u.*u+v.*v);                  % Horizontale Windkomponente
        H2O=data(:,7)*18/1000/1000/rho; % mmol/m3 -> kg/kg
        CO2_ppmv=data(:,6)*0.0224*1000; % mmol/m3 -> mmol/mol (ppmv)
        CO2=data(:,6)*44/1000/1000/rho; %  mmol/m3 -> kg/kg

        % unrealistische Werte filtern
        u(abs(u)>50) = NaN;
        v(abs(v)>50) = NaN;
        w(abs(w)>50) = NaN;
        T(T<273.15+(-25) | T>273.15+(45)) = NaN;
        U(isnan(u) | isnan(v)) = NaN;
        H2O(H2O<0 | H2O*1e2/0.622>4) = NaN;
        CO2(CO2*0.658e6<0 | CO2*0.658e6>1000) = NaN;

        % Planar-Fit-Methode Rotationskorrektur
        wind=[u,v,w];
        method='PF';
        [wind2,theta,phi] = rotateWindVector(wind,method,z);
        
        u=wind2(:,1);
        v=wind2(:,2);
        w=wind2(:,3);
        
        % Mittelwerte der Periode berechnen
        um=nanmean(u);
        vm=nanmean(v);
        wm=nanmean(w);
        Tm=nanmean(T);
        Tm_C=nanmean(T)-273.15;    % in °C
        Um=nanmean(U);
        qm=nanmean(H2O);
        cm=nanmean(CO2);
        
        % Fluktuationen um den Mittelwert berechnen
        uf=u-um;
        vf=v-vm;
        wf=w-wm;
        Tf=T-Tm;
        Uf= U-Um;
        qf=H2O-qm;
        cf=CO2-cm;
        
        % Wert ohne Korrektur
        KS = wf.*Tf;
        
        % Korrektur Seitenwind
        A=0.5;
        B=0.5;
        KS=wf.*Tf + ((2*Tm)/(cp^2))*(wf.*uf.*um.*A + wf.*vf.*vm.*B);
        
        % Kovarianz der Fluktuationen
        kvwt = nanmean(KS);                % Richtung des Wärmetransportes aufgrund der Fluktuationen
        
        % Flüsse aus Kovarianzen berechnen
        ssp=-rho*nanmean(Uf.*wf);           % Schubspannung
        H=rho*cp*kvwt;                  % Sensibler Wärmefluss
        vel_ssp=sqrt(abs(nanmean(Uf.*wf)));    % Schubspannungsgeschwindigkeit
        E=rho*(2500827-2360*(Tm-T0))*nanmean(wf.*qf); % Latenter Wärmefluss
        
        FCO2 = rho*nanmean(wf.*cf); % CO2 Fluss
        
        % Integrale Turbulenzcharakteristik ITCw des Vertikalwindes
        std_w=nanstd(w);                   % Standardabweichung von w
        ITCw=(std_w/vel_ssp);
        
        % Monin-Obukhov-Länge L
        L=-vel_ssp^3/(K*g*H/Tm/rho/cp);
        
        % Rauigkeitslänge z0
        
        % dimensionslose Parameter z'/L
        zeta=5.0/L;
        
        fclose(fid);
    end
    
    % Werte in Messdatentabelle schreiben
    Messdatenq(l,1)=datenum(dv(1),dv(2),dv(3),dv(4),dv(5),00);
    Messdatenq(l,2)=H;
    Messdatenq(l,3)=ssp;
    Messdatenq(l,4)=um;
    Messdatenq(l,5)=vm;
    Messdatenq(l,6)=wm;
    Messdatenq(l,7)=Tm;
    Messdatenq(l,8)=Um;
    Messdatenq(l,9)=Tm_C;
    Messdatenq(l,10)=E;
    Messdatenq(l,11)=qm;
    Messdatenq(l,12)=vel_ssp;
    Messdatenq(l,13)=zeta;
    Messdatenq(l,14)=theta/pi*180+180;
    Messdatenq(l,15)=FCO2;
    
end
Messdatenq(Messdatenq(:,1) == 0,:) = [];        % leere Zeilen entfernen