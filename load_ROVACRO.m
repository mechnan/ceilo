function roveredo = load_ROVACRO(list_dates)

%clear

%list_dates = datenum(2018,3,7):datenum(2018,3,9);

filepath = [pwd '/' 'ROVACRO Data'];

directory = dir(filepath);

j = 0;
k = 0;
for i = 1:length(directory)
    if directory(i).bytes > 0
        j = j+1;
        date(j) = datenum(str2num(directory(i).name(13:16)),str2num(directory(i).name(17:18)),str2num(directory(i).name(19:20)));
        if ismember(date(j), list_dates)
            k = k+1;
            filename = [filepath '/' directory(i).name];
            fid = fopen(filename);
            str = messwagen(fid);
            if k == 1
                roveredoUnsorted = struct2table(str);
            else
                roveredoUnsorted = vertcat(roveredoUnsorted, struct2table(str));
            end
        end
    end
end

roveredo = sortrows(roveredoUnsorted,'time','ascend');
end