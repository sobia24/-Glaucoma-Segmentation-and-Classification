

function [Ip] =proposed_enhc(I,rH,rL,hm,d0)


[r,c]=size(I)


P=r/2
Q=c/2


for i=1:r
    for j=1:c

 H(i,j)= (rH-rL)*(1-exp(-hm*((sqrt((i-P/2)^2+(j-Q/2)^2))/d0)^2))+rL;
    end
end

 L=log(double(I)+1);
 
 F=fft2(L);
 
  Filtout = F.*H;
  
 
  iF=ifft2(Filtout);
  
  
  Ip=abs(exp(iF));
  
  Ip=(Ip);