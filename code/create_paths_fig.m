%this is hardcoded :\
clc;clear;close all;

wsName = 'movemoent A to B';
%wsName = '100 weight';
wsName = 'shape shifting';

%for 100g
%SWEEPS = 5;
%for AB
%SWEEPS = 8;
%for shape shifting
SWEEPS = 1;

%for AB & shape shifting
bg_vid = VideoReader(strcat(wsName,'/bg.mp4'));
background = read(bg_vid, 1);

%for 100g
% background = imread(strcat(wsName,'/new_bg.png'));
% background = rgb2gray(background);

my_paths = cell(SWEEPS,4);
%1: names, 2: colors, 3:data 4:handle
% THIS IS FOR THE 100gr
% my_paths(:,1) = {  '1-1231-1234',
%                 '2-1235-1239',
%                 '6-1257-1259',
%                 '7-1259-1302',
%                 '11-1322-1325'};
%             
% my_paths(:,3) = {  [1 0 0];
%                 [0 1 0];
%                 [0 0 1];
%                 [1 0.5 0.5];
%                 [0 1 1]};
  
% %This is for the movement from A to B
% my_paths(:,1) = {  '1-1345-1347',
%                 '3-1350-1352',
%                 '4-1353-1355',
%                 '5-1357-1359',
%                 '6-1359-1401',
%                 '7-1402-1405',
%                 '8-1406-1408',
%                 '10-1413-1414'};
%             
% my_paths(:,3) = {  [1 0 0];
%                 [0 1 0];
%                 [0 0 1];
%                 [1 0.5 0.5];
%                 [0 0.5 0];
%                 [0.5 0 0];
%                 [1 1 0];
%                 [0 1 1]};

%for shape shifting
my_paths(:,1) = {  '1-1705-1707'};
my_paths(:,3) = {  [1 0 0];};

%the next line is useless i think
my_paths_backup = my_paths;

h_path = figure;
xlabel('X');
ylabel('Y');
title(strcat(wsName,{' '},'Path'));
axis([1 size(background,2) size(background,1)*(-1) 1]);
ax_path = gca;
%axis([1 size(background,2) size(background,2)*(-1) 1]);%for square
hold on

%draw rectangels
TR = [530 30*-1]; %Top right
DL = [58 543*-1]; %Down left
x_diff = TR(1) - DL(1);
y_diff = TR(2) - DL(2);

%draw frame
line([TR(1) DL(1) DL(1) TR(1) TR(1)],[TR(2) TR(2) DL(2) DL(2) TR(2)],'Color',[0 0 0],'Parent',ax_path);

%vertical lines
line([DL(1) + x_diff * 0.25 , DL(1) + x_diff * 0.25],[DL(2) TR(2)],'Color',[0 0 0],'Parent',ax_path);
line([DL(1) + x_diff * 0.5 , DL(1) + x_diff * 0.5],[DL(2) TR(2)],'Color',[0 0 0],'Parent',ax_path);
line([DL(1) + x_diff * 0.75 , DL(1) + x_diff * 0.75],[DL(2) TR(2)],'Color',[0 0 0],'Parent',ax_path);

%horizontal lines
line([DL(1), TR(1)],[DL(2) + y_diff * 0.25 DL(2) + y_diff * 0.25],'Color',[0 0 0],'Parent',ax_path);
line([DL(1), TR(1)],[DL(2) + y_diff * 0.5 DL(2) + y_diff * 0.5],'Color',[0 0 0],'Parent',ax_path);
line([DL(1), TR(1)],[DL(2) + y_diff * 0.75 DL(2) + y_diff * 0.75],'Color',[0 0 0],'Parent',ax_path);

%plot all sweeps on the figure
for my_sweep=1:SWEEPS
    load(strcat(wsName,'/output/',my_paths{my_sweep,1},'/',my_paths{my_sweep,1},'_vars'));
    my_paths{my_sweep,2} = track_path;
    
    vals_count = ceil(nframes/fps);
    path_per_second = zeros(vals_count,2);
    speed_per_second = zeros(vals_count,1);
    area_per_second = zeros(vals_count,1);
    for ii = 1:vals_count
        start_index = (ii-1) * fps + 1;
        end_index = ii * fps + 1;
        

        x1 = track_path(start_index,1);
        y1 = track_path(start_index,2);
        if ii == length(speed_per_second)
            x2 = track_path(end,1);
            y2 = track_path(end,2);
        else
            x2 = track_path(end_index,1);
            y2 = track_path(end_index,2);
        end
        speed_per_second(ii) = sqrt((x1 - x2)^2 + (y1 - y2)^2);
        
        %calc area
        if ii == length(speed_per_second)
            area_per_second(ii) = mean(track_area(start_index:end));
        else
            area_per_second(ii) = mean(track_area(start_index:end_index));
        end
        
        %calc path
        if ii == vals_count
            path_per_second(ii,:) = mean(track_path(start_index:end,:),1);
        else
            path_per_second(ii,:) = mean(track_path(start_index:end_index,:),1);
        end
         
    end
    
    gca = ax_path;
    hold on
    my_paths{my_sweep,4} = plot(ax_path, path_per_second(:,1),path_per_second(:,2)*(-1),'-','Color',cell2mat(my_paths(my_sweep,3)));
end

legend(ax_path, cell2mat(my_paths(:,4)),my_paths(:,1));

%save figure
print(h_path, '-dpng', strcat(wsName,'/output/',wsName,'_paths.png'));

%after we done with the big graph, we continue to single graphs

%calculate calibration factor
%http://matlab.wikia.com/wiki/FAQ#How_do_I_measure_a_distance_or_area_in_real_world_units_instead_of_in_pixels.3F
%calibrationFactor = 50/513;
%new calibration factor for new camera shape shifting
calibrationFactor = 50/410;
FPS = 25;

%for each selected sweep
for my_sweep=1:SWEEPS
    h_path = figure('name',cell2mat(my_paths(my_sweep,1)));
    load(strcat(wsName,'/output/',cell2mat(my_paths(my_sweep,1)),'/',my_paths{my_sweep,1},'_vars'));

    num_dots = length(track_area);
    speed_per_second = zeros(ceil(num_dots/FPS),1);
    area_per_second = zeros(ceil(num_dots/FPS),1);
    path_per_second = zeros(ceil(num_dots/FPS),2);
    if strcmp(wsName, 'shape shifting') == 1
        ratio_per_second = zeros(ceil(num_dots/FPS),1);
    end
    
    for ii = 1:length(speed_per_second)
        start_index = (ii-1) * FPS + 1;
        end_index = ii * FPS + 1;
        
        x1 = track_path(start_index,1);
        y1 = track_path(start_index,2);
        if ii == length(speed_per_second)
            x2 = track_path(end,1);
            y2 = track_path(end,2);
        else
            x2 = track_path(end_index,1);
            y2 = track_path(end_index,2);
        end
        speed_per_second(ii) = sqrt((x1 - x2)^2 + (y1 - y2)^2);
        
        %calc area
        if ii == length(speed_per_second)
            area_per_second(ii) = mean(track_area(start_index:end));
        else
            area_per_second(ii) = mean(track_area(start_index:end_index));
        end
        
        %calc path
        if ii == length(speed_per_second)
            path_per_second(ii,:) = mean(track_path(start_index:end,:),1);
        else
            path_per_second(ii,:) = mean(track_path(start_index:end_index,:),1);
        end
        
        if strcmp(wsName, 'shape shifting') == 1
            if ii == length(speed_per_second)
                ratio_per_second(ii,:) = mean(track_ratio(start_index:end,:),1);
            else
                ratio_per_second(ii,:) = mean(track_ratio(start_index:end_index,:),1);
            end
        end
    end
    
    %remove the last point
    speed_per_second = speed_per_second(1:end-1);
    area_per_second = area_per_second(1:end-1);
    path_per_second = path_per_second(1:end-1);
    
    %create speed figure
    diff_track_path = diff(track_path); %find diff
    diff_track_path_squared = diff_track_path .^ 2; %square
    diff_track_path_squared_summed = sum(diff_track_path_squared,2); %sum
    track_path_vectorial_change = diff_track_path_squared_summed .^ 0.5; %root
    
    calibrated_speed_per_second = speed_per_second * calibrationFactor;
    
    %plot design
    if strcmp(wsName, 'shape shifting') == 1
        plotsX = 2;
        plotsY = 2;
        
        subplot(plotsY, plotsX,4);
        plot(1:length(ratio_per_second),ratio_per_second);
        xlabel('Seconds');
        ylabel('Ratio');
        title('Maximal aspect ratio');
    else
        plotsX = 1;
        plotsY = 3;
    end
    
    %plot velocity
    subplot(plotsY,plotsX,1);
    plot(1:length(calibrated_speed_per_second),calibrated_speed_per_second);
    xlabel('Seconds');
    ylabel(strcat('cm s^-1'));
    title('Velocity');
    
    
    %calculate normalized area
    subplot(plotsY,plotsX,2);
    plot(area_per_second/max(area_per_second));
%     plot(norm_track_area(1:25:end));
%     %change the xTicks to seconds
%     x_ticks = str2num(get(gca,'XTickLabel'));
%     x_ticks = x_ticks / FPS;
%     set(gca, 'XTickLabel', num2str(x_ticks));
    xlabel('Seconds');
    ylabel('Normallized Area');
    title('Normallized Area');
    
    subplot(plotsY,plotsX,3);
    calibrated_area_per_second = area_per_second * calibrationFactor^2;
    scatter(calibrated_area_per_second , speed_per_second,[],'b.');
    title('Area VS Velocity');
    xlabel('Area cm^2');
    ylabel('Velocity cm s^-1');

    suptitle(strcat(wsName,{' Trial: '},cell2mat(my_paths(my_sweep,1))));
    
    %create folder
    mkdir(strcat(wsName,'output/',my_paths{my_sweep,1}));
    
    %save figures
    print(h_path, '-dpng', strcat(wsName,'/output/',my_paths{my_sweep,1},'/fig_',my_paths{my_sweep,1},'.png'));
    
    %save specific variables  
    if strcmp(wsName , 'shape shifting') == 1
        csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/track_ratio_',my_paths{my_sweep,1},'.csv'),track_ratio);
        csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/track_cross_size_',my_paths{my_sweep,1},'.csv'),track_cross_size);
        csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/ratio_per_second',my_paths{my_sweep,1},'.csv'),ratio_per_second);
    end
    
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/area_',my_paths{my_sweep,1},'.csv'),track_area);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/path_',my_paths{my_sweep,1},'.csv'),track_path);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/path_vectorial_change_',my_paths{my_sweep,1},'.csv'),track_path_vectorial_change);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/norm_area_',my_paths{my_sweep,1},'.csv'),norm_track_area);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/calibrated_speed_per_second_',my_paths{my_sweep,1},'.csv'),calibrated_speed_per_second);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/area_per_second_',my_paths{my_sweep,1},'.csv'),area_per_second);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/path_per_second_',my_paths{my_sweep,1},'.csv'),path_per_second);
    csvwrite(strcat(wsName,'/output/',my_paths{my_sweep,1},'/calibrated_area_',my_paths{my_sweep,1},'.csv'),calibrated_area_per_second);
    save(strcat(wsName,'/output/',my_paths{my_sweep,1},'/useful_vars_',my_paths{my_sweep,1},'.mat'),'track_area','norm_track_area','track_path','track_path_vectorial_change','speed_per_second','path_per_second','area_per_second');
end