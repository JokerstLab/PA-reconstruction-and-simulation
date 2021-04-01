%%%%%%%%%Important codes%%%%%%%%%%
%%%%%%
for i=1:1000
ResolveVolumePosiX(1:1000,i)=i;
end
for i=1:1000
ResolveVolumePosiZ(i,1:1000)=i;
end
%%%%%
for i=1:128
ans=((0.01*(100-1)+0.001*(ResolveVolumePosiZ-500)).^2+(0.01*(64-i)+0.001*(ResolveVolumePosiX-500)).^2).^0.5;
Radius=((0.01*(100-1)).^2+(0.01*(64-i)).^2).^0.5; %Distance bettwwen the center of resoultion volume to the transducer element
f=exp(-0.5.*((ans-Radius).^2)./(2*(0.2/2.355)^2)); %Gaussian distribution, 0.2mm is FWHM, 0.2/2.355 is standard diviatation
ff(:,:,i)=f;  %%%all the results from different transducer element
end
figure;imagesc(sum(ff,3))

%%%%%%%%%%%
%0.01 mm, 0.001 mm



%%%Defination%%%
%Define imaging plane
%Z (Depth)*X (Width),10 mm* 10mm, 1000 pixels*1000 pixels
numZpixels=1000; numXpixels=1000;%Define the number of Z and X pixels
Z=10; X=10;%Define imaging range, in millimeter
Img=uint8(zeros(numZpixels,numXpixels));%Define imaging plane

%Generate imaging plane coordination matrix
for i=1:numXpixels
coorXmatrix(1:numZpixels,i)=i-numXpixels/2; % X-coordination of the imaging plane, in pixel
end
coorXmatrix=coorXmatrix*(X/numXpixels);% In mm
for i=1:numZpixels
coorZmatrix(i,1:numXpixels)=i;% z-coordination of the imaging plane
end
coorZmatrix=coorZmatrix*(Z/numZpixels);%In mm

%Define the sample point coordination
SampleCoor=[200*(Z/numZpixels),(500-numXpixels/2)*(X/numXpixels)]; % [Axial position Transverse position] in pixels

%Define the transducer coordination
nElements=128 %Number of elements
pitchElement=0.1 % Element pitch in millimeter
coorElementsZ=0; %Z-coordination of the transducer
coorElementsX=([1:nElements]-nElements/2)*pitchElement;%X-coordination of the transducer


%%%Back-projection and summation%%%
for i=1:nElements 
disPixel2Ele=((coorXmatrix-coorElementsX(i)).^2+(coorZmatrix-coorElementsZ).^2).^0.5; %Distance between each pixel on the imaging plane to the sample point
disSample2Ele=((SampleCoor(1)-coorElementsZ).^2+(SampleCoor(2)-coorElementsX(i)).^2).^0.5;
%Distance=((0.01*(100-1)+0.001*(ResolveVolumePosiZ-500)).^2+(0.01*(64-i)+0.001*(ResolveVolumePosiX-500)).^2).^0.5;
%Radius=((0.01*(100-1)).^2+(0.01*(64-i)).^2).^0.5; %Distance bettwwen the center of resoultion volume to the transducer element
f=exp(-0.5.*((disPixel2Ele-disSample2Ele).^2)./(2*(0.2/2.355)^2)); %Gaussian distribution, 0.2mm is FWHM, 0.2/2.355 is standard diviatation
ff(:,:,i)=f;  %%%all the results from different transducer element
end
figure;imagesc(sum(ff,3))
%figure; imagesc(sum(ff(:,:,[1:53,74:128]),3))