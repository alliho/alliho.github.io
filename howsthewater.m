%% assign variables
tmzone = 8/24;
tmzone = 7/24;

%% SORT URLS
addpath(genpath('/Users/alliho/Documents/SIO/gitsio/code_universal/dload_cdip_v3'))
addpath(genpath('/Users/alliho/Documents/SIO/gitsio/code_universal/fxnout'))
addpath(genpath('/Users/alliho/Documents/SIO/gitsio/code_universal/plotfxns'))

% https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=air_temperature&application=NOS.COOPS.TAC.MET&begin_date=20230901&end_date=20230902&station=9410230&time_zone=GMT&units=english&interval=6&format=csvhttps://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=air_temperature&application=NOS.COOPS.TAC.MET&begin_date=20230901&end_date=20230902&station=9410230&time_zone=GMT&units=english&interval=6&format=csv


daterange = [now-15 now+2];
% daterange = [now-20 now+2];
%%% water temp
ndbc = dload_ndbc_fromurl('https://www.ndbc.noaa.gov/data/realtime2/46254.txt')

%%% tidal elevation
stationid = 9410230;
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
cdip = dload_cdipbuoy(201, daterange+[-5 0],1, 'include', {'hs', 'dp', 'tp'});
% cdip = dload_cdipbuoy(201, daterange+[-5 0],1, 'include', {'hs', 'dp', 'tp', 'sf'});


% [hfr.U hfr.V hfr.lat hfr.lon hfr.T] = dload_hfr(cdip.lat0,cdip.lon0-0.02,daterange);


%% PLOT
xlims = [now-5 now+6/24];

figure(858); clf;
setfigsize(gcf, [976   567]);
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
ha = tight_subplot(4, 1, [0.01 0.05], [0.14 0.05], [0.08 0.08]);
% [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});


% -------------------------------------------------------------------------
% format_fig4print(ha)
setAllAxesOpts(ha, 'FontName', 'avenir');
setAllAxesOpts(ha, 'FontSize', 12);
setAllAxesOpts(ha, 'Box', 'on');
setAllAxesOpts(ha, 'XLim', xlims);
dt = 6/24;

ttlstr = ['Updated ' datestr(max([ndbc.time; noaa.time; cdip.time'])-tmzone, 'yyyy/mm/dd HH:MM') ' PST'];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 
t = noaa.time-tmzone; var = noaa.wsp./1.944;
col = [237, 167, 81]./256;

autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt)
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

autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
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
t = noaa.time-tmzone; var = noaa.waterlevel;
plot(t, var, 'g-', 'Color', col, 'LineWidth',3)
plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
tt = find(isin(t, xlims));
ylims = minmax(var(tt)) +[-1 1].*0.33; ylim(ylims)
ylabel('MLLW [ft]')


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(4); axes(thisha); hold on; 
t = ndbc.time-tmzone; var = (ndbc.wtmp*9/5)+32;
col = [110,153,211]./256;
plot(t, var, 'b.-', 'Color', col, 'LineWidth',2.5, 'Markersize',13, 'DisplayName', ['water, buoy [-1 m]'])
plot(t(end), var(end), 'o', 'Color', col*0.7, 'LineWidth',2)
text(t(end)+0.5/24, var(end), num2str(round(var(end),1)), 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dt);
tt = find(isin(t, xlims));
ylims = minmax(var(tt))+[-1 1]*1; ylim(ylims)
% ylims = minmax(var(tt))+[-4 1]*0.5; ylim(ylims)
ylabel('F^o')

% t = noaa.time-tmzone; var = (noaa.wtmp); var = movmean(var,5);
% plot(t, var, 'b-', 'Color', [col-0.3 0.4], 'LineWidth',2, 'Markersize',10, 'DisplayName', ['water, pier [-3.4 m]'])

t = noaa.time-tmzone; var = (noaa.atmp);var = movmean(var,5);
plot(t, var, 'b-', 'Color', [col+0.15 0.6], 'LineWidth',2, 'Markersize',10, 'DisplayName', ['air, pier [+16.5 m]'])

% -------------------------------------------------------------------------
quietaxes(ha(1:end-1), 'x');
setAllAxesOpts(ha(end), 'XLabel','PST');
setAllAxesOpts(ha(end), 'XTickLabelRotation',20);
alignyaxes(ha, xlims(1)-tmzone+1/24);


% bns = [floor(xlims(1))-1:1:xlims(2)+1];
% bns = [floor(xlims(1))-1 + 6/24:0.5:xlims(2)+1];
dys = unique(floor(cdip.time-tmzone)); dys = unique([dys max(dys):1:max(dys)+2]);
[sun_rise, sun_set] = sun_up_down(dys, cdip.lat0, cdip.lon0, 0, 0);


dataorigins = {'tidesandcurrents.noaa.gov | 9410230','cdip.ucsd.edu | CDIP201', 'tidesandcurrents.noaa.gov | 9410230', {'cdip.ucsd.edu | CDIP201', 'tidesandcurrents.noaa.gov | 9410230'}};
for i=1:length(ha)
    axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
    ylims = get(gca, 'YLim');
    xlims = get(gca, 'XLim');
    text(xlims(1)+1/24, ylims(1) + diff(ylims)*0.03, dataorigins{i}, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
        'BackgroundColor',[1 1 1 0.8])
    % if i==4; cleanLegend(gca, 'northeast', 'Orientation', 'Horizontal', 'FontSize',8); end
    
    % for bi=1:2:length(bns)-1
    % for bi=length(bns)-2:-2:1
    %     bn = bns(bi:bi+1);
    %     bn = bn + [-1 1].*0.5/24;
    %     tmp = patch([bn bn(2) bn(1)], [ylims(1) ylims(1) ylims(2) ylims(2)], 'k', 'FaceAlpha', 0.04, 'EdgeColor', 'none');
    %     uistack(tmp, 'bottom')
    % end

    for bi=1:length(sun_rise)-1
        disp(bi)
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
savejpg(gcf, 'howsthewater', '/Users/alliho/Documents/gitwebsite/', 'on');


%% directional plot [add data]
daterange = [now-5 now+2];
cdip_inner = dload_cdipbuoy(201, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2', 'lon', 'lat'});
cdip_inner.id = 201;

daterange = [now-5 now+2];
cdip_outer = dload_cdipbuoy(100, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2', 'lon', 'lat'});
cdip_outer.id = 100;

%% spectrogram over past three days

xlims = [now-5 now+6/24];




figure(93); clf;
% setfigsize(gcf, [393   297]);
setfigsize(gcf, [976         422])
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
ha = tight_subplot(2, 1, [0.01 0.05], [0.145 0.05], [0.08 0.08]);
% [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% -------------------------------------------------------------------------
setaxes(ha, 'FontName', 'avenir')
setaxes(ha, 'CLim',[-4 0.5])
colormap(jet);

setaxes(ha, 'Layer', 'top');
setaxes(ha, 'FontSize', 12);
setaxes(ha, 'Box', 'on');
setaxes(ha, 'XLim', xlims);
setaxes(ha, 'YLim', [0.04 0.55]);
setaxes(ha, 'YMinorGrid', 'off');
setaxes(ha, 'YLabel', 'f [Hz]');
setaxes(ha, 'YTick', [0.05 0.1 0.2 0.5]);
setloglog(ha, 'y'); 
dx = 12/24;
ttlstr = ['Updated ' datestr(max([ndbc.time; noaa.time; cdip.time'])-tmzone, 'yyyy/mm/dd HH:MM') ' PST'];


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(2); axes(thisha); hold on; 
cdip = cdip_inner;
x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
pcolor(x,y,Z); shading flat;
[X Y] = ndgrid(x,y); Z = movmean(Z,3,1); Z = movmean(Z,(2./24)./dt,2);
% contourf(X,Y,Z', [-4:0.25:2])
contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.5)
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 
cdip = cdip_outer;
x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
pcolor(x,y,Z); shading flat;
[X Y] = ndgrid(x,y); Z = movmean(Z,3,1); Z = movmean(Z,(2./24)./dt,2);
% contourf(X,Y,Z', [-4:0.25:2])
contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.5)
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);


% -------------------------------------------------------------------------
quietaxes(ha(1:end-1), 'x');
setaxes(ha(end), 'XLabel','PST');
setaxes(ha(end), 'XTickLabelRotation',20);
alignyaxes(ha, xlims(1)-tmzone -1/24);

bns = [floor(xlims(1))-1:1:xlims(2)+1];
bns = [floor(xlims(1))-1 + 6/24:0.5:xlims(2)+1];

dataorigins = {['cdip.ucsd.edu | CDIP'  num2str(cdip_inner.id)], ['cdip.ucsd.edu | CDIP' num2str(cdip_inner.id)]};
for i=1:length(ha)
    axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
    ylims = get(gca, 'YLim');
    xlims = get(gca, 'XLim');
    text(xlims(1)+1/24, ylims(1) + 0.005, dataorigins{i}, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
        'BackgroundColor',[1 1 1 0.8])
end

%% spectrogram over past three days and partition hs

xlims = [now-5 now+6/24];




figure(94); clf;
% setfigsize(gcf, [393   297]);
setfigsize(gcf, [976         522])
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
oldha = tight_subplot(6, 1, [0.01 0.05], [0.125 0.025], [0.08 0.08]);
[ha] = reorg_tightsubplot(oldha, {1,2,[3:4],[5:6]});
% -------------------------------------------------------------------------
setaxes(ha, 'FontName', 'avenir')
setaxes(ha, 'Layer', 'top');
setaxes(ha, 'FontSize', 12);
setaxes(ha, 'Box', 'on');
setaxes(ha, 'CLim',[-4 0.5])
colormap(jet);
setaxes(ha, 'XLim', xlims);
setaxes(ha(3:4), 'YLim', [0.04 0.55]);
setaxes(ha(3:4), 'YMinorGrid', 'off');
setaxes(ha(3:4), 'YLabel', 'f [Hz]');
setaxes(ha(3:4), 'YTick', [0.05 0.1 0.2 0.5]);
setloglog(ha(3:4), 'y'); 
dx = 12/24;
ttlstr = ['Updated ' datestr(max([ndbc.time; noaa.time; cdip.time'])-tmzone, 'yyyy/mm/dd HH:MM') ' PST'];


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 

flims = [0.1 0.5];
col = [1 1 1].*0.3;
cdip = cdip_inner; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims)); var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])

col = [1 1  1].*0.6;
cdip = cdip_outer; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims));  var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])


tt = find(isin(cdip_outer.time, xlims));
ylims = [0 max(cdip_outer.hs(tt)).*3.28084 + 0.2]; ylim(ylims)
ylabel('Hs_{seas} [ft]')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(2); axes(thisha); hold on; 


flims = [0.05 0.1];
col = [1 1 1].*0.3;
cdip = cdip_inner; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims)); var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])

col = [1 1  1].*0.6;
cdip = cdip_outer; t = cdip.time - tmzone; ff = find(isin(cdip.f, flims));  var = trapz(cdip.f(ff), cdip.sf(ff,:)); var = 4.*sqrt(var); var = var.*3.28084;
plot(t, var, 'k-', 'Color', col, 'LineWidth',2, 'DisplayName', ['CDIP' num2str(cdip.id)])

tt = find(isin(cdip_outer.time, xlims));
ylims = [0 max(cdip_outer.hs(tt)).*3.28084 + 0.2]; ylim(ylims)
ylabel('Hs_{swell} [ft]')
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(4); axes(thisha); hold on; 
cdip = cdip_inner;
x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
pcolor(x,y,Z); shading flat;
[X Y] = ndgrid(x,y); Z = movmean(Z,3,1); Z = movmean(Z,(2./24)./dt,2);
% contourf(X,Y,Z', [-4:0.25:2])
contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.5)
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(3); axes(thisha); hold on; 
cdip = cdip_outer;
x = cdip.time - tmzone; y = cdip.f; Z = cdip.sf; Z = log10(Z); dt = mode(diff(cdip.time));
pcolor(x,y,Z); shading flat;
[X Y] = ndgrid(x,y); Z = movmean(Z,3,1); Z = movmean(Z,(2./24)./dt,2);
% contourf(X,Y,Z', [-4:0.25:2])
contour(X,Y,Z', [-4:0.2:3], 'EdgeColor', 'k', 'EdgeAlpha', 0.5)
autodatetick(gca, 'x', 'dlabstyle', 'mm/dd HH:MM', 'dt', dx);


% -------------------------------------------------------------------------
quietaxes(ha(1:end-1), 'x');
setaxes(ha(end), 'XLabel','PST');
setaxes(ha(end), 'XTickLabelRotation',20);
alignyaxes(ha, xlims(1)-tmzone -1/24);

bns = [floor(xlims(1))-1:1:xlims(2)+1];
bns = [floor(xlims(1))-1 + 6/24:0.5:xlims(2)+1];

dataorigins = {'', '',['cdip.ucsd.edu | CDIP'  num2str(cdip_inner.id)], ['cdip.ucsd.edu | CDIP' num2str(cdip_inner.id)]};
for i=1:length(ha)
    axes(ha(i)); drawLineOpts(gca, now, 'x', 'LineStyle', ':');
    ylims = get(gca, 'YLim');
    xlims = get(gca, 'XLim');
    text(xlims(1)+1/24, ylims(1) + 0.005, dataorigins{i}, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontName', 'Avenir', ...
        'BackgroundColor',[1 1 1 0.8])

    if i==1 
        leg = cleanLegend(gca, 'southwest', 'NumColumns',2, 'FontSize',10); 
        leg.Box = 0;
        leg.ItemTokenSize = leg.ItemTokenSize/2;
        leg.Position(1) = leg.Position(1) - 0.005;
        leg.Position(2) = leg.Position(2) + 0.005;
    end
end



%% directional plot

cdip = cdip_inner;
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
mem_out_inner = mem_out;

cdip = cdip_outer;
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
mem_out_outer = mem_out;

figure(92); clf; 
% setfigsize(gcf, [393   297]);
setfigsize(gcf, [872   378])
% tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
ha = tight_subplot(1, 2, [0.05 0.1], [0.01 0.12], [0.2 0.2]);
% [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
% -------------------------------------------------------------------------
setaxes(ha, 'FontName', 'avenir')
setaxes(ha, 'CLim',[-7 -2])
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
thisha = ha(1); axes(thisha); hold on; 
mem_out = mem_out_outer; cdip = cdip_outer;
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
mem_out = mem_out_inner;cdip = cdip_inner;
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
ylabel(c, '{\it log_{10}[S(f)] }', 'FontName', 'avenir')


col = [237, 167, 81]./256;
t = noaa.time; var = noaa.wsp./1.944;
th = met2oc(oc2pol(noaa.wdir));
u = var.*cosd(th);
v = var.*sind(th);
tt = find(isin(t,[t0-1/24 t0+1/24]));
tt = find(isin(t,[t0-0.5/24 t0+0.5/24]));
u0 = nanmean(u(tt)); v0 = nanmean(v(tt)); th0 = atan2d(v0, u0); spd0 = sqrt(u0.^2 + v0.^2);
scl =0.25;
x0 = -cosd(th0).*max(fr); y0 = -sind(th0).*max(fr);
% x0 = 0; y0 = 0;
quiver(x0,y0,scl*u0, scl*v0, 'w-', 'AutoScale','off', 'LineWidth',6, 'MaxHeadSize',0.4, 'Color', 'w')
quiver(x0,y0,scl*u0, scl*v0, 'w-', 'AutoScale','off', 'LineWidth',3, 'MaxHeadSize',0.35, 'Color', col)
text(x0 + x0*0.2,y0 + y0*0.1, [num2str(round(spd0,1))  ' m/s'],...
    'FontName', 'avenir', 'Color', col, 'BackgroundColor', [1 1 1 0.9], 'Margin', 0.2, 'HorizontalAlignment','center', 'VerticalAlignment','middle')

col = [1 1 1]*0.2;
fp = 1./cdip.tp(i); dp = cdip.dp(i); dp = (oc2pol(dp));
fp = log10(fp)-f0;
fxp = cosd(dp).*fp; fyp = sind(dp).*fp;
scatter(fxp, fyp, 30, col, 'filled', 'MarkerFaceAlpha', [0.8])
text(fxp+0.02, fyp+0.02, {['' num2str(round(cdip.tp(i),1)) 's']}, 'Color', col*0.7, ...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'FontName', 'avenir', 'FontSize',8)


savejpg(gcf, 'howsthewaves', '/Users/alliho/Documents/gitwebsite/', 'on')


%% add currents

%% PLOT
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
% setAllAxesOpts(ha, 'FontName', 'avenir');
% setAllAxesOpts(ha, 'FontSize', 12);
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


%% ray tracing based on peak 
rayopt = 1;

addpath('/Users/alliho/Documents/SIO/misc_projects/john/code/tracingwaves/')
g = 9.81; 


daterange = [now-2 now+1] + tmzone;
% cdipouter = dload_cdipbuoy(100, daterange,1, 'include', {'hs', 'sf','md'});
cdipouter = dload_cdipbuoy(100, daterange,1, 'include', {'hs', 'dp', 'tp', 'sf','md', 'a1','b1','a2','b2', 'lon', 'lat'});
[~, i] = min(abs(cdipouter.time - (now + tmzone)));
t0 = cdipouter.time(i);
sp_data.freq = cdipouter.f'; 
sp_data.band_width = cdipouter.df'; 
sp_data.ener_dens = cdipouter.sf(:,i); 
sp_data.a1 = cdipouter.a1(:,i); 
sp_data.b1 = cdipouter.b1(:,i); 
sp_data.a2 = cdipouter.a2(:,i); 
sp_data.b2 = cdipouter.b2(:,i); 
[mem_out] = MEM_est(sp_data);


x = mem_out.freq; y = mem_out.dir; z = log10(mem_out.ds);
z = movmean(z,3,1);
z = movmean(z,3,2);
[~,ith] = max(z, [],2);
[~,im] = max(diag(z(:,ith)));
fp0 = x(im); dp0 = y(ith(im)); 
% ff = find(isin(cdipouter.f, [0.05 0.25])); 
% [~, mi] = max(cdipouter.sf(ff,:));
% fi = ff(mi);
% [~, ti] = min(abs(cdipouter.time-(tmzone+now)));
% fp0 = nanmean(cdipouter.f(fi(ti-1:ti)));
% [~, mi] = min(abs(cdipouter.f-fp0));
% dp0 = cdipouter.md(fi(ti-1:ti),ti-1:ti); dp0 = diag(dp0); dp0 = directionalavg(dp0);
tp0 = 1./fp0; 
dp0 = round(dp0./5)*5;
if (dp0>180 & dp0<0); rayopt = 0; end



% 
% figure(5); clf; hold on;
% % pcolor(mem_out.freq, mem_out.dir, log10(mem_out.ds')); shading flat;
% % colormap(nicejet)
% % [~, i] = min(abs(cdipouter.time- (now + tmzone)));
% x = mem_out.freq; y = mem_out.dir; z = log10(mem_out.ds);
% z = movmean(z,3,1);
% z = movmean(z,3,2);
% % H = ones(3)./9;
% % z = filter2(H,z);
% pcolor(x,y,z'); shading flat;
% [~,ith] = max(z, [],2);
% scatter(x, y(ith), 30, diag(z(:,ith)), 'filled', 'MarkerEdgeColor', 'k')
% [~,im] = max(diag(z(:,ith)));
% plot(x(im), y(ith(im)), 'wo', 'LineWidth',2);


%%
if rayopt
    
    load('/Users/alliho/Documents/SIO/misc_projects/lajolla_grids.mat');
    tmp = load('/Users/alliho/Documents/SIO/misc_projects/lajolla_interpgrids.mat');
    flds = cellfun(@(nm) tmp.(nm), {'interpU' 'interpdUdx' 'interpdUdy' 'interpdUdt' 'interpV' 'interpdVdx' 'interpdVdy' 'interpdVdt' 'interpZ' 'interpdZdx' 'interpdZdy' 'interpdZdt'}, 'Un', 0); clear tmp;
    load('/Users/alliho/Documents/SIO/misc_projects/lajolla_roads.mat');
    % %%
    Nwaves = 150; 
    bnd_ys = [minmax(y0) + [1 -1].*range(y0)/25];
    bnd_xs = [minmax(x0) + [1 -1].*range(x0)/30];
    bnds_left = [linspace(bnd_xs(1), bnd_xs(1), round(Nwaves*0.7)); linspace(bnd_ys(1), bnd_ys(2), round(Nwaves.*0.7))];
    bnds_top = [linspace(bnd_xs(1), bnd_xs(2), round(Nwaves*0.3)); linspace(bnd_ys(2), bnd_ys(2), round(Nwaves.*0.3))];
    if dp0<20 | dp0>360-20
        bnds = [bnds_top]; 
    elseif (dp0>270-90 & dp0<270+20) | dp0<=180
        bnds = [bnds_left]; 
    else
        bnds = [bnds_left bnds_top];
    end
    Nwaves = length(bnds);
    
    th0 = deg2rad(met2oc(oc2pol(dp0)));
    start0 = 1*(1/24)*24*3600;
    h0 = max(Z(:)); kp0 = abs(findk_u(2*pi.*fp0,h0,0,0));
    
    % state0 = [x0 y0 t0 kx0 ky0 om0];
    % state0 should have dimensions [Nwaves 6];
    state0 = NaN(Nwaves,6);
    state0(:,1) = bnds(1,:);
    state0(:,2) = bnds(2,:);
    state0(:,3) = start0;
    state0(:,4) = kp0.*cos(th0);
    state0(:,5) = kp0.*sin(th0);
    state0(:,6) = 2*pi./tp0;
    % remove points that fall along boundary
    ii = find(state0(:,2)~=max(y0) & state0(:,2)~=min(y0) & state0(:,1)~=max(x0) & state0(:,1)~=min(x0));
    state0 = state0(ii,:);
    
    
    %%% DEFINE TIME STEP
    dt_min = deg2km(mode(diff(x0)))*1000/(0.5*sqrt(g./kp0)); % integration time step limit = grid resolution / wave speed (wave has to travel at least one grid point between steps)
    dt = dt_min.*5;
    dt = round(dt,1);
    dt = dt.*2;
    
    %%% DEFINE NUMBER TIME STEPS
    % or approximate time to cross domain
    totalsecs = (1000*deg2km(range(x0)))./(0.5*sqrt(g./kp0));
    totaldays = totalsecs./(3600*24);
    N = totaldays*24*3600./dt; N = round(N);
    N = abs(N);
    
    %%% RUN
    [STATES DSTATES] = run_raytrace(state0',dt,N, 'fields', flds);
    
    
    
    %% plot
    
    % -------------------------------------------------------------------------
    % -------------------------------------------------------------------------
    figure(855); clf;  
    setfigsize(gcf, [564   602])
    % tight_subplot(Nh, Nw, [gap_h gap_w], [lower upper], [left right]) 
    ha = tight_subplot(1, 1, [0.05 0.05], [0.09 0.01], [0.12 0.12]);
    % [ha] = reorg_tightsubplot(oldha, {[1],[2:3]});
    % -------------------------------------------------------------------------
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    thisha = ha(1); axes(thisha); hold on; 

    % format_fig4print(gca, 'FontName', 'avenir')
    set(gca, 'FontName', 'avenir')
    set(gca, 'FontName', 'avenir')
    set(gca, 'YTickLabelRotation',15)
    set(gca, 'XTickLabelRotation',15)
    set(gca, 'FontSize',10)
    xlim(minmax(x0))
    ylim(minmax(y0))
    grid on; box on;
    set(gca, 'Layer', 'top');
    set(gca, 'DataAspectRatio', [1 1 1])
    ylabel('lat [deg]'); xlabel('lon [deg]')
    % -------------------------------------------------------------------------
    %%% PLOT FIELDS
    ti = length(t0);
    [~, ti] = min(abs(STATES{1}(1,end)-t0));
    plX = X0(:,:,ti); plY = Y0(:,:,ti); plZ = Z(:,:,ti); %caxis([-1 1].*1) 
    plZ = plZ; %plZ(plZ<=-1) = 0;
    A = arrayfun(@squeeze, {plX,plY,plZ}); [plX,plY,plZ] = A{:};
    pcolor(plX,plY,plZ); shading flat; 
    c = fixedcolorbar(gca); ylabel(c, 'z [m]'); caxis([-10 350])
    cmap = [242,86,59,255; 251,166,74,255; 252,197,45,255; 255,242,46,255; 147,187,87,255;...
        86,153,131,255; 64,142,191,255; 67,139,250,255; 45,89,209,255; 27,53,149,255];
    cmap = cmap(:,1:3)./255; cmap = buildcmap(cmap,120); cmap = [0.56 0.22 0.22; cmap];
    colormap(cmap)
    %%% PLOT ROADS
    plot([-117.25427800401353 -117.257465], [32.86620057050582 32.867069],'w-', 'LineWidth',8, 'Color', cmap(1,:) + 0.0)
    plot(lajollaroads.lon, lajollaroads.lat, 'w-', 'Color', cmap(1,:) + 0.2)
    % 32.86620057050582, -117.25427800401353
    %%% PLOT RAYS
    for si=1:1:length(STATES)
        state = STATES{si};
        [ray] = state_to_ray(state, 'fields', flds);
        % cg0 = ray.cg(1);
        % Erat = cg./(cg0);
        % nn = find(Erat<0);
        plot(ray.x, ray.y, 'k-', 'Linewidth',1)
    
    end
    caxis([-1 350])
    
    if nansum(ray.U); 
        currstr = 'currents'; 
        [~, ti] = min(abs(t0./3600 - ray.t(1)./3600)); Urat = squeeze(U(1,1,ti))./max(squeeze(U(1,1,:))); Urat = round(Urat, 1);
        currstr = [currstr '_' num2str(Urat)];
        Ustr = ['$U = ' num2str(Urat) 'U_{max}$']
    else; currstr = ''; Ustr = ''; end
    
    txtstyles = {'FontName', 'avenir', 'HorizontalAlignment','left', 'VerticalAlignment','bottom'};
    [~, ti] = min(abs((cdip.time-tmzone)-now));
    plot(cdip.lon(ti), cdip.lat(ti), 'wo', 'LineWidth',1, 'Color', 'k', 'MarkerFaceColor', 'w', 'MarkerSize',8, 'DisplayName', 'CDIP201', ...
        'MarkerFaceColor',cmap(1,:) + [0.4 0.6 0.6])
    plot([-117.255886 -117.2573], [32.86665 32.8670],'w-', 'LineWidth',3, 'Color', cmap(1,:) + [0.4 0.5 0.5], 'DisplayName', 'Scripps Pier | 9410230')
    % text(cdip.lon0-0.001, cdip.lat0+0.0005, 'CDIP201', txtstyles{:},...
    %     'BackgroundColor', [1 1 1 0.9], 'Color', 'k', 'HorizontalAlignment','right', 'FontSize',8)

    [~, ti] = min(abs((cdipouter.time-tmzone)-now));
    text(max(x0) - range(x0).*0.03, min(y0) + range(y0).*0.016,...
        {['CDIP100 | ' datestr(cdipouter.time(ti) - tmzone, 'yyyy/mm/dd HH:MM') 'PST']},...
        txtstyles{:}, 'Color', 'w','HorizontalAlignment','right', 'FontSize',8);

    text(max(x0) - range(x0).*0.147, min(y0) + range(y0).*0.025,...
        {['Tp=' num2str(round(tp0)) 's'],['Dp=' num2str(pol2oc(met2oc(rad2deg(th0)))) '^o'],Ustr},...
        txtstyles{:}, 'Color', 'w', 'FontSize',12);

    cleanLegend(gca, 'northeast', 'FontName', 'avenir', 'Color', [1 1 1 0.5], 'EdgeColor', 'none', 'FontSize',8)

    savejpg(gcf, 'howstherays', '/Users/alliho/Documents/gitwebsite/', 'on')
    
end

%% temperatures 




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
% setAllAxesOpts(ha, 'FontName', 'avenir')
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


