clc
close all
clear 
addpath(genpath('.'))
path = './DRIONS-DB_/';
path1= dir(path);
path1(1:2)=[];Feal=[];
for N1=1:length(path1)
    Folder = [path,path1(N1).name '/'];
    Folder1 = dir(Folder);
    Folder1(1:2)=[];
    for N2=1:length(Folder1)
        Img_path=[Folder,Folder1(N2).name];
        Img=imresize(imread(Img_path),[224 224]);
        %% Feature Extraction for  data
        %% Hog
        Hog=mean(extractHOGFeatures(Img));
        %% Local Binary pattern
        grayImage = rgb2gray(Img);
        % Define the parameters for LBP
        radius = 1;
        numPoints = 8;
        % Compute LBP features
        lbpFeatures = extractLBPFeatures(grayImage, 'Radius', radius, 'NumNeighbors', numPoints);
        Fea(N2,:) =[Hog,lbpFeatures];
    end
     Feal=[Feal ;Fea];
end
save Fea_DRIONS Feal

load Features
load Fea_DRIONS
Feature=[fea,Feal];
save Fuse_Fea Feature