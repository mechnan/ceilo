function chmguiprogram
% GUI for processing chm15k ncdf files.


%Get user acronym
if isunix
       [~,tmp] = system('echo "$USER"');
    accronym=tmp(1:3);
else
    [~,tmp] = system('echo %username%');
    accronym=tmp(1:3);
end
% Old version: input DLG
answer = inputdlg('Enter your MCH accronym:','MCH accronym', [1 30]);
if ~isempty(answer)
    accronym = answer{:};
else
     return;
end
if length(accronym)~=3
    warndlg('Invalid accronym (must be 3 letters)');
    return;
end

addpath(genpath('./external/'));
if isunix
%    addpath(genpath('/proj/pay/REM/MATLAB/lib/'));
else
%    addpath(genpath('\\paynas200.meteoswiss.ch\proj\pay\REM\MATLAB\lib\'));
end


%% set configuration
config = ['./config_templates/manualPBLselection.',accronym,'.conf']; 

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

% add paths
for path_id = 1:length(cf.displayParam.paths)  
    addpath(genpath(cf.displayParam.paths{path_id}));   
end

%% handles

% accronym = 'poy';

% Contains every handle.
handles = struct;

% station_list={'pay','kse'};
station_list = cf.stationName;
colormap_list={'ypcmap3','ypcmap2','eprofilecmap','lidarcmap','nyeki2000cmap','jethighblacklowwhitecmap','flexpartcmap',...
    'bluoypcmap'};
ovlap_list = {'default','other...'};
display1_var_list = {'log10(abs(RCS))','RCS'};
display2_var_list = {'grad(RCS)','10 min var(RCS)'};
%N1_list = {'30 s','1 min','2 min','5 min','10 min'};
%N2_list = {'15 m','30 m','45 m'};
N1_list = {'1 min','2 min','5 min','10 min','20 min','30 min'};
N2_list = {'10 m','20 m','30 m','40 m','50 m'};

% screen_size = get(0,'ScreenSize');
figure_pos = [1 41 1920 1111];

% GUI figure
handles.figure_main = figure(...,
    'Name','manualPBLselection GUI',...
    'NumberTitle','off',...
    'Units','Pixels',...
    'Position',figure_pos,...
    'Color','w',...
    'MenuBar','none',...
    'Toolbar','figure',...
    'Tag','figure_main');


% * Axes
handles.axes_surface = axes(...,
    'Units','Pixels',...
    'Position',[375 700 1000 375],...
    'Parent',handles.figure_main,...
    'Tag','axes_surface',...
    'NextPlot','replacechildren');
ylabel(handles.axes_surface,'Altitude (m a.s.l.)');
ylim(handles.axes_surface,[0 3000]);
title(handles.axes_surface,'stn - (lat:...,long:...,alt:...,azimuth:...,zenith:...) - date - synop');
xlims = [floor(now) floor(now)+1];
xticks = xlims(1):1/24:xlims(2);
set(handles.axes_surface,'XLim',xlims,'XTick',xticks,'XGrid','on','YGrid','on');
datetick('x','HH:MM','keepticks','keeplimits');

handles.colorbar_surface = colorbar(handles.axes_surface,...
    'location','EastOutside',...
    'Units','Pixels',...
    'Position',[1380 700 15 375],...
    'Parent',handles.figure_main);
set(handles.colorbar_surface,'Tag','colorbar_surface');

ylabel(handles.colorbar_surface,'log10(abs(RCS))');
caxis(handles.axes_surface,[3.5 6]);
load([colormap_list{1} '.mat'],'cmap');
colormap(handles.axes_surface,cmap);

handles.axes_surface_grad = axes(...,
    'Units','Pixels',...
    'Position',[375 275 1000 375],...
    'Parent',handles.figure_main,...
    'Tag','axes_surface_grad',...
    'NextPlot','replacechildren');
ylabel(handles.axes_surface_grad,'Altitude (m a.s.l.)');
ylim(handles.axes_surface_grad,[0 3000]);
xlims = [floor(now) floor(now)+1];
xticks = xlims(1):1/24:xlims(2);
set(handles.axes_surface_grad,'XLim',xlims,'XTick',xticks,'XGrid','on','YGrid','on');
datetick('x','HH:MM','keepticks','keeplimits');

handles.colorbar_surface_grad = colorbar(handles.axes_surface_grad,...
    'location','EastOutside',...
    'Units','Pixels',...
    'Position',[1380 275 15 375],...
    'Parent',handles.figure_main);
set(handles.colorbar_surface_grad,'Tag','colorbar_surface_grad');

ylabel(handles.colorbar_surface_grad,'grad(RCS)');
caxis(handles.axes_surface_grad,[-500 500]);
load([colormap_list{6} '.mat'],'cmap');
colormap(handles.axes_surface_grad,cmap);

handles.axes_station_measurements = axes(...,
    'Units','Pixels',...
    'Position',[375 100 1000 125],...
    'Parent',handles.figure_main,...
    'Tag','axes_station_measurements',...
    'NextPlot','replacechildren');
xlabel(handles.axes_station_measurements,'Time UT [h]');
ylabel(handles.axes_station_measurements,'Surface Obs.');
ylim(handles.axes_station_measurements,[-6 6]);
line(get(handles.axes_station_measurements,'XLim'),[0 0],'Color','k','Parent',handles.axes_station_measurements);
xlims = [floor(now) floor(now)+1];
xticks = xlims(1):1/24:xlims(2);
set(handles.axes_station_measurements,'XLim',xlims,'XTick',xticks,'XGrid','on','YGrid','on');
datetick('x','HH:MM','keepticks','keeplimits');

handles.edit_Tplot = uicontrol('Style','edit',...
    'String','',...
    'Enable','off',...
    'Units','Pixels',...
    'Position',[820,25,110,20],...
    'Parent',handles.figure_main,...
    'Tag','edit_Tplot');


% * Configuration Panel
handles.uipanel_configuration = uipanel('Title','',...
    'Units','Pixels',...
    'Position',[5,100,295,975],...
    'Parent',handles.figure_main,...
    'Tag','uipanel_loading');

% ** Loading Panel
handles.uipanel_loading = uipanel('Title','Loading',...
    'Units','Pixels',...
    'Position',[5,910,280,60],...
    'Parent',handles.uipanel_configuration,...
    'Tag','uipanel_loading');

handles.popupmenu_station = uicontrol('Style','popupmenu',...
    'String',station_list,...
    'Units','Pixels',...
    'Position',[5,20,50,5],...
    'Parent',handles.uipanel_loading,...
    'Tag','popupmenu_station');
handles.text_station = uicontrol('Style','text','Units','Pixels','Position',[5,25,50,15],...
    'Parent',handles.uipanel_loading,'String','station');

handles.edit_date = uicontrol('Style','edit',...
    'String',datestr(now,'yyyymmdd'),...
    'Units','Pixels',...
    'Position',[90,5,75,20],...
    'Parent',handles.uipanel_loading,...
    'Tag','edit_date');
handles.text_date = uicontrol('Style','text','Units','Pixels','Position',[90,25,75,15],...
    'Parent',handles.uipanel_loading,'String','date');

handles.pushbutton_previous_date = uicontrol('Style','pushbutton',...
    'String','<<',...
    'Units','Pixels',...
    'Position',[70,5,20,20],...
    'Parent',handles.uipanel_loading,...
    'Tag','pushbutton_previous_date');
 
handles.pushbutton_next_date = uicontrol('Style','pushbutton',...
    'String','>>',...
    'Units','Pixels',...
    'Position',[165,5,20,20],...
    'Parent',handles.uipanel_loading,...
    'Tag','pushbutton_next_date');

handles.pushbutton_load_dataset = uicontrol('Style','pushbutton',...
    'String','LOAD',...
    'Units','Pixels',...
    'Position',[200,5,50,20],...
    'Parent',handles.uipanel_loading,...
    'Tag','pushbutton_load_dataset');

% ** Display Options Panel
handles.uipanel_display_options = uipanel('Title','Display options',...
    'Units','Pixels',...
    'Position',[5,10,280,895],...
    'Parent',handles.uipanel_configuration,...
    'Tag','uipanel_display_options');

% *** Time Panel
handles.uipanel_time = uipanel('Title','time',...
    'Units','Pixels',...
    'Position',[5,825,265,50],...
    'Parent',handles.uipanel_display_options,...
    'Tag','uipanel_time');

handles.edit_T0 = uicontrol('Style','edit',...
    'String','00:00:00',...
    'Units','Pixels',...
    'Position',[5,5,80,20],...
    'Parent',handles.uipanel_time,...
    'Tag','edit_T0');

handles.edit_T1 = uicontrol('Style','edit',...
    'String','24:00:00',...
    'Units','Pixels',...
    'Position',[90,5,80,20],...
    'Parent',handles.uipanel_time,...
    'Tag','edit_T1');

% handles.pushbutton_time_set = uicontrol('Style','pushbutton',...
%     'String','set',...
%     'Units','Pixels',...
%     'Position',[175,5,30,20],...
%     'Parent',handles.uipanel_time,...
%     'Tag','pushbutton_time_set');

handles.pushbutton_time_reset = uicontrol('Style','pushbutton',...
    'String','reset',...
    'Units','Pixels',...
    'Position',[215,5,40,20],...
    'Parent',handles.uipanel_time,...
    'Tag','pushbutton_time_reset');

% *** Range Panel
handles.uipanel_range = uipanel('Title','altitude',...
    'Units','Pixels',...
    'Position',[5,770,265,50],...
    'Parent',handles.uipanel_display_options,...
    'Tag','uipanel_range');

handles.edit_R0 = uicontrol('Style','edit',...
    'String','0',...
    'Units','Pixels',...
    'Position',[5,5,80,20],...
    'Parent',handles.uipanel_range,...
    'Tag','edit_R0');
handles.edit_R1 = uicontrol('Style','edit',...
    'String','3000',...
    'Units','Pixels',...
    'Position',[90,5,80,20],...
    'Parent',handles.uipanel_range,...
    'Tag','edit_R1');
% handles.pushbutton_range_set = uicontrol('Style','pushbutton',...
%     'String','set',...
%     'Units','Pixels',...
%     'Position',[175,5,30,20],...
%     'Parent',handles.uipanel_range,...
%     'Tag','pushbutton_range_set');
handles.pushbutton_range_reset = uicontrol('Style','pushbutton',...
    'String','reset',...
    'Units','Pixels',...
    'Position',[215,5,40,20],...
    'Parent',handles.uipanel_range,...
    'Tag','pushbutton_range_reset');

% *** caxis surface Panel
handles.uipanel_caxis = uipanel('Title','caxis display 1',...
    'Units','Pixels',...
    'Position',[5,640,265,120],...
    'Parent',handles.uipanel_display_options,...
    'Tag','uipanel_caxis');

handles.popupmenu_display1_var = uicontrol('Style','popupmenu',...
    'String',display1_var_list,...
    'Units','Pixels',...
    'Position',[75,90,150,5],...
    'Parent',handles.uipanel_caxis,...
    'Value',1,...
    'Tag','popupmenu_display1_var');
handles.text_variable = uicontrol('Style','text','Units','Pixels','Position',[5,75,50,15],...
    'Parent',handles.uipanel_caxis,'String','variable');

handles.edit_C0 = uicontrol('Style','edit',...
    'String','3.5',...
    'Units','Pixels',...
    'Position',[5,35,80,20],...
    'Parent',handles.uipanel_caxis,...
    'Tag','edit_C0');
handles.edit_C1 = uicontrol('Style','edit',...
    'String','6',...
    'Units','Pixels',...
    'Position',[90,35,80,20],...
    'Parent',handles.uipanel_caxis,...
    'Tag','edit_C1');
% handles.pushbutton_caxis_set = uicontrol('Style','pushbutton',...
%     'String','set',...
%     'Units','Pixels',...
%     'Position',[175,35,30,20],...
%     'Parent',handles.uipanel_caxis,...
%     'Tag','pushbutton_caxis_set');
handles.pushbutton_caxis_reset = uicontrol('Style','pushbutton',...
    'String','reset',...
    'Units','Pixels',...
    'Position',[215,35,40,20],...
    'Parent',handles.uipanel_caxis,...
    'Tag','pushbutton_caxis_reset');
handles.popupmenu_colormap = uicontrol('Style','popupmenu',...
    'String',colormap_list,...
    'Units','Pixels',...
    'Position',[75,25,150,5],...
    'Parent',handles.uipanel_caxis,...
    'Value',1,...
    'Tag','popupmenu_colormap');
handles.text_colormap = uicontrol('Style','text','Units','Pixels','Position',[5,10,50,15],...
    'Parent',handles.uipanel_caxis,'String','colormap');

% *** caxis grad surface Panel
handles.uipanel_caxis_grad = uipanel('Title','caxis display 2',...
    'Units','Pixels',...
    'Position',[5,510,265,120],...
    'Parent',handles.uipanel_display_options,...
    'Tag','uipanel_caxis_grad');

handles.popupmenu_display2_var = uicontrol('Style','popupmenu',...
    'String',display2_var_list,...
    'Units','Pixels',...
    'Position',[75,90,150,5],...
    'Parent',handles.uipanel_caxis_grad,...
    'Value',1,...
    'Tag','popupmenu_display2_var');
handles.text_variable_grad = uicontrol('Style','text','Units','Pixels','Position',[5,75,50,15],...
    'Parent',handles.uipanel_caxis_grad,'String','variable');

handles.edit_C0_grad = uicontrol('Style','edit',...
    'String','-500',...
    'Units','Pixels',...
    'Position',[5,35,80,20],...
    'Parent',handles.uipanel_caxis_grad,...
    'Tag','edit_C0_grad');
handles.edit_C1_grad = uicontrol('Style','edit',...
    'String','500',...
    'Units','Pixels',...
    'Position',[90,35,80,20],...
    'Parent',handles.uipanel_caxis_grad,...
    'Tag','edit_C1_grad');
% handles.pushbutton_caxis_grad_set = uicontrol('Style','pushbutton',...
%     'String','set',...
%     'Units','Pixels',...
%     'Position',[175,35,30,20],...
%     'Parent',handles.uipanel_caxis_grad,...
%     'Tag','pushbutton_caxis_grad_set');
handles.pushbutton_caxis_grad_reset = uicontrol('Style','pushbutton',...
    'String','reset',...
    'Units','Pixels',...
    'Position',[215,35,40,20],...
    'Parent',handles.uipanel_caxis_grad,...
    'Tag','pushbutton_caxis_grad_reset');
handles.popupmenu_colormap_grad = uicontrol('Style','popupmenu',...
    'String',colormap_list,...
    'Units','Pixels',...
    'Position',[75,25,150,5],...
    'Parent',handles.uipanel_caxis_grad,...
    'Value',3,...
    'Tag','popupmenu_colormap_grad');
handles.text_colormap_grad = uicontrol('Style','text','Units','Pixels','Position',[5,10,50,15],...
    'Parent',handles.uipanel_caxis_grad,'String','colormap');

% *** resolution Panel
handles.uipanel_resolution = uipanel('Title','resolution',...
    'Units','Pixels',...
    'Position',[5,440,265,60],...
    'Parent',handles.uipanel_display_options,...
    'Tag','uipanel_resolution');

handles.popupmenu_avg1 = uicontrol('Style','popupmenu',...
    'Units','Pixels',...
    'String',N1_list,...
    'Position',[5,20,75,5],...
    'Parent',handles.uipanel_resolution,...
    'Value',3,...
    'Tag','popupmenu_avg1');
handles.text_time = uicontrol('Style','text','Units','Pixels','Position',[5,25,75,15],...
    'Parent',handles.uipanel_resolution,'String','time');

handles.popupmenu_avg2 = uicontrol('Style','popupmenu',...
    'Units','Pixels',...
    'String',N2_list,...
    'Position',[90,20,75,5],...
    'Parent',handles.uipanel_resolution,...
    'Value',1,...
    'Tag','popupmenu_avg2');
handles.text_range = uicontrol('Style','text','Units','Pixels','Position',[90,25,75,15],...
    'Parent',handles.uipanel_resolution,'String','range');


% *** overlap Panel
handles.uipanel_overlap = uipanel('Title','overlap function',...
    'Units','Pixels',...
    'Position',[5,380,265,50],...
    'Parent',handles.uipanel_display_options,...
    'Tag','uipanel_overlap');

handles.popupmenu_overlap = uicontrol('Style','popupmenu',...
    'Units','Pixels',...
    'String',ovlap_list,...
    'Position',[5,20,80,5],...
    'Parent',handles.uipanel_overlap,...
    'Value',1,...
    'Tag','popupmenu_overlap');

handles.text_overlap = uicontrol('Style','text',...
    'Units','Pixels',...
    'String','...',...
    'Position',[90,5,170,15],...
    'Parent',handles.uipanel_overlap,...
    'Tag','text_overlap');


% Checkboxes
handles.checkbox_pathfinder = uicontrol('Style','checkbox',...
    'String','pathfinder',...
    'Units','Pixels',...
    'Position',[5,350,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Value',1,...
    'Tag','checkbox_pathfinder');


handles.checkbox_cbh = uicontrol('Style','checkbox',...
    'String','cbh',...
    'Units','Pixels',...
    'Position',[5,320,50,20],...
    'Parent',handles.uipanel_display_options,...
    'Value',1,...
    'Tag','checkbox_cbh');

handles.checkbox_pbl = uicontrol('Style','checkbox',...
    'String','pbl',...
    'Units','Pixels',...
    'Position',[60,320,50,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_pbl');

handles.checkbox_mxd = uicontrol('Style','checkbox',...
    'String','mxd',...
    'Units','Pixels',...
    'Position',[115,320,50,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_mxd');

handles.checkbox_vor = uicontrol('Style','checkbox',...
    'String','vor',...
    'Units','Pixels',...
    'Position',[170,320,50,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_vor');


handles.checkbox_CBL_PM_RS = uicontrol('Style','checkbox',...
    'String','CBL (PM,RS)',...
    'Units','Pixels',...
    'Position',[5,290,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_CBL_PM_RS');

handles.checkbox_CBL_bR_RS = uicontrol('Style','checkbox',...
    'String','CBL (bR,RS)',...
    'Units','Pixels',...
    'Position',[115,290,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_CBL_bR_RS');

handles.checkbox_CBL_PM = uicontrol('Style','checkbox',...
    'String','CBL (PM)',...
    'Units','Pixels',...
    'Position',[5,260,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_CBL_PM');

handles.checkbox_CBL_bR = uicontrol('Style','checkbox',...
    'String','CBL (bR)',...
    'Units','Pixels',...
    'Position',[115,260,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_CBL_bR');

handles.checkbox_SBL_RS = uicontrol('Style','checkbox',...
    'String','SBL (Theta,RS)',...
    'Units','Pixels',...
    'Position',[5,230,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_SBL_RS');

handles.checkbox_SBL = uicontrol('Style','checkbox',...
    'String','SBL (Theta)',...
    'Units','Pixels',...
    'Position',[115,230,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_SBL');

handles.checkbox_Tinv_RS = uicontrol('Style','checkbox',...
    'String','Tinv (T,RS)',...
    'Units','Pixels',...
    'Position',[5,200,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_Tinv_RS');

handles.checkbox_Tinv = uicontrol('Style','checkbox',...
    'String','Tinv (T)',...
    'Units','Pixels',...
    'Position',[115,200,100,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_Tinv');

handles.checkbox_manual_PBL = uicontrol('Style','checkbox',...
    'String','display manual PBL',...
    'Units','Pixels',...
    'Position',[5,170,120,20],...
    'Value',1,...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_manual_PBL');

handles.checkbox_instrumental_PBL = uicontrol('Style','checkbox',...
    'String','display instrumental PBL',...
    'Units','Pixels',...
    'Position',[130,170,120,20],...
    'Value',1,...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_instrumental_PBL');


% manual PBL

list_PBLtype = {'CBL','RL','SBL'};
handles.listbox_PBLtype = uicontrol('Style','listbox',...
    'Units','Pixels',...
    'Position',[5 90 50 45],...
    'Parent',handles.uipanel_display_options,...
    'String',list_PBLtype,...
    'Tag','listbox_PBLtype');
handles.text_PBLtype = uicontrol('Style','text','Units','Pixels','Position',[5 140 50 15],...
    'Parent',handles.uipanel_display_options,'String','PBL type');

handles.pushbutton_manualPBL_view = uicontrol('Style','pushbutton',...
    'String','view m. PBL',...
    'Units','Pixels',...
    'Position',[65,90,70,30],...
    'Parent',handles.uipanel_display_options,...
    'Tag','pushbutton_manualPBL_view');

handles.checkbox_manual_PBL_view = uicontrol('Style','checkbox',...
    'String','display v.m.PBL',...
    'Units','Pixels',...
    'Position',[140,100,150,20],...
    'Value',1,...
    'Parent',handles.uipanel_display_options,...
    'Tag','checkbox_manual_PBL_view');

handles.edit_accronym = uicontrol('Style','edit',...
    'String',accronym,...
    'Units','Pixels',...
    'Position',[5,40,75,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','edit_accronym');
handles.text_accronym = uicontrol('Style','text','Units','Pixels','Position',[5,60,75,15],...
    'Parent',handles.uipanel_display_options,'String','accronym');

% handles.pushbutton_quick_save_and_next_day = uicontrol('Style','pushbutton',...
%     'String','quick save m. PBL and load next day',...
%     'Units','Pixels',...
%     'Position',[85,40,190,30],...
%     'Parent',handles.uipanel_display_options,...
%     'Tag','pushbutton_quick_save_and_next_day');
%Modif Hem 08/2015
handles.pushbutton_quick_save_and_next_day = uicontrol('Style','pushbutton',...
    'String','quick save m. PBL and load in',...
    'Units','Pixels',...
    'Position',[80,40,155,25],...
    'Parent',handles.uipanel_display_options,...
    'Tag','pushbutton_quick_save_and_next_day');

handles.number_of_days_for_quick_save = uicontrol('Style','edit',...
    'String','1',...
    'Units','Pixels',...
    'Position',[235,40,20,25],...
    'Parent',handles.uipanel_display_options,...
    'Tag','number_of_days_for_quick_save');

handles.text_for_quick_save = uicontrol('Style','text',...
    'String','day',...
    'Units','Pixels',...
    'Position',[255,40,25,20],...
    'Parent',handles.uipanel_display_options,...
    'Tag','test_for_quick_save');

handles.pushbutton_manualPBL_clear = uicontrol('Style','pushbutton',...
    'String','clear manual PBL',...
    'Units','Pixels',...
    'Position',[5,5,100,30],...
    'Parent',handles.uipanel_display_options,...
    'Tag','pushbutton_manualPBL_clear');

handles.pushbutton_manualPBL_save = uicontrol('Style','pushbutton',...
    'String','save manual PBL',...
    'Units','Pixels',...
    'Position',[105,5,100,30],...
    'Parent',handles.uipanel_display_options,...
    'Tag','pushbutton_manualPBL_save');

handles.pushbutton_manualPBL_load = uicontrol('Style','pushbutton',...
    'String','load m. PBL',...
    'Units','Pixels',...
    'Position',[205,5,70,30],...
    'Parent',handles.uipanel_display_options,...
    'Tag','pushbutton_manualPBL_load');

% Resize all handles
names = fieldnames(handles);
for j=2:length(names)
    h_field = getfield(handles,names{j});
    set(h_field,'Units','Normalized');
end

%% Callbacks
set(handles.popupmenu_avg1,'Callback',@update_avg);
set(handles.popupmenu_avg2,'Callback',@update_avg);

set(handles.edit_R0,'Callback',@cbfcn_edit_R01);
set(handles.edit_R1,'Callback',@cbfcn_edit_R01);
set(handles.pushbutton_range_reset,'Callback',@cbfcn_pushbutton_range_reset);

set(handles.edit_T0,'Callback',@cbfcn_edit_T01);
set(handles.edit_T1,'Callback',@cbfcn_edit_T01);
set(handles.pushbutton_time_reset,'Callback',@cbfcn_pushbutton_time_reset);

set(handles.edit_C0,'Callback',@cbfcn_edit_C01);
set(handles.edit_C1,'Callback',@cbfcn_edit_C01);
set(handles.pushbutton_caxis_reset,'Callback',@cbfcn_pushbutton_caxis_reset);
set(handles.popupmenu_colormap,'Callback',@cbfcn_popupmenu_colormap);
set(handles.popupmenu_display1_var,'Callback',@cbfcn_popupmenu_display1_var);

set(handles.edit_C0_grad,'Callback',@cbfcn_edit_C01_grad);
set(handles.edit_C1_grad,'Callback',@cbfcn_edit_C01_grad);
set(handles.pushbutton_caxis_grad_reset,'Callback',@cbfcn_pushbutton_caxis_grad_reset);
set(handles.popupmenu_colormap_grad,'Callback',@cbfcn_popupmenu_colormap_grad);
set(handles.popupmenu_display2_var,'Callback',@cbfcn_popupmenu_display2_var);

set(handles.popupmenu_overlap,'Callback',@cbfcn_popupmenu_overlap);

set(handles.checkbox_pathfinder,'Callback',@cbfcn_checkbox_pathfinder);

set(handles.checkbox_cbh,'Callback',@cbfcn_checkbox_cbh);
set(handles.checkbox_pbl,'Callback',@cbfcn_checkbox_pbl);
set(handles.checkbox_mxd,'Callback',@cbfcn_checkbox_mxd);
set(handles.checkbox_vor,'Callback',@cbfcn_checkbox_vor);
set(handles.checkbox_manual_PBL,'Callback',@cbfcn_checkbox_manual_PBL);
set(handles.checkbox_instrumental_PBL,'Callback',@cbfcn_checkbox_instrumental_PBL);

set(handles.checkbox_CBL_PM_RS,'Callback',@cbfcn_checkbox_CBL_PM_RS);
set(handles.checkbox_CBL_bR_RS,'Callback',@cbfcn_checkbox_CBL_bR_RS);
set(handles.checkbox_CBL_PM,'Callback',@cbfcn_checkbox_CBL_PM);
set(handles.checkbox_CBL_bR,'Callback',@cbfcn_checkbox_CBL_bR);
set(handles.checkbox_SBL_RS,'Callback',@cbfcn_checkbox_SBL_RS);
set(handles.checkbox_SBL,'Callback',@cbfcn_checkbox_SBL);
set(handles.checkbox_Tinv_RS,'Callback',@cbfcn_checkbox_Tinv_RS);
set(handles.checkbox_Tinv,'Callback',@cbfcn_checkbox_Tinv);

set(handles.pushbutton_previous_date,'Callback',@cbfcn_pushbutton_previous_date);
set(handles.pushbutton_next_date,'Callback',@cbfcn_pushbutton_next_date);
set(handles.pushbutton_load_dataset,'Callback',@load_and_plot);

set(handles.pushbutton_manualPBL_clear,'Callback',@cbfcn_pushbutton_manualPBL_clear);
set(handles.pushbutton_manualPBL_save,'Callback',@cbfcn_pushbutton_manualPBL_save);
set(handles.pushbutton_manualPBL_load,'Callback',@cbfcn_pushbutton_manualPBL_load);
set(handles.pushbutton_quick_save_and_next_day,'Callback',@cbfcn_pushbutton_quick_save_and_next_day);
set(handles.pushbutton_quick_save_and_next_day,'Callback',@cbfcn_pushbutton_quick_save_and_next_day);

set(handles.pushbutton_manualPBL_view,'Callback',@cbfcn_pushbutton_manualPBL_view);
set(handles.checkbox_manual_PBL_view,'Callback',@cbfcn_checkbox_manual_PBL_view);

mainObj = handles.figure_main;
setappdata(mainObj,'C0_grad_var1_0',-500);
setappdata(mainObj,'C0_grad_var1',-500);
setappdata(mainObj,'C1_grad_var1_0',500);
setappdata(mainObj,'C1_grad_var1',500);
setappdata(mainObj,'C0_grad_var2_0',0);
setappdata(mainObj,'C0_grad_var2',0);
setappdata(mainObj,'C1_grad_var2_0',1e10);
setappdata(mainObj,'C1_grad_var2',1e10);
setappdata(mainObj,'C0_var1_0',3.5);
setappdata(mainObj,'C0_var1',3.5);
setappdata(mainObj,'C1_var1_0',6);
setappdata(mainObj,'C1_var1',6);
setappdata(mainObj,'C0_var2_0',0);
setappdata(mainObj,'C0_var2',0);
setappdata(mainObj,'C1_var2_0',5*1e5);
setappdata(mainObj,'C1_var2',5*1e5);

setappdata(mainObj,'donotaskforoverlap',false);

setappdata(mainObj,'configFile',config);