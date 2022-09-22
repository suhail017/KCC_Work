%
% MCS detector V1.0
% Developed by : Suhail Mahmud
% Project advisor : Sara Sienkiewicz, Daniel Ward
% Project creation timeline : September 2022
%
% The purpose of this script is 3 folds. They are as follows:
% 1. Download the images from the mesonet server
% 2. Predict whether it is a MCS day or not
% 3. Detect a Bouning box for the MCS event and convert the bounding box to lat/lon
%
% Running instruction: It is completely automated script which will automatically
% download the image and do all the prediction by itself.
%
% Output : It will produce an Image with bounding boxes and a Text/CSV file
% with all the lat/lon, Scores of the model for the bounding box.
%
% For any issue/problem with the code, please contact author at
% smahmud@karenclarkandco.com.


%%  Get the image download of yesterday

Date = datetime('yesterday');
Date = string(yyyymmdd(Date));

Year = (extractBetween(Date,1,4));
Month = (extractBetween(Date,5,6));
Day = (extractBetween(Date,7,8));


Download_file = urlwrite(sprintf('https://mesonet.agron.iastate.edu/archive/data/%s/%s/%s/GIS/uscomp/max_n0r_0z0z_%s.png',Year,Month,Day,Date),sprintf('%s.jpg',Date));


%% Convert the file into jpg format

[currentimage,cmap] = imread(sprintf('%s.jpg',Date));
image = ind2rgb(currentimage,cmap);
imwrite(image,sprintf('%s.jpg',Date));
im = imresize(image,[224 224]);

 %%  Detecting the MCS/Non-MCS day

% Loading the models in the explorer
load('MCS_models.mat')

[YPred_vgg16]= classify(netTransfer_vgg16,im);
[YPred_googlenet]= classify(netTransfer_googlenet,im);
[YPred_resnet50]= classify(netTransfer_resnet50,im);


result{1} = string(YPred_vgg16);
result{2} = string(YPred_googlenet);
result{3} = string(YPred_resnet50);

sprintf('Result from VGG16 model is %s,\nResult from the Resnet model is %s\nResult from the Google net model is %s',result{1},result{2},result{3})

result_str = string(result);
Derecho_prob = nnz(strcmp(result_str,"Derecho"));
total = Derecho_prob/3;
total = total*100;
sprintf("The probabilty of the Derecho is %i %%",total)

%% Detecting the bounding box from the image and display it

image = imread(sprintf('%s.jpg',Date));
[bboxes,scores,labels] = detect(detector_yolov2,image);
[bboxes_new,scores_new,labels_new] = detect(detector_yolov4,image);
imshow(image)


if isempty(bboxes)&& isempty(bboxes_new)
    disp ('No derecho detection')
    exit
end

if isempty(bboxes) && ~isempty(bboxes_new)
    points = bbox2points(bboxes_new);
end

if isempty(bboxes_new) && ~isempty(bboxes)
    points =  bbox2points(bboxes);
end


for mm=1:length(scores)
    label_str{mm} = [ ' Yolov2: ' num2str(scores(mm), '%0.4f')];
end

for kk=1:length(scores_new)
    label_str_new{kk} = [ ' Yolov4: ' num2str(scores_new(kk), '%0.4f')];
end


if isempty(bboxes_new) && ~isempty(bboxes)
    image = insertObjectAnnotation(image,"rectangle",bboxes,label_str,"Color","white","LineWidth",10,"FontSize",60);
end

if isempty(bboxes) && ~isempty(bboxes_new)
    image = insertObjectAnnotation(image,"rectangle",bboxes_new,label_str_new,"LineWidth",10,"FontSize",60);
end

if ~isempty(bboxes) && ~isempty(bboxes_new)
    image = insertObjectAnnotation(image,"rectangle",bboxes,label_str,"Color","white","LineWidth",10,"FontSize",60);
    image = insertObjectAnnotation(image,"rectangle",bboxes_new,label_str_new,"LineWidth",10,"FontSize",60);
end

f = figure();
imshow(image)
saveas(f,sprintf('Result_%s.jpg',Date))


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

model_name_2 = "YOLOV4";
model_name = "YOLOV2";


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
writetable(t,sprintf('%s.xlsx',Date),"WriteMode","replacefile","AutoFitWidth",false)


disp("Congratulation! You have successfully run the MCS detector V1.0. Please look for the resulted image and the excel file in the working directory.")

