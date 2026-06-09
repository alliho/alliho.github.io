%% assign variables
tmzone = 8/24;
tmzone = 7/24;
tmzone = timezone(-157.858093)./24;

%% fpath
% https://www.pacioos.hawaii.edu/voyager/info/bathymetry.html
[upath regpath wpath trpath] = checksystem()
addpath([upath trpath ])

%% SORT URLS


% https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=air_temperature&application=NOS.COOPS.TAC.MET&begin_date=20230901&end_date=20230902&station=9410230&time_zone=GMT&units=english&interval=6&format=csvhttps://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=air_temperature&application=NOS.COOPS.TAC.MET&begin_date=20230901&end_date=20230902&station=9410230&time_zone=GMT&units=english&interval=6&format=csv


daterange = [now-15 now+2];
% daterange = [now-20 now+2];
%%% water temp
ndbcid = 51002; 
ndbc = dload_ndbc_fromurl(['https://www.ndbc.noaa.gov/data/realtime2/'  num2str(ndbcid) '.txt']);
ndbc.id = ndbcid; 
[ndbc.lat ndbc.lon] = dload_ndbclatlon(ndbc.id);

%%% tidal elevation
stationid = 1612340; noaa.id = stationid; [noaa.lat, noaa.lon, noaa.depth] = dload_noaa_info(noaa.id);
urlheader = 'https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?';
urlstr = [urlheader 'product=water_level&application=NOS.COOPS.TAC.WL&begin_date=' datestr(daterange(1), 'yyyymmdd') '&end_date=' datestr(daterange(2), 'yyyymmdd') '&datum=MLLW&station=' num2str(stationid) '&time_zone=GMT&units=english&format=csv'];
raw = urlread(urlstr, 'Timeout', 50);
raw = splitlines(raw); raw = raw(1:end-1);
raw = cellfun(@(x) strsplit(x, ','), raw, 'Un', 0);
noaa.time = cellfun(@(x) datenum(x{1}, 'yyyy-mm-dd HH:MM'), raw(2:end));
noaa.waterlevel = cellfun(@(x) str2num(x{2}), raw(2:end));


%%% winds
urlstr = [urlheader 'product=wind&application=NOS.COOPS.TAC.WL&begin_date=' datestr(daterange(1), 'yyyymmdd') '&end_date=' datestr(daterange(2), 'yyyymmdd') '&station=' num2str(stationid) '&time_zone=GMT&units=english&format=csv'];
raw = urlread(urlstr, 'Timeout', 50);
raw = splitlines(raw); raw = raw(1:end-1);
raw = cellfun(@(x) strsplit(x, ','), raw, 'Un', 0);
% noaamet.time = cellfun(@(x) datenum(x{1}, 'yyyy-mm-dd HH:MM'), raw(2:end));
noaa.wsp = cellfun(@(x) str2num(x{2}), raw(2:end));
noaa.wdir = cellfun(@(x) str2num(x{3}), raw(2:end));


%%% water temp
urlstr = [urlheader 'product=water_temperature&application=NOS.COOPS.TAC.WL&begin_date=' datestr(daterange(1), 'yyyymmdd') '&end_date=' datestr(daterange(2), 'yyyymmdd') '&station=' num2str(stationid) '&time_zone=GMT&units=english&format=csv'];
raw = urlread(urlstr, 'Timeout', 50);
raw = splitlines(raw); raw = raw(1:end-1);
raw = cellfun(@(x) strsplit(x, ','), raw, 'Un', 0);
% noaa.time = cellfun(@(x) datenum(x{1}, 'yyyy-mm-dd HH:MM'), raw(2:end));
noaa.wtmp = cellfun(@(x) str2num(x{2}), raw(2:end));

%%% air temp
urlstr = [urlheader 'product=air_temperature&application=NOS.COOPS.TAC.WL&begin_date=' datestr(daterange(1), 'yyyymmdd') '&end_date=' datestr(daterange(2), 'yyyymmdd') '&station=' num2str(stationid) '&time_zone=GMT&units=english&format=csv'];
raw = urlread(urlstr, 'Timeout', 50);
raw = splitlines(raw); raw = raw(1:end-1);
raw = cellfun(@(x) strsplit(x, ','), raw, 'Un', 0);
% noaa.time = cellfun(@(x) datenum(x{1}, 'yyyy-mm-dd HH:MM'), raw(2:end));
noaa.atmp = cellfun(@(x) str2num(x{2}), raw(2:end));

%%% wave 
cdip = dload_cdipbuoy(233, daterange+[-5 0],1, 'include', {'hs', 'dp', 'tp', 'sst'});
% cdip = dload_cdipbuoy(201, daterange+[-5 0],1, 'include', {'hs', 'dp', 'tp', 'sf'});

%%% tide

ids = {'alawa', 'maka', 'hono2', 'keehi', 'heeia', 'moku', 'halei', 'waian', 'brpt'};
for i=1:length(ids)
    disp([num2str(i) '/' num2str(length(ids)) ': ' ids{i}] )
    iocs(i) = dload_ioc(ids{i});
end

% figure(55); clf; hold on; 
% for i=1:length(iocs);
%     ioc = iocs(i);
%     plot(ioc.time, ioc.pres - nanmedian(ioc.pres))
% end


% [hfr.U hfr.V hfr.lat hfr.lon hfr.T] = dload_hfr(cdip.lat0,cdip.lon0-0.02,daterange);


%% [save] PLOT
xlims = [now-5 now+6/24];
dsmhr = 0.5/25;



figure(858); clf;
setfigsize(gcf, [1080   567].*1.2);
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
% ha = tight_subplot(4, 1, [0.01 0.05], [0.14 0.05], [0.08 0.08]);
ha = tight_subplot(4, 1, [0.01 0.05], [0.14 0.05], [0.12 0.12]);
% [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});


% -------------------------------------------------------------------------
% format_fig4print(ha)
setAllAxesOpts(ha, 'FontName', 'avenir', 'FontSize', 10);
setAllAxesOpts(ha, 'Box', 'on');
setAllAxesOpts(ha, 'XLim', xlims);
dx = 6/24;

ttlstr = ['Updated ' datestr(max([ndbc.time; noaa.time; cdip.time'])-tmzone, 'yyyy/mm/dd HH:MM') ' HST'];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 
t = noaa.time-tmzone; var = noaa.wsp./1.944; 
dt = mode(diff(t)); var = movmean(var, round(dsmhr./dt));
col = [237, 167, 81]./256;

autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx)
tt = find(isin(t, xlims));
ylims = [0 max(var(tt))+1.5]; ylim(ylims);
ylabel('wind speed [m/s]')

plot(t, var, 'b-', 'Color', col, 'LineWidth',2);

plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')

title(ttlstr, 'HorizontalAlignment', 'right')
pos = gca().Title.Position; 
pos(1) = xlims(2);
set(gca().Title, 'Position', pos);



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(2); axes(thisha); hold on; 

col = [100, 100, 100]./258;
yyaxis left; set(gca, 'YColor', col)
t = cdip.time-tmzone; var = cdip.hs.*3.28084;
dt = mode(diff(t)); var = movmean(var, round(dsmhr./dt));

autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);
tt = find(isin(t, xlims));
ylims = [0 max(var(tt)) + 0.2]; ylim(ylims)
ylabel('Hs [ft]')


plot(t, var, 'k-', 'Color', col, 'LineWidth',2)

plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')

% ff = find(cdip.f<0.15); var = 4.*sqrt(trapz(cdip.f(ff), cdip.sf(ff,:))).*3.28084;
% plot(t, var, 'k.')

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(3); axes(thisha); hold on; 



col = [154, 163, 67]./258;
% yyaxis left; set(gca, 'YColor', col)

% v0 = nanmedian(var(tt));

mvar = cellfun(@(x) nanmedian(x.*3.28084), {iocs.pres}); 
ii = find(isin(mvar, prctile(mvar, [10 90])));
ii = intersect(ii, find(isin([iocs.lon], noaa.lon + [-1 1]*0.25) & isin([iocs.lat], noaa.lat + [-1 1]*0.25)));
for io = ii
    ioc = iocs(io)
    t = ioc.time-tmzone; var = abs(ioc.pres.*3.28084); 
    dt = mode(diff(t)); tt = find([NaN diff(t)] < dt*100); t = t(tt); var = var(tt);
    tt = find(isin(t, xlims)); t = t(tt); var = var(tt);
    var = var - min(var) ;
    plot(t, var, 'g-', 'Color', col + 0.2, 'LineWidth',1)
end

t = noaa.time-tmzone; var = noaa.waterlevel; var(var==1) = NaN;
dt = mode(diff(t)); var = movmean(var, round(dsmhr./dt));
var = var - min(var);
plot(t, var, 'g-', 'Color', col, 'LineWidth',3)
plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);

tt = find(isin(t, xlims));
ylims = minmax(var(tt)) +[-1 1.2].*0.33; ylim(ylims)
ylabel('MLLW [ft]')


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(4); axes(thisha); hold on; 
% t = ndbc.time-tmzone; var = (ndbc.wtmp*9/5)+32;
t = noaa.time - tmzone; var = noaa.wtmp; 
dt = mode(diff(t)); var = movmean(var, round(dsmhr./dt));

col = [110,153,211]./256;
plot(t, var, 'b.-', 'Color', col, 'LineWidth',2.5, 'Markersize',8, 'DisplayName', ['water, buoy [-1 m]'])
plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')

autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);
ylabel('F^o')

t = cdip.sst_time-tmzone; var = (cdip.sst*9/5)+32; 
dt = mode(diff(t)); var = movmean(var, round(dsmhr./dt));
plot(t, var, 'b-', 'Color', col, 'LineWidth',1, 'Markersize',5, 'DisplayName', ['water, pier [-3.4 m]'])
plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')

t = noaa.time - tmzone; var = noaa.atmp; 
dt = mode(diff(t)); var = movmean(var, round(dsmhr./dt));
plot(t, var, 'b-', 'Color', [col+0.15 0.6], 'LineWidth',2, 'Markersize',10, 'DisplayName', ['air, pier [+16.5 m]'])
plot(t(end), var(end), 'o', 'Color', [col+0.15 0.6], 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', [col+0.15 0.6], ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')

tt = find(isin(t, xlims + [1 0]));
ylims = minmax(var(tt))+[-1 1]*1; ylim(ylims)

% -------------------------------------------------------------------------
quietaxes(ha(1:end-1), 'x');
setAllAxesOpts(ha(end), 'XLabel','PST');
setAllAxesOpts(ha(end), 'XTickLabelRotation',20);
% alignyaxes(ha, xlims(1)-tmzone+1/24);
alignyaxes(ha, xlims(1)-tmzone);


% bns = [floor(xlims(1))-1:1:xlims(2)+1];
% bns = [floor(xlims(1))-1 + 6/24:0.5:xlims(2)+1];
dys = unique(floor(cdip.time-tmzone)); dys = unique([dys max(dys):1:max(dys)+2]);
[sun_rise, sun_set] = sun_up_down(dys, cdip.lat0, cdip.lon0, 1, 0);
% sun_rise = sun_rise + 1/24;
% sun_set = sun_set + 1/24;

dataorigins = { ['tidesandcurrents.noaa.gov | ' num2str(noaa.id)], ...
                ['cdip.ucsd.edu | CDIP' num2str(cdip.id)],...
                {['ioc-sealevelmonitoring.org'],['tidesandcurrents.noaa.gov | ' num2str(noaa.id)]},...
                {['cdip.ucsd.edu | CDIP' num2str(cdip.id)], ['tidesandcurrents.noaa.gov | ' num2str(noaa.id)]}};
% dataorigins = {['tidesandcurrents.noaa.gov | ' num2str(noaa.id)],['cdip.ucsd.edu | CDIP' num2str(cdip.id)], ['tidesandcurrents.noaa.gov | ' num2str(noaa.id)], ['tidesandcurrents.noaa.gov | ' num2str(noaa.id)]};
for i=1:length(ha)
    axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
    ylims = get(gca, 'YLim');
    xlims = get(gca, 'XLim');
    text(xlims(1)+1/24, ylims(1) + diff(ylims)*0.03, dataorigins{i}, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
        'BackgroundColor',[1 1 1 0.8])
    for bi=1:length(sun_rise)-1
        disp(bi);
        
        bn = [sun_set(bi) sun_rise(bi+1)] - tmzone;
        tmp = patch([bn bn(2) bn(1)], [ylims(1) ylims(1) ylims(2) ylims(2)], 'k', 'FaceAlpha', 0.04, 'EdgeColor', 'none');
        uistack(tmp, 'bottom')
    end
end


% -------------------------------------------------------------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(2); axes(thisha); hold on; 
col = [1 1 1]*0.6;
yyaxis right; set(gca, 'YColor', col)
t = cdip.time-tmzone; var = cdip.tp;
plot(t, var, 'k.', 'Color', col)
ylabel('Tp [s]')
plot(t(end), var(end), 'o', 'Color', col*0.9, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.9, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')
ylim([0 20])
% -------------------------------------------------------------------------
savejpg(gcf, 'howsthewater_oahu', [upath wpath], 'on');


%% [download] directional plot [add data]
daterange = [now-5.5 now+2];


cdip_south = dload_cdipbuoy(233, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2'});
cdip_south.id = 233;

id = 98;
cdip_windward = dload_cdipbuoy(id, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2'});
cdip_windward.id = id;

cdip_north = dload_cdipbuoy(106, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2'});
cdip_north.id = 106;

cdip_west = dload_cdipbuoy(238, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2'});
cdip_west.id = 238;

%% [compute] 2D spectra

cdip = cdip_south;
[~, i] = min(abs(cdip.time- (now + tmzone)));
t0 = cdip.time(i);
sp_data.freq = cdip.f'; 
sp_data.band_width = cdip.df'; 
sp_data.ener_dens = cdip.sf(:,i); 
sp_data.a1 = cdip.a1(:,i); 
sp_data.b1 = cdip.b1(:,i); 
sp_data.a2 = cdip.a2(:,i); 
sp_data.b2 = cdip.b2(:,i); 
[mem_out] = MEM_est(sp_data);
cdip_south.mem_out = mem_out;


cdip = cdip_windward;
[~, i] = min(abs(cdip.time- (now + tmzone)));
t0 = cdip.time(i);
sp_data.freq = cdip.f'; 
sp_data.band_width = cdip.df'; 
sp_data.ener_dens = cdip.sf(:,i); 
sp_data.a1 = cdip.a1(:,i); 
sp_data.b1 = cdip.b1(:,i); 
sp_data.a2 = cdip.a2(:,i); 
sp_data.b2 = cdip.b2(:,i); 
[mem_out] = MEM_est(sp_data);
cdip_windward.mem_out = mem_out;

cdip = cdip_north;
[~, i] = min(abs(cdip.time- (now + tmzone)));
t0 = cdip.time(i);
sp_data.freq = cdip.f'; 
sp_data.band_width = cdip.df'; 
sp_data.ener_dens = cdip.sf(:,i); 
sp_data.a1 = cdip.a1(:,i); 
sp_data.b1 = cdip.b1(:,i); 
sp_data.a2 = cdip.a2(:,i); 
sp_data.b2 = cdip.b2(:,i); 
[mem_out] = MEM_est(sp_data);
cdip_north.mem_out = mem_out;

cdip = cdip_west;
[~, i] = min(abs(cdip.time- (now + tmzone)));
t0 = cdip.time(i);
sp_data.freq = cdip.f'; 
sp_data.band_width = cdip.df'; 
sp_data.ener_dens = cdip.sf(:,i); 
sp_data.a1 = cdip.a1(:,i); 
sp_data.b1 = cdip.b1(:,i); 
sp_data.a2 = cdip.a2(:,i); 
sp_data.b2 = cdip.b2(:,i); 
[mem_out] = MEM_est(sp_data);
cdip_west.mem_out = mem_out;

%% [off] spectrogram over past three days

% xlims = [now-5 now+6/24];
% 
% 
% 
% 
% figure(93); clf;
% % setfigsize(gcf, [393   297]);
% setfigsize(gcf, [976         422])
% % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
% ha = tight_subplot(2, 1, [0.01 0.05], [0.145 0.05], [0.08 0.08]);
% % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% % -------------------------------------------------------------------------
% setaxes(ha, 'FontName', 'avenir')
% setaxes(ha, 'CLim',[-4 0.9])
% colormap(jet);
% 
% setaxes(ha, 'Layer', 'top');
% setaxes(ha, 'FontSize', 12);
% setaxes(ha, 'Box', 'on');
% setaxes(ha, 'XLim', xlims);
% setaxes(ha, 'YLim', [0.04 0.55]);
% setaxes(ha, 'YMinorGrid', 'off');
% setaxes(ha, 'YLabel', 'f [Hz]');
% setaxes(ha, 'YTick', [0.05 0.1 0.2 0.5]);
% setloglog(ha, 'y'); 
% dx = 12/24;
% ttlstr = ['Updated ' datestr(max([ndbc.time; noaa.time; cdip.time'])-tmzone, 'yyyy/mm/dd HH:MM') ' PST'];
% 
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(2); axes(thisha); hold on; 
% cdip = cdip_inner;
% x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
% pcolor(x,y,Z); shading flat;
% [X Y] = ndgrid(x,y); Z = movmean(Z,3,1); Z = movmean(Z,(2./24)./dt,2);
% % contourf(X,Y,Z', [-4:0.25:2])
% contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.5)
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(1); axes(thisha); hold on; 
% cdip = cdip_outer;
% x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
% pcolor(x,y,Z); shading flat;
% [X Y] = ndgrid(x,y); Z = movmean(Z,3,1); Z = movmean(Z,(2./24)./dt,2);
% % contourf(X,Y,Z', [-4:0.25:2])
% contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.5)
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);
% 
% 
% % -------------------------------------------------------------------------
% quietaxes(ha(1:end-1), 'x');
% setaxes(ha(end), 'XLabel','PST');
% setaxes(ha(end), 'XTickLabelRotation',20);
% alignyaxes(ha, xlims(1)-tmzone -1/24);
% 
% bns = [floor(xlims(1))-1:1:xlims(2)+1];
% bns = [floor(xlims(1))-1 + 6/24:0.5:xlims(2)+1];
% 
% dataorigins = {['cdip.ucsd.edu | CDIP'  num2str(cdip_inner.id)], ['cdip.ucsd.edu | CDIP' num2str(cdip_inner.id)]};
% for i=1:length(ha)
%     axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
%     ylims = get(gca, 'YLim');
%     xlims = get(gca, 'XLim');
%     text(xlims(1)+1/24, ylims(1) + 0.005, dataorigins{i}, ...
%         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
%         'BackgroundColor',[1 1 1 0.8])
% end

%% [save] spectrogram over past three days and partition hs

% xlims = [now-5 now+6/24];
xlims = [now-5 now+6/24];


ytx = [20 10 5 2]; ylb = strsplit(num2str(ytx), ' '); ylb = cellfun(@(x) [x 's'], ylb, 'Un', 0);


figure(94); clf;
% setfigsize(gcf, [393   297]);
setfigsize(gcf, [976         522].*1.2)
setfigsize(gcf, [1080   567].*1.2);
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
% oldha = tight_subplot(6, 1, [0.01 0.05], [0.125 0.015], [0.08 0.08]);
% oldha = tight_subplot(6, 1, [0.01 0.05], [0.125 0.015], [0.12 0.12]);
oldha = tight_subplot(6, 1, [0.01 0.05], [0.14 0.05], [0.12 0.12]);
[ha] = reorg_tightsubplot(oldha, {1,2,[3:4],[5:6]});
% -------------------------------------------------------------------------
setaxes(ha, 'FontName', 'avenir', 'Fontsize',10)
setaxes(ha, 'Layer', 'top');
setaxes(ha, 'Box', 'on');
setaxes(ha, 'CLim',[-3.2 0.8])
colormap(jet);
setaxes(ha, 'XLim', xlims);
setaxes(ha(3:4), 'YLim', [0.04 0.55]);
setaxes(ha(3:4), 'YMinorGrid', 'off');
setaxes(ha(3:4), 'YLabel', 'f [Hz]');
setaxes(ha(3:4), 'YTick', [0.05 0.1 0.2 0.5]);
setloglog(ha(3:4), 'y'); 
dx = 6/24;
ttlstr = ['Updated ' datestr(max([cdip_windward.time cdip_south.time])-tmzone, 'yyyy/mm/dd HH:MM') ' PST'];


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fsplit = 0.1;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 
title(gca, ttlstr, 'HorizontalAlignment', 'right')

flims = [fsplit 0.5];
col = [1 1 1].*0.3;
cdip = cdip_south; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims)); var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])

col = [1 1  1].*0.6;
cdip = cdip_windward; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims));  var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])


tt = find(isin(cdip_windward.time, xlims));
ylims = [0 max(cdip_windward.hs(tt)).*3.28084 + 0.2]; ylim(ylims)
ylabel('Hs_{seas} [ft]')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);

title(ttlstr, 'HorizontalAlignment', 'right')
pos = gca().Title.Position; 
pos(1) = xlims(2);
set(gca().Title, 'Position', pos);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(2); axes(thisha); hold on; 


flims = [0.05 fsplit];
col = [1 1 1].*0.3;
cdip = cdip_south; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims, 'inclusive')); var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])

col = [1 1  1].*0.6;
cdip = cdip_windward; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims, 'inclusive'));  var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])

tt = find(isin(cdip_windward.time, xlims));
ylims = [0 max(cdip_windward.hs(tt)).*3.28084 + 0.2]; ylim(ylims)
ylabel('Hs_{swell} [ft]')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(4); axes(thisha); hold on; 
yyaxis right; set(gca, 'YColor', 'k')
ylim([0.04 0.55]); setloglog(gca, 'y');
yticks(1./ytx);
set(gca, 'YTickLabel', ylb)

yyaxis left; set(gca, 'YColor', 'k')
cdip = cdip_south;
x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
pcolor(x,y,Z); shading flat;
[X Y] = ndgrid(x,y); Z = movmean(Z,(2./24)./dt,2); Z = movmean(Z,3,1); 
% contourf(X,Y,Z', [-4:0.25:2])
contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.25)
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(3); axes(thisha); hold on; 
yyaxis right; set(gca, 'YColor', 'k')
ylim([0.04 0.55]); setloglog(gca, 'y');
yticks(1./ytx);
set(gca, 'YTickLabel', ylb)

yyaxis left; set(gca, 'YColor', 'k')
cdip = cdip_windward;
x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
pcolor(x,y,Z); shading flat;
[X Y] = ndgrid(x,y); Z = movmean(Z,(2./24)./dt,2); Z = movmean(Z,3,1); 
% contourf(X,Y,Z', [-4:0.25:2])
contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.25)
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);


% -------------------------------------------------------------------------
quietaxes(ha(1:end-1), 'x');
setaxes(ha(end), 'XLabel','PST');
setaxes(ha(end), 'XTickLabelRotation',20);
alignyaxes(ha, xlims(1)-tmzone);

bns = [floor(xlims(1))-1:1:xlims(2)+1];
bns = [floor(xlims(1))-1 + 6/24:0.5:xlims(2)+1];

dys = unique(floor(cdip.time-tmzone)); dys = unique([dys max(dys):1:max(dys)+2]);
[sun_rise, sun_set] = sun_up_down(dys, cdip.lat0, cdip.lon0, 0, 0);


dataorigins = {'', '',['cdip.ucsd.edu | CDIP'  num2str(cdip_windward.id)], ['cdip.ucsd.edu | CDIP' num2str(cdip_south.id)]};
for i=1:length(ha)
    axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
    ylims = get(gca, 'YLim');
    xlims = get(gca, 'XLim');
    text(xlims(1)+1/24, ylims(1) + 0.005, dataorigins{i}, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
        'BackgroundColor',[1 1 1 0.8])

    
    for bi=1:length(sun_rise)-1
        disp(bi);
        bn = [sun_set(bi) sun_rise(bi+1)] - tmzone;
        tmp = patch([bn bn(2) bn(1)], [ylims(1) ylims(1) ylims(2) ylims(2)], 'k', 'FaceAlpha', 0.04, 'EdgeColor', 'none');
        uistack(tmp, 'bottom')
    end

    if i==1 
        leg = cleanLegend(gca, 'southwest', 'NumColumns',2, 'FontSize',10, 'FontName', 'avenir'); 
        leg.Box = 0;
        leg.ItemTokenSize = leg.ItemTokenSize/2;
        leg.Position(1) = leg.Position(1) - 0.005;
        leg.Position(2) = leg.Position(2) - 0.0085;
    end

end

savejpg(gcf, 'howsthespectrograms_oahu', [upath wpath], 'on');


%% [save] directional plot
figure(92); clf; 
% setfigsize(gcf, [393   297]);
setfigsize(gcf, [872   378].*1.2)
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
ha = tight_subplot(1, 2, [0.05 0.1], [0.01 0.12], [0.2 0.2]);
% [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% -------------------------------------------------------------------------
setaxes(ha, 'FontName', 'avenir')
setaxes(ha, 'CLim',[-7 -2])
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 
cdip = cdip_windward; mem_out = cdip.mem_out; 
title({ ['CDIP' num2str(cdip.id)], [datestr(t0-tmzone ,'yyyy/mm/dd HH:MM') ' PST'] })
th = mem_out.dir; fr = mem_out.freq; Efth = mem_out.ds; fr = log10(fr); f0 = log10(0.02); fr = fr - f0;;
ph = makePolarGrid(...
  'ALabelScheme', 'wave',...
  'RTicks',        0.01:0.21:max(fr)+0.2,...  % Radial ticks (inner circles)
  'RUnits',        '[Hz]',...   % Add units to outer-most radial labels
  'AMinorTicks', 0, ...
  'RScale', 'linear');         
[md,mf] = meshgrid(th,(fr));
[px,py] = polgrid2cart(md, mf, ph);
z = Efth;z = log10(z);
[~,hc]  = contourf(px, py, z, 10);
uistack(hc, 'bottom');  % this will put the grid on top of the contours
hc.LineStyle = 'none';  % enable/disble contour lines

rstrs = {ph.RLabels.String};
rstrs = cellfun(@(x) round(10.^(str2num(x)+f0),2), rstrs, 'Un',0);
tmp = strsplit(ph.RLabels(end).String);
rstrs{end} = round(10.^(str2num(tmp{1})+f0),2);
rstrs = cellfun(@num2str,rstrs, 'Un',0);
rstrs{end-1} = [rstrs{end-1} ' [Hz]'];
rstrs{1} = '';
rstrs{end} = '';
for j=1:length(rstrs)
    set(ph.RLabels(j), 'String', rstrs(j));
    set(ph.RLabels(j), 'Color', 'w');
    set(ph.RLabels(j), 'HorizontalAlignment', 'left');
    set(ph.RLabels(j), 'VerticalAlignment', 'top');
    set(ph.RLabels(j), 'FontName', 'avenir');
    set(ph.ALabels(j), 'FontSize', 10);
end

% caxis([-7 -2])
% c = fixedcolorbar(gca); 
% colormap(jet);
% c.Position(1) = c.Position(1) + 0.04;
% c.Position(4) = c.Position(4)*0.3;
% c.Position(2) = c.Position(2)+0.055;
% ylabel(c, '{\it log_{10}[S(f)] }', 'FontName', 'avenir')

% 
% col = [237, 167, 81]./256;
% t = noaa.time; var = noaa.wsp./1.944;
% th = met2oc(oc2pol(noaa.wdir));
% u = var.*cosd(th);
% v = var.*sind(th);
% tt = find(isin(t,[t0-1/24 t0+1/24]));
% tt = find(isin(t,[t0-0.5/24 t0+0.5/24]));
% u0 = nanmean(u(tt)); v0 = nanmean(v(tt)); th0 = atan2d(v0, u0); spd0 = sqrt(u0.^2 + v0.^2);
% scl =0.25;
% x0 = -cosd(th0).*max(fr); y0 = -sind(th0).*max(fr);
% % x0 = 0; y0 = 0;
% quiver(x0,y0,scl*u0, scl*v0, 'w-', 'AutoScale','off', 'LineWidth',6, 'MaxHeadSize',0.4, 'Color', 'w')
% quiver(x0,y0,scl*u0, scl*v0, 'w-', 'AutoScale','off', 'LineWidth',3, 'MaxHeadSize',0.35, 'Color', col)
% text(x0 + x0*0.2,y0 + y0*0.1, [num2str(round(spd0,1))  ' m/s'],...
%     'FontName', 'avenir', 'Color', col, 'BackgroundColor', [1 1 1 0.9], 'Margin', 0.2, 'HorizontalAlignment','center', 'VerticalAlignment','middle')
% 
% fp = 1./cdip.tp(i); dp = cdip.dp(i); dp = (oc2pol(dp));
% fp = log10(fp)-f0;
% fxp = cosd(dp).*fp; fyp = sind(dp).*fp;
% scatter(fxp, fyp, 30, col, 'filled', 'MarkerFaceAlpha', [0.8])
% text(fxp+0.02, fyp+0.02, {['' num2str(round(cdip.tp(i),1)) 's']}, 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'FontName', 'avenir', 'FontSize',8)

col = [1 1 1]*0.2;
x = mem_out.freq; y = mem_out.dir; z = log10(mem_out.ds);
z = movmean(z,3,1);
z = movmean(z,3,2);
[~,ith] = max(z, [],2);
[~,im] = max(diag(z(:,ith)));
fp0 = x(im); dp0 = y(ith(im)); 
dp0 = round(dp0./5)*5; 
fp = log10(fp0)-f0;
dp = oc2pol(dp0);
fxp = cosd(dp).*fp; fyp = sind(dp).*fp;
scatter(fxp, fyp, 30, col, 'filled', 'MarkerFaceAlpha', [0.8])
text(fxp+0.02, fyp+0.02, {['' num2str(round(1./fp0,1)) 's']}, 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'FontName', 'avenir', 'FontSize',8)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(2); axes(thisha); hold on; 
cdip = cdip_south;  mem_out = cdip.mem_out; 
title({ ['CDIP' num2str(cdip.id)], [datestr(t0-tmzone ,'yyyy/mm/dd HH:MM') ' PST'] })
th = mem_out.dir; fr = mem_out.freq; Efth = mem_out.ds; fr = log10(fr); f0 = log10(0.02); fr = fr - f0;;
ph = makePolarGrid(...
  'ALabelScheme', 'wave',...
  'RTicks',        0.01:0.21:max(fr)+0.2,...  % Radial ticks (inner circles)
  'RUnits',        '[Hz]',...   % Add units to outer-most radial labels
  'AMinorTicks', 0, ...
  'RScale', 'linear');         
[md,mf] = meshgrid(th,(fr));
[px,py] = polgrid2cart(md, mf, ph);
z = Efth;z = log10(z);
[~,hc]  = contourf(px, py, z, 10);
uistack(hc, 'bottom');  % this will put the grid on top of the contours
hc.LineStyle = 'none';  % enable/disble contour lines

rstrs = {ph.RLabels.String};
rstrs = cellfun(@(x) round(10.^(str2num(x)+f0),2), rstrs, 'Un',0);
tmp = strsplit(ph.RLabels(end).String);
rstrs{end} = round(10.^(str2num(tmp{1})+f0),2);
rstrs = cellfun(@num2str,rstrs, 'Un',0);
rstrs{end-1} = [rstrs{end-1} ' [Hz]'];
rstrs{1} = '';
rstrs{end} = '';
for j=1:length(rstrs)
    set(ph.RLabels(j), 'String', rstrs(j));
    set(ph.RLabels(j), 'Color', 'w');
    set(ph.RLabels(j), 'HorizontalAlignment', 'left');
    set(ph.RLabels(j), 'VerticalAlignment', 'top');
    set(ph.RLabels(j), 'FontName', 'avenir');
    set(ph.ALabels(j), 'FontSize', 10);
end

c = fixedcolorbar(gca); 
colormap(jet);
c.Position(1) = c.Position(1) + 0.04;
c.Position(4) = c.Position(4)*0.3;
c.Position(2) = c.Position(2)+0.055;
ylabel(c, '$\it log_{10}$[S(f)] ', 'FontName', 'avenir')


% col = [237, 167, 81]./256;
% t = noaa.time; var = noaa.wsp./1.944;
% th = met2oc(oc2pol(noaa.wdir));
% u = var.*cosd(th);
% v = var.*sind(th);
% tt = find(isin(t,[t0-1/24 t0+1/24]));
% tt = find(isin(t,[t0-0.5/24 t0+0.5/24]));
% u0 = nanmean(u(tt)); v0 = nanmean(v(tt)); th0 = atan2d(v0, u0); spd0 = sqrt(u0.^2 + v0.^2);
% scl =0.25;
% x0 = -cosd(th0).*max(fr); y0 = -sind(th0).*max(fr);
% % x0 = 0; y0 = 0;
% quiver(x0,y0,scl*u0, scl*v0, 'w-', 'AutoScale','off', 'LineWidth',6, 'MaxHeadSize',0.4, 'Color', 'w')
% quiver(x0,y0,scl*u0, scl*v0, 'w-', 'AutoScale','off', 'LineWidth',3, 'MaxHeadSize',0.35, 'Color', col)
% text(x0 + x0*0.2,y0 + y0*0.1, [num2str(round(spd0,1))  ' m/s'],...
%     'FontName', 'avenir', 'Color', col, 'BackgroundColor', [1 1 1 0.9], 'Margin', 0.2, 'HorizontalAlignment','center', 'VerticalAlignment','middle')

col = [1 1 1]*0.2;
[~, i] = min(abs(cdip.time- (now + tmzone)));
fp = 1./cdip.tp(i); dp = cdip.dp(i); dp = (oc2pol(dp));
fp = log10(fp)-f0;
fxp = cosd(dp).*fp; fyp = sind(dp).*fp;
scatter(fxp, fyp, 30, col, 'filled', 'MarkerFaceAlpha', [0.8])
text(fxp+0.02, fyp+0.02, {['' num2str(round(cdip.tp(i),1)) 's']}, 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'FontName', 'avenir', 'FontSize',8)


savejpg(gcf, 'howsthewaves_oahu', [upath wpath], 'on')


%% [off] map
%{
% -------------------------------------------------------------------------
    % -------------------------------------------------------------------------
    figure(855); clf;  
    setfigsize(gcf, [1025   625])
    % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
    ha = tight_subplot(1, 1, [0.05 0.05], [0.11 0.01], [1 1].*0.1);
    % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
    % -------------------------------------------------------------------------
    % ha(2) = axes; ha(2).Position = ha(1).Position; 
    % ha(2).Position(3) = ha(2).Position(3)./4;
    % ha(2).Position(4) = ha(2).Position(4)./5.5;
    % 
    % 
    % ha(2).Position([1 2]) = ha(1).Position([1 2]) + [ha(1).Position([3 4]) -  ha(2).Position([3 4])].*[1 0] +  ha(2).Position([3 4]).*0.14.*[-1 1]
    % % ha(2).Position([1 2]) = -  ha(2).Position([3 4]) + ha(1).Position([3 4]).*0.1;
   
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = ha(1); axes(thisha); hold on; 

    % format_fig4print(gca, 'FontName', 'avenir')
    set(gca, 'FontName', 'avenir')
    set(gca, 'FontName', 'avenir')
    set(gca, 'YTickLabelRotation',15)
    set(gca, 'XTickLabelRotation',15)
    set(gca, 'FontSize',10)
    set(gca, 'YLim', 21.5 + [-1 1]*0.35-0.1)
    set(gca, 'XLim', -158.01 + [-1 1]*0.5 + 0.1)
    set(gca, 'YLim', 21.5 + [-1 1]*0.2-0.1)
    set(gca, 'XLim', -158.01 + [-1 1]*0.3 + 0.15)
    set(gca, 'CLim', [-2000 0])
    
    % ylim(minmax(y0))
    grid on; box on;
    set(gca, 'Layer', 'top');
    set(gca, 'DataAspectRatio', [1 1 1])
    ylabel('lat [deg]'); xlabel('lon [deg]')
    % -------------------------------------------------------------------------
    xlims =get(gca, 'XLim'); ylims = get(gca, 'YLim');
    % [ELEV,LON,LAT]=m_etopo2([xlims ylims]);
    % pcolor(LON, LAT, -ELEV); shading flat;
    bathy = load_any_nc([upath regpath 'hawaii_mhi_mbsyn_bathytopo_50m_v21.nc']);
    xx = find(isin(bathy.lon, xlims)); yy = find(isin(bathy.lat, ylims));
    pcolor(bathy.lon(xx), bathy.lat(yy), bathy.z(xx,yy)'); shading flat;
    mindepth = 1000; maxelev = 1000;
    
    c = fixedcolorbar(gca, 'Location', 'southoutside'); 
    c.Position([3 4]) = c.Position([3 4])./[8 1.5];
    c.Position([1 2]) = thisha.Position([1 2]) + thisha.Position([3 4]).*[0.05 0.1];
    ylabel(c, 'z [m]', 'fontname', 'avenir', 'interpreter', 'none')

  

    N = 700;
    cmap_sea = buildcmap([0.07 0.25 0.42; 0.27 0.47 0.63; 0.5 0.77 0.87; 0.74 0.86 0.9], N-1);
    cmap_beach = buildcmap([0.73 0.76 0.45; 0.32 0.47 0.08], floor(N.*0.05));
    cmap_land = buildcmap([0.32 0.47 0.08; 0.6 0.72 0.43], ceil(N.*0.95));
    cmap_land = [cmap_beach; cmap_land];
    landrat = maxelev./mindepth; landrat = abs(landrat); 
    cmap = [cmap_sea; (cmap_land(1:landrat*length(cmap_land),:))];
    colormap(gca, cmap); 
    % mindepth = min(bathy.z(xx,yy), [], [1 2]); 
    
    mindepth = abs(ceil(mindepth./100)*100);
    caxis([-1 landrat].*mindepth);

    buoycol = cmap(1,:) + [0.4 0.6 0.6];
    buoycol =  + [0.6 0.6 0.6]+0.2;

    % -------------------------------------------------------------------------
    txtstyles = {'FontName', 'avenir', 'HorizontalAlignment','left', 'VerticalAlignment','bottom'};
    
    cdip = cdip_south;
    [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon(ti), cdip.lat(ti), 'wo', 'LineWidth',1, 'Color', 'k', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', ['CDIP' num2str(cdip.id)], ...
        'MarkerFaceColor',buoycol)

    cdip = cdip_windward;
    [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon(ti), cdip.lat(ti), 'wo', 'LineWidth',1, 'Color', 'k', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', ['CDIP' num2str(cdip.id)], ...
        'MarkerFaceColor',buoycol.*0.6 + [buoycol - nanmean(buoycol)].*1.4)
    
    plot(noaa.lon, noaa.lat, 'bo', 'MarkerFaceColor',buoycol + 0.2, 'MarkerEdgeColor','k', 'linewidth',2, 'DisplayName',['NOAA ' num2str(noaa.id)])
    % plot([-117.255886 -117.2573], [32.86665 32.8670],'w-', 'LineWidth',3, 'Color', cmap(1,:) + [0.4 0.5 0.5], 'DisplayName', 'Scripps Pier | 9410230')
    

    % [~, ti] = min(abs((cdipouter.time-tmzone)-now));
    % text(max(x0) - range(x0).*0.03, min(y0) + range(y0).*0.016,...
    %     {['CDIP100 | ' datestr(cdipouter.time(ti) - tmzone, 'yyyy/mm/dd HH:MM') 'PST']},...
    %     txtstyles{:}, 'Color', 'w','HorizontalAlignment','right', 'FontSize',8);
    % 
    % text(max(x0) - range(x0).*0.45, min(y0) + range(y0).*0.0005,...
    %     {['Tp=' num2str(round(tp0)) 's'],['Dp=' num2str(pol2oc(met2oc(rad2deg(th0)))) '^o'],Ustr},...
    %     txtstyles{:}, 'Color', 'w', 'FontSize',12);

    % textbypos((ha(2).Position([1])) - 0.2, ha(2).Position([2]),...
    %     {['Tp=' num2str(round(tp0)) 's'],['Dp=' num2str(pol2oc(met2oc(rad2deg(th0)))) '^o'],Ustr},...
    %     txtstyles{:}, 'Color', 'w', 'FontSize',12, 'HorizontalAlignment','left');
    

    cleanLegend(gca, 'northeast','NumColumns',3, 'FontName', 'avenir', 'Color', [1 1 1 0.5], 'EdgeColor', 'none', 'FontSize',8)


    savejpg(gcf, 'howsthe_map_oahu', [upath wpath], 'on')

    %}


%% [save] map add directional!
    % -------------------------------------------------------------------------
    % -------------------------------------------------------------------------
    figure(855); clf;  
    setfigsize(gcf, [1339         966])
    % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
    ha = tight_subplot(1, 1, [0.05 0.05], [0.11 0.01], [1 1].*0.08);
    % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
    % -------------------------------------------------------------------------
    % ha(2) = axes; ha(2).Position = ha(1).Position; 
    % ha(2).Position(3) = ha(2).Position(3)./4;
    % ha(2).Position(4) = ha(2).Position(4)./5.5;
    % 
    % 
    % ha(2).Position([1 2]) = ha(1).Position([1 2]) + [ha(1).Position([3 4]) -  ha(2).Position([3 4])].*[1 0] +  ha(2).Position([3 4]).*0.14.*[-1 1]
    % % ha(2).Position([1 2]) = -  ha(2).Position([3 4]) + ha(1).Position([3 4]).*0.1;
   
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = ha(1); axes(thisha); hold on; 

    % format_fig4print(gca, 'FontName', 'avenir')
    set(gca, 'FontName', 'avenir')
    set(gca, 'FontName', 'avenir')
    set(gca, 'YTickLabelRotation',15)
    set(gca, 'XTickLabelRotation',15)
    set(gca, 'FontSize',10)
    set(gca, 'YLim', 21.5 + [-1.4 1]*0.35-0.01)
    set(gca, 'XLim', -158.01 + [-1 1]*0.55 + 0.01)
    % set(gca, 'YLim', 21.5 + [-1.5 1]*0.2-0.1)
    % set(gca, 'XLim', -158.01 + [-1 1]*0.3 + 0.15)
    set(gca, 'CLim', [-2000 0])
    
    % ylim(minmax(y0))
    grid on; box on;
    set(gca, 'Layer', 'top');
    set(gca, 'DataAspectRatio', [1 1 1])
    ylabel('lat [deg]'); xlabel('lon [deg]')
    % -------------------------------------------------------------------------
    xlims =get(gca, 'XLim'); ylims = get(gca, 'YLim');
    % [ELEV,LON,LAT]=m_etopo2([xlims ylims]);
    % pcolor(LON, LAT, -ELEV); shading flat;
    bathy = load_any_nc([upath regpath 'hawaii_mhi_mbsyn_bathytopo_50m_v21.nc']);
    xx = find(isin(bathy.lon, xlims)); yy = find(isin(bathy.lat, ylims));
    pcolor(bathy.lon(xx), bathy.lat(yy), bathy.z(xx,yy)'); shading flat;
    mindepth = 2800; maxelev = 1000;
    
    c = fixedcolorbar(gca, 'Location', 'southoutside', 'color', 'w'); 
    c.Position([3 4]) = c.Position([3 4])./[13 1.5];
    c.Position([1 2]) = thisha.Position([1 2]) + thisha.Position([3 4]).*([-0.05 0.05] + [1 0]) +  c.Position([3 4]).*[-1 1];
    ylabel(c, 'z [m]', 'fontname', 'avenir', 'interpreter', 'none')
    cbarpos = c.Position; 

    
  

    N = 700;
    % cmap_sea = buildcmap([0.07 0.25 0.42; 0.27 0.47 0.63; 0.5 0.77 0.87; 0.74 0.86 0.9], N-1);
    cmap_sea = buildcmap([0.08 0.17 0.26; 0.07 0.25 0.42; 0.16 0.37 0.52; 0.27 0.47 0.63; 0.5 0.77 0.87; 0.74 0.86 0.9], N-1);
    cmap_beach = buildcmap([0.73 0.76 0.45; 0.32 0.47 0.08], floor(N.*0.05));
    % cmap_land = buildcmap([0.32 0.47 0.08; 0.6 0.72 0.43], ceil(N.*0.95));
    cmap_land = buildcmap([0.32 0.47 0.08; 0.12 0.35 0.1; 0.07 0.22 0.06; 0.26 0.34 0.31], ceil(N.*0.95));
    cmap_land = [cmap_beach; cmap_land];
    landrat = maxelev./mindepth; landrat = abs(landrat); 
    cmap = [cmap_sea; subsetcmap(cmap_land,  round(landrat*length(cmap_land)))];
    % cmap = [cmap_sea; (cmap_land(1:landrat*length(cmap_land),:))];
    colormap(gca, cmap); 
    % mindepth = min(bathy.z(xx,yy), [], [1 2]); 
    
    mindepth = abs(ceil(mindepth./100)*100);
    caxis([-1 landrat].*mindepth);

    buoycol = cmap(1,:) + [0.4 0.6 0.6];
    buoycol =  + [0.6 0.6 0.6]+0.2;

    % -------------------------------------------------------------------------
    % -------------------------------------------------------------------------
    txtstyles = {'FontName', 'avenir', 'HorizontalAlignment','left', 'VerticalAlignment','bottom'};
    
    cdip = cdip_south;
    % [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon0, cdip.lat0, 'ro', 'LineWidth',2, 'Color', 'r', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', ['CDIP' num2str(cdip.id)], ...
        'MarkerFaceColor',buoycol)
    text(cdip.lon0-0.008, cdip.lat0-0.008, ['CDIP' num2str(cdip.id)], 'FontSize',10, 'FontName','avenir', 'color', 'r', ...
        'HorizontalAlignment', 'right', 'VerticalAlignment','top')

    cdip = cdip_windward;
    % [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon0, cdip.lat0, 'ro', 'LineWidth',2, 'Color', 'r', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', ['CDIP' num2str(cdip.id)], ...
        'MarkerFaceColor',buoycol.*0.6 + [buoycol - nanmean(buoycol)].*1.4)
    text(cdip.lon0+0.008, cdip.lat0+0.008, ['CDIP' num2str(cdip.id)], 'FontSize',10, 'FontName','avenir', 'color', 'r', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment','bottom')

    cdip = cdip_north;
    % [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon0, cdip.lat0, 'ro', 'LineWidth',2, 'Color', 'r', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', ['CDIP' num2str(cdip.id)], ...
        'MarkerFaceColor',buoycol.*0.6 + [buoycol - nanmean(buoycol)].*1.4)
    text(cdip.lon0+0.008, cdip.lat0+0.008, ['CDIP' num2str(cdip.id)], 'FontSize',10, 'FontName','avenir', 'color', 'r', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment','bottom')

    cdip = cdip_west;
    % [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon0, cdip.lat0, 'ro', 'LineWidth',2, 'Color', 'r', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', ['CDIP' num2str(cdip.id)], ...
        'MarkerFaceColor',buoycol)
    text(cdip.lon0-0.008, cdip.lat0-0.008, ['CDIP' num2str(cdip.id)], 'FontSize',10, 'FontName','avenir', 'color', 'r', ...
        'HorizontalAlignment', 'right', 'VerticalAlignment','top')
    
   
    for io = 1:length(iocs); 
        ioc = iocs(io); 
        minN = [(1/24)./mode(diff(ioc.time))];
        tt = find(isin(ioc.time-tmzone, [now - 3/24 now])); 
        if length(tt)<minN; slpstr = ''; else
            mdl = fitlm(ioc.time(tt), ioc.pres(tt));
            slp = mdl.Coefficients.Estimate(2); slp = round(slp,1); 
            % figure(23132);clf; plot(ioc.time, ioc.pres); hold on; plot(ioc.time(tt), ioc.pres(tt), 'r.')
            % % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % thisha = ha(1); axes(thisha); hold on; 
            % slpth = atan2d(slp,1);
            % [slpu, slpv] = pol2cart(deg2rad(slpth), 1); sc = 0.01;
            % quiver(ioc.lon+0.004, ioc.lat+0.01, sc.*slpu, sc.*slpv, 'k-', 'AutoScale', 'off', 'maxheadsize',1)
            slpstr = '→'; dx = 0.0002; dy = -0.009; 
            if slp>0.5; slpstr = '↑'; dx = -0.009; dy = 0; 
            elseif slp<-0.5; slpstr = '↓'; dx = -0.009; dy = 0; 
            end
            text(ioc.lon+dx, ioc.lat+dy, [slpstr], 'FontSize',10, 'FontName','avenir', 'color', [1 1  1]*0.1, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment','middle');
            % pause;
        end

        lab = strsplit(erase(ioc.info, {'Tide gauge ', 'Hbr', ',Oahu'}), ', ');
        plot(ioc.lon, ioc.lat, 'bo', 'MarkerFaceColor',buoycol + 0.2, 'MarkerEdgeColor',[1 1  1]*0.3, 'linewidth',1, 'DisplayName',['IOC ' ioc.id], 'markersize',5);

        
        text(ioc.lon+0.002, ioc.lat+0.005, ['IOC ' lab{1}], 'FontSize',8, 'FontName','avenir', 'color', [1 1  1]*0.3, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment','bottom')
    end

    plot(noaa.lon, noaa.lat, 'bo', 'MarkerFaceColor',buoycol + 0.2, 'MarkerEdgeColor','k', 'linewidth',2, 'DisplayName',['NOAA ' num2str(noaa.id)])
    text(noaa.lon-0.025, noaa.lat-0.005, ['NOAA' num2str(noaa.id)], 'FontSize',8, 'FontName','avenir', 'color', 'k', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment','top')

    % cleanLegend(gca, 'northeast','NumColumns',3, 'FontName', 'avenir', 'Color', [1 1 1 0.5], 'EdgeColor', 'none', 'FontSize',8)

    % -------------------------------------------------------------------------
    % DURECTUIBAK OKITS
    % -------------------------------------------------------------------------

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = axes; hold on; thisha.Position = ha(1).Position; set(gca, 'Color', 'w')
    thisha.Position = thisha.Position.*[1 1 0.25 0.25]; thisha.Position(3:4) = thisha.Position(3).*[1 1.5].*0.9;
    thisha.Position(1:2) = thisha.Position(1:2)  + thisha.Position(3:4).*[0.2 0.8];
    % + thisha.Position(3:4).*[0.5 0];
    % thisha.Position(1:2) = thisha.Position(1:2) + thisha.Position(3:4).*0.1.*[6 0.7];
    colormap(gca,jet); caxis([-6.5 -1.5])

    cdip = cdip_west; mem_out = cdip.mem_out; 

    % title({[datestr(t0-tmzone ,'yyyy/mm/dd HH:MM') ' PST'] }, 'color', 'w', 'fontweight', 'normal', 'fontname', 'avenir')
    th = mem_out.dir; fr = mem_out.freq; Efth = mem_out.ds; 
    % ff = find(fr>0.4); Efth(ff,:) = NaN;
    fr = log10(fr); f0 = log10(0.02); fr = fr - f0;;
    ph = makePolarGrid(...
        'ALabelScheme', 'wave',...
        'RTicks',        [0.01:0.21:max(fr) max(fr)*1.015],...  % Radial ticks (inner circles)
        'RUnits',        '[Hz]',...   % Add units to outer-most radial labels
        'AMinorTicks', 0, ...
        'RScale', 'linear', 'GridColor', [1 1 1], 'FontName', 'avenir', 'FontSize',6);         
    [md,mf] = meshgrid(th,(fr));
    [px,py] = polgrid2cart(md, mf, ph);
    z = Efth;z = log10(z);
    [~,hc]  = contourf(px, py, z, 10);
    uistack(hc, 'bottom');  % this will put the grid on top of the contours
    hc.LineStyle = 'none';  % enable/disble contour lines


    rstrs = {ph.RLabels.String};
    rstrs = cellfun(@(x) round(10.^(str2num(x)+f0),2), rstrs, 'Un',0);
    tmp = strsplit(ph.RLabels(end).String);
    rstrs{end} = round(10.^(str2num(tmp{1})+f0),2);
    rstrs = cellfun(@num2str,rstrs, 'Un',0);
    rstrs{end-1} = [rstrs{end-1} ' [Hz]'];
    rstrs{1} = '';
    rstrs{end} = '';
    for j=1:length(rstrs)
        set(ph.RLabels(j), 'String', rstrs(j));
        set(ph.RLabels(j), 'Color', 'w');
        set(ph.RLabels(j), 'HorizontalAlignment', 'left');
        set(ph.RLabels(j), 'VerticalAlignment', 'top');
        set(ph.RLabels(j), 'FontName', 'avenir');
        set(ph.ALabels(j), 'FontSize', 7);
    end

    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = axes; hold on; thisha.Position = ha(1).Position; set(gca, 'Color', 'w')
    thisha.Position = thisha.Position.*[1 1 0.25 0.25]; thisha.Position(3:4) = thisha.Position(3).*[1 1.5].*0.9;
    thisha.Position(1:2) = ha(1).Position(1:2) + ha(1).Position(3:4) + thisha.Position(3:4).*([-1 -1] + [-2 -1]*0.1) ;
    % thisha.Position(1:2) = thisha.Position(1:2) - thisha.Position(3:4).*0.1.*[1 2.5];
    colormap(gca,jet); caxis([-6.5 -1.5])

    cdip = cdip_windward; mem_out = cdip.mem_out; 

    % title({[datestr(t0-tmzone ,'yyyy/mm/dd HH:MM') ' PST'] }, 'color', 'w', 'fontweight', 'normal', 'fontname', 'avenir')
    th = mem_out.dir; fr = mem_out.freq; Efth = mem_out.ds; 
    % ff = find(fr>0.4); Efth(ff,:) = NaN;
    fr = log10(fr); f0 = log10(0.02); fr = fr - f0;;
    ph = makePolarGrid(...
        'ALabelScheme', 'wave',...
        'RTicks',        [0.01:0.21:max(fr) max(fr)*1.015],...  % Radial ticks (inner circles)
        'RUnits',        '[Hz]',...   % Add units to outer-most radial labels
        'AMinorTicks', 0, ...
        'RScale', 'linear', 'GridColor', [1 1 1], 'FontName', 'avenir', 'FontSize',6);         
    [md,mf] = meshgrid(th,(fr));
    [px,py] = polgrid2cart(md, mf, ph);
    z = Efth;z = log10(z);
    [~,hc]  = contourf(px, py, z, 10);
    uistack(hc, 'bottom');  % this will put the grid on top of the contours
    hc.LineStyle = 'none';  % enable/disble contour lines


    rstrs = {ph.RLabels.String};
    rstrs = cellfun(@(x) round(10.^(str2num(x)+f0),2), rstrs, 'Un',0);
    tmp = strsplit(ph.RLabels(end).String);
    rstrs{end} = round(10.^(str2num(tmp{1})+f0),2);
    rstrs = cellfun(@num2str,rstrs, 'Un',0);
    rstrs{end-1} = [rstrs{end-1} ' [Hz]'];
    rstrs{1} = '';
    rstrs{end} = '';
    for j=1:length(rstrs)
        set(ph.RLabels(j), 'String', rstrs(j));
        set(ph.RLabels(j), 'Color', 'w');
        set(ph.RLabels(j), 'HorizontalAlignment', 'left');
        set(ph.RLabels(j), 'VerticalAlignment', 'top');
        set(ph.RLabels(j), 'FontName', 'avenir');
        set(ph.ALabels(j), 'FontSize', 7);
    end


    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = axes; hold on; thisha.Position = ha(1).Position; set(gca, 'Color', 'w')
    thisha.Position = thisha.Position.*[1 1 0.25 0.25]; thisha.Position(3:4) = thisha.Position(3).*[1 1.5].*0.9;
    thisha.Position(1:2) = ha(1).Position(1:2) + thisha.Position(3:4).*[1.4 0.025];
    % thisha.Position(1:2) = thisha.Position(1:2) + thisha.Position(3:4).*0.1.*[6 0.7];
    colormap(gca,jet); caxis([-6.5 -1.5])

    cdip = cdip_south; mem_out = cdip.mem_out; 
    % title({[datestr(t0-tmzone ,'yyyy/mm/dd HH:MM') ' PST'] }, 'color', 'w', 'fontweight', 'normal', 'fontname', 'avenir')
    th = mem_out.dir; fr = mem_out.freq; Efth = mem_out.ds; 
    % ff = find(fr>0.4); Efth(ff,:) = NaN;
    fr = log10(fr); f0 = log10(0.02); fr = fr - f0;;
    ph = makePolarGrid(...
        'ALabelScheme', 'wave',...
        'RTicks',        [0.01:0.21:max(fr) max(fr)*1.015],...  % Radial ticks (inner circles)
        'RUnits',        '[Hz]',...   % Add units to outer-most radial labels
        'AMinorTicks', 0, ...
        'RScale', 'linear', 'GridColor', [1 1 1], 'FontName', 'avenir', 'FontSize',6);         
    [md,mf] = meshgrid(th,(fr));
    [px,py] = polgrid2cart(md, mf, ph);
    z = Efth;z = log10(z);
    [~,hc]  = contourf(px, py, z, 10);
    uistack(hc, 'bottom');  % this will put the grid on top of the contours
    hc.LineStyle = 'none';  % enable/disble contour lines


    rstrs = {ph.RLabels.String};
    rstrs = cellfun(@(x) round(10.^(str2num(x)+f0),2), rstrs, 'Un',0);
    tmp = strsplit(ph.RLabels(end).String);
    rstrs{end} = round(10.^(str2num(tmp{1})+f0),2);
    rstrs = cellfun(@num2str,rstrs, 'Un',0);
    rstrs{end-1} = [rstrs{end-1} ' [Hz]'];
    rstrs{1} = '';
    rstrs{end} = '';
    for j=1:length(rstrs)
        set(ph.RLabels(j), 'String', rstrs(j));
        set(ph.RLabels(j), 'Color', 'w');
        set(ph.RLabels(j), 'HorizontalAlignment', 'left');
        set(ph.RLabels(j), 'VerticalAlignment', 'top');
        set(ph.RLabels(j), 'FontName', 'avenir');
        set(ph.ALabels(j), 'FontSize', 7);
    end

  
  
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = axes; hold on; thisha.Position = ha(1).Position; set(gca, 'Color', 'w')
    thisha.Position = thisha.Position.*[1 1 0.25 0.25]; thisha.Position(3:4) = thisha.Position(3).*[1 1.5].*0.9;
    thisha.Position(1:2) = ha(1).Position(1:2) + ha(1).Position(3:4).*[0 1] + [0 -1].*thisha.Position(3:4);
    thisha.Position(1:2) = thisha.Position(1:2) + thisha.Position(3:4).*0.1.*[1.4 -0.5];
    colormap(gca,jet); caxis([-6.5 -1.5])

    cdip = cdip_north; mem_out = cdip.mem_out; 
    % title({[datestr(t0-tmzone ,'yyyy/mm/dd HH:MM') ' PST'] }, 'color', 'w', 'fontweight', 'normal', 'fontname', 'avenir')
    th = mem_out.dir; fr = mem_out.freq; Efth = mem_out.ds; 
    % ff = find(fr>0.4); Efth(ff,:) = NaN;
    fr = log10(fr); f0 = log10(0.02); fr = fr - f0;;
    ph = makePolarGrid(...
        'ALabelScheme', 'wave',...
        'RTicks',        [0.01:0.21:max(fr) max(fr)*1.015],...  % Radial ticks (inner circles)
        'RUnits',        '[Hz]',...   % Add units to outer-most radial labels
        'AMinorTicks', 0, ...
        'RScale', 'linear', 'GridColor', [1 1 1], 'FontName', 'avenir', 'FontSize',6);         
    [md,mf] = meshgrid(th,(fr));
    [px,py] = polgrid2cart(md, mf, ph);
    z = Efth;z = log10(z);
    [~,hc]  = contourf(px, py, z, 10);
    uistack(hc, 'bottom');  % this will put the grid on top of the contours
    hc.LineStyle = 'none';  % enable/disble contour lines


    rstrs = {ph.RLabels.String};
    rstrs = cellfun(@(x) round(10.^(str2num(x)+f0),2), rstrs, 'Un',0);
    tmp = strsplit(ph.RLabels(end).String);
    rstrs{end} = round(10.^(str2num(tmp{1})+f0),2);
    rstrs = cellfun(@num2str,rstrs, 'Un',0);
    rstrs{end-1} = [rstrs{end-1} ' [Hz]'];
    rstrs{1} = '';
    rstrs{end} = '';
    for j=1:length(rstrs)
        set(ph.RLabels(j), 'String', rstrs(j));
        set(ph.RLabels(j), 'Color', 'w');
        set(ph.RLabels(j), 'HorizontalAlignment', 'left');
        set(ph.RLabels(j), 'VerticalAlignment', 'top');
        set(ph.RLabels(j), 'FontName', 'avenir');
        set(ph.ALabels(j), 'FontSize', 7);
    end

    
    c = fixedcolorbar(gca, 'location', 'southoutside', 'Color', 'w'); 
    c.Position([3 4]) = c.Position([3 4])./[2.5 1.5];
    c.Position = cbarpos;
    c.Position(2) = c.Position(2) + c.Position(4)*2;
    % c.Position([1 2]) = ha(1).Position([1 2]) + ha(1).Position([3 4]).*[0 0] + [1 2.8].*ha(1).Position(3:4).*0.05;
    ylabel(c, '\it log$_{10}$\{S(f)\} [m$^2$Hz]', 'fontname', 'avenir', 'interpreter', 'latex')
    set(c, 'AxisLocation', 'in');

    tmax = max(cellfun(@max, {cdip_north.time, cdip_west.time, cdip_south.time, cdip_windward.time}))-tmzone; 
    textbypos(ha(1).Position(1) + ha(1).Position(3)*0.007, ha(1).Position(2) + ha(1).Position(4)*0.02, ['Updated ' datestr(tmax, 'yyyy/mm/dd HH:MM') 'HST'] , 'fontname', 'avenir', 'Color', [1 1 1].*0.7)
    


    savejpg(gcf, 'howsthewaves_map_oahu', [upath wpath], 'on')



    


%% [off] add currents

%% [off] PLOT
% xlims = [now-5 now+6/24];
% 
% figure(8581); clf;
% setfigsize(gcf, [976   680]);
% % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
% ha = tight_subplot(5, 1, [0.01 0.05], [0.1 0.05], [0.05 0.05]);
% % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% 
% 
% % -------------------------------------------------------------------------
% % format_fig4print(ha)
% setAllAxesOpts(ha, 'FontName', 'avenir', 'FontSize', 10);;
% 
% setAllAxesOpts(ha, 'Box', 'on');
% setAllAxesOpts(ha, 'XLim', xlims);
% dt = 6/24;
% tmzone = 8/24;
% tmzone = 7/24;
% ttlstr = ['Updated ' datestr(max([ndbc.time; noaa.time; cdip.time'])-tmzone, 'yyyy/mm/dd HH:MM') ' PST'];
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(1); axes(thisha); hold on; 
% t = noaa.time-tmzone; var = noaa.wsp./1.944;
% col = [237, 167, 81]./256;
% 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% tt = find(isin(t, xlims));
% ylims = [0 max(var(tt))+1.5]; ylim(ylims);
% ylabel('wind speed [m/s]')
% 
% plot(t, var, 'b-', 'Color', col, 'LineWidth',2);
% 
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% 
% title(ttlstr, 'HorizontalAlignment', 'right')
% pos = gca().Title.Position; 
% pos(1) = xlims(2);
% set(gca().Title, 'Position', pos);
% 
% 
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(2); axes(thisha); hold on; 
% t = cdip.time-tmzone; var = cdip.hs.*3.28084;
% col = [100, 100, 100]./258;
% 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
% tt = find(isin(t, xlims));
% ylims = [0 max(var(tt)) + 0.2]; ylim(ylims)
% ylabel('Hs [ft]')
% 
% 
% plot(t, var, 'k-', 'Color', col, 'LineWidth',2)
% 
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% 
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(3); axes(thisha); hold on; 
% 
% 
% 
% col = [154, 163, 67]./258;
% % yyaxis left; set(gca, 'YColor', col)
% t = noaa.time-tmzone; var = noaa.waterlevel;
% plot(t, var, 'g-', 'Color', col, 'LineWidth',3)
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
% tt = find(isin(t, xlims));
% ylims = minmax(var(tt)) + [-1 1].*0.33; ylim(ylims)
% ylabel('MLLW [ft]')
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(4); axes(thisha); hold on; 
% % col = [154, 163, 67]./258;
% % % yyaxis right; set(gca, 'YColor', col)
% t = hfr.T-tmzone; u = hfr.U; v = hfr.V; nn = find(~isnan(u) & ~isnan(v)); t = t(nn); v = v(nn); u = u(nn);
% % plot(t,u, 'r.-', 'LineWidth',2, 'Markersize',10, 'Color', [0.73 0.18 0.23], 'DisplayName', 'u')
% % plot(t,v, 'b.-','LineWidth',2, 'Markersize',10, 'Color', [110,153,211]./256, 'DisplayName', 'v')
% 
% var = u; col = [0.73 0.18 0.23];
% plot(t,var, 'r.-', 'LineWidth',2, 'Markersize',10, 'Color', col, 'DisplayName', 'u')
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% var = v; col = [110,153,211]./256;
% plot(t,var, 'r.-', 'LineWidth',2, 'Markersize',10, 'Color', col, 'DisplayName', 'v')
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% 
% 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% tt = find(isin(t, xlims));
% ylims = max(abs([u(tt); v(tt)])).*[-1 1]+[-1 1]*0.05; ylim(ylims)
% drawLineOpts(gca, 0, 'y', 'LineStyle','-', 'Color', [0 0 0 0.4])
% ylabel('current [m/s]')
% 
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(5); axes(thisha); hold on; 
% t = ndbc.time-tmzone; var = (ndbc.wtmp*9/5)+32;
% col = [110,153,211]./256; col = [0.47 0.4 0.7];
% plot(t, var, 'b.-', 'Color', col, 'LineWidth',2.5, 'Markersize',13, 'DisplayName', ['water, buoy [-1 m]'])
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
% tt = find(isin(t, xlims));
% ylims = minmax(var(tt))+[-1 1]*1; ylim(ylims)
% % ylims = minmax(var(tt))+[-4 1]*0.5; ylim(ylims)
% ylabel('F^o')
% 
% % t = noaa.time-tmzone; var = (noaa.wtmp); var = movmean(var,5);
% % plot(t, var, 'b-', 'Color', [col-0.3 0.4], 'LineWidth',2, 'Markersize',10, 'DisplayName', ['water, pier [-3.4 m]'])
% 
% t = noaa.time-tmzone; var = (noaa.atmp);var = movmean(var,5);
% plot(t, var, 'b-', 'Color', [col+0.15 0.6], 'LineWidth',2, 'Markersize',10, 'DisplayName', ['air, pier [+16.5 m]'])
% 
% % -------------------------------------------------------------------------
% quietaxes(ha(1:end-1), 'x');
% setAllAxesOpts(ha(end), 'XLabel','PST');
% setAllAxesOpts(ha(end), 'XTickLabelRotation',20);
% alignyaxes(ha, xlims(1)-tmzone+1/24);
% 
% 
% bns = [floor(xlims(1))-1:1:xlims(2)+1];
% % dataorigins = {'tidesandcurrents.noaa.gov | 9410230','cdip.ucsd.edu | CDIP201', 'tidesandcurrents.noaa.gov | 9410230', {'cdip.ucsd.edu | CDIP201', 'tidesandcurrents.noaa.gov | 9410230'}};
% dataorigins = {'tidesandcurrents.noaa.gov | 9410230','cdip.ucsd.edu | CDIP201', 'tidesandcurrents.noaa.gov | 9410230', 'HFR',{'cdip.ucsd.edu | CDIP201', 'tidesandcurrents.noaa.gov | 9410230'}};
% for i=1:length(ha)
%     axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
%     ylims = get(gca, 'YLim');
%     xlims = get(gca, 'XLim');
%     text(xlims(1)+1/24, ylims(1) + diff(ylims)*0.03, dataorigins{i}, ...
%         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
%         'BackgroundColor',[1 1 1 0.8])
% 
%     % for i=1:2:length(bns)-1
%     for j=length(bns)-2:-2:1
%         bn = bns(j:j+1);
%         bn = bn + [-1 1].*0.5/24;
%         tmp = patch([bn bn(2) bn(1)], [ylims(1) ylims(1) ylims(2) ylims(2)], 'k', 'FaceAlpha', 0.04, 'EdgeColor', 'none');
%         uistack(tmp, 'bottom');
%     end
%     if i==4; cleanLegend(gca, 'northeast', 'Orientation', 'Horizontal', 'FontSize',8); end
% 
% end
% 
% 
% 
% 
% savejpg(gcf, 'howsthewater_uv', '/Users/alliho/Documents/gitwebsite/', 'on');
% 
% 


%% [off] temperatures 




% 
% figure(8023); clf; hold on; 
% % plot(ndbc.time, (ndbc.wtmp*9/5)+32, 'k-');
% % plot(noaa.time, noaa.wtmp, 'b-');
% % plot(noaa.time, noaa.atmp, 'r-');
% 
% t = noaa.time-tmzone;
% btmp = noaa.wtmp;
% stmp = interp1(ndbc.time, (ndbc.wtmp*9/5)+32, noaa.time);
% atmp = noaa.atmp;
% atmp = movmean(atmp, 3);
% stmp = movmean(stmp, 3);
% btmp = movmean(btmp, 3);
% 
% % plot(stmp, btmp, 'k.')
% % plot(stmp, atmp, 'r.')
% % plotone2one(gca);
% % set(gca, 'DataAspectRatio', [1 1 1])
% 
% col = [110,153,211]./256;
% 
% plot(t, stmp, 'k-', 'Color', col, 'LineWidth',3);
% plot(t, btmp, 'b-', 'Color', col-0.3, 'LineWidth',2);
% plot(t, atmp, 'r-', 'Color', col+[0.3 0.24 0.15], 'LineWidth',2);
% 
% 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
% 
% col = [154, 163, 67]./258;
% yyaxis right; set(gca, 'YColor', col)
% plot(noaa.time, noaa.waterlevel, 'Color', col, 'LineWidth',2)
% xlims = [now-5 now+6/24];
% 
% figure(858);clf;
% setfigsize(gcf, [976   567])
% % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
% % ha = tight_subplot(4, 1, [0.01 0.05], [0.14 0.05], [0.08 0.03]);
% % % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% 
% ha = tight_subplot(5, 1, [0.01 0.05], [0.14 0.05], [0.08 0.03]);
% % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% dy = 0.09;
% ha(2).Position(4) = ha(2).Position(4)-dy;
% for i=[1 3 4 5]
%     ha(i).Position(4) = ha(i).Position(4) + dy/4;
% end
% 
% y0 = 0.14;
% for i=5:-1:1
%     ha(i).Position(2) = y0;
%     y0 = y0 + ha(i).Position(4) + 0.01;
% end
% 
% 
% 
% % -------------------------------------------------------------------------
% % format_fig4print(ha)
% setAllAxesOpts(ha, 'FontName', 'avenir', 'FontSize', 10);
% setAllAxesOpts(ha, 'FontSize', 12)
% setAllAxesOpts(ha, 'Box', 'on')
% setAllAxesOpts(ha, 'XLim', xlims)
% dt = 6/24;
% tmzone = 8/24;
% tmzone = 7/24;
% ttlstr = ['Updated ' datestr(max([ndbc.time; noaamet.time; cdip.time'; noaa.time])-tmzone, 'yyyy/mm/dd HH:MM') ' PST']
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(1); axes(thisha); hold on; 
% t = noaamet.time-tmzone; var = noaamet.wsp./1.944;
% u = var.*cosd(met2oc(oc2pol(noaamet.wdir)));
% v = var.*sind(met2oc(oc2pol(noaamet.wdir)));
% col = [237, 167, 81]./256;
% 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% tt = find(isin(t+tmzone, xlims));
% ylims = [0 max(var(tt))+1.5]; ylim(ylims)
% ylabel('wind speed [m/s]')
% 
% 
% 
% plot(t, var, 'b-', 'Color', col, 'LineWidth',2);
% 
% 
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% 
% 
% 
% title(ttlstr, 'HorizontalAlignment', 'right')
% pos = gca().Title.Position; 
% pos(1) = xlims(2);
% set(gca().Title, 'Position', pos)
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(2); axes(thisha); hold on; 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% ylims = [-1 1]; ylim(ylims);
% 
% 
% t = noaamet.time-tmzone; var = noaamet.wsp./1.944;
% u = var.*cosd(met2oc(oc2pol(noaamet.wdir)));
% v = var.*sind(met2oc(oc2pol(noaamet.wdir)));
% col = [237, 167, 81]./256;
% 
% scale = 0.12;
% dar = daspect;
% pdar = get(gca, 'PlotBoxAspectRatio');
% set(gca, 'DataAspectRatioMode', 'manual')
% darrat = dar(1)./dar(2); pdarrat = pdar(1)/pdar(2);
% resetvar = pdarrat./darrat
% ndar = [1 resetvar 1]; rat = ndar(1)./ndar(2);
% set(gca, 'DataAspectRatio', ndar)
% quiver(t,ones(size(t)).*0.1, scale.*u.*rat,scale.*v,'Color',col + [0.01 0.2 0.25], 'AutoScale','off', 'LineWidth',1, 'MaxHeadSize',0.005)
% 
% 
% t = cdip.time-tmzone; var = cdip.hs.*3.28084;
% u = var.*cosd(met2oc(oc2pol(cdip.dp)));
% v = var.*sind(met2oc(oc2pol(cdip.dp)));
% col = [100, 100, 100]./258;
% 
% scale = 0.4;
% % dar = daspect;
% % pdar = get(gca, 'PlotBoxAspectRatio');
% % set(gca, 'DataAspectRatioMode', 'manual')
% % darrat = dar(1)./dar(2); pdarrat = pdar(1)/pdar(2);
% % resetvar = pdarrat./darrat
% % ndar = [1 resetvar 1]; rat = ndar(1)./ndar(2);
% set(gca, 'DataAspectRatio', ndar)
% quiver(t,ones(size(t)).*-0.1, scale.*u.*rat,scale.*v,'Color',col + [1 1 1]*0.2, 'AutoScale','off', 'LineWidth',1, 'MaxHeadSize',0.005)
% 
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(3); axes(thisha); hold on; 
% t = cdip.time-tmzone; var = cdip.hs.*3.28084;
% u = var.*cosd(met2oc(oc2pol(cdip.dp)));
% v = var.*sind(met2oc(oc2pol(cdip.dp)));
% col = [100, 100, 100]./258;
% 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% tt = find(isin(t+tmzone, xlims));
% ylims = [0 max(var(tt)) + 0.2]; ylim(ylims)
% ylabel('Hs [ft]')
% 
% 
% plot(t, var, 'k-', 'Color', col, 'LineWidth',2)
% 
% scale = 0.15;
% dar = daspect;
% pdar = get(gca, 'PlotBoxAspectRatio');
% set(gca, 'DataAspectRatioMode', 'manual')
% darrat = dar(1)./dar(2); pdarrat = pdar(1)/pdar(2);
% resetvar = pdarrat./darrat
% ndar = [1 resetvar 1]; rat = ndar(1)./ndar(2);
% set(gca, 'DataAspectRatio', ndar)
% quiver(t,ones(size(t)).*ylims(1)+0.2, scale.*u.*rat,scale.*v,'Color',col + [1 1 1]*0.2, 'AutoScale','off', 'LineWidth',1, 'MaxHeadSize',0.005)
% 
% 
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% 
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(4); axes(thisha); hold on; 
% col = [154, 163, 67]./258;
% t = noaa.time-tmzone; var = noaa.waterlevel;
% plot(t, var, 'g-', 'Color', col, 'LineWidth',3)
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% xlim(xlims)
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% tt = find(isin(t+tmzone, xlims));
% ylims = minmax(var(tt)) +[-1 1].*0.33; ylim(ylims)
% ylabel('MLLW [ft]')
% 
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% thisha = ha(5); axes(thisha); hold on; 
% t = ndbc.time-tmzone; var = (ndbc.wtmp*9/5)+32;
% col = [110,153,211]./256;
% plot(t, var, 'bo-', 'Color', col, 'LineWidth',2)
% plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
% text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
%     'HorizontalAlignment','left', 'VerticalAlignment','top')
% xlim(xlims); 
% autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
% tt = find(isin(t+tmzone, xlims));
% ylims = minmax(var(tt))+[-1 1]; ylim(ylims)
% ylabel('F^o')
% 
% % -------------------------------------------------------------------------
% quietaxes(ha(1:end-1), 'x')
% setAllAxesOpts(ha(end), 'XLabel','PST')
% setAllAxesOpts(ha(end), 'XTickLabelRotation',20)
% alignyaxes(ha, xlims(1)-tmzone+1/24)
% 
% 
% dataorigins = {'tidesandcurrents.noaa.gov', '','cdip.ucsd.edu', 'tidesandcurrents.noaa.gov', 'cdip.ucsd.edu'};
% for i=1:length(ha)
%     axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':')
%     ylims = get(gca, 'YLim');
%     xlims = get(gca, 'XLim');
%     text(xlims(1)+1/24, ylims(1) + diff(ylims)*0.03, dataorigins{i}, ...
%         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
%         'BackgroundColor',[1 1 1 0.8])
% 
% end
% 
% savejpg(gcf, 'howsthewater', '/Users/alliho/Documents/gitwebsite/', 'on')


%% finish
disp('------------------------------------')
disp('Successfully executed howsthewater.m')
disp('------------------------------------')


