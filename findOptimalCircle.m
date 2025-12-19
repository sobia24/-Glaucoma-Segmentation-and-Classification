function [x,y]=findOptimalCircle(c,r,img)
    circNum=length(r);
    coverage=zeros(circNum, 1);

    % finding coordinates that form a circle
    [rI,cI]=find(img==1);

    % traversing through all circles
    for i=1:circNum
        [xF,yF]=circlePoints(i);    
        commonX=length(intersect(xF,rI));
        commonY=length(intersect(yF,cI));
        coverage(i)=commonX+commonY;
    end

    bC=[];
    bR=[];

    % Selection of the circle with the largest coverage
    if (size(coverage)>0)
        maxIdx=find(coverage==max(coverage));
        bC=c(maxIdx(1),:);
        bR=r(maxIdx(1));
    end

    % transformation to x, y coordinates
    thF=linspace(0,2*pi,360);
    x=bC(2)+bR*cos(thF);
    y=bC(1)+bR*sin(thF);

    % determining x and y coordinates based on the index
    function [x,y]=circlePoints(i)
        th=linspace(0,2*pi,100);
        x=round(c(i,1)+r(i)*cos(th));
        y=round(c(i,2)+r(i)*sin(th));
    end
end