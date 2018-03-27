clear
clc

% Dateipfad
% root_url='http://iacweb.ethz.ch/staff//krieger/data/FS18/Sonic';
path='/Users/RemoSigg/polybox/ETH-ERDW/ERDW - 6.Semester/Praktikum Atmosphäre/Ceilometergruppe/CeilometerFS2018/data/Sonic';

% Zeitperiode
time_period = datenum(2018,02,10,00,00,00):15/60/24:datenum(2018,03,08,00,00,00);

% sonic data in matrix
% sonic = read_sonic_run_from_url(time_period, root_url);
sonic = read_sonic_run_from_files(time_period, path);

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

%% plot Waermefluesse Tagesgangmittel

% Teste ob die Zeitperiode um 00:00 Uhr beginnt
test_timearray = datestr(sonic(1,1),'HH:MM')*1; % sollte [...,...,...,48,48]

if test_timearray(4) == 48 && test_timearray(5) == 48
   
    m = 4*24; % Anzahl 15 min Werte in einem Tag
    Tage = (length(time_period)-1)/m; % Anzahl Tage in time_period
    
    % Initialisiere Matrix für Tagesgänge in Zeilen
    H_matrix = NaN(Tage,m); 
    E_matrix = NaN(Tage,m);
    
    % Matrix füllen mit 15 min Werten sensibler Warmefluss
    for j = 1:Tage 
        H_matrix(j,:) = sonic((1+m*(j-1)):(m*j),2);
    end

    % Matrix füllen mit 15 min Werten latenter Waermefluss
    for j = 1:Tage
        E_matrix(j,:) = sonic((1+m*(j-1)):(m*j),10);
    end
 
    % Tagesgangmittel über die Messperiode
    for i = 1:m
        H_mittel(i) = nanmean(H_matrix(:,i)); % sensibler Waermefluss
        E_mittel(i) = nanmean(E_matrix(:,i)); % latenter Waermefluss
        H_std(i) = nanstd(H_matrix(:,i)); % Standardabweichung H
        E_std(i) = nanstd(E_matrix(:,i)); % Standardabweichung E
        % obere und untere Grenzen der Standardabweichung
        H_hi(i) = H_mittel(i) + H_std(i);
        H_lo(i) = H_mittel(i) - H_std(i);
        E_hi(i) = E_mittel(i) + E_std(i);
        E_lo(i) = E_mittel(i) - E_std(i);
    end
    
    % Plot sensibler Waermefluss
    figure;
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(1,2,1)
    t = datetime(sonic(1:m,1),'ConvertFrom','datenum');
    confplot(t,H_mittel,H_std)
    hold on;
    plot(t,H_mittel,'r','LineWidth',1.5)
    plot(t,H_hi,'color',[.8 .8 .8])
    plot(t,H_lo,'color',[.8 .8 .8])
    datetick('x','HH:MM','keeplimits','keepticks')
    grid on;
    title(['Tagesgang des sensiblen Wärmeflusses gemittelt über ', num2str(Tage),' Tage'])
    xlabel('Zeit')
    ylabel('H [W/m^2]')
    legend('Stndardabweichung')
    ylim([-60 100])
    
    % Plot latenter Waermefluss
    subplot(1,2,2)
    confplot(t,E_mittel,E_std)
    hold on;
    plot(t,E_mittel,'b','LineWidth',1.5)
    plot(t,E_hi,'color',[.8 .8 .8])
    plot(t,E_lo,'color',[.8 .8 .8])
    datetick('x','HH:MM','keeplimits','keepticks')
    grid on;
    title(['Tagesgabg des latenten Wärmeflusses gemittelt über ', num2str(Tage),' Tage'])
    xlabel('Zeit')
    ylabel('E [W/m^2]')
    legend('Standardabweichung')
    ylim([-60 100])
    
else
     disp('Bitte Zeitperiode um 00:00 Uhr starten')
end
%% plot Stabilitaet

plot_stabilitaet(sonic)

