function cbfcn_checkbox_CBL_bR(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_CBL_bR = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_CBL_bR');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_CBL_bR;

%delete already existing line
handles.line_CBL_bR = findobj(handles.axes_surface,'Type','line','Tag','line_CBL_bR');
if(ishandle(handles.line_CBL_bR))
    delete(handles.line_CBL_bR);
end;
handles.line_CBL_bR_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_CBL_bR_grad');
if(ishandle(handles.line_CBL_bR_grad))
    delete(handles.line_CBL_bR_grad);
end;  

list_plots = [];
list_legends = {};
if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'CBL_bR')
        y =  getappdata(mainObj,'CBL_bR');
        x = getappdata(mainObj,'CBL_bR_t');
        axes(handles.axes_surface);
        
        handles.checkbox_instrumental_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_instrumental_PBL');
        if get(handles.checkbox_instrumental_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end

        handles.line_CBL_bR = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','g','MarkerSize',4,...
            'Parent',handles.axes_surface,'Tag','line_CBL_bR','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);
        handles.line_CBL_bR_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','g','MarkerSize',4,...
            'Parent',handles.axes_surface_grad,'Tag','line_CBL_bR_grad','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        list_plots(end+1) = handles.line_CBL_bR;
        list_legends{end+1} = {'CBL_bR'};
    end
end

end