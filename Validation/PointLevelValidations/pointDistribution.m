%% point level validate

frame_samples = [400, 600, 800, 1000, 1500, 2000];

distance_thrld = 0.000001;

intersections =  ["French@Joyce", "George@Albany"];


xlimits = [-150 150];
ylimits = [-150 150];
zlimits = [-10 2];

% intersections = ["French@Joyce", "George@Albany"];

true_backgrounds = 0;
foreground = 0;

for k = 1 : max(size(intersections))

    intersection = intersections(k);

    if k == 1

        mask = "..\French@Joyce_ROI.png";

    else

        mask = "..\George_st_ROI.png";

    end

    roi_mask = imread(mask);
    
    for i = 1 : max(size(frame_samples))
    
        frame_num = frame_samples(i);

        row = (k-1) * max(size(frame_samples)) + i;
    
        ground_truth_file = strcat(intersection, sprintf('_frame_%d.ply', frame_num));
        raw_file = strcat(intersection, sprintf('_CFTA_original_frame_%d.ply', frame_num));

        ground_truth_ptCloud = pcread(ground_truth_file);
        raw_ptCould = pcread(raw_file);
        [raw_ptCould, ~] = cropPointCloud(raw_ptCould,xlimits, ylimits, zlimits);
%             raw_ptCould = roi_filter(raw_ptCould, roi_mask); 

        ground_truth_ptCloud_XYZ = ground_truth_ptCloud.Location;
        raw_ptCould_XYZ = raw_ptCould.Location;

        Raw_Ground_Dist = pdist2(raw_ptCould_XYZ, ground_truth_ptCloud_XYZ);
        True_backgrounds = sum(Raw_Ground_Dist > distance_thrld, 2) > 0;

        true_backgrounds = true_backgrounds +  sum(True_backgrounds==1);
        foreground = foreground + size(ground_truth_ptCloud_XYZ,1);

        
    end

end

%%
point_counts = [foreground, true_backgrounds]; 
lyer = categorical({'Foreground Points ' 'Background Points'});
figure
bar(lyer,point_counts)
title('Imbalanced Foreground and Background Points');
%%
labels = {'Foreground Points ' 'Background Points'};
pie(point_counts,labels)

