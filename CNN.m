%% Loading the variable

imds = imageDatastore('jpg\', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

%augmentedImageDatastore(inputSize(1:2),imds,'ColorPreprocessing','gray2rgb');

[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');

%% Load Pretrained Network

net = googlenet;

%deepNetworkDesigner(net);


inputSize = net.Layers(1).InputSize;




%% Importing the libraries and declaring variables


lgraph = layerGraph(net); 
numClasses = numel(categories(imdsTrain.Labels));

newLearnableLayer = fullyConnectedLayer(numClasses, ...
    'Name','new_fc', ...
    'WeightLearnRateFactor',10, ...
    'BiasLearnRateFactor',10);
    
lgraph = replaceLayer(lgraph,'loss3-classifier',newLearnableLayer);

%lgraph = replaceLayer(lgraph,'data',newinputlayer);

newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter,'ColorPreprocessing','gray2rgb');

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing','gray2rgb');

options = trainingOptions('sgdm', ...
    'MiniBatchSize',8, ...
    'MaxEpochs',3, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',16, ...
    'Verbose',false, ...
    'Plots','training-progress');

netTransfer = trainNetwork(augimdsTrain,lgraph,options);

[YPred,scores] = classify(netTransfer,augimdsValidation);

%% Validation the results

idx = randperm(numel(imdsValidation.Files),4);
figure
for i = 1:4
    subplot(2,2,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
    name= string(imdsValidation.Files(idx(i)));
    name= strsplit(name,'\');
    name = strsplit(name(end),'_');
    name = string(name{end});
    name = strsplit(name,'.');
    name = name(1);
   % name = extractBetween(name,"_",".jpg");
    title([name,label])
end


YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);

figure()
plotconfusion(imdsValidation.Labels,YPred)

