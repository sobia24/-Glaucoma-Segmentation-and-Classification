function [circCent,circRad]=houghTransform(img,rMin,rMax,rNr,pNr,thr)
    N=rNr*pNr; %number of possible circles
    circCent=zeros(N,2); % centers of the circles
    circRad=zeros(N,1); % radii of the circles
    
    rN=0; % number of detected circles
    for radius=rMin:(rMax-rMin)/4:rMax
        acc=calcDimAcc();

        hoodSize=floor(size(acc)/100.0)*2+1; % neighborhood size
        peaks=zeros(pNr,2); % coordinates of the peaks

        currPkNr=0;
        % until it finds the predicted number of peaks
        while currPkNr<pNr
            maxAcc=max(acc(:)); % accumulator maximum
            %stop if the threshold is not exceeded
            if (maxAcc<thr*maxAcc)
                break;
            end
            currPkNr=currPkNr+1;

            % Find the maximum value of the accumulator
            [~,accIdx]=max(acc(:));
            [mR,mC]=ind2sub(size(acc), accIdx);
            %add a peak
            peaks(currPkNr,:)=[mR,mC];

            % removing pixels in the neighborhood of the accumulator peak
            for cR=calcStart(mR,1):calcEnd(mR,1)
                for cC=calcStart(mC,2):calcEnd(mC,2)
                    acc(cR,cC) = 0;
                end
            end
        end

        peaks=peaks(1:currPkNr,:);   
        
        % if peaks are found, add them and their radii to the array
        if (size(peaks,1)>0)
            rNAcc=rN+size(peaks,1);
            circCent(rN+1:rNAcc,:)=peaks;
            circRad(rN+1:rNAcc)=radius;
            rN=rNAcc;
        end
    end

    circCent=circCent(1:rN,:); % determined coordinates
    circRad=circRad(1:rN); % determined radii

    % Determining coordinates for the radius
    function acc=calcDimAcc()
        acc=zeros(size(img)); % accumulator
        for i=1:size(img,2)
            for j=1:size(img,1)
                % if it is the background, skip it
                if (~img(j,i))
                    continue;
                end
                for th=linspace(0,2*pi,360)
                    y=round(i+radius*cos(th));
                    x=round(j+radius*sin(th));
                    % add to the accumulator only for the range 0->max
                    if (y>0 && y<=size(acc,2) && x>0 && x<=size(acc,1))
                        acc(x,y)=acc(x,y)+1;
                    end
                end
            end
        end
    end

    % initial index of the loop iterating over the pixel neighborhood
    function d=calcStart(s,i)
        d=max(1,s-(hoodSize(i)-1)/2);
    end

    % final index of the loop iterating over the pixel neighborhood
    function d=calcEnd(s,i)
        d=min(size(acc,i),s+(hoodSize(i)-1)/2);
    end
end

