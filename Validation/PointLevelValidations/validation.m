%% point level validate

frame_samples = [400, 600, 800, 1000, 1500, 2000];

distance_thrlds = [0.0000000001, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100];

intersections =  ["French@Joyce", "George@Albany"];

GMM_precisions = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
GMM_recalls = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
GMM_F1s = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
GMM_tps = GMM_precisions;
GMM_fps = GMM_precisions;
GMM_fns = GMM_precisions;
GMM_tns = GMM_precisions;


CFTA_precisions = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
CFTA_recalls = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
CFTA_F1s = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
CFTA_tps = GMM_precisions;
CFTA_fps = GMM_precisions;
CFTA_fns = GMM_precisions;
CFTA_tns = GMM_precisions;

ITSTRANS_precisions = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
ITSTRANS_recalls = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
ITSTRANS_F1s = zeros([2*max(size(frame_samples)), max(size(distance_thrlds))]);
ITSTRANS_tps = GMM_precisions;
ITSTRANS_fps = GMM_precisions;
ITSTRANS_fns = GMM_precisions;
ITSTRANS_tns = GMM_precisions;


xlimits = [-150 150];
ylimits = [-150 150];
zlimits = [-10 2];

% intersections = ["French@Joyce", "George@Albany"];

for j = 1 : max(size(distance_thrlds))

    distance_thrld = distance_thrlds(j);

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
            GMM_file = strcat(intersection, sprintf('_GMM_frame_%d.ply', frame_num));
            CFTA_file = strcat(intersection, sprintf('_CFTA_frame_%d.ply', frame_num));
            ITSTRANS_file = strcat(intersection, sprintf('_ReferenceModel_frame_%d.ply', frame_num));
            raw_file = strcat(intersection, sprintf('_CFTA_original_frame_%d.ply', frame_num));

            ground_truth_ptCloud = pcread(ground_truth_file);
            GMM_ptCloud = pcread(GMM_file);
            CFTA_ptCloud = pcread(CFTA_file);
            ITSTRANS_ptCloud = pcread(ITSTRANS_file);
            raw_ptCould = pcread(raw_file);
            [raw_ptCould, ~] = cropPointCloud(raw_ptCould,xlimits, ylimits, zlimits);
            raw_ptCould = roi_filter(raw_ptCould, roi_mask); 

            ground_truth_ptCloud_XYZ = ground_truth_ptCloud.Location;
            GMM_ptCloud_XYZ = GMM_ptCloud.Location;
            CFTA_ptCloud_XYZ = CFTA_ptCloud.Location;
            ITSTRANS_ptCloud_XYZ = ITSTRANS_ptCloud.Location;
            raw_ptCould_XYZ = raw_ptCould.Location;

            Raw_Ground_Dist = pdist2(raw_ptCould_XYZ, ground_truth_ptCloud_XYZ);
            True_backgrounds = sum(Raw_Ground_Dist > distance_thrld, 2) > 0;

            % calculate model performance metrics
            GMM_Ground_Dist = pdist2(GMM_ptCloud_XYZ, ground_truth_ptCloud_XYZ);
            Ground_GMM_Dist = pdist2(ground_truth_ptCloud_XYZ, GMM_ptCloud_XYZ);
            Raw_GMM_Dist = pdist2(raw_ptCould_XYZ, GMM_ptCloud_XYZ);
    
            GMM_accurate_det = sum(GMM_Ground_Dist <= distance_thrld, 2) > 0;
            GMM_false_det = 1 - GMM_accurate_det;
            GMM_missed = 1- sum(Ground_GMM_Dist <= distance_thrld, 2) > 0;
            GMM_backgrounds = sum(Raw_GMM_Dist > distance_thrld, 2) > 0;
    
            GMM_tps(row, j) = sum(GMM_accurate_det == 1);
            GMM_fps(row, j) = sum((GMM_false_det == 1));
            GMM_fns(row, j) = sum((GMM_missed == 1));
            GMM_tns(row,j) = sum(True_backgrounds==1 & GMM_backgrounds == 1);
    
            GMM_precisions(row, j) = GMM_tps(row, j) / (GMM_tps(row, j) + GMM_fps(row, j));
            GMM_recalls(row, j) = GMM_tps(row, j) / (GMM_tps(row, j) + GMM_fns(row, j));
            GMM_F1s(row, j) = (2 * GMM_precisions(row, j) * GMM_recalls(row, j)) / (GMM_precisions(row, j) + GMM_recalls(row, j));
    
            % calculate comparable model performance metrics
            CFTA_Ground_Dist = pdist2(CFTA_ptCloud_XYZ, ground_truth_ptCloud_XYZ);
            Ground_CFTA_Dist = pdist2(ground_truth_ptCloud_XYZ, CFTA_ptCloud_XYZ);
            Raw_CFTA_Dist = pdist2(raw_ptCould_XYZ, CFTA_ptCloud_XYZ);
    
            CFTA_accurate_det = sum(CFTA_Ground_Dist <= distance_thrld, 2) > 0;
            CFTA_false_det = 1 - CFTA_accurate_det;
            CFTA_mdoel_missed = 1- sum(Ground_CFTA_Dist <= distance_thrld, 2) > 0;
            CFTA_backgrounds = sum(Raw_CFTA_Dist > distance_thrld, 2) > 0;
    
            CFTA_tps(row, j) = sum(CFTA_accurate_det == 1);
            CFTA_fps(row, j) = sum((CFTA_false_det == 1));
            CFTA_fns(row, j) = sum((CFTA_mdoel_missed == 1));
            CFTA_tns(row,j) = sum(True_backgrounds==1 & CFTA_backgrounds == 1);
    
            CFTA_precisions(row, j) = CFTA_tps(row, j) / (CFTA_tps(row, j) + CFTA_fps(row, j));
            CFTA_recalls(row, j) = CFTA_tps(row, j) / (CFTA_tps(row, j) + CFTA_fns(row, j));
            CFTA_F1s(row, j) = (2 * CFTA_precisions(row, j) * CFTA_recalls(row, j)) / (CFTA_precisions(row, j) + CFTA_recalls(row, j));
    
    
            % calculate ITSTRANS performance metrics
            ITSTRANS_Ground_Dist = pdist2(ITSTRANS_ptCloud_XYZ, ground_truth_ptCloud_XYZ);
            Ground_ITSTRANS_Dist = pdist2(ground_truth_ptCloud_XYZ, ITSTRANS_ptCloud_XYZ);
            Raw_ITSTRANS_Dist = pdist2(raw_ptCould_XYZ, ITSTRANS_ptCloud_XYZ);
    
            ITSTRANS_accurate_det = sum(ITSTRANS_Ground_Dist <= distance_thrld, 2) > 0;
            ITSTRANS_false_det = 1 - ITSTRANS_accurate_det;
            ITSTRANS_missed = 1- sum(Ground_ITSTRANS_Dist <= distance_thrld, 2) > 0;
            ITSTRANS_backgrounds = sum(Raw_ITSTRANS_Dist > distance_thrld, 2) > 0;
    
            ITSTRANS_tps(row, j) = sum(ITSTRANS_accurate_det == 1);
            ITSTRANS_fps(row, j) = sum((ITSTRANS_false_det == 1));
            ITSTRANS_fns(row, j) = sum((ITSTRANS_missed == 1));
            ITSTRANS_tns(row,j) = sum(True_backgrounds==1 & ITSTRANS_backgrounds == 1);
    
            ITSTRANS_precisions(row, j) = ITSTRANS_tps(row, j) / (ITSTRANS_tps(row, j) + ITSTRANS_fps(row, j));
            ITSTRANS_recalls(row, j) = ITSTRANS_tps(row, j) / (ITSTRANS_tps(row, j) + ITSTRANS_fns(row, j));
            ITSTRANS_F1s(row, j) = (2 * ITSTRANS_precisions(row, j) * ITSTRANS_recalls(row, j)) / (ITSTRANS_precisions(row, j) + ITSTRANS_recalls(row, j));

        end

    end

end


%% Draw Precision Recall

% True Positive Rate = TP/(FN+TP)
% False Positive Rate = FP/(FP+TN)
% 
FalsePositiveRate_CFTA = sum(CFTA_fps,1)./(sum(CFTA_fps,1) + sum(CFTA_tns,1));
TruePositiveRate_CFTA = sum(CFTA_tps,1)./(sum(CFTA_fns,1) + sum(CFTA_tps,1));

FalsePositiveRate_GMM = sum(GMM_fps,1)./(sum(GMM_fps,1) + sum(GMM_tns,1));
TruePositiveRate_GMM = sum(GMM_tps,1)./(sum(GMM_fns,1) + sum(GMM_tps,1));

FalsePositiveRate_ITSTRANS = sum(ITSTRANS_fps,1)./(sum(ITSTRANS_fps,1) + sum(ITSTRANS_tns,1));
TruePositiveRate_ITSTRANS = sum(ITSTRANS_tps,1)./(sum(ITSTRANS_fns,1) + sum(ITSTRANS_tps,1));

%% 
plot(FalsePositiveRate_CFTA, TruePositiveRate_CFTA)
hold on
plot(FalsePositiveRate_GMM, TruePositiveRate_GMM)
plot(FalsePositiveRate_ITSTRANS, TruePositiveRate_ITSTRANS)
legend('Coarse Fine Triangle Algorihtm','Gaussian Mixture Model','Point Based Reference Model','Location','Best')
xlabel('False positive rate'); ylabel('True positive rate');
title('ROC Curves for CFTA, GMM, and ITS-T Reference Model')
hold off


%% French@Joyce Evaluation Metrics

CFTA_Accuracy_French = (sum(CFTA_tps(1:6,2),1) + sum(CFTA_tns(1:6,2),1)) ./(sum(CFTA_tps(1:6,2),1) + sum(CFTA_fps(1:6,2),1) + sum(CFTA_tns(1:6,2),1) + sum(CFTA_fns(1:6,2),1));

CFTA_Precision_French = (sum(CFTA_tps(1:6,2),1)) ./(sum(CFTA_tps(1:6,2),1) + sum(CFTA_fps(1:6,2),1));

CFTA_Recall_French = (sum(CFTA_tps(1:6,2),1)) ./(sum(CFTA_tps(1:6,2),1) + sum(CFTA_fns(1:6,2),1));

CFTA_F1s_French = 2 * (CFTA_Precision_French * CFTA_Recall_French)/(CFTA_Precision_French  + CFTA_Recall_French);

%% George@Albany Evaluation Metrics

CFTA_Accuracy_George = (sum(CFTA_tps(7:12,2),1) + sum(CFTA_tns(7:12,2),1)) ./(sum(CFTA_tps(7:12,2),1) + sum(CFTA_fps(7:12,2),1) + sum(CFTA_tns(7:12,2),1) + sum(CFTA_fns(7:12,2),1));

CFTA_Precision_George = (sum(CFTA_tps(7:12,2),1)) ./(sum(CFTA_tps(7:12,2),1) + sum(CFTA_fps(7:12,2),1));

CFTA_Recall_George = (sum(CFTA_tps(7:12,2),1)) ./(sum(CFTA_tps(7:12,2),1) + sum(CFTA_fns(7:12,2),1));

CFTA_F1s_George = 2 * (CFTA_Precision_George * CFTA_Recall_George)/(CFTA_Precision_George  + CFTA_Recall_George);

%% French@Joyce Evaluation Metrics

GMM_Accuracy_French = (sum(GMM_tps(1:6,2),1) + sum(GMM_tns(1:6,2),1)) ./(sum(GMM_tps(1:6,2),1) + sum(GMM_fps(1:6,2),1) + sum(GMM_tns(1:6,2),1) + sum(GMM_fns(1:6,2),1));

GMM_Precision_French = (sum(GMM_tps(1:6,2),1)) ./(sum(GMM_tps(1:6,2),1) + sum(GMM_fps(1:6,2),1));

GMM_Recall_French = (sum(GMM_tps(1:6,2),1)) ./(sum(GMM_tps(1:6,2),1) + sum(GMM_fns(1:6,2),1));

GMM_F1s_French = 2 * (GMM_Precision_French * GMM_Recall_French)/(GMM_Precision_French  + GMM_Recall_French);

%% George@Albany Evaluation Metrics

GMM_Accuracy_George = (sum(GMM_tps(7:12,2),1) + sum(GMM_tns(7:12,2),1)) ./(sum(GMM_tps(7:12,2),1) + sum(GMM_fps(7:12,2),1) + sum(GMM_tns(7:12,2),1) + sum(GMM_fns(7:12,2),1));

GMM_Precision_George = (sum(GMM_tps(7:12,2),1)) ./(sum(GMM_tps(7:12,2),1) + sum(GMM_fps(7:12,2),1));

GMM_Recall_George = (sum(GMM_tps(7:12,2),1)) ./(sum(GMM_tps(7:12,2),1) + sum(GMM_fns(7:12,2),1));

GMM_F1s_George = 2 * (GMM_Precision_George * GMM_Recall_George)/(GMM_Precision_George  + GMM_Recall_George);

%% French@Joyce Evaluation Metrics

ITSTRANS_Accuracy_French = (sum(ITSTRANS_tps(1:6,2),1) + sum(ITSTRANS_tns(1:6,2),1)) ./(sum(ITSTRANS_tps(1:6,2),1) + sum(ITSTRANS_fps(1:6,2),1) + sum(ITSTRANS_tns(1:6,2),1) + sum(ITSTRANS_fns(1:6,2),1));

ITSTRANS_Precision_French = (sum(ITSTRANS_tps(1:6,2),1)) ./(sum(ITSTRANS_tps(1:6,2),1) + sum(ITSTRANS_fps(1:6,2),1));

ITSTRANS_Recall_French = (sum(ITSTRANS_tps(1:6,2),1)) ./(sum(ITSTRANS_tps(1:6,2),1) + sum(ITSTRANS_fns(1:6,2),1));

ITSTRANS_F1s_French = 2 * (ITSTRANS_Precision_French * ITSTRANS_Recall_French)/(ITSTRANS_Precision_French + ITSTRANS_Recall_French);

%% George@Albany Evaluation Metrics

ITSTRANS_Accuracy_George = (sum(ITSTRANS_tps(7:12,2),1) + sum(ITSTRANS_tns(7:12,2),1)) ./(sum(ITSTRANS_tps(7:12,2),1) + sum(ITSTRANS_fps(7:12,2),1) + sum(ITSTRANS_tns(7:12,2),1) + sum(ITSTRANS_fns(7:12,2),1));

ITSTRANS_Precision_George = (sum(ITSTRANS_tps(7:12,2),1)) ./(sum(ITSTRANS_tps(7:12,2),1) + sum(ITSTRANS_fps(7:12,2),1));

ITSTRANS_Recall_George = (sum(ITSTRANS_tps(7:12,2),1)) ./(sum(ITSTRANS_tps(7:12,2),1) + sum(ITSTRANS_fns(7:12,2),1));

ITSTRANS_F1s_George = 2 * (ITSTRANS_Precision_George * ITSTRANS_Recall_George)/(ITSTRANS_Precision_George + ITSTRANS_Recall_George);




