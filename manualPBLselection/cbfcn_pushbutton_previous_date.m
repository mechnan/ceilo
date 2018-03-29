function cbfcn_pushbutton_previous_date(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

handles.edit_date = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_date');
date = get(handles.edit_date,'String');
set(handles.edit_date,'String',datestr(datenum(date,'yyyymmdd')-1,'yyyymmdd'));

% load_and_plot;

end