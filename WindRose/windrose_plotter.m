% windrose_plotter

% WindRose(direction,velocity,'anglenorth',0,'angleeast',90)

%%
startdate = datenum(2018,3,19,0,0,0);
enddate   = datenum(2018,3,19,2,30,0);
index_start=find(data.time==startdate);
index_end=find(data.time==enddate);
WindRose(data.S197(index_start:index_end),data.U196(index_start:index_end),'anglenorth',0,'angleeast',90)

%%
startdate = datenum(2018,3,19,2,30,0);
enddate   = datenum(2018,3,19,7,00,0);
index_start=find(data.time==startdate);
index_end=find(data.time==enddate);
WindRose(data.S197(index_start:index_end),data.U196(index_start:index_end),'anglenorth',0,'angleeast',90)

%%
startdate = datenum(2018,3,19,7,00,0);
enddate   = datenum(2018,3,19,20,00,0);
index_start=find(data.time==startdate);
index_end=find(data.time==enddate);
WindRose(data.S197(index_start:index_end),data.U196(index_start:index_end),'anglenorth',0,'angleeast',90)

%%
startdate = datenum(2018,3,19,20,00,0);
enddate   = datenum(2018,3,19,24,00,0);
index_start=find(data.time==startdate);
index_end=find(data.time==enddate);
WindRose(data.S197(index_start:index_end),data.U196(index_start:index_end),)

