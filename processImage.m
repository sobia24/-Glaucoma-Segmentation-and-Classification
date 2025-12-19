function [cImg,gImg,gfImg,sgImg,dlImg]=processImage(cImg)
%     cImg=imread(imgName);
if ndims(cImg) == 3
    gImg=cImg(:,:,2); % green component
    cImg=gImg;
else 
    gImg=cImg;
end
    
%     imshow(gImg)
    % averaging filter
    mS=5; % size
    fm=ones(mS)/(mS^2); % mask
    gfImg = imfilter(gImg,fm);

    % thresholding
    prNr=15; % number of thresholds
    levels=multithresh(gImg,prNr);
    sgImg=imquantize(gfImg,levels);
    %applying a mask and binarization
    mask=sgImg<(prNr-5);
    sgImg=imbinarize(sgImg.*~mask);
    
    % edge detection
    sgImg=imdilate(sgImg,strel('disk',30)); % edge dilation
    edImg= improvedCannyEdgeDetection(sgImg);
%     imshow(edImg)
    dlImg=imdilate(edImg,strel('disk',5)); % edge dilation
%     imshow(dlImg)
end