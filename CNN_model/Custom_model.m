%% Loading the variable

imds = imageDatastore('GAN\', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');


[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');

%% Model structure

layers = [
    imageInputLayer([224 224 3])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
        maxPooling2dLayer(2,'Stride',2)

convolution2dLayer(3,64,'Padding','same')
    batchNormalizationLayer
    reluLayer
           
    maxPooling2dLayer(2,'Stride',2)

convolution2dLayer(3,128,'Padding','same')
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];
%% input and data augmentations 

inputSize = layers(1).InputSize;


pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter,'ColorPreprocessing','gray2rgb');

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing','gray2rgb');
%% The real model

options = trainingOptions('sgdm', ...
    'MiniBatchSize',32,...
    'InitialLearnRate',0.0001, ...
    'MaxEpochs',50, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',32, ...
    'Verbose',true, ...
    'Plots','training-progress', ...
    'OutputNetwork','best-validation-loss');


net = trainNetwork(augimdsTrain,layers,options);

[YPred,scores] = classify(net,augimdsValidation);

%% 
YPred = classify(net,augimdsValidation);
YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);

figure()
plotconfusion(imdsValidation.Labels,YPred) 


%%
augimdsDerecho  = augmentedImageDatastore(inputSize(1:2),imdsDerecho,'ColorPreprocessing','gray2rgb');
[YPred,scores] = classify(netTransfer,augimdsDerecho);

plotconfusion(imdsDerecho.Labels,YPred)
% im = imread("20220929.jpg");
% im = imresize(im,[266 600]);
% [YPred,scores] = classify(net,im)