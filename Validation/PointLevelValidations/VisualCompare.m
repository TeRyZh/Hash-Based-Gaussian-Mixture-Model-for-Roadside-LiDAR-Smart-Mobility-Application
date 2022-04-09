% frame_samples = [200, 400, 600, 800, 1000];
frame_samples = [400];

model_precisions = [0,0];
model_recalls = [0,0];
model_F1s = [0,0];

comparable_precisions = [0, 0];
comparable_recalls = [0, 0];
comparable_F1s = [0, 0];

xlim([-50 30])
ylim([-10 20])

for i = 1 : max(size(frame_samples))

    frame_num = frame_samples(i);

    ground_truth_file = sprintf('French@Joyce_frame_%d.ply', frame_num);
    model_file = sprintf('French@Joyce_GMM_frame_%d.ply', frame_num);
    comparable_file_1 = sprintf('French@Joyce_CFTA_frame_%d.ply', frame_num);
    comparable_file_2 = sprintf('French@Joyce_ReferenceModel_frame_%d.ply', frame_num);

    ground_truth_ptCloud = pcread(ground_truth_file);
    model_ptCloud = pcread(model_file);
    comparable_ptCloud_1 = pcread(comparable_file_1);
    comparable_ptCloud_2 = pcread(comparable_file_2);

    figure;
    pcshow(ground_truth_ptCloud, 'BackgroundColor', [1 1 1]);
    xlim([-50 30])
    ylim([-10 20])
    title('Ground Truth Point Clouds');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    figure;
    pcshow(model_ptCloud, 'BackgroundColor', [1 1 1]);
    xlim([-50 30])
    ylim([-10 20])
    title('GMM Model Detected Point Clouds')
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    figure;
    pcshow(comparable_ptCloud_1, 'BackgroundColor', [1 1 1]);
    xlim([-50 30])
    ylim([-10 20])
    title('CFTA Model Detected Point Clouds')
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    figure;
    pcshow(comparable_ptCloud_2, 'BackgroundColor', [1 1 1]);
    xlim([-50 30])
    ylim([-10 20])
    title('Mean-Max Model Detected Point Clouds')
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

end


