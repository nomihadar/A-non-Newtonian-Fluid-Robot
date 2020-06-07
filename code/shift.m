
calibFactor = 50/410;            

[rows, ~] = size(track_cross_size);


%sort values
sorted = track_cross_size;
for i = 1 : rows
    if (sorted(i,1) > sorted(i,2))
        sorted(i,:) = [sorted(i,2),sorted(i,1)];
    end    
end

%clean noise
TC_no_noise = sorted;
for i = 1 : rows
    if (track_path(i,1) < 296 || track_path(i,2) < 300)
        TC_no_noise(i,:) = [0,0];
    end    
end



per_frame_centim = TC_no_noise.*calibFactor;


%per second
per_second = zeros(floor(rows/fps),2);
for ii = 1:length(per_second)
    
    second = (ii-1)*fps+1 : ii*fps;
    
    %get the short and long lines over a second
    short_line = TC_no_noise(second,1);
    long_line = TC_no_noise(second,2);
    
    %sum 
    sumShort = sum(short_line~=0);
    sumLong = sum(long_line~=0);
    
    %calc avg. IGNORE zeros
    if (sumLong==0)
         per_second(ii,:) = [0,0];
    else
        mean_short_line = sum(short_line) ./ sumShort;
        mean_long_line = sum(long_line) ./ sumLong;
        per_second(ii,:) = [mean_short_line, mean_long_line];
    end
end

%round it
per_second_pix = round(per_second);

%per second in cantimeters
per_sec_centim = per_second.*calibFactor;

%per second ratio
per_sec_ratio = per_second;
for ii = 1:length(per_second)
    if( per_sec_ratio(ii,:) ~= 0)
    per_sec_ratio(ii,:) = per_sec_ratio(ii,:)./per_second(ii,1);
    end
end

per_frame_ratio = TC_no_noise;
for ii = 1:length(TC_no_noise)
    if( per_frame_ratio(ii,:) ~= 0)
    per_frame_ratio(ii,:) = per_frame_ratio(ii,:)./per_frame_ratio(ii,1);
    end
end


%write TC_no_noise_pix
csvwrite('aspect_ratio_pix_per_frame.csv', TC_no_noise);

%write per_second_pix
csvwrite('aspect_ratio_pix_per_sec.csv', per_second_pix);

%write per second in cantimeters
csvwrite('aspect_ratio_cent_per_sec.csv', per_sec_centim);

%write cent per frame
csvwrite('aspect_ratio_cent_per_frame.csv', per_frame_centim);



