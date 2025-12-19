function image= improvedCannyEdgeDetection(img)
    % Read the input image
%     img = imread(imagePath);
    if size(img, 3) == 3
        img = rgb2gray(img); % Convert to grayscale if RGB
    end
    
    % Step 1: Morphological Filtering (Replace Gaussian Filtering)
    seSmall = strel('diamond', 1); % Small structural element
    seLarge = strel('disk', 3);    % Large structural element
    openImg = imopen(img, seSmall);  % Opening operation
    closeImg = imclose(openImg, seLarge); % Closing operation
    morphFilteredImg = imadd(0.1 * double(openImg), 0.9 * double(closeImg));

    % Step 2: Compute Gradients in Four Directions
    sobelX = [-1 0 1; -2 0 2; -1 0 1]; % X direction
    sobelY = [-1 -2 -1; 0 0 0; 1 2 1]; % Y direction
    sobel45 = [0 1 2; -1 0 1; -2 -1 0]; % 45-degree direction
    sobel135 = [2 1 0; 1 0 -1; 0 -1 -2]; % 135-degree direction
    
    gradX = imfilter(morphFilteredImg, sobelX, 'replicate');
    gradY = imfilter(morphFilteredImg, sobelY, 'replicate');
    grad45 = imfilter(morphFilteredImg, sobel45, 'replicate');
    grad135 = imfilter(morphFilteredImg, sobel135, 'replicate');
    
    % Gradient Magnitude and Angle
    gradMagnitude = sqrt(gradX.^2 + gradY.^2 + grad45.^2 + grad135.^2);
    gradAngle = atan2(gradY, gradX);

    % Step 3: Non-Maximum Suppression
    nonMaxSuppressedImg = nonMaximumSuppression(gradMagnitude, gradAngle);

    % Step 4: Adaptive Double Thresholding
    highThreshold = 0.2 * max(nonMaxSuppressedImg(:));
    lowThreshold = 0.1 * highThreshold;
    image = doubleThreshold(nonMaxSuppressedImg, highThreshold, lowThreshold);

    % Display results
%     figure;
%     subplot(1, 3, 1); imshow(img); title('Original Image');
%     subplot(1, 3, 2); imshow(nonMaxSuppressedImg, []); title('Gradient Image');
%     subplot(1, 3, 3); imshow(image); title('Final Edge Detection');
end

function nmsImage = nonMaximumSuppression(magnitude, angle)
    [rows, cols] = size(magnitude);
    nmsImage = zeros(rows, cols);
    angle = angle * (180 / pi); % Convert radians to degrees
    angle(angle < 0) = angle(angle < 0) + 180;

    for i = 2:rows-1
        for j = 2:cols-1
            q = 255; r = 255;
            if (0 <= angle(i, j) < 22.5) || (157.5 <= angle(i, j) <= 180)
                q = magnitude(i, j+1);
                r = magnitude(i, j-1);
            elseif (22.5 <= angle(i, j) < 67.5)
                q = magnitude(i-1, j+1);
                r = magnitude(i+1, j-1);
            elseif (67.5 <= angle(i, j) < 112.5)
                q = magnitude(i-1, j);
                r = magnitude(i+1, j);
            elseif (112.5 <= angle(i, j) < 157.5)
                q = magnitude(i-1, j-1);
                r = magnitude(i+1, j+1);
            end
            
            if (magnitude(i, j) >= q) && (magnitude(i, j) >= r)
                nmsImage(i, j) = magnitude(i, j);
            else
                nmsImage(i, j) = 0;
            end
        end
    end
end

function edgeMap = doubleThreshold(img, highThreshold, lowThreshold)
    strong = 255;
    weak = 75;
    edgeMap = zeros(size(img));

    strongEdges = (img >= highThreshold);
    weakEdges = (img >= lowThreshold) & ~strongEdges;

    edgeMap(strongEdges) = strong;
    edgeMap(weakEdges) = weak;

    % Hysteresis: Connect weak edges to strong edges
    [rows, cols] = size(img);
    for i = 2:rows-1
        for j = 2:cols-1
            if edgeMap(i, j) == weak
                if any(any(edgeMap(i-1:i+1, j-1:j+1) == strong))
                    edgeMap(i, j) = strong;
                else
                    edgeMap(i, j) = 0;
                end
            end
        end
    end
end
