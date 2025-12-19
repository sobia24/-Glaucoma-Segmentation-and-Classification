clc
close all
clear 
addpath(genpath('.'))
load Features1
for N1=1:2 % you can set upto 50 iteration
    Tot_size = size(fea,1)/2;
    %% Training Percentages
    Train_len=round(Tot_size*0.8);
    Test_len=Tot_size-Train_len;
    jj=1;
    tb=fea;
    %% Setting target values
    Train_tar1 = repmat((1:2),[Tot_size,1]);
    Train_tar1 = Train_tar1(:);
    for N=1:5
    %% Seperation of Training and testing
    %% K-fold validation for splitting Training and Testing set
    indices = crossvalind('Kfold',Train_tar1,5);
    cp = classperf(Train_tar1);
    test  = (indices == N1);
    train = ~test;
    Test1  = tb(test,:);
    Train1 = tb(train,:);
    Train_tar = Train_tar1(train,:);
    Test_tar  = Train_tar1(test,:);
    Train1(isinf(Train1)) =0;
    Test1(isinf(Test1))   =0;
    Train1(isnan(Train1)) =0;
    Test1(isnan(Test1))   =0;
    
    %% Feature selection
    % Number of k in K-nearest neighbor
    opts.k = 5;
    % Ratio of validation data
    ho = 0.2;
    % Common parameter settings
    opts.N  = 10;     % number of solutions
    opts.T  = 100;    % maximum number of iterations
    % Parameters of PSO
    opts.c1 = 2;
    opts.c2 = 2;
    opts.w  = 0.9;
    % Divide data into training and validation sets
    HO = cvpartition(Train_tar,'HoldOut',ho);
    opts.Model = HO;
    % Marine Predators Algorithm
    [SF] = jEquilibriumOptimizer(Train1,Train_tar,opts);
    featuresTrain_CNN1=Train1;
    featuresTest_CNN1=Test1;
    
    %% KNN
    Knn_b = fitcknn(featuresTrain_CNN1,Train_tar,'distance' ,'chebychev','NumNeighbors',100);
    label= predict(Knn_b,featuresTest_CNN1);
    [Knn_Parameter(N)]=Finding_parameter1(Test_tar,label);
    
    %% RF  Tree
    Mdl = TreeBagger(1,featuresTrain_CNN1,Train_tar,'OOBPrediction','on');
    label= predict(Mdl,featuresTest_CNN1);
    label=double(string(label));
    [RF_Parameter_5(N)]=Finding_parameter1(Test_tar,double(string(label)));
    
    %% Decision tree
    DE_Tree = fitctree(featuresTrain_CNN1,Train_tar,  'MinLeafSize', 40);
    label= predict(DE_Tree,featuresTest_CNN1);
    [DE_Parameter(N)]=Finding_parameter1(Test_tar,label);
     %% MSVM
    Regularization=grid_search(featuresTrain_CNN1, Train_tar,Test_tar,featuresTest_CNN1);
    SVMStruct = fitcecoc(featuresTrain_CNN1, Train_tar,'Learners',templateSVM('KernelFunction','linear','BoxConstraint', Regularization ));
    label= predict(SVMStruct,featuresTest_CNN1);
    [MSVM_Parameter(N)]=Finding_parameter1(Test_tar,label);
    
    %% NB
    NBStruct = fitcnb(featuresTrain_CNN1, Train_tar,'DistributionNames','mvmn');
    label= predict(NBStruct,featuresTest_CNN1);
    [NB_Parameter_MF(N)]=Finding_parameter1(Test_tar,label);
    end
    %% Perfomance measure Parameters
    Result_Acc(N1,:)=[min([RF_Parameter_5.Accuracy]) max([Knn_Parameter.Accuracy])....
        min([DE_Parameter.Accuracy]) max([MSVM_Parameter.Accuracy]) max([NB_Parameter_MF.Accuracy])];
    Result_Sen(N1,:)=[min([RF_Parameter_5.sensitivity]) max([Knn_Parameter.sensitivity])...
        min([DE_Parameter.sensitivity]) max([MSVM_Parameter.sensitivity]) max([NB_Parameter_MF.sensitivity])];
    Result_Spec(N1,:)=[min([RF_Parameter_5.specificity]) max([Knn_Parameter.specificity])...
        min([DE_Parameter.specificity]) max([MSVM_Parameter.specificity]) max([NB_Parameter_MF.specificity])];
    Result_FOR(N1,:)=[min([RF_Parameter_5.FOR]) max([Knn_Parameter.FOR])...
        min([DE_Parameter.FOR]) max([MSVM_Parameter.FOR]) max([NB_Parameter_MF.FOR])];
    Result_FDR(N1,:)=[min([RF_Parameter_5.FDR]) max([Knn_Parameter.FDR])...
        min([DE_Parameter.FDR]) max([MSVM_Parameter.FDR]) max([NB_Parameter_MF.FDR])];
    
    
end
%% Remove damage data
Result_Acc(isnan(Result_Acc))=0;
Result_Sen(isnan(Result_Sen))=0;
Result_Spec(isnan(Result_Spec))=0;
Result_FOR(isnan(Result_FOR))=0;
Result_FDR(isnan(Result_FDR))=0;
%% Perfomance measure
Results=[mean(Result_Acc);mean(Result_Sen);mean(Result_Spec);mean(Result_FOR);mean(Result_FDR); 1-mean(Result_Acc)];
Classifier={ 'RF' 'KNN' 'DE' 'MSVM' 'NB'};
Parameters={'Accuracy' 'sensitivity' 'specificity' 'FOR' 'FDR' 'Error_rate'};
Results_table=array2table(Results*100,'VariableNames',Classifier,'RowNames',Parameters)
% disp(Results_table)