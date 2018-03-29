function cbfcn_pushbutton_manualPBL_clear(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
parentObj = findobj(mainObj,'Type','axes','Tag','axes_surface');

%delete existing line
handles.line_manual_pbl = findobj(parentObj,'Type','scatter','Tag','line_manual_pbl');
handles.line_manual_pbl_grad = findobj(findobj(mainObj,'Type','axes','Tag','axes_surface_grad'),'Type','scatter','Tag','line_manual_pbl_grad');
if(ishandle(handles.line_manual_pbl))
    delete(handles.line_manual_pbl);
    delete(handles.line_manual_pbl_grad);
end

axes(parentObj);

end