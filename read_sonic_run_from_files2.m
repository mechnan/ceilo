function [u,v,w,U] = read_sonic_run_from_files2(time_period, path )
% read sonic data from files 
% Roveredo station
% Remo Sigg FS2018
% grosser Teil des Codes aus read_sonic_from_files uebernommen
% hochfrequente Daten 20 mal in der Sekunde - Einlesen eines 15 min file

% Konstanten festlegen
rho=1.293;                      % kg m-3
cp=1004.832;                    % J kg-1 K-1
K=0.4;                          % Karman-Konstante
g=9.81;
T0=273.15;


% loop for all days
for l=1:length(time_period)
    
    dv = datevec(time_period(l));
  
    
    % get the file name
    filename=sprintf('%s/ec_%4d-%02d-%02d_%02d-%02d.txt', path,dv(1),dv(2),dv(3),dv(4),dv(5));
    
    if  ~exist(filename,'file')
        disp(['Datei nicht gefunden: ' filename]);
        [u,v,w,T,U] = deal(NaN);
    else
        disp(filename);
        
        fid = fopen(filename);
        data = cell2mat(textscan(fid,'%f %f %f %f %f %f %f'));

        % Daten zuweisen und berechnen
        time=datenum(dv(1),dv(2),dv(3),dv(4),dv(5),00);
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
        
%         [z,b] = getPlanarFitCoeffs(u(i_ok),v(i_ok),w(i_ok)); % option 'PF'
        z = [0 0 1]; % option 'DR'
        method='DR'; % option 'DR' or 'PF'
        [wind,theta,phi] = rotateWindVector(wind,method,z);
        
        
        u=wind(:,1);
        v=wind(:,2);
        w=wind(:,3);
        
        fclose(fid);
    end
    
    
end
end
