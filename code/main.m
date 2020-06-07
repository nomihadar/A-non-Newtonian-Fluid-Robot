clear;clc;
%%%%%%%%%%%%%   define variabels and constants  %%%%%%%%%%%
%wsName = 'shape shifting';
wsName = 'shape shifting';
vidName = '1-1705-1707';
bgName = 'bg.png';

partPath = strcat(wsName,'/',vidName,'/',vidName);

outputPath = strcat(wsName,'/output/',vidName,'/',vidName);

nSpeak = 16;        %number of speakers
nSpeakRow = 4;      %number of speakers in a row/column

MINIMAL_PARTICLE_SIZE = 7;

indexes = [4:4:16 3:4:15 2:4:14 1:4:13];    %the reorder of the speakers

fillColor = uint8(zeros(nSpeak,3));  %fill-colors for each speaker
redIntensity = uint8(zeros(1,nSpeak)); %red intensity only (0-255) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir(strcat(wsName,'/output/',vidName));

%extract background
%for AB
% bg_vid = VideoReader(strcat(wsName,'/',bgName));
% background = read(bg_vid, 1);
% [bgHight, bgWidth, ~] = size(background);
% background = rgb2gray(background);

%for 100g
background = imread(strcat(wsName,'/',bgName));
[bgHight, bgWidth, ~] = size(background);
background = rgb2gray(background);

%video reader
my_vid = VideoReader(strcat(partPath,'.mp4'));
nframes = my_vid.NumberOfFrames;
fps = my_vid.FrameRate;

convertSpeakerOutputToFPS(partPath,outputPath, nframes, fps); 

%get the intensities matrix from a file
intensMat = readIntensities(outputPath);
[nIntRows,~] = size(intensMat); 

%get circles dimensions (centerX centerY radius)
cirCenters = getCirCenters(bgHight,bgWidth);

I = read(my_vid, 1);


track_area = zeros(nframes,1);
track_path = zeros(nframes,2);
track_particles = zeros(nframes,1);
track_cross_size = zeros(nframes,2);

if strcmp(wsName, 'shape shifting') == 1
    track_ratio = zeros(nframes,1);
end

%cretae the VideoWriter objects
write_color_vid = VideoWriter(strcat(outputPath,'_output.mp4'),'MPEG-4');
write_vid_speakers = VideoWriter(strcat(outputPath,'_speakers_output.mp4'),'MPEG-4');

%set fps
write_color_vid.FrameRate = fps; 
write_vid_speakers.FrameRate = fps;

%open for writing
open(write_color_vid)
open(write_vid_speakers)

%for seeing advancement through the command window
percentage = -1;

for ii = 1 : nframes
    
    single_frame = read(my_vid, ii);
    I = rgb2gray(single_frame);
    
    I2 = background-I;
    
    I3 = imadjust(I2);
    
    level = graythresh(I3);
    bw = im2bw(I3, level);
    bw = bwareaopen(bw,200);

    %start - using this: http://www.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html?prodcode=IP
    se90 = strel('line', 1, 90);
    se0 = strel('line', 1, 0);
    BWsdil = imdilate(bw, [se90 se0]);
    BWdfill = imfill(BWsdil, 'holes');
    BWnobord = imclearborder(BWdfill,4);
    %end
    
    %find connected components: http://www.mathworks.com/help/images/examples/correcting-nonuniform-illumination.html
    cc = bwconncomp(BWnobord,4);
    all_spots_data = regionprops(cc, 'basic');
    
    areas_vector = [all_spots_data(:).Area];
    spot_id = find(max(areas_vector) == areas_vector); %find the maximal size spot
    my_spot_center = all_spots_data(spot_id).Centroid; %get spot center
    target_center = ceil(my_spot_center); %save spot's center
    track_path(ii,:) = target_center; %track the center
    track_area(ii) = all_spots_data(spot_id).Area; %track the area
    track_particles(ii) = sum(areas_vector>MINIMAL_PARTICLE_SIZE);
        
    %creates epileptic movie
%     labeled = labelmatrix(cc);
%     RGB_label = label2rgb(labeled, @spring, 'c', 'noshuffle');
 
    if (track_path(ii,1) > 296 || track_path(ii,2) > 300)
        
        max_ratio = 0;
        for jj = 1:3:90
            rotated_pic = imrotate(BWnobord,jj);%rotate the image
            [rows, cols] = size(rotated_pic);
            
            %now calc the middle 
            cc = bwconncomp(rotated_pic,4);
            rotated_spots_data = regionprops(cc, 'basic');
 
            rotated_areas_vector = [rotated_spots_data(:).Area];
            rotated_spot_id = find(max(rotated_areas_vector) == rotated_areas_vector); %find the maximal size spot
            my_spot_center = rotated_spots_data(rotated_spot_id).Centroid; %get spot center
            my_spot_center = ceil(my_spot_center); %save spot's center
            xc = my_spot_center(1);
            yc = my_spot_center(2); %save spot's center
            
            comp_image = imcomplement(rotated_pic);
            
            x_vals = 1:cols;
            dx = cols-1;
            dy = 0;
            y = ones(size(x_vals))*yc;
            idx = sub2ind(size(rotated_pic),y,x_vals);
            comp_image(idx) = 255;
            sum_horizontal = logical(comp_image) .* logical(rotated_pic);
            horizontal_length = sum(sum(sum_horizontal));
            
            comp_image = imcomplement(rotated_pic);
            y_vals = 1:rows;
            x_vals = ones(size(y_vals))*xc;
            idx = sub2ind(size(rotated_pic),y_vals,x_vals);
            comp_image(idx) = 255;
            sum_vertical = logical(comp_image) .* logical(rotated_pic);
            vertical_length = sum(sum(sum_vertical));
            
            if horizontal_length > vertical_length
                cur_ratio = horizontal_length/vertical_length;
            else
                cur_ratio = vertical_length/horizontal_length;
            end
            
            if(cur_ratio > max_ratio)
                max_ratio = cur_ratio;
                track_cross_size(ii,1) = vertical_length;
                track_cross_size(ii,2) = horizontal_length;
            end
        end
      track_ratio(ii) = max_ratio;
    end 

    %draw ouline
    BWoutline = bwperim(BWnobord);
    
    r = single_frame(:,:,1);
    g = single_frame(:,:,2);
    b = single_frame(:,:,3);
    r(BWoutline) = 255; %white
    g(BWoutline) = 255;
    b(BWoutline) = 255;
    
    RGBoutline = cat(3,r,g,b);
    
    %draw speakers
    %reorder the speakers locations
    redIntensity(indexes) = intensMat(ii,:);
    %assign the red intensity to fillColor mat. format: [redIntensity 0 0]
    fillColor(:,1) = redIntensity;
    %get background with circles 
    RGBoutlineSpeak = drawCircles(RGBoutline, fillColor, cirCenters);
    
    %draw a cross
    markerInserter = vision.MarkerInserter('Shape','Plus',...
                                        'Size', 10,'BorderColor','white');
    Pts = int32([target_center(1) target_center(2)]);
    crossed = step(markerInserter, RGBoutline, Pts);
    crossedSpeak = step(markerInserter, RGBoutlineSpeak, Pts);
   
    %write to video
    writeVideo(write_color_vid, crossed);
    writeVideo(write_vid_speakers, crossedSpeak);
      
    current_percentage = floor(ii*100/nframes);
    if percentage ~= current_percentage
        disp(strcat(num2str(current_percentage),'%'))
        percentage = current_percentage;
    end
end
 
%close video writer
close(write_color_vid);
close(write_vid_speakers);

%create normallized area figure
norm_track_area = track_area / max(track_area);

save(strcat(outputPath,'_vars'));

% notify its done
for ii = 1:10
    beep;
    pause(0.1);
end