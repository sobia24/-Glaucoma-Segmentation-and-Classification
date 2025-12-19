clc
clear 
close all
warning off
addpath(genpath('.'));
path=('./CHASEDB1/');
Data=dir(path);
Data(1:2)=[];
out=[path(3:end-1),'segmented_out'];
mkdir(out)
for N1=1:length(Data)
    Get=[path,Data(N1).name];
        I=imread (Get);
        hm=0.2;
        d0=200;
        rH=1.8631;
        rL= 0.01;
        II=proposed_enhc(im2double(I(:,:,2)),rH,rL,hm,d0);%% Preprocessing
        m=II;
        min1=min(min(m));
        max1=max(max(m));
        II=im2uint8(((m-min1).*1)./(max1-min1));
%         II=imresize (II,[224 224]);
%         figure(1),imshow(II,[]),title('Preprocessed Image')
        %% Disk localization
        III=zeros(size(II));
        a=1;c=1;
        for i=1:size(I,1)/32
            b=1;
            for j=1:size(I,2)/32
                I1=II(a:a+31,b:b+31);%% Entrophy
                I2(b:b+2)=entropy(I1);
                b=b+32;
                c=c+1;
            end
            [va,id]=max(I2);
            III(a:a+30,id:id+30)=va;
            a=a+32;
        end
        [bw1,lab]=bwlabel(logical(III));
        va1=regionprops(logical(III));
        for i=1:lab
            I23= (imcrop(I,va1(i).BoundingBox));
            %    glcm = graycomatrix(I23);
            %    stats = graycoprops(glcm);
            I24(i,:)=mean2(I23);
        end
        [I25,id]=max(I24);
%         figure(2),imshow(uint8(logical(III)).*II), title('Entrophy image')
        B_Box=va1(id).BoundingBox;
        final_out=imcrop(I,[B_Box(1)-48*2 B_Box(2)-48*2 B_Box(3)+96*2 B_Box(4)+96*2]);
        Cropped_img_=final_out;
        final_out(:,:,1)=imadjust(final_out(:,:,1));
%         figure
%         imshow(final_out);
        %% segmentation 
          [cImg,~,~,~,dlImg]=processImage(final_out);
          [cImg_,~,~,~,dlImg_]=processImage_1(final_out);
        %% Proposed
          % Hough transform
          [circCent,circRad]=houghTransform(dlImg,30,65,20,20,0.8);
          [x,y]=findOptimalCircle(circCent,circRad,dlImg);
          [rows, cols, ~] = size(cImg);
          mask = poly2mask(x, y, rows, cols);
          segmentedimage = bsxfun(@times, cImg, cast(mask, 'like', cImg));
%           maskedGrayImage = bsxfun(@times, final_out, cast(mask, 'like', final_out));
%           figure
%           imshow(segmentedimage);
          sal_OD=imbinarize(imfill(uint8(segmentedimage)));
        Final_OD=imclearborder(sal_OD);
        Final_OD1=bwlabel(Final_OD);
        s = regionprops(Final_OD1,'all');
        [A,A1]=max([(s.Area)]);
        if isempty(A)|| N1==10
            Final_OD1=bwlabel(sal_OD);
            s = regionprops(Final_OD1,'all');
            [A,A1]=max([(s.Area)]);
        end
        Bounding_box_value_od=s(A1).BoundingBox;
        se = strel('disk',1);
        OD_groundTruth = imdilate(Final_OD1==A1,se);
        Final_OD1=(Final_OD1==A1);
%           figure;
%           subplot(1, 2, 1);
%           imshow(cImg);
%           title('Original Image');
%           hold on;
%           plot(x,y,'g','LineWidth',1);
%           hold off;
%           subplot(1, 2, 2);
%           imshow(segmentedimage);
%           title('segmented region');
%          subImgHough(r,c,I,cImg,x,y);
%% ESISTING 
          % Hough transform
          [circCent,circRad]=houghTransform(dlImg_,30,65,20,20,0.8);
          [x,y]=findOptimalCircle(circCent,circRad,dlImg_);
          [rows, cols, ~] = size(cImg_);
          mask = poly2mask(x, y, rows, cols);
          EX_segmentedimage = bsxfun(@times, cImg_, cast(mask, 'like', cImg_));
        Final_OD_=imbinarize(imfill(uint8(EX_segmentedimage)));
        Final_OD_1=imclearborder(Final_OD_);
        Final_OD1_=bwlabel(Final_OD_1);
        s = regionprops(Final_OD1_,'all');
        [B,B1]=max([(s.Area)]);
        if isempty(B)
            Final_OD1_=bwlabel(Final_OD_);
            s = regionprops(Final_OD1_,'all');
            [B,B1]=max([(s.Area)]);
        end
        se = strel('disk',2);
        OD_groundTruth_E = imerode(Final_OD1_==B1,se);
        Final_OD1_ =(Final_OD1_==B1);
        Final_OD=imcrop(Cropped_img_.*uint8(Final_OD1),Bounding_box_value_od);
        figure,subplot(2,1,1),imshow(Cropped_img_,[])
        title('Cropped Image')
        subplot(2,1,2),imshow(OD_groundTruth,[])
        title('GroundTruth');
        figure,subplot(2,1,1),imshow(I,[]);
        title('Original Image')
        Final_OD=imresize(Final_OD,[224 224]);
        subplot(2, 1, 2),imshow(Final_OD)
        title('Segmented disc Image')
        %% jacard distance calculation
        [Accuracy_P, FN_P, FP_P,TP_P, TN_P,Sensitivity_P,...
            Dice_P, Jaccard_P] = EvaluateImageSegmentationScores(OD_groundTruth,(Final_OD1));
%                 figure
%                 imshowpair((Final_OD1), OD_groundTruth)
        %         title(['Jaccard Index = ' num2str(Jaccard_P)])
        %         figure
        %         imshowpair((Final_OD1), ((OD_groundTruth)))
        %         title(['Dice Index = ' num2str(Dice_P)])
        %% jacard distance calculation Existing
        [Accuracy_E, FN_E, FP_E,TP_E, TN_E,Sensitivity_E,...
            Dice_E, Jaccard_E ] = EvaluateImageSegmentationScores(OD_groundTruth_E,(Final_OD1_));
        %         figure
        %         imshowpair((Final_OD1_), OD_groundTruth_E)
        %         title(['Jaccard Index Existing = ' num2str(Jaccard_E)])
        %         figure
        %         imshowpair((Final_OD1_), ((OD_groundTruth_E)))
        %         title(['Dice Index Existing = ' num2str(Dice_E)])
        
        Result_J=[Jaccard_P,Jaccard_E];
        Result_D=[Dice_P,Dice_E];
        Result_ACC=[Accuracy_P,Accuracy_E];
        Result_SEN=[Sensitivity_P,Sensitivity_E];
        Result_FN=[FN_P,FN_E];
        Result_FP=[FP_P,FP_E];
        Result_TN=[TN_P,TN_E];
        Result_TP=[TP_P,TP_E];
        % blockexecution up until an image is closed
        Result_J(isnan(Jaccard_P))=0;
        Result_D(isnan(Dice_P))=0;
        %         Result_JE(isnan(similarity_J_E))=0;
        %         Result_DE(isnan(similarity_D_E))=0;
        %% Perfomance measure
        Results=[Result_J' Result_D' Result_ACC' Result_SEN' Result_FN' Result_FP' Result_TN' Result_TP' ];
        Perfomance={'Jacard'  'Dice' 'Accuracy' 'Sensitivity' 'FN' 'FP' 'TN' 'TP'};
        Images={'Proposed','Existing'};
        array2table(Results,'VariableNames',Perfomance, 'RowNames' ,Images )
%         uiwait;
        close all
        disp('you have to cancel the last tab of figure to go next image ')
        %     figure,imshow(imcrop(I,[B_Box(1)-48*2 B_Box(2)-48*2 B_Box(3)+96*2 B_Box(4)+96*2]))
        % figure,imshow(imcrop(I,B_Box))
    end 
    