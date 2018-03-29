function load_and_plot(hObj,eventdata)
hw=waitbar(0,'Loading data');
mainObj = gcbf;

handles.edit_date = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_date');
date = get(handles.edit_date,'String');

handles.popupmenu_station = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_station');
contents = cellstr(get(handles.popupmenu_station,'String'));
station = contents{get(handles.popupmenu_station,'Value')};

config = getappdata(mainObj,'configFile'); 
if isa(config,'setConfig')
    cf=config;
elseif exist(config,'file')==2
    cf=setConfig(config);
else
    disp('not able to get configuration ...')
    return
end
% is cf correct
if cf.configOK==0
    disp('error in config structure ...');
    return
end
setappdata(mainObj,'pbl_analysis_REM_path',cf.displayParam.chm15k.pbl_analysis_REM.path);
setappdata(mainObj,'manual_PBL_path',cf.displayParam.chm15k.manual_PBL.path);
setappdata(mainObj,'JFJ_measurements_path',cf.displayParam.chm15k.JFJ_measurements.path);
setappdata(mainObj,'overlap_functions_Lufft_path',cf.displayParam.chm15k.overlap_functions_Lufft.path);
setappdata(mainObj,'overlap_functions_path',cf.displayParam.chm15k.overlap_functions.path);

if ~cf.displayParam.chm15k.(station).is_eprofilefolder
	if strcmp(station,'roveredo')
		ceilo = read_ceilo_from_url2(datenum(date,'yyyymmdd'):datenum(date,'yyyymmdd')+1,cf.displayParam.chm15k.(station).daily_netcdf.path);
		chm15k = struct;
		chm15k.time = ceilo.time;
		chm15k.range = ceilo.range;
		chm15k.beta_raw = ceilo.RCS;
        chm15k.beta_raw = 10.^(ceilo.RCS*ceilo.CL*1e6);
		chm15k.zenith = ceilo.zenith;
		chm15k.azimuth = ceilo.azimuth;
		chm15k.altitude = 0*ceilo.alt;
		chm15k.longitude = ceilo.lon;
		chm15k.latitude = ceilo.lat;
% 		chm15k.average_time = [60*1000;diff(ceilo.time)*24*3600*1000]; % milliseconds
        chm15k.average_time = 60*1000 * ones(length(ceilo.time),1); % milliseconds
% 		chm15k.cbh = ceilo.cbh;
        
        chm15k.cbh = NaN(3,length(ceilo.time));
		
		chm15k.pbl = NaN*chm15k.cbh;
		chm15k.pbs = NaN*chm15k.cbh;
		chm15k.cbe = NaN*chm15k.cbh;
		chm15k.cdp = NaN*chm15k.cbh;
		chm15k.cde = NaN*chm15k.cbh;
		chm15k.mxd = NaN(length(ceilo.time),1);
		chm15k.vor = NaN(length(ceilo.time),1);
		chm15k.sci = NaN(length(ceilo.time),1);
		chm15k.cho = 0;
		
	else
    [chm15k,info] = readcorrectlyncfile3(cf.displayParam.chm15k.(station).fname_prefix,datestr(datenum(date,'yyyymmdd'),'yyyymmddHHMMSS'),datestr(datenum(date,'yyyymmdd')+1,'yyyymmddHHMMSS'),cf.displayParam.chm15k.(station).daily_netcdf.path);
    % [chm15k,info] = readcorrectlyncfile3(station,datestr(datenum(date,'yyyymmdd'),'yyyymmddHHMMSS'),datestr(datenum(date,'yyyymmdd')+1,'yyyymmddHHMMSS'));%,'C:\AllData\');
	end
else
    stations_EPROFILE={'lindenberg','hohenpeissenberg','hamburg','oslo','flesland','macehead'};
    wmoind = {'10393','10962','10140','01492','01311','03963'};
    institute = {'DWD','DWD','DWD','METNO','METNO','NUIG'};
    if any(strcmp(station,stations_EPROFILE))
        istn = strcmpi(station,stations_EPROFILE);
        [chm15k,info] = read_chm15k(wmoind{istn},institute{istn},[date '000000'],[datestr(datenum(date,'yyyymmdd')+1,'yyyymmdd') '000000'],cf.displayParam.chm15k.(station).daily_netcdf.path);
    end
    if isempty(chm15k)
        errordlg('dataset not found');return;
    end
    chm15k.beta_raw = chm15k.beta_raw';
    if isfield(chm15k,'beta_raw_hr')
        chm15k.beta_raw_hr = chm15k.beta_raw_hr';
    end
    chm15k.pbl = chm15k.pbl';
    chm15k.pbs = chm15k.pbs';
    chm15k.cbh = chm15k.cbh';
    chm15k.cbe = chm15k.cbe';
    chm15k.cdp = chm15k.cdp';
    chm15k.cde = chm15k.cde';
end

if(isempty(chm15k))
    errordlg('dataset not found');
	drawnow;
	close(hw);
    return;
end

% handle old software version in Granada
if strcmp(station,'granada')
        fname_overlapfc = fullfile([cf.displayParam.chm15k.overlap_functions_Lufft.path,'TUB120012_20120917_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            frewind(fid);
            scaling_cell = textscan(fid, 'scaling: %f',1,'headerLines',4);
            fclose(fid);
            ov = cell2mat(ov_cell);
            scaling = cell2mat(scaling_cell);
            chm15k.beta_raw = chm15k.beta_raw_old .* repmat(chm15k.stddev',length(chm15k.range),1) / scaling ./ repmat(ov,1,length(chm15k.time)) ./ repmat(chm15k.p_calc',length(chm15k.range),1) .* repmat(chm15k.range,1,length(chm15k.time)).^2;
            chm15k.zenith = chm15k.zenith / 100;
        end
end

% handle Mace Head
if strcmp(station,'macehead')
   chm15k.cho = 0;
   ov = ones(length(chm15k.range),1);
   chm15k.p_calc = 0.08*ones(length(chm15k.time),1);
   scaling = 1;
   chm15k.beta_raw = chm15k.beta_raw .* repmat(chm15k.stddev',length(chm15k.range),1) / scaling ./ repmat(ov,1,length(chm15k.time)) ./ repmat(chm15k.p_calc',length(chm15k.range),1) .* repmat(chm15k.range,1,length(chm15k.time)).^2;
end

% handle zenith and azimuth scaling
if ~(strcmp(station,'pay') || strcmp(station,'kse'))
    chm15k.zenith = chm15k.zenith / 100;
    chm15k.azimuth = chm15k.azimuth / 100;
end

%error('boo')
% figure;pcolor(chm15k.time-datenum(2000,1,1)+1,chm15k.range,log10(abs(chm15k.beta_raw)));shading flat;datetick;colorbar;caxis([3.5 6]);colormap(jet);


% restrict time to period of interest
indt = chm15k.time>datenum(date,'yyyymmdd') & chm15k.time-chm15k.average_time/(1000*24*3600)<datenum(date,'yyyymmdd')+1;
chm15k.time = chm15k.time(indt);
chm15k.average_time = chm15k.average_time(indt);
chm15k.beta_raw = chm15k.beta_raw(:,indt);
chm15k.cbh = chm15k.cbh(:,indt);
chm15k.pbl = chm15k.pbl(:,indt);
chm15k.mxd = chm15k.mxd(indt);
chm15k.vor = chm15k.vor(indt);

setappdata(mainObj,'chm15k_time_original',chm15k.time);
setappdata(mainObj,'chm15k_beta_raw_original',chm15k.beta_raw);
setappdata(mainObj,'chm15k_range_original',chm15k.range);

setappdata(mainObj,'chm15k_pbl_original',chm15k.pbl);
setappdata(mainObj,'chm15k_cbh_original',chm15k.cbh);
setappdata(mainObj,'chm15k_mxd_original',chm15k.mxd);
setappdata(mainObj,'chm15k_vor_original',chm15k.vor);
setappdata(mainObj,'chm15k_cho_original',chm15k.cho);

% disp('------- Setting the resolution to 30 s -------');
% waitbar(0.5,hw,' Setting the resolution to 30 s...');
% 
% % output time resolution in minutes
% dt = 0.5;
disp('------- Setting the resolution to 60 s -------');
waitbar(0.5,hw,' Setting the resolution to 60 s...');

% output time resolution in minutes
dt = 1;
% vector of timestamps
xtime = datenum(date,'yyyymmdd')+dt/(24*60):dt/(24*60):datenum(date,'yyyymmdd')+1;
% split chm.time in seconds
t_seconds_chm = NaN(sum(chm15k.average_time/1000),1);
indices_seconds_chm = NaN(sum(chm15k.average_time/1000),1);
for j=1:length(chm15k.time)
    t_seconds_chm(sum(chm15k.average_time(1:j-1)/1000)+1:sum(chm15k.average_time(1:j)/1000)) = (chm15k.time(j)-chm15k.average_time(j)/1000/24/3600+1/24/3600:1/24/3600:chm15k.time(j))';
    indices_seconds_chm(sum(chm15k.average_time(1:j-1)/1000)+1:sum(chm15k.average_time(1:j)/1000)) = repmat(j,chm15k.average_time(j)/1000,1);
end
indices_seconds_chm = indices_seconds_chm(t_seconds_chm>xtime(1)-dt/(24*60) & t_seconds_chm<=xtime(end));
t_seconds_chm = t_seconds_chm(t_seconds_chm>xtime(1)-dt/(24*60) & t_seconds_chm<=xtime(end));
% Range Corrected Signal (averaged in time)
RCS = NaN(length(chm15k.range),length(xtime));
for k=1:length(xtime)
    ind_equal = find(t_seconds_chm>xtime(k)-dt/(24*60) & t_seconds_chm<=xtime(k));
    if ~isempty(ind_equal)
        RCS(:,k) = mean(chm15k.beta_raw(:,indices_seconds_chm(ind_equal)),2);
    end
end

% disp('------- Calculating the 10-min variance -------');
% waitbar(0.60,hw,' Calculating the 10-min variance...');
% 
% % 10-minutes variance
% RCS_var = NaN(size(RCS));
% for k=20:length(xtime)
%     RCS_var(:,k) = nanvar(RCS(:,k-20+1:k),[],2);
% end
disp('------- Calculating the 10-min variance -------');
waitbar(0.60,hw,' Calculating the 10-min variance...');

% 10-minutes variance
RCS_var = NaN(size(RCS));
for k=10:length(xtime)
    RCS_var(:,k) = nanstd(RCS(:,k-10+1:k),[],2);
end

setappdata(mainObj,'chm15k_beta_raw_0_0',RCS);
setappdata(mainObj,'RCS_var_0_0',RCS_var);
setappdata(mainObj,'chm15k_beta_raw_0',RCS);
setappdata(mainObj,'RCS_var_0',RCS_var);
setappdata(mainObj,'chm15k_time_0',xtime);
setappdata(mainObj,'chm15k_range_0',chm15k.range);

setappdata(mainObj,'chm15k_beta_raw',RCS);
setappdata(mainObj,'RCS_var',RCS_var);
setappdata(mainObj,'chm15k_time',xtime);
setappdata(mainObj,'chm15k_range',chm15k.range);

setappdata(mainObj,'chm15k_altitude',chm15k.altitude);
setappdata(mainObj,'chm15k_zenith',chm15k.zenith);

% get synoptic data
disp('------- Getting synoptic conditions in the Alps -------');
waitbar(0.75,hw,'Getting synoptic conditions in the Alps ...');
disp([date,'000000'])

% synop = get_synop_from_dwh([date,'000000'],[date,'000000']);
synop = [];
if isempty(synop)
    synop_alps = '';
else
    synop_alps = synop.synop.desc{1};
end
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
title_str = [station ' - (lat: ' num2str(chm15k.latitude) ', long: ' num2str(chm15k.longitude) ', alt: ' num2str(chm15k.altitude) ' m, azimuth: ' num2str(100*chm15k.azimuth) ', zenith: ' num2str(100*chm15k.zenith) ') - ' date ' - Synop in the Alps: ' synop_alps];
title(handles.axes_surface,title_str);

if false
disp('------- Getting overlap function -------');
hw=waitbar(0.80,hw,'Getting overlap function ...');
setappdata(mainObj,'donotaskforoverlap',true);
cbfcn_popupmenu_overlap;
setappdata(mainObj,'donotaskforoverlap',false);
end

% if isunix
%     root_folder = '/data/pay/PBL4EMPA/overlap_correction/overlap_functions_Lufft/';
% else
%     root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\overlap_correction\overlap_functions_Lufft\';    
% end
% % get and apply specified overlap
% if strcmp(station,'pay')
%     if datenum(date,'yyyymmdd')<datenum(2015,03,04)
%         fname_overlapfc = fullfile([root_folder 'TUB120011_20121112_1024.cfg']);
%         fid = fopen(fname_overlapfc);
%         ov_cell = textscan(fid, '%f','headerLines',1);
%         fclose(fid);
%         ovp_manufacturer = cell2mat(ov_cell);
%     else
%         fname_overlapfc = fullfile([root_folder 'TUB140007_20150126_1024.cfg']);
%         fid = fopen(fname_overlapfc);
%         ov_cell = textscan(fid, '%f','headerLines',1);
%         fclose(fid);
%         ovp_manufacturer = cell2mat(ov_cell);
%     end
% elseif strcmp(station,'kse')
%         fname_overlapfc = fullfile([root_folder 'TUB140005_20140515_1024.cfg']);
%         fid = fopen(fname_overlapfc);
%         ov_cell = textscan(fid, '%f','headerLines',1);
%         fclose(fid);
%         ovp_manufacturer = cell2mat(ov_cell); 
% end
% 
% handles.popupmenu_overlap = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_overlap');
% handles.text_overlap = findobj(mainObj,'Type','uicontrol','Style','text','Tag','text_overlap');
% switch get(handles.popupmenu_overlap,'Value')
%     case 1       
%         [pathstr,name,ext] = fileparts(fname_overlapfc);
%         set(handles.text_overlap,'String',[name,ext]);  
%     case 2
%         if isunix
%             root_folder = '/data/pay/PBL4EMPA/overlap_correction/manualPBLselection/overlap_functions/';
%         else
%             root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\overlap_correction\manualPBLselection\overlap_functions\';
%         end
%         filenames = [root_folder get(handles.text_overlap,'String')];
%         
%         load(fullfile(filenames),'ovp_fc');
%         
%         chm15k.beta_raw_0_0 = getappdata(mainObj,'chm15k_beta_raw_0_0');
%         RCS_var_0_0 = getappdata(mainObj,'RCS_var_0_0');
% 
%         factor = repmat(ovp_manufacturer,1,size(chm15k.beta_raw_0_0,2))./repmat(ovp_fc,1,size(chm15k.beta_raw_0_0,2));
%         
%         chm15k.beta_raw_0 = chm15k.beta_raw_0_0 .* factor;
%         RCS_var_0 = RCS_var_0_0 .* (factor.^2);
%         
%         setappdata(mainObj,'chm15k_beta_raw_0',chm15k.beta_raw_0);
%         setappdata(mainObj,'RVS_var_0',RCS_var_0);
%         
%     otherwise
%         return
% end



% get pbl measurements

% if isunix
%     root_folder = '/data/pay/PBL4EMPA/pbl_analysis/REM/';
% else
%     root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\pbl_analysis\REM\';
% end
root_folder = getappdata(mainObj,'pbl_analysis_REM_path');

if strcmp(station,'pay') || strcmp(station,'kse')
    disp('------- Getting pbl measurements -------');
    hw=waitbar(0.85,hw,'Getting pbl measurements ...');
    
    stn_used = 'pay';
    altitude_used = 490;
%     altitude_used = chm15k.altitude;
    if str2double(date(1:4))>=2014
        filename = [root_folder '/analysis_pbl_' date '_' stn_used '.mat'];
    else
        filename = [root_folder '\pbl_' stn_used '_' date '.mat'];
    end
    try 
        if str2double(date(1:4))>=2014
            load(fullfile(filename),'analysis');
        else
            load(fullfile(filename),'result');
            analysis.pbl.pay = result{1};
        end

        pblh = analysis.pbl.pay.snd_day.pbl_pm + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.snd_day.t;
        setappdata(mainObj,'CBL_PM_RS',pblh);
        setappdata(mainObj,'CBL_PM_RS_t',pbltime);
        
        pblh = analysis.pbl.pay.snd_day.pbl_bR + altitude_used;
        pbltime = analysis.pbl.pay.snd_day.t;
        pblh = [pblh,analysis.pbl.pay.snd_night.pbl_bR];
        pbltime = [pbltime,analysis.pbl.pay.snd_night.t_night];
        pblh(pblh<=altitude_used) = NaN;
        setappdata(mainObj,'CBL_bR_RS',pblh);
        setappdata(mainObj,'CBL_bR_RS_t',pbltime);

        pblh = analysis.pbl.pay.pm.pbl + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.pm.t;
        setappdata(mainObj,'CBL_PM',pblh);
        setappdata(mainObj,'CBL_PM_t',pbltime);
        
        pblh = analysis.pbl.pay.bR.pbl + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.bR.t;
        setappdata(mainObj,'CBL_bR',pblh);
        setappdata(mainObj,'CBL_bR_t',pbltime);

        pblh = analysis.pbl.pay.snd_night.sbl + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.snd_night.t_night;
        setappdata(mainObj,'SBL_RS',pblh);
        setappdata(mainObj,'SBL_RS_t',pbltime);

        pblh = analysis.pbl.pay.sbl.sbl_z + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.sbl.t;
        setappdata(mainObj,'SBL',pblh);
        setappdata(mainObj,'SBL_t',pbltime);
        
        pblh = analysis.pbl.pay.snd_night.z_inversion + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.snd_night.t_night;
        setappdata(mainObj,'Tinv_RS',pblh);
        setappdata(mainObj,'Tinv_RS_t',pbltime);

        pblh = analysis.pbl.pay.sbl.z_inversion + altitude_used;pblh(pblh<=altitude_used) = NaN;
        pbltime = analysis.pbl.pay.sbl.t;
        setappdata(mainObj,'Tinv',pblh);
        setappdata(mainObj,'Tinv_t',pbltime);
        
    catch err
        disp('failed to load pbl measurements');
    end
    
%     try 
%         if isunix
%             load('/data/pay/PBL4EMPA/pbl_analysis/bay/pblh_instr_20102014.mat')
%             load('/data/pay/PBL4EMPA/pbl_analysis/bay/pblh_sound_20102014.mat')
%         else
%             load('\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\pbl_analysis\bay\pblh_instr_20102014.mat');
%             load('\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\pbl_analysis\bay\pblh_sound_20102014.mat');
%         end
% 
%         str_doi = ['d_',date];
% 
%         if(isfield(pblh_instr,(str_doi)))
%             bR_theta_int = pblh_instr.(str_doi).pay.bR_theta_int;
%             bR_thetav_int = pblh_instr.(str_doi).pay.bR_thetav_woint;
%             pm_theta = pblh_instr.(str_doi).pay.pm_theta;
%             pm_thetav = pblh_instr.(str_doi).pay.pm_thetav;
%             xtime = linspace(datenum(date,'yyyymmdd'),datenum(date,'yyyymmdd')+1,145);
%         end
%         if(isfield(pblh_sound,(str_doi)))
%             bR_theta_woint_sound = pblh_sound.(str_doi).pay.bR_theta_woint;
%             bR_thetav_woint_sound = pblh_sound.(str_doi).pay.bR_thetav_woint;
%             pm_theta_sound = pblh_sound.(str_doi).pay.pm_theta;
%             pm_thetav_sound = pblh_sound.(str_doi).pay.pm_thetav;
%             xtime_sound = datenum(date,'yyyymmdd')+0.5;
%         end
%     catch err
%         
%     end
end

if(strcmp(station,'kse') || strcmp(station,'pay'))
    if isunix
        root_folder_pbl_data = '/data/pay/PBL4EMPA/';
        root_folder_pbl_data = '/data/pay/REM/PBL4EMPA/reprocessing_pathfinderturb_1.14/';
    else
        root_folder_pbl_data = 'M:\pay-data\data\pay\PBL4EMPA\';
%         root_folder_pbl_data = 'M:\pay-data\data\pay\REM\PBL4EMPA\reprocessing_debruine_1.6_pay_ovpcorr\';
%         root_folder_pbl_data = 'M:\pay-data\data\pay\REM\PBL4EMPA\reprocessing_pathfinderturb_1.14\';
    end
    pbldata = read_chm15k_pbl_data(station,datestr(datenum(date,'yyyymmdd'),'yyyymmddHHMMSS'),datestr(datenum(date,'yyyymmdd')+1,'yyyymmddHHMMSS'),root_folder_pbl_data);
    if ~isempty(pbldata)
        pbldata.mlh(pbldata.mlh<0 & pbldata.flag<=0) = NaN;
        setappdata(mainObj,'pathfinder',pbldata.mlh);
        setappdata(mainObj,'pathfinder_t',pbldata.time);
        setappdata(mainObj,'pathfinder_flag',pbldata.flag);
    end
end

update_avg;
cbfcn_checkbox_cbh;
cbfcn_checkbox_pbl;
cbfcn_checkbox_mxd;
cbfcn_checkbox_vor;
cbfcn_checkbox_CBL_PM_RS;
cbfcn_checkbox_CBL_bR_RS;
cbfcn_checkbox_CBL_PM;
cbfcn_checkbox_CBL_bR;
cbfcn_checkbox_SBL_RS;
cbfcn_checkbox_SBL;
cbfcn_checkbox_Tinv_RS;
cbfcn_checkbox_Tinv;
cbfcn_checkbox_pathfinder;
%% get station data

start_str = [datestr(xtime(1)-50/(24*60),'yyyymmddHHMMSS')];
end_str = [datestr(xtime(1)+1+1/24,'yyyymmddHHMMSS')];
stn = station;
disp('------- Getting station data -------');
disp(start_str)
disp(end_str)
waitbar(0.9,hw,'Getting station data ...');

stn_data = [];
if(strcmp(stn,'pay'));
    stn_data = get_surf_from_dwh(stn,start_str,end_str);
elseif(strcmp(stn,'kse'))
    stn_data = get_bekse_from_dwh(start_str,end_str);
end

%% station measurements
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

handles.line_manual_pbl = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl');
handles.line_manual_pbl_grad = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad');
if(ishandle(handles.line_manual_pbl))
    delete(handles.line_manual_pbl);
    delete(handles.line_manual_pbl_grad);
end
handles.line_manual_pbl_view = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl_view');
handles.line_manual_pbl_grad_view = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad_view');
if(ishandle(handles.line_manual_pbl_view))
    delete(handles.line_manual_pbl_view);
    delete(handles.line_manual_pbl_grad_view);
end

display_string = {'CBH','PBL','MXD','VOR','CBL (PM,RS)','CBL (PM)','CBL (bR,RS)','CBL (bR)','SBL (Theta,RS)','SBL (Theta)','Tinv (T,RS)','Tinv (T)','manual CBL','manual RL','manual SBL','manual haa','manual gim','manual hem','manual poy'};
display_marker = {'.'  ,'.'  ,'.'  ,'.'  ,'o'          ,'o'         ,'o'       ,'o'      ,'o'          ,'o'            ,'o'          ,'o'      ,'o'   ,'o'  ,'o' ,'o','o','o','o'      };
display_marker_size = {6,6,6,6,8,4,8,4,8,4,8,4,6,6,6,6,6,6,6};
display_color = {[0.5 0.5 0.5],[1 0.65 0],[0 0 0],[1 0.2 0.6],[1 0 0],[1 0 0],[0.5 1 0],[0.5 1 0],[0.5 0 1],[0.5 0 1],[0 0 1],[0 0 1],[0 0 0],[1 1 0],[0 1 1],[0.75 0.75 0.75],[0.5 0.5 1],[1 0.5 0.25],[1 0 0.5]};

list_plots = [];
list_legends = {};
% trick to show the legend for all cases by putting points for
% away from the axes limits
axes(handles.axes_surface)
hold on;
for j=1:length(display_color)
    list_plots(end+1) = plot(0,0,'LineStyle','none','Marker',display_marker{j},'MarkerSize',display_marker_size{j},'Color',display_color{j},'MarkerFaceColor',display_color{j});
    list_legends{end+1} = display_string{j};
end
hl = legend(handles.axes_surface,list_plots,list_legends,'Location','EastOutside','Units','Pixels','Parent',mainObj);
pos1 = get(handles.axes_surface,'Position');
pos2 = get(handles.axes_surface_grad,'Position');
%# set width of third axe equal to that of first one
pos1(3) = pos2(3);
set(handles.axes_surface,'Position',pos1);
pos_hl = get(hl,'Position');
set(hl,'Position',pos_hl + [50,0,0,0]);

  
        
handles.axes_station_measurements = findobj(mainObj,'Type','axes','Tag','axes_station_measurements');
axes(handles.axes_station_measurements);cla;

offset = 0;
% line(get(handles.axes_station_measurements,'XLim'),[0 0],'Color','k','Parent',handles.axes_station_measurements);
hold on;

ylims = [-6 6];



chm15k.sci = chm15k.sci(indt);
is_bad_sci = zeros(length(chm15k.sci),1);
is_bad_sci(chm15k.sci~=0) = (ylims(2)-1)/2;
is_bad_sci(is_bad_sci==0) = NaN;

list_plots=[];
list_legends={};
    
if(~isempty(stn_data))
    % precipitation logical vector
    if(isfield(stn_data,'precip'))
        is_rainy = zeros(length(stn_data.precip),1);
        is_rainy(stn_data.precip>0) = (ylims(2)-1)/2;
        is_rainy(is_rainy==0) = NaN;
        for i=2:length(is_rainy)-1
            if isnan(is_rainy(i)) && (is_rainy(i+1)>0 || is_rainy(i-1)>0)
                is_rainy(i) = 0;
            end 
        end
    end
    
    
    if(isfield(stn_data,'T'))
        T = stn_data.T - 273.15;
        T_hourly_mean = my_average_bin(T,6/1);
        t_hourly_mean = stn_data.t(6/1:6/1:end);

        t_T_growth_rate = t_hourly_mean(1:end-2)+0.5/1/24;
        T_growth_rate = diff(T_hourly_mean(1:end-1));
    end

%     if(isfield(stn_data,'T'))
%         ground_T_grad=[NaN;diff(stn_data.T)*12];% to have [K/2h]
%     end

    if strcmp(stn,'pay')
        
        % Monin-Obukhov (param \in [-0.01;0.01] in data.station)
        z=30; % altitude of the device 
        M_O_length=z./stn_data.turb.M_O_stability_param;
        
        MOL = M_O_length;
        SI = NaN(size(MOL));
        % SI(MOL>10 & MOL<=200)= 1;% stable (like in paper)
        SI(MOL>0 & MOL<=200)= 1;% stable
        SI(MOL>200 & MOL<=500) = 2;% near neutral
        SI(MOL<-500 | MOL>500) = 3;% neutral
        SI(MOL>=-500 & MOL<-200) = 4;% near neutral unstable
        SI(MOL>=-200 & MOL<-100) = 5;% unstable
        % SI(MOL>=-100 & MOL<-10) = 6;% very unstable (like in paper)
        SI(MOL>=-100 & MOL<0) = 6;% very unstable


        SI_final = [];
        t_SI_final = [];
        t = stn_data.t;
        for j=6+1:6:length(t)-5-6
            SI_hour = SI(j:j+5);
            nelements = hist(SI_hour,1:6);
            [~,imax] = nanmax(nelements);
            SI_final(end+1) = imax;
            t_SI_final(end+1) = t(j+2);
        end


        M_O_length_top_plateau = M_O_length;
        M_O_length_top_plateau(M_O_length<(ylims(2)-1)) = NaN;
        M_O_length_top_plateau(M_O_length>(ylims(2)-1)) = (ylims(2)-1);

        M_O_length_bot_plateau = M_O_length;
        M_O_length_bot_plateau(M_O_length>-(ylims(2)-1)) = NaN;
        M_O_length_bot_plateau(M_O_length<-(ylims(2)-1)) = -(ylims(2)-1);

        M_O_length_mid = M_O_length;
        for i=1:length(M_O_length)-1
            if M_O_length_mid(i)>(ylims(2)-1) && M_O_length_mid(i+1)<(ylims(2)-1)
                M_O_length_mid(i)=(ylims(2)-1);
            elseif M_O_length_mid(i)<-(ylims(2)-1) && M_O_length_mid(i+1)>-(ylims(2)-1)
                M_O_length_mid(i)=-(ylims(2)-1);
            elseif M_O_length_mid(i)<(ylims(2)-1) && M_O_length_mid(i+1)>(ylims(2)-1)
                M_O_length_mid(i+1)=(ylims(2)-1);
            elseif M_O_length_mid(i)>-(ylims(2)-1) && M_O_length_mid(i+1)<-(ylims(2)-1)
                M_O_length_mid(i+1)=-(ylims(2)-1);
            end
        end
        M_O_length_mid(M_O_length_mid>(ylims(2)-1) | M_O_length_mid<-(ylims(2)-1)) = NaN;


        % vertical heat flux
        v_heat_flux = stn_data.turb.vert_heat_flux/100;

        v_heat_flux_top_plateau = v_heat_flux;
        v_heat_flux_top_plateau(v_heat_flux<(ylims(2)-1)) = NaN;
        v_heat_flux_top_plateau(v_heat_flux>(ylims(2)-1)) = (ylims(2)-1);

        v_heat_flux_bot_plateau = v_heat_flux;
        v_heat_flux_bot_plateau(v_heat_flux>-(ylims(2)-1)) = NaN;
        v_heat_flux_bot_plateau(v_heat_flux<-(ylims(2)-1)) = -(ylims(2)-1);

        v_heat_flux_mid = v_heat_flux;
        for i=1:length(v_heat_flux)-1
            if v_heat_flux_mid(i)>(ylims(2)-1) && v_heat_flux_mid(i+1)<(ylims(2)-1)
                v_heat_flux_mid(i)=(ylims(2)-1);
            elseif v_heat_flux_mid(i)<-(ylims(2)-1) && v_heat_flux_mid(i+1)>-(ylims(2)-1)
                v_heat_flux_mid(i)=-(ylims(2)-1);
            elseif v_heat_flux_mid(i)<(ylims(2)-1) && v_heat_flux_mid(i+1)>(ylims(2)-1)
                v_heat_flux_mid(i+1)=(ylims(2)-1);
            elseif v_heat_flux_mid(i)>-(ylims(2)-1) && v_heat_flux_mid(i+1)<-(ylims(2)-1)
                v_heat_flux_mid(i+1)=-(ylims(2)-1);
            end
        end
        v_heat_flux_mid(v_heat_flux_mid>(ylims(2)-1) | v_heat_flux_mid<-(ylims(2)-1)) = NaN;

    end
    
    
    if(isfield(stn_data,'sunshine'))
        list_plots(end+1) = bar(stn_data.t-offset,stn_data.sunshine/(10/(ylims(2)-1)),'FaceColor','y','EdgeColor','k');
        list_legends{end+1} = 'sunshine [2min/10min]';
    end

    if(isfield(stn_data,'T'))
%         list_plots(end+1) = plot(stn_data.t-offset,ground_T_grad,'color','b','linestyle','-', 'linewidth',2);
%         list_legends{end+1} = '\Delta T [K/2h]';
        list_plots(end+1) = plot(t_T_growth_rate-offset,T_growth_rate,'color','b','linestyle','-','linewidth',2);
        list_legends{end+1} = '\Delta T [K/1h]';
    end

    if(isfield(stn_data,'precip') && nansum(stn_data.precip)>0)
        list_plots(end+1) = plot(stn_data.t-offset,is_rainy,'color','k','linestyle','-','linewidth',2);
        list_legends{end+1} = 'precip [y/n]';
    end
    
    if(nansum(chm15k.sci~=0)>0)
        list_plots(end+1) = plot(chm15k.time-offset,is_bad_sci,'color',[0.5 0.5 0.5],'linestyle','none','Marker','.');
        list_legends{end+1} = 'bad sci [y/n]';
    end

    if strcmp(stn,'pay')
        
        % list_plots(end+1) = plot(stn_data.t-offset,M_O_length_mid,'color','m','linestyle','-','linewidth',2);
        % plot(stn_data.t-offset,M_O_length_bot_plateau,'color','m','linestyle','-.','linewidth',2);
        % plot(stn_data.t-offset,M_O_length_top_plateau,'color','m','linestyle','-.','linewidth',2);
        % list_legends{end+1} = 'M-O-length';
        
        list_plots(end+1) = plot(stn_data.t-offset,v_heat_flux_mid,'color','r','linestyle','-','linewidth',2);
        plot(stn_data.t-offset,v_heat_flux_bot_plateau,'color','r','linestyle','-.','linewidth',2);
        plot(stn_data.t-offset,v_heat_flux_top_plateau,'color','r','linestyle','-.','linewidth',2); 
        list_legends{end+1} = 'vert. heat flux [0.1kW/m^2]';
        

        
        stability_string = {'stable','near neutral','neutral','near neutral unstable','unstable','very unstable'};
        stability_color = {[0 0 1],[0 0.5 1],[0.5 1 0],[1 1 0],[1 0.5 0],[1 0 0]};
        
        % trick to show the legend for all cases by putting patches far
        % away from the axes limits
        for j=1:length(stability_color)
            list_plots(end+1) = patch([0,1,1,0],[0,0,1,1],stability_color{j});
            list_legends{end+1} = stability_string{j};
        end
        
        
        xticks = xtime(1):1/24:xtime(1)+1;
        for j=1:length(SI_final)-1
            patch([xticks(j),xticks(j+1),xticks(j+1),xticks(j)],[ylims(1),ylims(1),ylims(1)+1,ylims(1)+1],stability_color{SI_final(j)});
        end
        
    end
    
    if strcmp(stn,'kse')
        yyyy = date(1:4);

%         if isunix
%             root_folder = ['/data/pay/PBL4EMPA/JFJ_measurements/' yyyy ,'/'];
%         else
%             root_folder = ['\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\JFJ_measurements\' yyyy '\'];
%         end
        root_folder = getappdata(mainObj,'JFJ_measurements_path');
        if isunix
            root_folder = [root_folder yyyy '/'];
        else
            root_folder = [root_folder yyyy '\'];
        end
        
        disp('------- Getting aerosol data -------');
        waitbar(0.925,hw,'Getting aerosol data ...');
        
        MAAP_failed = false;
        try
            load([root_folder yyyy '_JFJ_MAAP.mat'],'MAAP');
            indt = MAAP.time>=datenum(date,'yyyymmdd') & MAAP.time<=datenum(date,'yyyymmdd')+1;
            if any(indt)
                t = MAAP.time(indt);
                f = MAAP.meas_flag(indt);
                f(isnan(f)) = 0;

                m = MAAP.meas_bc_660nm(indt);
                list_plots(end+1) = plot(t(f<=30),m(f<=30)/100,'-','Color','r','linewidth',2);
                list_legends{end+1} = ['BC 660nm (MAAP 637nm)' ' (100 x ' MAAP.meas_units ')'];
            else
                warning(['no MAAP Data at JFJ available for date ' date ', trying Aeth...']);
                MAAP_failed = true;
            end
        catch err
            warning(['no MAAP Data at JFJ available for year ' yyyy ', trying Aeth...']);
            MAAP_failed = true;
        end

        if MAAP_failed
            try
                load([root_folder yyyy '_JFJ_Aeth.mat'],'Aeth');
                indt = Aeth.time>=datenum(date,'yyyymmdd') & Aeth.time<=datenum(date,'yyyymmdd')+1;
                if any(indt)
                    colors = hsv(7);
                    t = Aeth.time(indt);
                    f = Aeth.meas_flag(indt);
                    f(isnan(f)) = 0;

                    % m = Aeth.meas_ebc_370nm(indt);
                    % list_plots(end+1) = plot(t(f<=30),m(f<=30)/50,'.-','Color',colors(2,:));
                    % list_legends{end+1} = ['EBC 370nm (AE31 Aethelometer 880nm)' ' (50 x ' Aeth.meas_units ')'];

                    % m = Aeth.meas_ebc_470nm(indt);
                    % list_plots(end+1) = plot(t(f<=30),m(f<=30)/50,'.-','Color',colors(3,:));
                    % list_legends{end+1} = ['EBC 470nm (AE31 Aethelometer 880nm)' ' (50 x ' Aeth.meas_units ')'];

                    m = Aeth.meas_ebc_520nm(indt);
                    list_plots(end+1) = plot(t(f<=30),m(f<=30)/100,'.-','Color','r');
                    list_legends{end+1} = ['EBC 520nm (AE31 Aethelometer 880nm)' ' (100 x ' Aeth.meas_units ')'];
                else
                    warning(['no Aeth Data at JFJ available for date ' date]);
                end
            catch err
                warning(['no Aeth Data at JFJ available for year ' yyyy]);
            end
        end

        try
            load([root_folder yyyy '_JFJ_Neph.mat'],'Neph');
            indt = Neph.time>=datenum(date,'yyyymmdd') & Neph.time<=datenum(date,'yyyymmdd')+1;
            if any(indt)
                colors = hsv(7);
                t = Neph.time(indt);
                f = Neph.meas_flag(indt);
                f(isnan(f)) = 0;

                % m = Neph.meas_scat_450nm(indt);
                % list_plots(end+1) = plot(t(f<=30),m(f<=30)/5,'.-','Color',colors(5,:));
                % list_legends{end+1} = ['Scattering 450nm (TSI 3563 Nephelometer)' ' (5 x ' Neph.meas_units ')'];

                m = Neph.meas_scat_550nm(indt);
                list_plots(end+1) = plot(t(f<=30),m(f<=30)/10,'-','Color','g','linewidth',2);
                list_legends{end+1} = ['Scattering 550nm (TSI 3563 Nephelometer)' ' (10 x ' Neph.meas_units ')'];

                % m = Neph.meas_scat_700nm(indt);
                % list_plots(end+1) = plot(t(f<=30),m(f<=30)/5,'.-','Color',colors(7,:));
                % list_legends{end+1} = ['Scattering 700nm (TSI 3563 Nephelometer)' ' (5 x ' Neph.meas_units ')'];
            else
                warning(['no Neph Data at JFJ available for date ' date]);
            end
        catch err
            warning(['no Neph Data at JFJ available for year ' yyyy]);
        end

        % try
        %     load([root_folder yyyy '_JFJ_CPC.mat'],'CPC');
        % catch err
        %     warning(['no CPC Data at JFJ available for year ' yyyy]);
        % end
        
        
        %------------------------------------------------------------------
        disp('------- Getting JFJ NRT aerosol data -------');
        if isunix()
            folder='/data/pay/aerosol_trend/JFJ_NRT/';
        else
            folder='M:\pay-data\data\pay\aerosol_trend\JFJ_NRT\';
        end
        
        MAAP_failed = false;
        % Read and PLOT MAAP
        try
            file=['CH0001G.' date '*.equivalent_black_carbon.maap.aerosol.1d.1h.lev2.nas'];
            folder_day=[folder datestr(datenum(date,'yyyymmdd'),'yyyy/mm/')];
            list=dir([folder_day file]);
            if ~isempty(list)
                data_maap=read_nasa_ames(list(1).name,folder_day);
                time=data_maap.end_time+datenum(date,'yyyymmdd');
                list_plots(end+1) = plot(time,data_maap.conc/50,'-','Color','r','linewidth',2);
                list_legends{end+1} = ['BC 660nm (MAAP 637nm)' ' (50 x ' '[Mm^{-1}]' ')'];
            else
                warning(['No MAAP file:' folder_day file])
                MAAP_failed = true;
            end
        catch err
            MAAP_failed = true;
        end
        
        % Read and PLOT AETHALOMETER
        if MAAP_failed
            try
                file=['CH0001G.' date '*.equivalent_black_carbon.aethalometer.aerosol.1d.1mn.lev0.nas'];
                folder_day=[folder datestr(datenum(date,'yyyymmdd'),'yyyy/mm/')];
                list=dir([folder_day file]);
                if ~isempty(list)
                    data_aethalo=read_nasa_ames(list(1).name,folder_day);
                    time=data_aethalo.end_time+datenum(date,'yyyymmdd');
                    list_plots(end+1) = plot(time,data_aethalo.Conc520,'.-','Color','r');
                    list_legends{end+1} = ['EBC 520nm (AE31 Aethelometer 880nm)' ' (1 x ' '[\mug.m^{-3}]' ')'];
                else
                    warning(['No AETHALOMETER file:' folder_day file])
                end
            catch err
            end
        end

        % Read and PLOT Nephelometer
        try
            file=['CH0001G.' date '*.aerosol_light_scattering_coefficient.aerosol.1d.1h.lev2.nas'];
            folder_day=[folder datestr(datenum(date,'yyyymmdd'),'yyyy/mm/')];
            list=dir([folder_day file]);
            if ~isempty(list)
                data_neph=read_nasa_ames(list(1).name,folder_day);
                time=data_neph.end_time+datenum(date,'yyyymmdd');
                list_plots(end+1) = plot(time,data_neph.sc550/5,'-','Color','g','linewidth',2);
                list_legends{end+1} = ['Scattering 550nm (TSI 3563 Nephelometer)' ' (5 x ' '[Mm^{-1}]' ')'];
            else
                warning(['No Nephelometer file:' folder_day file])
            end
        catch err
        end
        %------------------------------------------------------------------
        
        
        
        

        start_str = datestr(datenum(date,'yyyymmdd'),'yyyymmddHHMMSS');
        end_str = datestr(datenum(date,'yyyymmdd')+1,'yyyymmddHHMMSS');
        
        disp('------- Getting wind data -------');
        waitbar(0.95,hw,'Getting wind data ...');

        datjun = get_station_from_dwh('jun',start_str,end_str);
        datmmlau = get_mmlau_from_dwh(start_str,end_str);

        xticks = datenum(date,'yyyymmdd'):1/24:datenum(date,'yyyymmdd')+1;

        hwi = 45/2;
        ang = [0,45,90,135,180,225,270,315];
        desc = {'N','NE','E','SE','S','SW','W','NW'};
        desc_col = {'N   (high: MMLAU, low: JUN, full(3): 15ms-1)','NE (high: MMLAU, low: JUN, full(3): 15ms-1)','E   (high: MMLAU, low: JUN, full(3): 15ms-1)','SE (high: MMLAU, low: JUN, full(3): 15ms-1)','S   (high: MMLAU, low: JUN, full(3): 15ms-1)','SW (high: MMLAU, low: JUN, full(3): 15ms-1)','W   (high: MMLAU, low: JUN, full(3): 15ms-1)','NW (high: MMLAU, low: JUN, full(3): 15ms-1)'};
        col = num2cell(hsv(8),2);

        % trick to show the legend for all cases by putting patches far
        % away from the axes limits
        for j=1:length(col)
            list_plots(end+1) = patch([0,1,1,0],[0,0,1,1],col{j});
            list_legends{end+1} = desc_col{j};
        end

        for j=1:length(xticks)-1
            
            if ~isempty(datjun)
                indt = datjun.t >= xticks(j) & datjun.t < xticks(j+1);
                if any(indt)
                    
                    uv_wind = [datjun.u(indt) datjun.v(indt)];
                    uv_wind_mean = nanmean(uv_wind,1);
                    [dir_mean,speed_mean] = uv2ddff(uv_wind_mean(1),uv_wind_mean(2));
                    
                    if ~isnan(speed_mean)
                        
                        dy = min(speed_mean/15,3);
                        
                        for k=1:length(ang)
                            if dir_mean >= ang(k)-hwi && dir_mean < ang(k)+hwi
                                dir_mean_desc = desc{k};
                                break;
                            end
                        end
                        
                        patch([xticks(j),xticks(j+1),xticks(j+1),xticks(j)],[ylims(1),ylims(1),ylims(1)+dy,ylims(1)+dy],col{k},'FaceAlpha',0.5);
                        
                    end
                end
            end

            
            if ~isempty(datmmlau)
                indt = datmmlau.t >= xticks(j) & datmmlau.t < xticks(j+1);
                if any(indt)
                    
                    uv_wind = [datmmlau.u(indt) datmmlau.v(indt)];
                    uv_wind_mean = nanmean(uv_wind,1);
                    [dir_mean,speed_mean] = uv2ddff(uv_wind_mean(1),uv_wind_mean(2));
                    
                    if ~isnan(speed_mean)
                        
                        dy = min(speed_mean/15,3);
                        
                        for k=1:length(ang)
                            if dir_mean >= ang(k)-hwi && dir_mean < ang(k)+hwi
                                dir_mean_desc = desc{k};
                                break;
                            end
                        end
                        
                        patch([xticks(j),xticks(j+1),xticks(j+1),xticks(j)],[ylims(1)+3,ylims(1)+3,ylims(1)+3+dy,ylims(1)+3+dy],col{k},'FaceAlpha',0.5);
                        
                    end
                end
            end
    
        end
    
    end
    
else
    disp('no station data found');
end


% plot sunrise & sunset
stn_lat = chm15k.latitude;
stn_long = chm15k.longitude;
days = floor(xtime(1));
for j=1:length(days)
    rs = suncycle(stn_lat,stn_long,days(j));
    sunrise = days(j)+rs(1)/24;
    sunset = days(j)+rs(2)/24;

    hold on
    plot((sunrise-offset)*[1 1],[ylims(1) ylims(2)],'k--','linewidth',2)
    list_plots(end+1)= plot((sunrise-offset),ylims(1)+1,'linestyle','none','Marker','^','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',8);
    list_legends{end+1} = 'sunrise';

    hold on
    plot((sunset-offset)*[1 1],[ylims(1) ylims(2)],'k--','linewidth',2)
    list_plots(end+1) = plot((sunset-offset),ylims(1)+1,'linestyle','none','Marker','v','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',8);
    list_legends{end+1} = 'sunset';
end

% plot current time
plot((SwissLocalTime2UT(now)-offset)*[1 1],[ylims(1) ylims(2)],'r--','linewidth',2)
text((SwissLocalTime2UT(now)-offset),ylims(1)+1,'NOW','Color','r');

% plot 0-line
hold on;
h_0 = plot([datenum(date,'yyyymmdd') datenum(date,'yyyymmdd')+1], [0 0], 'k-');
uistack(h_0,'bottom');


% Copyright
% text(xlims(2)-0.01*diff(xlims),ylims(2)-(ylims(2)-ylims(1))*0.04,'Issued by MeteoSwiss','BackgroundColor',[1 0 1],'FontWeight','demi','HorizontalAlignment','right'); 

legend(handles.axes_station_measurements,list_plots,list_legends,'Location','EastOutside','Units','Pixels','Parent',mainObj);

handles.edit_T0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T0');
handles.edit_T1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T1');

datedn = floor(xtime(1));
xlims = [datedn+datenum(['0000-01-00 ' get(handles.edit_T0,'String')],'yyyy-mm-dd HH:MM:SS') datedn+datenum(['0000-01-00 ' get(handles.edit_T1,'String')],'yyyy-mm-dd HH:MM:SS')];
tol = 0.5/24/3600;
if(xlims(2)-xlims(1) <= 1/24+tol)
    xticks = datedn:10/24/60:datedn+1;
elseif(xlims(2)-xlims(1) <= 4/24+tol)
    xticks = datedn:0.25/24:datedn+1;
elseif(xlims(2)-xlims(1) <= 8/24+tol)
    xticks = datedn:0.5/24:datedn+1;
else
    xticks = datedn:1/24:datedn+1;
end

set(gca,'XLim',xlims);
set(gca,'XTick',xticks);
set(gca,'YLim',ylims);
set(gca,'YTick',[-5:1:5]);
datetick('x','HH:MM','keepticks','keeplimits');


box on;grid on;


pos1 = get(handles.axes_surface,'Position');
pos3 = get(handles.axes_station_measurements,'Position');
%# set width of third axe equal to that of first one
pos3(3) = pos1(3);
set(handles.axes_station_measurements,'Position',pos3);

drawnow % Plot before closing waitbar
close(hw); % Close wait bar 