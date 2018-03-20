clear

% path to data
path='/Users/RemoSigg/polybox/ETH-ERDW/ERDW - 6.Semester/Praktikum Atmosphäre/Ceilometergruppe/CeilometerFS2018/data/Rov_FS18/Sonic';

% time period
time_period = datenum(2018,02,01,00,00,00):15/60/24:datenum(2018,02,02,00,00,00);

sonic = read_sonic_run_from_files(time_period, path);
% Spaltenausgaben sonic 
%  1  = Zeit (15 min Periode)
%  2  = sensibler Waermefluss
%  3  = Schubspannung
%  4  = u Mittelwert der Periode 
%  5  = v Mittelwert der Periode 
%  6  = w Mittelwert der Periode 
%  7  = Temperatur Mittelwert der Periode in Kelvin
%  8  = Horizontale Windkomponente Mittelwert der Periode
%  9  = Temperatur Mittelwert der Periode in Celcius
% 10  = latenter Wärmefluss
% 11  = H2O Mittelwert der Periode in kg/kg
% 12  = Schubspannungsgeschwindigkeit
% 13  = dimensionsloser Parameter
% 14  = theta/pi*180+180
% 15  = CO2 Fluss

%% plots