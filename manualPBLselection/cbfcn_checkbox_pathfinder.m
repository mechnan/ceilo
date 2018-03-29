function cbfcn_checkbox_pathfinder(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_pathfinder = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_pathfinder');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_pathfinder;

%delete already existing line
handles.line_pathfinder = findobj(handles.axes_surface,'Type','scatter','Tag','line_pathfinder');
if(ishandle(handles.line_pathfinder))
    delete(handles.line_pathfinder);
end;
handles.line_pathfinder_grad = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_pathfinder_grad');
if(ishandle(handles.line_pathfinder_grad))
    delete(handles.line_pathfinder_grad);
end;  

if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'pathfinder')
        y =  getappdata(mainObj,'pathfinder');
        x = getappdata(mainObj,'pathfinder_t');
        z = getappdata(mainObj,'pathfinder_flag');
        
        c = repmat([0.25 0.25 0.25],length(x),1);
        for j=1:length(z)
            if z(j) == 2
               c(j,:) = [1 1 1]; 
            end
        end
        
        axes(handles.axes_surface);
        hold on;
        handles.line_manual_pbl = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',8,'Parent',handles.axes_surface ,'Tag','line_pathfinder','ZData',z,'CData',c,'ButtonDownFcn',@bdfcn_surface_pcolor);
        
        axes(handles.axes_surface_grad);
        hold on;
        handles.line_manual_pbl_grad = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',8,'Parent',handles.axes_surface_grad,'Tag','line_pathfinder_grad','ZData',z,'CData',c,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        
%         axes(handles.axes_surface);
%         handles.line_pathfinder = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor',[1 1 1],'MarkerSize',4,...
%             'Parent',handles.axes_surface,'Tag','line_pathfinder','ButtonDownFcn',@bdfcn_surface_pcolor);
%         handles.line_pathfinder_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor',[1 1 1],'MarkerSize',4,...
%             'Parent',handles.axes_surface_grad,'Tag','line_pathfinder_grad','ButtonDownFcn',@bdfcn_surface_pcolor_grad);
    end
end

end