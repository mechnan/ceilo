
function data=get_bekse_from_dwh(t1,t2)

stn_id = '4270';
stn_alt = 2060;

% get station
disp('getting station from DWH...');

data=get_data(stn_id,t1,t2,stn_alt);

if(isempty(data))
    return;
end


function data=get_data(stn_id,t1,t2,stn_alt)


% jretrievedwh url

url = ['http://wlsprod.meteoswiss.ch:9010/jretrievedwh/surface/station_id?',...
            'locationIds=',stn_id,...
            '&parameterIds=91,93',...
            '&date=',t1,'-',t2];
% read data
[msg,status] = urlread(url);
% stop if c is empty
if status==0
    disp('Failed to read data from dwh.');
    data=[];
    return
end

% if(ispc)
%     
% [status,msg] = dos(['"C:\Program Files (x86)\MeteoSwiss\jretrievedwh\bin\jretrievedwh.bat"',...
%     ' -s surface',...
%     ' -i station_id,',stn_id,...
%     ' -t ',t1,',',t2,...
%     ' -p 91,93']);
% 
% elseif(isunix)
% 
% [status,msg] = unix(['jretrievedwh.sh',...
% ' -s surface',...
%     ' -i station_id,',stn_id,...
%     ' -t ',t1,',',t2,...
%     ' -p 91,93']);
% 
% end
% 
% 
% % stop if c is empty
% if status~=0
%     disp('Failed to read data from dwh.');
%     data=[];
%     return
% end


% read data from string
[c,~]=textscan(msg,'%n|%s|%f|%f','headerlines',3);

% stop if c is empty
if isempty(c{1})
    disp('No data found.');
    data=[];
    return
end

% time
t=datenum(c{2},'yyyymmddHHMMSS');

% count records
records = length(find(diff(t)>0)) + 1;
disp(sprintf('%i records read',records));

% read parameters

% standard parameters
T=c{3};
% turbulence parameters

% new params
precip=c{4};

    
% remove nan's and empty values
ind=find(isnan(t)==0);
t=t(ind);
T=T(ind);
precip=precip(ind);

% set nan's for unphysical values
T(T>999)=nan;
precip(precip>999)=nan;

data.t=t;
data.stn_alt=stn_alt;
data.T=T+273.15;
data.precip=precip;
data.records=records;

return