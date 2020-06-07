%this function 

function [ cirCenters ] = getCirCenters(bgHight,bgWidth)

nSpeak = 16;        %number of speakers
nSpeakRow = 4;      %number of speakers in a row/column

%for new camera
radius = 38;        %size of radius
x = 0.64;           %for the distance between the rows
y = 0.5;           %for the distance between each circle in a row
widthOffset = 250;  %offset to the right
hightOffset = 175;   %down offset  

%circles dimensions (centerX centerY radius)
cirCenters = int16(zeros(nSpeak,3)); 

%for each circle calculate its center and put in cirCenters matrix
offsetX = bgWidth/nSpeakRow;
offsetY = bgHight/nSpeakRow;

[X,Y] = meshgrid(0:x:3*x, 0:y:3*y);

centersX = reshape(Y,[1,nSpeak]);
centersY = reshape(X,[1,nSpeak]);

cirCenters(:,1) = centersX*offsetX + widthOffset;  %centerX
cirCenters(:,2) = centersY *offsetY + hightOffset;  %centerY
cirCenters(:,3) = repmat(radius, nSpeak, 1);    %third column is the radius 


end

%for old camera
% radius = 43;        %size of radius
% x = 0.82;           %for the distance between the rows
% y = 0.66;           %for the distance between each circle in a row
% widthOffset = 268;  %offset to the right
% hightOffset = 80;   %down offset 
