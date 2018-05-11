%read backscatter


%initializing
data.year   = []; % Jahr
data.month  = []; % Monat
data.day    = []; % Tag
data.hour   = []; % Stunde
data.min    = []; % Minute
data.time=[];
data.fmps=[];

%filepath
filepath = pwd;
filename = [filepath '/' 'fmps_backscatter.txt'];
disp(filename);

% read data - first determining headerlines
fid = fopen(filename);
frewind(fid);

c = textscan(fid,'%f %f %f %f %f %f %f','Headerlines',1);
fclose(fid);


data.year   = [data.year;  c{ 1}]; 
data.month  = [data.month; c{ 2}];
data.day    = [data.day;   c{ 3}]; 
data.hour   = [data.hour;  c{ 4}]; 
data.min    = [data.min;   c{ 5}];
data.fmps   = [data.fmps;  c{ 7}];
data.time = datenum(data.year,data.month,data.day,data.hour,data.min,0);