function [ sonic ] = read_sonic_run_from_url(time_period,root_url)
% read sonic data from url (Roveredo)
%   Remo Sigg FS2018
%   Code teilweise von read_sonic_from_files uebernommen

% Konstanten festlegen
rho=1.293;                      % kg m-3
cp=1004.832;                    % J kg-1 K-1
K=0.4;                          % Karman-Konstante
g=9.81;
T0=273.15;

% Datenmatrizen
sonic = NaN(length(time_period),15);

% loop for all days
for l=1:length(time_period)
    
    dv = datevec(time_period(l));
    
    % get the url
    filename=sprintf('%s/ec_%4d-%02d-%02d_%02d-%02d.txt', root_url,dv(1),dv(2),dv(3),dv(4),dv(5));
    
    disp(filename)
    
    % store data in matrix
    data = cell2mat(textscan(webread(filename),'%f %f %f %f %f %f %f'));

        % Daten zuweisen und berechnen
        u=data(:,2);
        v=data(:,3);
        w=data(:,4);
        T=(data(:,5)./20.055).^2;         % Temperatur aus Schallgeschwindigkeit
        U=sqrt(u.*u+v.*v);                % Horizontale Windkomponente
        H2O=data(:,7)*18/1000/1000/rho;   % mmol/m3 -> kg/kg
        CO2_ppmv=data(:,6)*0.0224*1000;   % mmol/m3 -> mmol/mol (ppmv)
        CO2=data(:,6)*44/1000/1000/rho;   % mmol/m3 -> kg/kg

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
        % Bestimmung z: Einheitsvektor z-Achse und tilt-Koeffizienten b0,b1,b2
        i_ok = isfinite(u) & isfinite(v) & isfinite(w);
        [z,b] = getPlanarFitCoeffs(u(i_ok),v(i_ok),w(i_ok));
        method='PF';
        [wind,theta,phi] = rotateWindVector(wind,method,z);
        
        u=wind(:,1);
        v=wind(:,2);
        w=wind(:,3);
        
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
        kvwt = nanmean(KS);                            % Richtung des Waermetransportes aufgrund der Fluktuationen
        
        % Fluesse aus Kovarianzen berechnen
        ssp=-rho*nanmean(Uf.*wf);                      % Schubspannung N m-2
        H=rho*cp*kvwt;                                 % Sensibler Waermefluss W m-2
        vel_ssp=sqrt(abs(nanmean(Uf.*wf)));            % Schubspannungsgeschwindigkeit
        E=rho*(2500827-2360*(Tm-T0))*nanmean(wf.*qf);  % Latenter Waermefluss
        
        FCO2 = rho*nanmean(wf.*cf);                    % CO2 Fluss
        
        % Integrale Turbulenzcharakteristik ITCw des Vertikalwindes
        
        std_w=nanstd(w);                               % Standardabweichung von w
        ITCw=(std_w/vel_ssp);
        
        % Monin-Obukhov-Laenge L
        L=-vel_ssp^3/(K*g*H/Tm/rho/cp);
        
        % Rauigkeitslaenge z0
        
        
        % dimensionslose Parameter z'/L
        zeta=5.0/L;                                    % Stabilitaetsmass z'/L
    
    % Werte in Messdatentabelle schreiben
    sonic(l,1)=datenum(dv(1),dv(2),dv(3),dv(4),dv(5),00);
    sonic(l,2)=H;
    sonic(l,3)=ssp;
    sonic(l,4)=um;
    sonic(l,5)=vm;
    sonic(l,6)=wm;
    sonic(l,7)=Tm;
    sonic(l,8)=Um;
    sonic(l,9)=Tm_C;
    sonic(l,10)=E;
    sonic(l,11)=qm;
    sonic(l,12)=vel_ssp;
    sonic(l,13)=zeta;
    sonic(l,14)=theta/pi*180+180;
    sonic(l,15)=FCO2;
    
end
sonic(sonic(:,1) == 0,:) = [];        % leere Zeilen entfernen
end

