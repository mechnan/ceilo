function data=read_nasa_ames(file,folder)
% Read NASA AIMES format
% Input:
%   date_str: String for the required day (format YYYYMMDD)
% 
% Example:
%   read_nasa_ames('myfile','myfolder')
%
% Output
%   data structure with a field for each variable
% 
% For more information about variables look directly in the file
% 
% By M.Hervo, MeteoSwiss, 08/2015

if nargin==0
    file='CH0001G.20150816000000.20150817010004.equivalent_black_carbon.aethalometer.aerosol.1d.1mn.lev0.nas';
    folder='M:\pay-data\data\pay\aerosol_trend\JFJ_NRT\2015\08\';
end
fid=fopen([folder file]);

if fid<0
    error(['No file: ' folder file])
end

%% READ data
disp([' Reading: ' folder file])
tmp=textscan(fid,'%f',1);
N_header_lines=tmp{1};
header=textscan(fid,'%s',1,'delimiter','\r','headerlines',N_header_lines-1);
headers=textscan(header{1}{1},'%s','delimiter',' ','MultipleDelimsAsOne',true);
N_variables=length(headers{1});
data_raw=textscan(fid,repmat('%f',1,N_variables));
fclose(fid);


%% Parse Data
for i=1:length(headers{1})
    % In case in number add a letter to remove error
    if ~isnan(str2double(headers{1}{i}(1))) && ~strcmp(headers{1}{i}(1),'i')
        var_name=['v' headers{1}{i}];
    else
        var_name=headers{1}{i};
    end
%     disp(var_name)
    data.(var_name)=data_raw{i};
end