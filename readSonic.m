clear
clc

% path to data
root_url='http://iacweb.ethz.ch/staff//krieger/data/FS18/Sonic';
% path='/Users/RemoSigg/polybox/ETH-ERDW/ERDW - 6.Semester/Praktikum Atmosphäre/Ceilometergruppe/CeilometerFS2018/data/Sonic';

% time period
time_period = datenum(2018,03,05,00,00,00):15/60/24:datenum(2018,03,06,00,00,00);

% sonic data in matrix
sonic = read_sonic_run_from_url(time_period, root_url);
% sonic = read_sonic_run_from_files(time_period, path);

% Spaltenausgaben sonic 
%  1  = Zeit (15 min Periode)
%  2  = sensibler Waermefluss in W m-2
%  3  = Schubspannung N m-2
%  4  = u Mittelwert der Periode m s-1
%  5  = v Mittelwert der Periode m s-1
%  6  = w Mittelwert der Periode m s-1
%  7  = Temperatur Mittelwert der Periode in Kelvin
%  8  = Horizontale Windkomponente Mittelwert der Periode m s-1
%  9  = Temperatur Mittelwert der Periode in Celcius
% 10  = latenter Wärmefluss in W m-2
% 11  = H2O Mittelwert der Periode in kg/kg
% 12  = Schubspannungsgeschwindigkeit
% 13  = Stabilitaetsmass z/L (<0 instabil; >0 stabil)
% 14  = Windrichtung in Grad
% 15  = CO2 Fluss

%% test plot Waermefluesse
figure;
plot(datetime(sonic(:,1),'ConvertFrom','datenum'), sonic(:,2))
grid on;
hold on;
plot(datetime(sonic(:,1),'ConvertFrom','datenum'), sonic(:,10))

%% test plot Stabilitaet

figure;
plot(datetime(sonic(:,1),'ConvertFrom','datenum'), sonic(:,13))
grid on;
