
%%%%%%%%%%%%%   define variabels and constants  %%%%%%%%%%%

vidName = 'vid1';

nSpeak = 16;        %number of speakers
nSpeakRow = 4;      %number of speakers in a row/column

indexes = [4:4:16 3:4:15 2:4:14 1:4:13];    %the rea order of the speakers

fillColor = uint8(zeros(nSpeak,3));  %fill-colors for each speaker
redIntensity = uint8(zeros(1,nSpeak)); %red intensity only (0-255)          

%%%%%%%%%%%     START       %%%%%%%%%%%%%%%%%%%%%%%%%%%

%extract background
bg_vid = VideoReader(strcat(vidName,'.mp4'));
background = read(bg_vid, 1);
[bgHight, bgWidth, ~] = size(background);

%get circles dimensions (centerX centerY radius)
cirCenters = getCirCenters(bgHight,bgWidth);

%get the intensities matrix from a file
intensMat = readIntensities(strcat(vidName,'.xlsx'));
[nIntRows,~] = size(intensMat); %number of rows in the intensities mat

%loop on each line of the intensities matrix
for i = 1 : nIntRows
    
    %reorder the speakers locations
    redIntensity(indexes) = intensMat(i,:);
   
    %assign the red intensity to fillColor mat. format: [redIntensity 0 0]
    fillColor(:,1) = redIntensity;
    
    %get background with circles 
    outputImage = drawCircles(background, fillColor, cirCenters);

   % imwrite(outputImage,strcat(int2str(i),'.png'));
end
