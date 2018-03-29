function cbfcn_checkbox_CBL_PM(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_CBL_PM = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_CBL_PM');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_CBL_PM;

%delete already existing line
handles.line_CBL_PM = findobj(handles.axes_surface,'Type','line','Tag','line_CBL_PM');
if(ishandle(handles.line_CBL_PM))
    delete(handles.line_CBL_PM);
end;
handles.line_CBL_PM_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_CBL_PM_grad');
if(ishandle(handles.line_CBL_PM_grad))
    delete(handles.line_CBL_PM_grad);
end;  

list_plots = [];
list_legends = {};
if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'CBL_PM')
        y =  getappdata(mainObj,'CBL_PM');
        x = getappdata(mainObj,'CBL_PM_t');
        axes(handles.axes_surface);
        
        handles.checkbox_instrumental_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_instrumental_PBL');
        if get(handles.checkbox_instrumental_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end        
                
        handles.line_CBL_PM = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','r','MarkerSize',4,...
            'Parent',handles.axes_surface,'Tag','line_CBL_PM','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);
        handles.line_CBL_PM_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','r','MarkerSize',4,...
            'Parent',handles.axes_surface_grad,'Tag','line_CBL_PM_grad','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        list_plots(end+1) = handles.line_CBL_PM;
        list_legends{end+1} = {'CBL_PM'};
    end
end

end