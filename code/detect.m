
%extract background
vidObj = VideoReader('bg.wmv');     %create a video object
background = read(vidObj, 1);       %read the first frame
background = rgb2gray(background);  %from RGB to gray scale


%read the original video 
my_vid = VideoReader('experVideoPart1.wmv');    %create a video object for the experiment video
nFrames = my_vid.NumberOfFrames;                %get the number of the frames in this video

%containers for saving data on the liquid 
track_area = zeros(nFrames,1);  %track liquid's area
track_path = zeros(nFrames,2);  %track path liquid does

%write the output video 
writerObj = VideoWriter('output');   %create a object video for the output
fps = my_vid.FrameRate;              %frames per second
open(writerObj)                      %opens the file associated with writerObj

%loop on each frame
for i = 1 : nFrames
    
    single_frame = read(my_vid, i);     %read frame number i
    
    I = rgb2gray(single_frame);         %from RGB to gray scale
    I2 = background-I;                  %subtract the background
    I3 = imadjust(I2);                  %increases the contrast
        
    level = graythresh(I3);             %for the next line
    bw = im2bw(I3, level);              %convert frame to binary -black/white
    bw = bwareaopen(bw,200);            %removes from a binary image all connected 
                                        %components (objects) that have fewer
                                        %than x pixels(here=200)
    
    %start - using this: http://www.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html?prodcode=IP
    %goal: 
    se90 = strel('line', 1, 90);
    se0 = strel('line', 1, 0);
    BWsdil = imdilate(bw, [se90 se0]);
    BWdfill = imfill(BWsdil, 'holes');      %fill the shape
    BWnobord = imclearborder(BWdfill,4);    %this does not has a great influence
    %end of the above tutorial                                  
                                       
    cc = bwconncomp(BWnobord,4);
    all_spots_data = regionprops(cc, 'basic');
    areas_vector = [all_spots_data(:).Area];
    spot_id = find(max(areas_vector) == areas_vector);
    target_center = ceil(all_spots_data(spot_id).Centroid);
    track_path(i,:) = target_center;
    track_area(i) = all_spots_data(spot_id).Area;
    
    %find outline
    BWoutline = bwperim(BWnobord);

    
    
end

close(writerObj)                        %close writeObj



