%% Reading the image file from a directory

%clearvars -except bboxes_new bboxes scores_new scores detector_yolov4 detector_yolov2 labels_new labels label_str_new labels_str

% Number of files found
imagefiles = dir('*.jpg');

nfiles = length(imagefiles);

for ii=1:nfiles

    clearvars -except detector_yolov4 detector_yolov2 ii nfiles imagefiles


    currentfilename = imagefiles(ii).name;
    I = imread(currentfilename);
    [bboxes,scores,labels] = detect(detector_yolov2,I);
    [bboxes_new,scores_new,labels_new] = detect(detector_yolov4,I);


    if isempty(bboxes)&& isempty(bboxes_new)
        disp('No derecho detection')
        currentfilename = imagefiles(ii+1).name;
        I = imread(currentfilename);
        [bboxes,scores,labels] = detect(detector_yolov2,I);
        [bboxes_new,scores_new,labels_new] = detect(detector_yolov4,I);
    end

    if isempty(bboxes) && ~isempty(bboxes_new)
        points = bbox2points(bboxes_new);
    end

    if isempty(bboxes_new) && ~isempty(bboxes)
        points =  bbox2points(bboxes);
    end



    %% Making string for the annotation


    for mm=1:length(scores)
        label_str{mm} = [ ' Yolov2: ' num2str(scores(mm), '%0.4f')];
    end

    for kk=1:length(scores_new)
        label_str_new{kk} = [ ' Yolov4: ' num2str(scores_new(kk), '%0.4f')];
    end

    %% Object Notation with the results save process

    f = figure('Visible','off');

    if isempty(bboxes_new) && ~isempty(bboxes)
     I = insertObjectAnnotation(I,"rectangle",bboxes,label_str,"Color","white","LineWidth",10,"FontSize",60);
    end

    if isempty(bboxes) && ~isempty(bboxes_new)
    I = insertObjectAnnotation(I,"rectangle",bboxes_new,label_str_new,"LineWidth",10,"FontSize",60);    
    end

    if ~isempty(bboxes) && ~isempty(bboxes_new)
    I = insertObjectAnnotation(I,"rectangle",bboxes,label_str,"Color","white","LineWidth",10,"FontSize",60);
    I = insertObjectAnnotation(I,"rectangle",bboxes_new,label_str_new,"LineWidth",10,"FontSize",60);    
    end
    imshow(I)

    %
    folder = 'C:\Users\smahmud\Desktop\MCS Dataset\images\png to jpg\results';

    % saveas(gcf,'C:\Users\smahmud\Desktop\New folder\jpg\results\%s',currentfilename,'bmp')
    saveas(f,[pwd '\results\res_',currentfilename]);

    %% Convert the bounding box coordinate to pixel co ordinates

    bbox = [bboxes;bboxes_new];
    for mm=1:height(bbox)
        points = bbox2points(bbox(mm,:));


        k = size(points);
        k=k(end);

        splitA=num2cell(points,[1 2]);


        points_new = vertcat(splitA{:});

        %Calculation

        for i=1:length(points_new)
            longitude(i) = points_new(i,1) * 0.01-126;
            latitude(i) = 50 + points_new(i,2)*(-0.01);
        end

        lat_lon_mat = [];
        lat_lon_mat = [latitude;longitude];
        lat_lon_mat = lat_lon_mat'
        lat_lon_mat_full{mm} = lat_lon_mat;
    end





    %% Saving it in a lat1,Lon1 format and write in a excel file

    model_name_2 = "YOLOv4";
    model_name = "YOLOV2";

    name= strsplit(currentfilename,'_');
    name = string(name{end});
    name = strsplit(name,'.');
    Date = string(name(1));
    Date_col = cell(1,length(lat_lon_mat_full));
    Date_col(:) = {Date};
    Date_col = Date_col';

    ss = cell2mat(lat_lon_mat_full);
    ss = ss';
    lat_list = ss(1:2:end,1:2:end);
    lon_list =  ss(2:2:end,1:2:end);
    scores_full = [scores;scores_new];
    model = cell(1,length(lat_lon_mat_full));
    model(1:length(scores)) = {model_name};
    model(length(scores)+1:end) = {model_name_2};
    model = model';
    name = cell(1,length(lat_lon_mat_full));
    t = table(Date_col,[lat_list(:,1)],[lon_list(:,1)],[lat_list(:,2)],[lon_list(:,2)],...
     scores_full,model,'VariableNames',{'Date','Lat_1','Lon_1','Lat_2','Lon_2','Scores','Model'});
    writetable(t,'mydata.xlsx',"WriteMode","append","AutoFitWidth",false)

    movefile ([imagefiles(ii).name] , 'C:\Users\smahmud\Desktop\MCS Dataset\images\png to jpg\results')

end
