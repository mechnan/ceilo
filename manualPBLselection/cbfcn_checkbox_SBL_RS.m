function cbfcn_checkbox_SBL_RS(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_SBL_RS = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_SBL_RS');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_SBL_RS;

%delete already existing line
handles.line_SBL_RS= findobj(handles.axes_surface,'Type','line','Tag','line_SBL_RS');
if(ishandle(handles.line_SBL_RS))
    delete(handles.line_SBL_RS);
end;
handles.line_SBL_RS_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_SBL_RS_grad');
if(ishandle(handles.line_SBL_RS_grad))
    delete(handles.line_SBL_RS_grad);
end; 

list_plots = [];
list_legends = {};
if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'SBL_RS')
        y =  getappdata(mainObj,'SBL_RS');
        x = getappdata(mainObj,'SBL_RS_t');
        axes(handles.axes_surface);
                
        handles.checkbox_instrumental_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_instrumental_PBL');
        if get(handles.checkbox_instrumental_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end        
        
        handles.line_SBL_RS = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor',[0.5 0 1],'MarkerSize',8,...
            'Parent',handles.axes_surface,'Tag','line_SBL_RS','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);
        handles.line_SBL_RS_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor',[0.5 0 1],'MarkerSize',8,...
            'Parent',handles.axes_surface_grad,'Tag','line_SBL_RS_grad','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        list_plots(end+1) = handles.line_SBL_RS;
        list_legends{end+1} = {'SBL_RS'};
    end
end


end