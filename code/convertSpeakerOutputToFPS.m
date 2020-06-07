
%this function takes speakers output (which is sampled at lower than 1Hz) and
%convert it into 25fps = 1/25 Hz

function [] = convertSpeakerOutputToFPS (path,outputPath, TOTAL_FRAMES, FPS_RATE)

%END OF SETTINGS

[num, txt, raw] = xlsread(strcat(path,'.xlsx'));
speakers_count = size(num,2)-1; %assuming structure: <datetime> <sp1> <sp2>

%create seconds differences vector
time_vectors = datevec(num(:,1));
time_diffs = zeros(size(time_vectors,1)-1,1);
%create time diffrences in seconds
for ii=1:length(time_diffs)
    time_diffs(ii) = etime(time_vectors(ii+1,:), time_vectors(ii,:));
end

%create empty matrix
out_csv = zeros(TOTAL_FRAMES, speakers_count);
csv_index = 0;

%this loop insert values to thier correct places
for ii = 1:length(time_diffs)
    for jj = 1:(time_diffs(ii)*FPS_RATE)
        out_csv(csv_index + jj,:) = num(ii,2:end);
    end
    csv_index = csv_index + jj;
end

%the last records
for ii = csv_index:TOTAL_FRAMES
    out_csv(ii,:) = num(end,2:end);
end

csvwrite(strcat(outputPath,'_full.csv'), out_csv);

end 

%max_v = max(max(out_csv));
%OPTION 1
% figure; %HARD CODED!!!
% axes_vec = zeros(16,1);
% for ii=1:16
%     axes_vec(ii) = subplot(4,4,ii);
%     plot(out_csv(:,ii));
%     axis([0,TOTAL_FRAMES,0,max_v]);
%     title(num2str(ii));
% end

% %OPTION 2
% for ii = 1:1
%     title(num2str(ii));
%     %cline(x,y,z,c,colormap);
%     h = cline(1:TOTAL_FRAMES,out_csv(:,ii),zeros(1:TOTAL_FRAMES,1),1:TOTAL_FRAMES,'jet');
% end
