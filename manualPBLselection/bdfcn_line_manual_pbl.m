function bdfcn_line_manual_pbl(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;
chm15k.time = getappdata(mainObj,'chm15k_time');

%get axes containers
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

% get line at nearest time point from click position
cp = get(handles.axes_surface,'CurrentPoint');
cp = cp(1,:);
indTplot = find(chm15k.time <= cp(1),1,'last');

if strcmp(get(mainObj,'SelectionType'),'normal') % left click
    
elseif strcmp(get(mainObj,'SelectionType'),'alt') % right click
    
    axes(handles.axes_surface);
    handles.line_manual_pbl = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl');
    handles.line_manual_pbl_grad = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad');
    if(ishandle(handles.line_manual_pbl))
        xdata = get(handles.line_manual_pbl,'XData');
        ydata = get(handles.line_manual_pbl,'YData');
        zdata = get(handles.line_manual_pbl,'ZData');
        cdata = get(handles.line_manual_pbl,'CData');
        
        xydata = [xdata'*10000,ydata'];
        [~,indmin] = min(sqrt(sum(abs(xydata - repmat(cp(1:2).*[10000 1],length(xdata),1)).^2,2)));
        xdata = [xdata(1:indmin-1),xdata(indmin+1:end)];
        ydata = [ydata(1:indmin-1),ydata(indmin+1:end)];
        zdata = [zdata(1:indmin-1),zdata(indmin+1:end)];
        cdata = [cdata(1:indmin-1,:);cdata(indmin+1:end,:)];
        
        if isempty(xdata)
            delete(handles.line_manual_pbl);
            delete(handles.line_manual_pbl_grad);
        else
            set(handles.line_manual_pbl,'XData',xdata,'YData',ydata,'ZData',zdata,'CData',cdata);
            set(handles.line_manual_pbl_grad,'XData',xdata,'YData',ydata,'ZData',zdata,'CData',cdata);
        end
    else
        
    end
    
end

%change time in edit_Tplot
hObj = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_Tplot');
set(hObj,'String',datestr(chm15k.time(indTplot),'dd/mm/yyyy HH:MM:SS'));

end