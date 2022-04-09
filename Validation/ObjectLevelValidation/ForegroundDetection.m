%% Load raw LiDAR Data

myDir = 'E:\GeorgeSt_Velodyne\Albany@George0730'; %gets directory

addpath(myDir);

myFiles = dir(fullfile(myDir,'*.pcap')); %gets all wav files in struct

%% load forground
% load("GMM_French@Joyce1110.mat");
load('GMM_George@Albany0730.mat');

%%
begin_timeSTMAP = 1639571100.11;

val_begin_timetamp  = 1639571400;

interval_sample = 30;

fps = 10;

frame_nums = zeros(30,1);

time_stamps = zeros(30,1);

for i = 1: 30

    timelaspe = val_begin_timetamp + interval_sample * i;

    frame_num = round((timelaspe - begin_timeSTMAP)*fps) + 1;

    time_stamps(i) = timelaspe;

    frame_nums(i) = frame_num;

end


%% 
xlimits = [-100 100];
ylimits = [-100 100];
zlimits = [-10 0];

ax = axes('Parent',uipanel);
axis([-100 100 -100 100]);
SegmentationMinDistance = 1.2;  % lateral is usually 1 meters, following cars usually 1.8 ft
minimum_cluster_pts = 30;
total_frames = 12000;

frame_num = 0;

idx = 0;

for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  veloReader = velodyneFileReader(fullFileName,'VLS128');

  while(hasFrame(veloReader))

      ptCloudObj = readFrame(veloReader);

      frame_num = frame_num + 1;

      if  k == 1

          continue;
       
      end

      if frame_num > start_Frame + total_frames

          break;
          
      end

    fg_LiDAR = lidarData{frame_num};

    fg_LiDAR = pcdenoise(fg_LiDAR,'NumNeighbors', 4);

    [labels,numClusters] = pcsegdist(fg_LiDAR, SegmentationMinDistance);

    % Select each cluster and fit a cuboid to each cluster.
    bboxes = [];
    for num = 1:numClusters
        labelIdx = (labels == num);
        
        % Ignore cluster that has points less than 200 points.
        if sum(labelIdx,'all') < minimum_cluster_pts
            continue;
        end

        pcSeg = select(fg_LiDAR, labelIdx);

        try
            mdl = pcfitcuboid(pcSeg);
            bboxes = [bboxes; mdl.Parameters];
        catch
            continue;
        end
    end

    pcshowpair(ptCloudObj, fg_LiDAR, 'Parent', ax);
    showShape('cuboid',bboxes,'Parent',ax,'Opacity',0.1,...
          'Color','yellow','LineWidth',0.5);

    view(2);
    axis([-100 100 -100 100]);
    frame = getframe(gcf);
    img =  frame2im(frame);

    if  ismember(frame_num, frame_nums)

        idx = idx + 1;

        time_stamp = time_stamps(idx);

        file_name = sprintf("AlbanyGeorge_frame_%d.png", frame_num);

        imwrite(img,file_name);

    end
    

  end

end