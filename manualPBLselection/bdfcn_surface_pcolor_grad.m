function bdfcn_surface_pcolor_grad(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;
chm15k.time = getappdata(mainObj,'chm15k_time');
chm15k.range = getappdata(mainObj,'chm15k_range');

%get axes containers
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

%draw line at nearest time point from click position
cp = get(handles.axes_surface_grad,'CurrentPoint');
cp = cp(1,:);
indTplot = find(chm15k.time <= cp(1),1,'last');
indRplot = find(chm15k.range <= cp(2),1,'last');
x = chm15k.time(indTplot);
y = chm15k.range(indRplot);

handles.listbox_PBLtype = findobj(mainObj,'Type','uicontrol','Style','listbox','Tag','listbox_PBLtype');
contents = cellstr(get(handles.listbox_PBLtype,'String'));
switch contents{get(handles.listbox_PBLtype,'Value')}
    case 'CBL'
        tag = 1;
    case 'RL'
        tag = 2;
    case 'SBL'
        tag = 3;
end

color_tag = {[0 0 0],[1 1 0],[0 1 1]};

if strcmp(get(mainObj,'SelectionType'),'normal') % left click
    
    handles.line_manual_pbl = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl');
    handles.line_manual_pbl_grad = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad');
    if(ishandle(handles.line_manual_pbl))
        xdata = [get(handles.line_manual_pbl_grad,'XData'),x];
        ydata = [get(handles.line_manual_pbl_grad,'YData'),y];
        zdata = [get(handles.line_manual_pbl_grad,'ZData'),tag];
        cdata = [get(handles.line_manual_pbl_grad,'CData');color_tag{tag}];
        
        axes(handles.axes_surface_grad);
        hold on;
        set(handles.line_manual_pbl_grad,'XData',xdata,'YData',ydata,'ZData',zdata,'CData',cdata);
        
        axes(handles.axes_surface);
        hold on;
        set(handles.line_manual_pbl,'XData',xdata,'YData',ydata,'ZData',zdata,'CData',cdata);

    else
        handles.checkbox_manual_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_manual_PBL');
        if get(handles.checkbox_manual_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end
        
        z = tag;
        c = color_tag{tag};
        
        axes(handles.axes_surface_grad);
        hold on;
        handles.line_manual_pbl_grad = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',24,'Parent',handles.axes_surface_grad,'Tag','line_manual_pbl_grad','ZData',z,'CData',c,'Visible',vis,'ButtonDownFcn',@bdfcn_line_manual_pbl_grad);

        axes(handles.axes_surface);
        hold on;
        handles.line_manual_pbl = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',24,'Parent',handles.axes_surface ,'Tag','line_manual_pbl','ZData',z,'CData',c,'Visible',vis,'ButtonDownFcn',@bdfcn_line_manual_pbl);

    end

elseif strcmp(get(mainObj,'SelectionType'),'alt') % right click
    
end

%change time in edit_Tplot
hObj = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_Tplot');
set(hObj,'String',datestr(chm15k.time(indTplot),'dd/mm/yyyy HH:MM:SS'));

end