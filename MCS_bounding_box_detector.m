
%% Initializations with the labeling data

%data = load("vehicleDatasetGroundTruth.mat");
%vehicleDataset = data.vehicleDataset;
derecho_dataset(1:4,:)

% Display first few rows of the data set.
%vehicleDataset(1:4,:)


% Add the fullpath to the local vehicle data folder.
%derecho_dataset.imageFilename = fullfile(pwd,derecho_dataset.imageFilename);

%% Setting up the Parameters

rng("default");
shuffledIndices = randperm(height(derecho_dataset));
idx = floor(0.6 * length(shuffledIndices) );

trainingIdx = 1:idx;
trainingDataTbl = derecho_dataset(shuffledIndices(trainingIdx),:);

validationIdx = idx+1 : idx + 1 + floor(0.1 * length(shuffledIndices) );
validationDataTbl = derecho_dataset(shuffledIndices(validationIdx),:);

testIdx = validationIdx(end)+1 : length(shuffledIndices);
testDataTbl = derecho_dataset(shuffledIndices(testIdx),:);

%% Datastores

imdsTrain = imageDatastore(trainingDataTbl{:,"imageFilename"});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,"Derecho"));

imdsValidation = imageDatastore(validationDataTbl{:,"imageFilename"});
bldsValidation = boxLabelDatastore(validationDataTbl(:,"Derecho"));

imdsTest = imageDatastore(testDataTbl{:,"imageFilename"});
bldsTest = boxLabelDatastore(testDataTbl(:,"Derecho"));

%% 

trainingData = combine(imdsTrain,bldsTrain);
validationData = combine(imdsValidation,bldsValidation);
testData = combine(imdsTest,bldsTest);




%% 

data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I,"Rectangle",bbox);
annotatedImage = imresize(annotatedImage,2);
figure
imshow(annotatedImage)
%reset(trainingData);

%% Creating anchor box and training it
inputSize = [224 224 3];
className = "Derecho";

rng("default")
trainingDataForEstimation = transform(trainingData,@(data)preprocessData(data,inputSize));
numAnchors = 6;
[anchors,meanIoU] = estimateAnchorBoxes(trainingDataForEstimation,numAnchors);

area = anchors(:, 1).*anchors(:,2);
[~,idx] = sort(area,"descend");

anchors = anchors(idx,:);
anchorBoxes = {anchors(1:3,:)
    anchors(4:6,:)    };
%% Loading pretrained YOLO v4 trainer

%detector = yolov4ObjectDetector("csp-darknet53-coco",className,anchorBoxes,InputSize=inputSize);
% pretrained = load("yolov4CSPDarknet53VehicleExample_22a.mat");
% detector = pretrained.detector;

%% 

% inputSize = [224 224 3];
% className = "Derecho";
% preprocessedTrainingData = transform(trainingData, @(data)preprocessData(data,inputSize));
% numAnchors = 3;
% anchorBoxes = estimateAnchorBoxes(preprocessedTrainingData,numAnchors);
% featureExtractionNetwork = resnet50;
% featureLayer = 'activation_40_relu';
% numClasses = width(derecho_dataset)-1;
%lgraph = yolov2Layers(inputSize,numClasses,anchorBoxes,featureExtractionNetwork,featureLayer);
lgraph = yolov4ObjectDetector("tiny-yolov4-coco",className,anchorBoxes,InputSize=inputSize);


%% 

augmentedTrainingData = transform(trainingData,@augmentData);

augmentedData = cell(4,1);
for k = 1:4
    data = read(augmentedTrainingData);
    augmentedData{k} = insertShape(data{1},"rectangle",data{2});
    reset(augmentedTrainingData);
end
figure
montage(augmentedData,BorderSize=10)

%% Model paramters

trainingData = transform(augmentedTrainingData,@(data)preprocessData(data,inputSize));
validationData = transform(validationData,@(data)preprocessData(data,inputSize));

data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I,'Rectangle',bbox);
annotatedImage = imresize(annotatedImage,2);
figure
imshow(annotatedImage)
%% 
% options = trainingOptions('sgdm',...
%     'MaxEpochs',5,...
%     'MiniBatchSize',16,...
%     'InitialLearnRate',1e-4,...
%     'CheckpointPath',tempdir,...
%     'ValidationData',validationData,...
%     'ValidationFrequency',50, ...
%      'BatchNormalizationStatistics','moving');
    %'Plots','training-progress');

options = trainingOptions('rmsprop',...
    'MaxEpochs',30,...
    'MiniBatchSize',8,...
    'InitialLearnRate',1e-3,...
    'CheckpointPath',tempdir,...
    'ValidationData',validationData,...
     'BatchNormalizationStatistics','moving',...
         LearnRateSchedule="none",...
         Shuffle="every-epoch",...
             VerboseFrequency=20,...
     ResetInputNormalization=false);
     %'ExecutionEnvironment','cpu');
     

%% % Train the Faster R-CNN detector.
    % * Adjust NegativeOverlapRange and PositiveOverlapRange to ensure
    %   that training samples tightly overlap with ground truth.

 %[detector, info] = trainYOLOv2ObjectDetector(trainingData,lgraph,options);
  [detector,info] = trainYOLOv4ObjectDetector(trainingData,lgraph,options);




%%
I = imread("C:\Users\smahmud\Desktop\MCS Dataset\images\Resized_dataset\NonDerecho\  resized_max_n0r_0z0z_20190515.jpg");
[bboxes,scores,labels] = detect(detector,I);

%% Object Notation with the results

I = insertObjectAnnotation(I,"rectangle",bboxes,scores);
figure
imshow(I)
%% 
testData = transform(testData,@(data)preprocessData(data,inputSize));
detectionResults = detect(detector,testData);   
[ap, recall, precision] = evaluateDetectionPrecision(detectionResults,testData);
figure
plot(recall,precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f', ap))

%% Functions required for the whole code


function data = augmentData(A)
data = cell(size(A));
for ii = 1:size(A,1)
    I = A{ii,1};
    bboxes = A{ii,2};
    labels = A{ii,3};
    sz = size(I);

    if numel(sz) == 3 && sz(3) == 3
        I = jitterColorHSV(I,...
            contrast=0.0,...
            Hue=0.1,...
            Saturation=0.2,...
            Brightness=0.2);
    end
    
    % Randomly flip image.
    tform = randomAffine2d(XReflection=true,Scale=[1 1.1]);
    rout = affineOutputView(sz,tform,BoundsStyle="centerOutput");
    I = imwarp(I,tform,OutputView=rout);
    
    % Apply same transform to boxes.
    [bboxes,indices] = bboxwarp(bboxes,tform,rout,OverlapThreshold=0.25);
    labels = labels(indices);
    
    % Return original data only when all boxes are removed by warping.
    if isempty(indices)
        data(ii,:) = A(ii,:);
    else
        data(ii,:) = {I,bboxes,labels};
    end
end
end

function data = preprocessData(data,targetSize)
% Resize the images and scale the pixels to between 0 and 1. Also scale the
% corresponding bounding boxes.

for ii = 1:size(data,1)
    I = data{ii,1};
    imgSize = size(I);
    
    bboxes = data{ii,2};

    I = im2single(imresize(I,targetSize(1:2)));
    scale = targetSize(1:2)./imgSize(1:2);
    bboxes = bboxresize(bboxes,scale);
    
    data(ii,1:2) = {I,bboxes};
end
end

% function detector = downloadPretrainedYOLOv4Detector()
% % Download a pretrained yolov4 detector.
% if ~exist("yolov4CSPDarknet53VehicleExample_22a.mat", "file")
%     if ~exist("yolov4CSPDarknet53VehicleExample_22a.zip", "file")
%         disp("Downloading pretrained detector...");
%         pretrainedURL = "https://ssd.mathworks.com/supportfiles/vision/data/yolov4CSPDarknet53VehicleExample_22a.zip";
%         websave("yolov4CSPDarknet53VehicleExample_22a.zip", pretrainedURL);
%     end
%     unzip("yolov4CSPDarknet53VehicleExample_22a.zip");
% end
% pretrained = load("yolov4CSPDarknet53VehicleExample_22a.mat");
% detector = pretrained.detector;
% end
