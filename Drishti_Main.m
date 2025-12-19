clc
close all
clear all
load ID
path=('./Drishti-GS1_files/');
Data=dir(path);
Data(1:2)=[];
addpath(genpath('.'))
for N1=2:2
    % I1=imresize(imread('drishtiGS_032.png'),[256 256]);
    Read_fol=[path,Data(N1).name '/'];
    Read_fol1=dir(Read_fol);
    Read_fol1(1:2)=[];
    for N2=2:length(Read_fol1)
        Get=[Read_fol,Read_fol1(N2).name '/'];
        Read_1=[Read_fol,Read_fol1(1).name '/'];
        Read_2=dir(Read_1);
        Read_2(1:2)=[];
        Get1=dir(Get);
        Get1(1:2)=[];
        for N3=1:length(Get1)
            Fol=[Read_1,Read_2(N3).name '/'];
            Fol1=dir(Fol);
            Fol1(1:2)=[];
            Read_=[Get,Get1(N3).name];
            gd_fol=[Fol,Fol1(N2).name '/'];
            Read=dir(gd_fol);
            Read(1:2)=[];
            GT1=imread([gd_fol,Read(1).name]);
            I=imresize(imread(Read_),[512 512]);%% Image read
            GT1=imresize(GT1,[512 512]);
            hm=0.2;
            d0=200;
            rH=1.8631;
            rL= 0.01;
            II=proposed_enhc( im2double(I(:,:,2)),rH,rL,hm,d0);%% Preprocessing
            m=II;
            min1=min(min(m));
            max1=max(max(m));
            II=im2uint8(((m-min1).*1)./(max1-min1));
            %% Disk localization
            III=zeros(size(II));
            a=1;c=1;
            for i=1:size(I,1)/32
                b=1;
                for j=1:size(I,2)/32
                    I1=II(a:a+31,b:b+31);
                    I2(b:b+2)=entropy(I1);%% Entrophy calculation
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
            %                 figure,imshow(uint8(logical(III)).*II)
            B_Box=va1(id).BoundingBox;
            final_out=imcrop(I,[B_Box(1)-48*2 B_Box(2)-48*2 B_Box(3)+96*2 B_Box(4)+96*2]);
            OD_groundTruth= imcrop(GT1,[B_Box(1)-48*2 B_Box(2)-48*2 B_Box(3)+96*2 B_Box(4)+96*2]);
            Cropped_img_=final_out;
            final_out(:,:,1)=imadjust(final_out(:,:,1));
            %% Segmentation
            Img_OD=saliency_levelset(final_out);
            Img_OD1=saliency_levelset1(final_out);
            %% Proposed
            Final_OD=imbinarize(imfill(uint8(Img_OD)));
            if N3==19
                Final_OD1=bwlabel(Final_OD);
                s = regionprops(Final_OD1,'all');
                [A,A1]=max([(s.Area)]);
            else
                Final_ODb=imclearborder(Final_OD);
                Final_OD1=bwlabel(Final_ODb);
                s = regionprops(Final_OD1,'all');
                [A,A1]=max([(s.Area)]);
            end
            Bounding_box_value=s(A1).BoundingBox;
            Final_OD1=Final_OD1==A1;
            Final_OD=imcrop(Cropped_img_.*uint8(Img_OD),Bounding_box_value);
            %             if isequal( InD{N3,1},'Glaucoma') && isequal( InD{N3,2},Get1(N3).name(1:end-4))
            %                 mkdir(['Drishti_db/Glucoma/'])
            %                 imwrite(Final_OD,['Drishti_db/Glucoma/' Get1(N3).name])
            %             else
            %                 mkdir(['Drishti_db/Normal/'])
            %                 imwrite(Final_OD,['Drishti_db/Normal/' Get1(N3).name])
            %             end
            %% Existing
            Final_OD_=imbinarize(imfill(uint8(Img_OD1)));
            Final_OD_=imclearborder(Final_OD_);
            Final_OD1_=bwlabel(Final_OD_);
            s = regionprops(Final_OD1_,'all');
            [A,B1]=max([(s.Area)]);
            Bounding_box_value=s(B1).BoundingBox;
            Final_OD1_=Final_OD1_==B1;
            Final_OD_=imcrop(Cropped_img_.*uint8(Img_OD1),Bounding_box_value);
            %% Show results
            figure,imshow(final_out,[])
            title('Cropped Image')
            figure,imshow(OD_groundTruth)
            title('Ground Truth')
            figure,subplot(2, 1, 1),imshow(I,[]);
            title('Original Image')
            subplot(2, 1, 2),imshow(Final_OD)
            title('Segmented disc Image')
            %% jacard distance calculation
            [Accuracy_P, FN_P, FP_P,TP_P, TN_P,Sensitivity_P,...
                Dice_P, Jaccard_P] = EvaluateImageSegmentationScores(OD_groundTruth,((Final_OD1)));
%             figure
%             imshowpair((Final_OD1), OD_groundTruth)
%             title(['Jaccard Index = ' num2str(Jaccard_P)])
%             figure
%             imshowpair(logical(Final_OD1), (logical(OD_groundTruth)))
%             title(['Dice Index = ' num2str(Dice_P)])
            
            [Accuracy_E, FN_E, FP_E,TP_E, TN_E,Sensitivity_E,...
                Dice_E, Jaccard_E] = EvaluateImageSegmentationScores(OD_groundTruth,(Final_OD1_));
%             figure
%             imshowpair((Final_OD1_), OD_groundTruth)
%             title(['Jaccard Index = ' num2str(Jaccard_E)])
%             similarity = dice(logical(Final_OD1_), (logical(OD_groundTruth)));
%             figure
%             imshowpair(logical(Final_OD1_), (logical(OD_groundTruth)))
%             title(['Dice Index = ' num2str(Dice_E)])
            
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
            Results=[Result_J' Result_D' Result_ACC' Result_SEN' Result_FN' Result_FP' Result_TN' Result_TP' ];
            Perfomance={'Jacard'  'Dice' 'Accuracy' 'Sensitivity' 'FN' 'FP' 'TN' 'TP'};
            Images={'Proposed','Existing'};
            array2table(Results,'VariableNames',Perfomance, 'RowNames' ,Images )
            % block execution up until an image is closed
            uiwait;
            close all
            disp('you have to cancel the last tab of figure to go next image ')
            %     figure,imshow(imcrop(I,[B_Box(1)-48*2 B_Box(2)-48*2 B_Box(3)+96*2 B_Box(4)+96*2]))
            % figure,imshow(imcrop(I,B_Box))
        end
    end
end