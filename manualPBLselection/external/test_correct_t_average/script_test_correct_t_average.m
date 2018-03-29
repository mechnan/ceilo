
% date of interest
date = '20140616';
% output time resolution in minutes
dt = 0.5;
% read data (including next date)
chm = readcorrectlyncfile3('pay',datestr(datenum(date,'yyyymmdd'),'yyyymmddHHMMSS'),datestr(datenum(date,'yyyymmdd')+2,'yyyymmddHHMMSS'),'C:\AllData\');

%% Average correctly
% We rearrange the data s.t. its daily timestamps correspond to a standard
% partitionning of the form 00:dt 00:2*dt etc., where dt is the time
% resolution in minutes (e.g. 00:10, 00:20 etc.).
%
% For each interval between two consecutive timestamps, nearby measurements
% are divided in sub-measurements of one-second length and only the
% sub-measurements that are in the interval are taken for averaging.

% vector of timestamps
xtime = datenum(date,'yyyymmdd')+dt/(24*60):dt/(24*60):datenum(date,'yyyymmdd')+1;

% restrict time to period of interest
indt = chm.time>datenum(date,'yyyymmdd') & chm.time-chm.average_time/(1000*24*3600)<datenum(date,'yyyymmdd')+1;
chm.time = chm.time(indt);
chm.average_time = chm.average_time(indt);
chm.beta_raw = chm.beta_raw(:,indt);

%%
% tic
% % Range Corrected Signal (averaged in time)
% RCS = NaN(length(chm.range),length(xtime));
% for j=1:length(xtime)
%     indt = find(chm.time>xtime(j)-dt/(24*60) & chm.time-chm.average_time/(1000*24*3600)<xtime(j));
%     if ~isempty(indt)
%         nseconds = zeros(1,length(indt));
%         for k=1:length(indt)
%             if(chm.time(indt(k))-chm.average_time(indt(k))/(1000*24*3600) < xtime(j)-dt/(24*60))
%                 nseconds(k) = (chm.time(indt(k))-(xtime(j)-dt/(24*60)))*24*3600;
%             elseif(chm.time(indt(k)) > xtime(j))
%                 nseconds(k) = (xtime(j)-(chm.time(indt(k))-chm.average_time(indt(k))/(1000*24*3600)))*24*3600;
%             else
%                 nseconds(k) = chm.average_time(indt(k))/1000;
%             end
%         end
% 
%         sum_nseconds = sum(nseconds);
%         if(sum_nseconds > 0)
%             RCS(:,j) = 1/sum_nseconds * sum(repmat(nseconds,length(chm.range),1).*chm.beta_raw(:,indt),2);
%         end
%     end 
% end
% toc
%%
tic
% split chm.time in seconds
t_seconds_chm = NaN(sum(chm.average_time/1000),1);
indices_seconds_chm = NaN(sum(chm.average_time/1000),1);
for j=1:length(chm.time)
    t_seconds_chm(sum(chm.average_time(1:j-1)/1000)+1:sum(chm.average_time(1:j)/1000)) = (chm.time(j)-chm.average_time(j)/1000/24/3600+1/24/3600:1/24/3600:chm.time(j))';
    indices_seconds_chm(sum(chm.average_time(1:j-1)/1000)+1:sum(chm.average_time(1:j)/1000)) = repmat(j,chm.average_time(j)/1000,1);
end
indices_seconds_chm = indices_seconds_chm(t_seconds_chm>xtime(1)-dt/(24*60) & t_seconds_chm<=xtime(end));
t_seconds_chm = t_seconds_chm(t_seconds_chm>xtime(1)-dt/(24*60) & t_seconds_chm<=xtime(end));

% Range Corrected Signal (averaged in time)
RCS = NaN(length(chm.range),length(xtime));
for k=1:length(xtime)
    ind_equal = find(t_seconds_chm>xtime(k)-dt/(24*60) & t_seconds_chm<=xtime(k));
    if ~isempty(ind_equal)
        RCS(:,k) = mean(chm.beta_raw(:,indices_seconds_chm(ind_equal)),2);
    end
end
toc
%%
figure;
offset = datenum(2000,1,1)-1;
X = [datenum(date,'yyyymmdd'),xtime]-offset;
stn_ZE = 90;
stn_alt = 490;
Y = [0*sind(stn_ZE)+stn_alt;chm.range*sind(stn_ZE)+stn_alt];
C = [RCS NaN(size(RCS,1),1);NaN(1,size(RCS,2)+1)];
xlims = [datenum(date,'yyyymmdd') datenum(date,'yyyymmdd')+1]-offset;
xticks = xlims(1):1/24:xlims(2);
ylims = [0 5000];
yticks = ylims(1):200:ylims(2);
pcolor(X,Y,log10(abs(C)));shading flat;colorbar;caxis([3.5 6])
set(gca,'XLim',xlims,'XTick',xticks,'YLim',ylims,'YTick',yticks)
datetick('x','keepticks','keeplimits');
set(gca,'Layer','top');
grid on;