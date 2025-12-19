clc
clear all
close all
addpath(genpath('.')) %Add pathlc
%% Feature extraction using resnet architecture
digitDatasetPath = 'Drishti_classy_db/';
%Read the data from folder and subfolders
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true);
Train_tar=repmat([1:2],[30,1]);
Train_tar=categorical(Train_tar(:));
imds.Labels=Train_tar;
numTrainFiles = 0.8;
%Split the data for training and testing
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');
Train_Fea=[];
%     options.gridHist = 1;

%% Neural Network

load resnet18
a= fullyConnectedLayer(2,'Name','fc1000');
%     b = classificationLayer('Name','ClassificationLayer_predictions')
res_net= replaceLayer(layerGraph(net),'fc1000',a);
a = imageInputLayer([224 224 3],'Name','data');
res_net1= replaceLayer((res_net),'data',a);
a = convolution2dLayer(7,64,'Name','conv1','Stride',2, 'Padding' ,[3 3 3 3]);
res_net2= replaceLayer((res_net1),'conv1',a);
b = classificationLayer('Name','ClassificationLayer_predictions');
res_net= replaceLayer((res_net2),'ClassificationLayer_predictions',b);
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',50, ...
    'Shuffle','every-epoch', ...
    'ValidationFrequency',10, ...
    'Verbose',false, ...
    'Plots','training-progress');
net = trainNetwork(imds,res_net,options);
layer = 'pool5';

%% CNN Feature
fea = normalize(activations(net,imds,layer,'OutputAs','rows'));
featuresTrain_CNN = activations(net,imdsTrain,layer,'OutputAs','rows');%train the data with CNN
featuresTest_CNN = activations(net,imdsValidation,layer,'OutputAs','rows');%train the test data with CNN
% save Features fea 