%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This algorithm is used for the reconstruction of PA image from RF data.
%This algorithm also allows some elements at any region of the transducer to be
%deleted, rfDataDel is the remaining RF data after deletion.
%%Only use a portion of all the elements
%ImageReconstructionALgorithms5 Changed to record the position of pixel
%that is being selected Data.Position


paraRecon.sf=62.5; % in MHz, sampling frequency of RF data. 40 MHz for prexion system,62.5 MHz for Verasonics
paraRecon.sound_speed=1.481;%1481m/s in water at 20 degree in room temerature
paraRecon.Shift=0; %Time ReconPara.Shift added to RF data. e.g. timeshift=ReconPara.Shift*(1/62.5) usc

%%%Transducer information
infoTrans.nElements=128;
infoTrans.Transducer=true(1,infoTrans.nElements); %Build a martix to put all the elements in
infoTrans.Spacing=0.100; % infoTrans.Spacing between two elements, unit mm%0.1 for 20 Mhz

%%% Reconstruction settings
setRecon.onTransducer=infoTrans.Transducer;
setRecon.onTransducer([])=0; %%Trun off certain elements, not using them in the reconstruction

%% RF data, Raw data to be used
Data.RF=RcvData{1}(12164:14592,:,10);%%%Data.RF should be the RF data you acquired
Data.RF=Data.RF(1:1566,:); %%%Determin how much RF data to be used in reconstruction
%Data.RF(Data.RF<0)=0;
%Data.RF(Data.RF<0)=0;
Data.hilbertRF=hilbert((Data.RF)); % Do hilbert transform at each column of original RF data
%%%%Data.RF=Data.RF(:,nElementsDel/2+1:128-nElementsDel/2);%%Delete RF data that won't be used

%% Basic information from RF data
[Nsample]=size(Data.RF,1);


%% 2D image coordinates
ImageCoo.xSize =12.8;                 % in mm
ImageCoo.zSize =25.0; %34.5                % in mm
ImageCoo.xPixels=1300; %650
ImageCoo.zPixels=2540; %1270
ImageCoo.xCenter = 0;
ImageCoo.zCenter = 0;
ImageCoo.xCOO = ((1:ImageCoo.xPixels)-(ImageCoo.xPixels+1)/2)*ImageCoo.xSize/(ImageCoo.xPixels-1)+ImageCoo.xCenter;       % x axis
ImageCoo.zCOO = ((1:ImageCoo.zPixels))*ImageCoo.zSize/(ImageCoo.zPixels)+ImageCoo.zCenter; %Check if this -1 make sense: not making sense, delete from (ImageCoo.zPixels-1)
ImageCoo.xPosition = ones(ImageCoo.zPixels,1).*ImageCoo.xCOO; % all enteries are mm, 2D coo system: xvalue
ImageCoo.zPosition = ImageCoo.zCOO'*ones(1,ImageCoo.xPixels); % all enteries are mm, 2D coo system: zvalue

%% 1D transducer coordinates
%infoTrans.Spacing=infoTrans.infoTrans.Spacing;
TransCoo.xElePosition = ((1:infoTrans.nElements)- (infoTrans.nElements+1)/2)*infoTrans.Spacing;
%%
pa = zeros(ImageCoo.zPixels, ImageCoo.xPixels);   

nStep=0;
for indexTrans = 1:infoTrans.nElements
    indexTrans
    if setRecon.onTransducer(indexTrans)==1
        nStep=nStep+1; % Index of all the elements that are used.
    
        
    Temp.RF_1D = ([Data.hilbertRF(:,indexTrans); 0]); %Extract RF data from one element
    Temp.dx=ImageCoo.xPosition-TransCoo.xElePosition(indexTrans);
    Temp.dy=ImageCoo.zPosition;
    Temp.distance=sqrt(Temp.dx.^2+Temp.dy.^2); % Temp.distance between pixels to the one element
    
    Temp.deg=abs(atan(Temp.dx./Temp.dy)); %Sensitivity angle of the one element and pixel
                
    Temp.Dis_inTime=Temp.distance/paraRecon.sound_speed;
    Temp.Dis_inPixels = round(Temp.Dis_inTime*paraRecon.sf); 
    %Transfer Temp.distance in Time into Temp.distance in Pixels in RF data
    Temp.Dis_inPixels=Temp.Dis_inPixels+paraRecon.Shift; 
    %%Time ReconPara.Shift is added here
    inRange = (Temp.Dis_inPixels >=1) & (Temp.Dis_inPixels <= Nsample) ;
    %%Check if Temp.distance is in the range of RF data
    Temp.Dis_inPixels = (inRange).*Temp.Dis_inPixels + (1-inRange).*(Nsample+1);
    Data.Position(:,:,nStep)=Temp.Dis_inPixels;
    %%%Judge in range, why Nsample+1??
    Temp.Img(:,:,nStep) = Temp.RF_1D(Temp.Dis_inPixels).*cos(Temp.deg);
    %Data.img_complex{nStep}=Temp.Img;
    pa = pa + Temp.Img(:,:,nStep);
   
    end
end

%%
%abs2= abs((pa_img_DAS));
Data.Img = abs((pa))/max(max(abs((pa))));
figure;imshow(uint8(Data.Img.*255))
colormap('hot')

%clear nStep inRange abs2 indexTrans
