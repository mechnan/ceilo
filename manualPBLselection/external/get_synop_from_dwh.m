% data=get_synop_from_dwh(t1,t2,varargin)
% 
% input:
% - t1,t2       : start and end time as string (format: 'yyyymmddHHMMSS')
% - varargin    : optional parameters, allow to specify the weather index
% to use (default=GWTWS). Syntaxe : (t1,t2,'index','GWT10_MSL')
%
% output:
% - data
%
% weather index allowed :   GWT10_MSL       4786
%                           GWT10_Z500      4787                                   
%                           GWT18_MSL       4788
%                           GWT18_Z500      4789
%                           GWT26_MSL       4790
%                           GWT26_Z500      4791
%                           GWTWS           4795
%                           CAP9            4796
%                           CAP18           4797
%                           CAP27           4798
%
% prc, 2012-08-30
% 
function data=get_synop_from_dwh(t1,t2,varargin)

% check input
ind=find(strcmpi(varargin,'index')==1);
if ~isempty(ind)
    data.idx=varargin{ind+1};
else
    data.idx='GWTWS';
end

% find shortcut number corresponding to index
switch data.idx
    case 'GWT10_MSL'
        nb=4786;
    case 'GWT10_Z500'
        nb=4787;
    case 'GWT18_MSL'
        nb=4788;
    case 'GWT18_Z500'
        nb=4789;
    case 'GWT26_MSL'
        nb=4790;
    case 'GWT26_Z500'
        nb=4791;
    case 'GWTWS';
        nb=4795;
    case 'CAP9'
        nb=4796;
    case 'CAP18'
        nb=4797;
    case 'CAP27'
        nb=4798;
    otherwise
        disp('the index given is incorrect...');
        data=[];
        return
end

% retrieve_dwh query
disp(' -> retrieving synoptic data from DWH...');

% cmd=sprintf('retrieve_dwh -p 4786,4787,4788,4789,4790,4791,4795,4796,4797,4798 -i nat_abbr,RHW -t %s-%s',t1,t2);
% [status msg]=unix(cmd);
% 
% if strcmp(msg(2:end-1),'Error reading values, sqlcode = 1403')==1
%     disp('no data found...');
%     data=[];
%     return
% end

url = ['http://wlsprod.meteoswiss.ch:9010/jretrievedwh/surface/station_id?',...
            'locationIds=1936',...
            '&parameterIds=4786,4787,4788,4789,4790,4791,4795,4796,4797,4798',...
            '&date=',t1,'-',t2];
% read data
[msg,status] = urlread(url);
% stop if c is empty
if status==0
    disp('Failed to read data from dwh.');
    data=[];
    return
end


% read data from string
[c_header pos_header]=textscan(msg,'%s%s%n%n%n%n%n%n%n%n%n%n*[\n]','headerlines',1);
[c pos]=textscan(msg,'%n|%s|%f|%f|%f|%f|%f|%f|%f|%f|%f|%f','headerlines',3);

% stop if c is empty
if isempty(c{1})
    disp(' ! failed to read data from file ...');
    data=[];
    return
end

%by default  short_index=wkmowkd0 -> nr. 4795 (11 types)
c_header{1}=NaN; c_header{2}=NaN;
tmp=cell2mat(c_header);
idx=find(tmp==nb);
clear tmp;
data.t=datenum(c{2},'yyyymmddHHMMSS');
data.synop.id=c{idx};
%if index is GWTWS (default index), data.synop.desc is provided
if nb==4795
    for k=1:length(data.synop.id)
        switch data.synop.id(k)
            case 1
                data.synop.desc{k}='West';
            case 2
                data.synop.desc{k}='SouthWest';
            case 3
                data.synop.desc{k}='NorthWest';
            case 4
                data.synop.desc{k}='North';
            case 5
                data.synop.desc{k}='NorthEast';
            case 6 
                data.synop.desc{k}='East';
            case 7
                data.synop.desc{k}='SouthEast';
            case 8
                data.synop.desc{k}='South';
            case 9
                data.synop.desc{k}='Low Pressure';
            case 10
                data.synop.desc{k}='High Pressure';
            case 11
                data.synop.desc{k}='Flat Pressure';
            otherwise
                data.synop.desc{k}='Error during translation from id to desc';
        end
    end
    data.synop.desc=data.synop.desc';   
end
end


