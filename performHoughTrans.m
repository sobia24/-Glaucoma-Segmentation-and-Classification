clc
clear 
close all
warning off
addpath(genpath('.'));
% path=('./all-miasimage/');
% Data=dir(path);
% Data(1:2)=[];
% out=[path(3:end-1),'_out'];
% mkdir(out)
% M1=1;
% for N1=1:length(Data)
%     Read_fol=[path,Data(N1).name '/'];
%     Read_fol1=dir(Read_fol);
%     Read_fol1(1:2)=[];
%     aa=[out '/',Data(N1).name];
%     mkdir(aa)
%     for N2=1:52
%           Get=[Read_fol,Read_fol1(N2).name];
images={
    'images/01_h.jpg'
    'images/02_h.jpg'
    'images/07_h.jpg'
    'images/10_h.jpg'
    'images/12_h.jpg'
    'images/13_h.jpg'
    'images/14_h.jpg'
    'images/15_h.jpg'
};

c=4;
r=length(images)/c;

figure;
for i=1:length(images)
    name=images{i};
    % przetworzenie obrazu
    [cImg,~,~,~,dlImg]=processImage(name);
    % transformata Hougha
    [circCent,circRad]=houghTransform(dlImg,30,65,20,20,0.8);
    % finding the optimal circle
    [x,y]=findOptimalCircle(circCent,circRad,dlImg);
    subImgHough(r,c,i,cImg,x,y);
end