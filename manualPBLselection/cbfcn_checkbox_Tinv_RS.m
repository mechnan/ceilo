function cbfcn_checkbox_Tinv_RS(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_Tinv_RS = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_Tinv_RS');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_Tinv_RS;

%delete already existing line
handles.line_Tinv_RS= findobj(handles.axes_surface,'Type','line','Tag','line_Tinv_RS');
if(ishandle(handles.line_Tinv_RS))
    delete(handles.line_Tinv_RS);
end;
handles.line_Tinv_RS_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_Tinv_RS_grad');
if(ishandle(handles.line_Tinv_RS_grad))
    delete(handles.line_Tinv_RS_grad);
end; 

list_plots = [];
list_legends = {};
if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'Tinv_RS')
        y =  getappdata(mainObj,'Tinv_RS');
        x = getappdata(mainObj,'Tinv_RS_t');
        axes(handles.axes_surface);
        
        handles.checkbox_instrumental_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_instrumental_PBL');
        if get(handles.checkbox_instrumental_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end        
                
        handles.line_Tinv_RS = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','b','MarkerSize',8,...
            'Parent',handles.axes_surface,'Tag','line_Tinv_RS','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);
        handles.line_Tinv_RS_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','b','MarkerSize',8,...
            'Parent',handles.axes_surface_grad,'Tag','line_Tinv_RS_grad','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        list_plots(end+1) = handles.line_Tinv_RS;
        list_legends{end+1} = {'Tinv_RS'};
    end
end


end