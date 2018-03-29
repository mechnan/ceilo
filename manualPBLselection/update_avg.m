function update_avg(hObj,eventdata)

mainObj = gcbf;

hN1 = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_avg1');
% N1str = get(hN1,'String');
% N1 = str2num(N1str{get(hN1,'Value')});
iN1 = get(hN1,'Value');
%N1_vec = [1 2 4 10 20];
N1_vec = [1 2 5 10 20 30];
N1 = N1_vec(iN1);

hN2 = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_avg2');
% N2str = get(hN2,'String');
% N2 = str2num(N2str{get(hN2,'Value')});
iN2 = get(hN2,'Value');
%N2_vec = [1 2 3];
N2_vec = [1 2 3 4 5];
N2 = N2_vec(iN2);

% get original time and range
chm15k.time_0 = getappdata(mainObj,'chm15k_time_0');
chm15k.range_0 = getappdata(mainObj,'chm15k_range_0');
RCS_var_0 = getappdata(mainObj,'RCS_var_0');

% average data
setappdata(mainObj,'chm15k_beta_raw',my_average_bin(my_average_bin(getappdata(mainObj,'chm15k_beta_raw_0'),N2,1),N1,2));
setappdata(mainObj,'RCS_var',RCS_var_0(N2:N2:end,N1:N1:end));
setappdata(mainObj,'chm15k_time',chm15k.time_0(N1:N1:end));
setappdata(mainObj,'chm15k_range',chm15k.range_0(N2:N2:end));

chm15k.time = getappdata(mainObj,'chm15k_time');
chm15k.range = getappdata(mainObj,'chm15k_range');
chm15k.beta_raw = getappdata(mainObj,'chm15k_beta_raw');
RCS_var = getappdata(mainObj,'RCS_var');

chm15k.zenith = getappdata(mainObj,'chm15k_zenith');
chm15k.altitude = getappdata(mainObj,'chm15k_altitude');

% get new time and range limits
% handles.edit_Tplot = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_Tplot');
% handles.edit_T0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T0');
% handles.edit_T1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T1');
% handles.edit_R0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_R0');
% handles.edit_R1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_R1');
% 
% tplot = datenum(get(handles.edit_Tplot,'String'),'dd/mm/yyyy HH:MM:SS');
% t0 = datenum(get(handles.edit_T0,'String'),'dd/mm/yyyy HH:MM:SS');
% t1 = datenum(get(handles.edit_T1,'String'),'dd/mm/yyyy HH:MM:SS');
% r0 = str2double(get(handles.edit_R0,'String'));
% r1 = str2double(get(handles.edit_R1,'String'));
% 
% indT0 =  find(chm15k.time >= t0,1,'first');
% indT1 =  find(chm15k.time <= t1,1,'last');
% indTplot = find(chm15k.time >= tplot,1,'first');
% indR0 =  find(chm15k.range >= r0,1,'first');
% indR1 =  find(chm15k.range <= r1,1,'last');
% 
% set(handles.edit_Tplot,'String',datestr(chm15k.time(indTplot),'dd/mm/yyyy HH:MM:SS'));
% set(handles.edit_T0,'String',datestr(chm15k.time(indT0),'dd/mm/yyyy HH:MM:SS'));
% set(handles.edit_T1,'String',datestr(chm15k.time(indT1),'dd/mm/yyyy HH:MM:SS'));
% set(handles.edit_R0,'String',num2str(chm15k.range(indR0)));
% set(handles.edit_R1,'String',num2str(chm15k.range(indR1)));

% replot axes_surface
datedn = floor(chm15k.time(1));
X = [datedn,chm15k.time];
Y = [0;chm15k.range*sind(90-100*chm15k.zenith)+chm15k.altitude];Y(1) = Y(2) - (Y(3)-Y(2));

C = [chm15k.beta_raw NaN(size(chm15k.beta_raw,1),1);NaN(1,size(chm15k.beta_raw,2)+1)];

handles.popupmenu_display1_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display1_var');
switch get(handles.popupmenu_display1_var,'Value')
    case 1
        var_to_plot = log10(abs(C));
        var_to_plot_str = 'log10(abs(RCS))';
    case 2
        var_to_plot = C;
        var_to_plot_str = 'RCS';
    otherwise
        return
end

handles.axes_surface = findobj(gcbf,'Type','axes','Tag','axes_surface');
axes(handles.axes_surface);

handles.surface_pcolor = findobj(handles.axes_surface,'Type','surface','Tag','surface_pcolor');
if isempty(handles.surface_pcolor)
    handles.surface_pcolor = pcolor(X,Y,var_to_plot,'Parent',handles.axes_surface);
    set(handles.surface_pcolor,'ButtonDownFcn',@bdfcn_surface_pcolor,'Tag','surface_pcolor');
    shading flat;
else
    set(handles.surface_pcolor,'XData',X,'YData',Y,'ZData',zeros(length(Y),length(X)),'CData',var_to_plot);
end

handles.edit_C0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0');
handles.edit_C1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1');
caxis([str2double(get(handles.edit_C0,'String')) str2double(get(handles.edit_C1,'String'))]);

handles.popupmenu_colormap = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_colormap');
contents = cellstr(get(handles.popupmenu_colormap,'String'));
colormap_str = contents{get(handles.popupmenu_colormap,'Value')};
load([colormap_str '.mat'],'cmap');
colormap(handles.axes_surface,cmap);

set(handles.axes_surface,'Layer','top');

set(handles.axes_surface,'XGrid','on','YGrid','on');

handles.colorbar_surface = findobj(mainObj,'Type','colorbar','Tag','colorbar_surface');
ylabel(handles.colorbar_surface,var_to_plot_str);

axes(handles.axes_surface);
    



handles.popupmenu_display2_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display2_var');
switch get(handles.popupmenu_display2_var,'Value')
    case 1
        grad_RCS = central_differences(chm15k.beta_raw,chm15k.range(2)-chm15k.range(1));
        C = [grad_RCS NaN(size(grad_RCS,1),1);NaN(1,size(grad_RCS,2)+1)];
        var_to_plot = C;
        var_to_plot_str = 'grad(RCS)';
    case 2
        C = [RCS_var NaN(size(RCS_var,1),1);NaN(1,size(RCS_var,2)+1)];
        var_to_plot = C;
        var_to_plot_str = '10 min var(RCS)';
    otherwise
        return
end
    
% replot axes_surface_grad


handles.axes_surface_grad = findobj(gcbf,'Type','axes','Tag','axes_surface_grad');
axes(handles.axes_surface_grad);

handles.surface_pcolor_grad = findobj(handles.axes_surface_grad,'Type','surface','Tag','surface_pcolor_grad');
if isempty(handles.surface_pcolor_grad)
    handles.surface_pcolor_grad = pcolor(X,Y,var_to_plot,'Parent',handles.axes_surface_grad);
    set(handles.surface_pcolor_grad,'ButtonDownFcn',@bdfcn_surface_pcolor_grad,'Tag','surface_pcolor_grad');
    shading flat;
else
    set(handles.surface_pcolor_grad,'XData',X,'YData',Y,'ZData',zeros(length(Y),length(X)),'CData',var_to_plot);
end

handles.edit_C0_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0_grad');
handles.edit_C1_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1_grad');
caxis([str2double(get(handles.edit_C0_grad,'String')) str2double(get(handles.edit_C1_grad,'String'))]);

handles.popupmenu_colormap_grad = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_colormap_grad');
contents = cellstr(get(handles.popupmenu_colormap_grad,'String'));
colormap_str = contents{get(handles.popupmenu_colormap_grad,'Value')};
load([colormap_str '.mat'],'cmap');
colormap(handles.axes_surface_grad,cmap);

set(handles.axes_surface_grad,'Layer','top');

set(handles.axes_surface_grad,'XGrid','on','YGrid','on');

handles.colorbar_surface_grad = findobj(mainObj,'Type','colorbar','Tag','colorbar_surface_grad');
ylabel(handles.colorbar_surface_grad,var_to_plot_str);



handles.edit_R0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_R0');
handles.edit_R1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_R1');

ylims = [str2double(get(handles.edit_R0,'String')) str2double(get(handles.edit_R1,'String'))];
tol = 1;
if(ylims(2)-ylims(1) <= 1500+tol)
    yticks = 0:100:16000;
elseif(ylims(2)-ylims(1) <= 3000+tol)
    yticks = 0:250:16000;
elseif(ylims(2)-ylims(1) <= 8000+tol)
    yticks = 0:500:16000;
else
   yticks = 0:1000:16000;
end

set(handles.axes_surface,'YLim',ylims,'YTick',yticks);
set(handles.axes_surface_grad,'YLim',ylims,'YTick',yticks);


handles.edit_T0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T0');
handles.edit_T1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T1');

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

set(handles.axes_surface,'XLim',xlims,'XTick',xticks);
datetick(handles.axes_surface,'x','HH:MM','keepticks','keeplimits');
set(handles.axes_surface_grad,'XLim',xlims,'XTick',xticks);
datetick(handles.axes_surface_grad,'x','HH:MM','keepticks','keeplimits');
% set(handles.axes_station_measurements,'XLim',xlims,'XTick',xticks);
% datetick(handles.axes_station_measurements,'x','HH:MM','keepticks','keeplimits');

end