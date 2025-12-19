function [cImg,gImg,gfImg,sgImg,dlImg]=processImage_(cImg)
%     cImg=imread(imgName);
if ndims(cImg) == 3
    gImg=cImg(:,:,2); % green component
    cImg=gImg;
else 
    gImg=cImg;
end
    
    % averaging filter
    mS=5; % size
    fm=ones(mS)/(mS^2); % mask
    gfImg = imfilter(gImg,fm);

    % thresholding
    prNr=10; % number of thresholds
    levels=multithresh(gImg,prNr);
    sgImg=imquantize(gfImg,levels);
    %applying a mask and binarization
    mask=sgImg<(prNr-5);
    sgImg=imbinarize(sgImg.*~mask);
    
    % edge detection
    sgImg=imdilate(sgImg,strel('disk',30)); % edge dilation
    edImg=edge(sgImg,'Canny'); % edge detection
    dlImg=imdilate(edImg,strel('disk',5)); % edge dilation
    imshow(dlImg)
end