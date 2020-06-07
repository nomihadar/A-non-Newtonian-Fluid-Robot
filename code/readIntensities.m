%this function reads an excel file with the intensities of 16 speakers
%and returns :
% 1. a numeric array with the normalized intensities, mapped to rhe value
% of thier bins (the bin center)
% 2. a cell array with the time. - to do
function [intMatOut] = readIntensities(path)
   
    maxIntensity = 900; %maximal intensity
    N = 15; %divide red channel into N equal-length segments (bins)
    
    %read the file
    intensitiesMat = xlsread(strcat(path,'_full.csv'));
    
    %get bins centers
    [~, binsCent] = hist(0:255, N);  
    %create a kind of a roulette with each center appears N times
    reBinsCenter = repmat(binsCent,ceil(255/N),1);
    roulette = round(reshape(reBinsCenter,1,numel(reBinsCenter)));
    
    %normalize intensities 
    normIntens = round((intensitiesMat/maxIntensity)*255); 
    
    %this function mapped each number between 0-255 to its center bin
    mappedInt = arrayfun(@(x)roulette(x+1),normIntens);
    
    intMatOut = uint8(mappedInt);

end

