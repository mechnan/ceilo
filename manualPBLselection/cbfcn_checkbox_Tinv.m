function cbfcn_checkbox_Tinv(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_Tinv = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_Tinv');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_Tinv;

%delete already existing line
handles.line_Tinv= findobj(handles.axes_surface,'Type','line','Tag','line_Tinv');
if(ishandle(handles.line_Tinv))
    delete(handles.line_Tinv);
end;
handles.line_Tinv_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_Tinv_grad');
if(ishandle(handles.line_Tinv_grad))
    delete(handles.line_Tinv_grad);
end; 

list_plots = [];
list_legends = {};
if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'Tinv')
        y =  getappdata(mainObj,'Tinv');
        x = getappdata(mainObj,'Tinv_t');
        axes(handles.axes_surface);
        
        handles.checkbox_instrumental_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_instrumental_PBL');
        if get(handles.checkbox_instrumental_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end        
                
        handles.line_Tinv = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','b','MarkerSize',4,...
            'Parent',handles.axes_surface,'Tag','line_Tinv','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);
        handles.line_Tinv_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','b','MarkerSize',4,...
            'Parent',handles.axes_surface_grad,'Tag','line_Tinv_grad','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        list_plots(end+1) = handles.line_Tinv;
        list_legends{end+1} = {'Tinv'};
    end
end


end