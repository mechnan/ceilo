%% Correlation ceilo-precipitation in Grono

list_dates = datenum(2018,3,10):datenum(2018,4,20);
numday = numel(list_dates);
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';

ceilo = read_ceilo_from_url(list_dates, root_url); %load data from ceilo

av_RCS10 = zeros(144*length(list_dates), 1);
time = zeros(144*length(list_dates), 1);
av_RCS = nanmean(ceilo.RCS(1,:),10);%10 miutes mean ceilo data
for i=1:10:1439*length(list_dates)
    
    av_RCS10(i)=av_RCS(i);
    time(i)=ceilo.time(i);
end  
av_RCS10(av_RCS10==0) = [];
time(time==0) = [];

length(av_RCS10)
length(time)
grono = grono_to_str;%load data from grono
mask_time = time>0;
mask_prec = grono.N93(mask_time)>0 & grono.N93(mask_time)<500;

grono_prec = grono.N93(mask_prec);%filter for precipitation in grono

length(grono_prec)
length(av_RCS(mask_prec))


%% linear fit
figure;
scatter((av_RCS10(mask_prec)), grono_prec);
model = fitlm((av_RCS10(mask_prec)), grono_prec,'RobustOpts','bisquare')
plot(model);
set(gca,'XLabel',[]);
ylabel('Niederschlag in Grono [mm]');
xlabel('Ceilo RCS')
title('Niederschlag-RCS Korrelation. p-value = 0.00657, R squared = 0.0143');
hLeg = legend();
set(hLeg,'visible','off');
text(10e5, 1.4, '\beta_0 = 0.37513, \beta_1 = 4.3582e-08');
