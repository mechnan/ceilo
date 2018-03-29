function t_ut=SwissLocalTime2UT(t_ch)

% wikipedia definition:
% Folgende Regelung gilt:
% 
% Die Umstellung von der Normal- auf die Sommerzeit findet am letzten Sonntag im März um 1 Uhr UTC, 
% also in der mitteleuropäischen Zeitzone von 2 Uhr MEZ auf 3 Uhr MESZ, statt. 
% Die Umstellung von der Sommer- auf die Normalzeit findet am letzten Sonntag im Oktober um 1 Uhr UTC, 
% also in der mitteleuropäischen Zeitzone von 3 Uhr MESZ auf 2 Uhr MEZ, statt. 

% finde den letzten März Sonntag im laufenden Jahr
dv=datevec(t_ch);
t_march=datenum(dv(1),3,1:31);
ind=length(t_march);
while datestr(t_march(ind),'ddd')~='Sun'
    ind=ind-1;
end
% Zeitumstellung um 2Uhr Lokalzeit statt
t1=t_march(ind)+2/24;

% finde den letzten Oktober Sonntag im laufenden Jahr
dv=datevec(t_ch);
t_okt=datenum(dv(1),10,1:30);
ind=length(t_okt);
while datestr(t_march(ind),'ddd')~='Sun'
    ind=ind-1;
end
% Zeitumstellung um 3Uhr Lokalzeit statt
t2=t_okt(ind)+3/24;

ind=find(t_ch>=t1 & t_ch<=t2);
t_ut(ind)=t_ch(ind)-2/24;
ind=find(t_ch<t1 | t_ch>t2);
t_ut(ind)=t_ch(ind)-1/24;
