function stn_data = get_station_data_TI(stn,list_dates)

[first_day,last_day] = deal(list_dates(1),list_dates(end));

base_url = 'http://www.oasi.ti.ch/web/rest/measure/csv?';
stn_data = [];
stn_data.name = lower(stn);

if strcmpi(stn,'mesocco')
    locations = {'69','69','GR_MES','GR_MES','GR_MES','GR_MES'};
    parameters = {'WD','WS','O3','NO','NO2','NOx'};
    parameters_type = {'meteo','meteo','air','air','air','air'};
    parameters_fieldname = {'dir','speed','O3','NO','NO2','NOx'};
    stn_data.location = [738060,139050,790];
end

if strcmpi(stn,'sanbernardino')
    locations = {'38','38','38','38','38','38','38'};
    parameters = {'WDvect','WSvect','T','RH','GI','Prec','P'};
    parameters_type = {'meteo','meteo','meteo','meteo','meteo','meteo','meteo'};
    parameters_fieldname = {'dir','speed','T','rh','Irrad','precip','p'};
    stn_data.location = [734112,147296,1639];
end

if strcmpi(stn,'castadena')
    locations = {'70','70','70','70','70','GR_CAS'};
    parameters = {'WD','WS','T','RH','GI','O3'};
    parameters_type = {'meteo','meteo','meteo','meteo','meteo','air'};
    parameters_fieldname = {'dir','speed','T','rh','Irrad','O3'};
    stn_data.location = [731320,124230,770];
end

if strcmpi(stn,'magadino')
    locations = {'12','12','12','12','12','12','12','Nabel_MAG','Nabel_MAG','Nabel_MAG','Nabel_MAG','Nabel_MAG'};
    parameters = {'WDvect','WSvect','T','RH','GI','Prec','P','O3','NO','NO2','NOx','PM10'};
    parameters_type = {'meteo','meteo','meteo','meteo','meteo','meteo','meteo','air','air','air','air','air'};
    parameters_fieldname = {'dir','speed','T','rh','Irrad','precip','p','O3','NO','NO2','NOx','PM10'};
    stn_data.location = [715480,113162,203];
end

if strcmpi(stn,'magadinoNABEL')
    locations = {'Nabel_MAG','Nabel_MAG','Nabel_MAG','Nabel_MAG','Nabel_MAG'};
    parameters = {'O3','NO','NO2','NOx','PM10'};
    parameters_type = {'air','air','air','air','air'};
    parameters_fieldname = {'O3','NO','NO2','NOx','PM10'};
    stn_data.location = [715500,113200,203];
end

if strcmpi(stn,'roveredo')
    locations = {'GR_ROVM'};
    parameters = {'O3'};
    parameters_type = {'air'};
    parameters_fieldname = {'O3'};
    stn_data.location = [730210,121970,320];
end

if strcmpi(stn,'sanvittore')
    locations = {'auto_81','auto_81','auto_81','auto_81','auto_81','auto_75','auto_75','auto_75','auto_75','auto_75'};
    parameters = {'WD','WS','T','RH','GI','NO','NO2','NOx','PM10','CO'};
    parameters_type = {'meteo','meteo','meteo','meteo','meteo','air','air','air','air','air'};
    parameters_fieldname = {'dir','speed','T','rh','Irrad','NO','NO2','NOx','PM10','CO'};
    stn_data.location = [728530,122160,280];
end

% giubiasco auto_51 PM2.5
% giubiasco auto_101 Tdew

for i=1:length(parameters)
    
    url = [base_url 'domain=' parameters_type{i} '&resolution=h&parameter=' parameters{i} '&from=' datestr(first_day,'yyyy-mm-dd') '&to=' datestr(last_day,'yyyy-mm-dd') '&location=' locations{i}];
    
    [str,status] = urlread(url);
    if status == 0
        if exist(url,'file')
            disp(url);
            fid = fopen(url);
            cscan = textscan(fid,'%s %f %s','HeaderLines',30,'Delimiter',';');
            stn_data.time = datenum(cscan{1},'dd.mm.yyyy HH:MM')-1/24;
            stn_data.(parameters_fieldname{i}) = cscan{2};
            fclose(fid);
            status = 1;
        end
    else
        disp(url);
        cscan = textscan(str,'%s %f %s','HeaderLines',30,'Delimiter',';');
        stn_data.time = datenum(cscan{1},'dd.mm.yyyy HH:MM')-1/24;
        stn_data.(parameters_fieldname{i}) = cscan{2};
    end
    
    if status == 0
        disp(['Unable to read '  url '...']);
        stn_data = [];
    end
    
end

end
