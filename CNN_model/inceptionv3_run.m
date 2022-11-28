%% Loading the variable

imds = imageDatastore('GAN\', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');


[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');



%% Load Pretrained Network

net = inceptionv3;
%deepNetworkDesigner(net);


inputSize = net.Layers(1).InputSize;



%% Importing the libraries and declaring variables


lgraph = layerGraph(net); 
numClasses = numel(categories(imdsTrain.Labels));

newLearnableLayer = fullyConnectedLayer(numClasses, ...
    'Name','new_fc', ...
    'WeightLearnRateFactor',10, ...
    'BiasLearnRateFactor',10);
    
lgraph = replaceLayer(lgraph,'predictions',newLearnableLayer);

%lgraph = replaceLayer(lgraph,'data',newinputlayer);

newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'ClassificationLayer_predictions',newClassLayer);

%% Freeze initial layer

% layers = lgraph.Layers;
% connections = lgraph.Connections;
% 
% layers(1:10) = freezeWeights(layers(1:10));
% lgraph = createLgraphUsingConnections(layers,connections);
%% Train Network


pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter,'ColorPreprocessing','gray2rgb');

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing','gray2rgb');

options = trainingOptions('adam', ...
    'MiniBatchSize',32, ...
    'MaxEpochs',10, ...
    'InitialLearnRate',1e-3, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ExecutionEnvironment','gpu',...
    'ValidationFrequency',32, ...
    'Verbose',true, ...
    'Plots','training-progress', ...
    'OutputNetwork','best-validation-loss');

netTransfer = trainNetwork(augimdsTrain,lgraph,options);

[YPred,scores] = classify(netTransfer,augimdsValidation);

%% Validation the results

% idx = randperm(numel(imdsDerecho.Files),4);
% figure
% for i = 1:4
%     subplot(2,2,i)
%     I = readimage(imdsDerecho,idx(i));
%     imshow(I)
%     label = YPred(idx(i));
%     scoress = max(scores(idx(i)));
%     title(string(label));
% end
% 

YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);

figure()
plotconfusion(imdsValidation.Labels,YPred) 

%% 
% im = imread("20221031.jpg");
% im = imresize(im,[299 299]);
% [YPred,scores] = classify(netTransfer,im)