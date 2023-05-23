# CNN_Preparation: A function to prepare a myoelectric signal to train a CNN 

This repository contains the description of the function "CNNpreparation," a code that, from a myoelectric signal acquired with a specific protocol, prepares the samples of each movement to be classified to train a CNN. Each part of the function, called CNNpreparation, is described below.

##  Input arguments
The signal must be recorded based on an acquisition protocol, where it is known how many acquisition channels there are, how many movements were made, how many repetitions of each movement were made, how long each repetition lasted, and also, each repetition must be interspersed by a rest time. 

Syntax
```matlab
CNNpreparation(EMG,Subject_number,channels,Movements,Seconds_per_move,Repetitions,Seconds_rest,sample_rate,Feature_group,image_type,Time_window_length,Time_overlap) 
```
* EMG - matrix  (The variable that contains the signal must be arranged like this: Rows are the number of channels, and Columns are the acquired data)
* Subject - scalar (It is the number of subject under experiment, the file of the images generated at the end will have this number)
* channels - scalar (It is the number of signal acquisition channels)
* Movements - scalar (Number of movements executed in the acquisition protocol)
* Seconds_per_move - scalar (Seconds of the duration of each movement made)
* Repetitions - scalar(Number of repetitios per movement)
* Seconds_rest - scalar(Seconds of rest between repetitions)
* sample_rate - scalar (Sampling frequency with which the signal was acquired)
* Feature_group - scalar between 1 and 4 (group of features to extract from each sample of the signal), Feature groups are built like this:
1. Integrated EMG(IEMG), Variance(VAR), Willison Amplitude(WAMP), Waveform Length(WL), Slope Sign Change(SSC) and Zero Crossing(ZC) 
2. Mean Absolute Value(MAV), SSC, WL, VAR, WAMP, ZC and four coefficients of the autoregression model (AR) 
3. Number of peaks multiplied by the signal power (MPP) and the zero crossings multiplied by the signal power (MZP)
4. Five features of the power spectrum in the time domain
* image_type - scalar between 1 and 4 (the type of image that will be formed with the samples for the training of the CNN network)
1. Feature Image, where the Image height is the number of acquisition channels, and the Image's width is the number of extracted features. 
2. MixChannel Image, where the Image height is the number of channels rearranged with the algorithm of the previous section (SIS), and the Image's width is the number of extracted features. 
3. MixFeature Image, where the Image height is the number of acquisition channels, and the Image's width is the number of features rearranged with the algorithm of the previous section (SIS2). 
4. MixImage, where the Image height is the number of channels rearranged with the algorithm of the previous section (SIS), and the Image's width is the number of features rearranged with the algorithm of the previous section (SIS2).
* Time_window_length - scalar (Window size in milliseconds)
* Time_overlap - scalar (Overlap size in milliseconds)

The last two parameters mean that for each sample, N amount of data will be taken, determined by the time of each window and the sampling time. The samples will be taken at each specific time determined by the overlap and sampling times.

Five other parameters can be edited within the function if the user requires it.

The "threshold" variable is adjusted empirically according to the acquired signal. It is crucial for some features, such as Zero Crossing (ZC), because if the threshold is too low, zero crossings of the noise will also be considered, and if it is very high, it will omit the zero crossings of the signal itself.

```matlab
threshold=0.000001;                 %Threshold for some features
```
The following four variables are necessary to carry out a digital filtering stage, which consists of a band-pass filter from 20 to 500 Hz (range of interest for a myoelectric signal) and a band-reject filter from 50 Hz (to eliminate possible power supply noise), both ranges can be changed as required.

```matlab
Low_frequency=20;                   %High pass cutoff frequency
High_frequency=500;                 %Low pass cutoff frequency
Low_band = 49;                      %Band Reject Filter Low Cutoff Frequency
High_band = 51;                     %Band Reject Filter High Cutoff Frequency
```

From here, it is not recommended to edit anything, it will only be explained in broad strokes what each part of the code does.

## Description

## Concatenate the movements
In this part of the function, the data of each movement is concatenated, taking into account the initial parameters; for this, a variable called "Labeled" is created according to the seconds per movement, the repetitions, and the rest time. Then using this variable, the samples are concatenated and stored in a new variable called "All movements."

```matlab
%Concatenate the signal of the movements
for k = 0:Movements
   Positions = find(Labeled == k);
   Data_per_movement (k+1) = length(Positions); 
   Actual_movement = EMG(:,Positions); 
   All_movements = [All_movements Actual_movement];
   Actual_movement = [];     
end 
```

## Digital filtering stage
Next, the bandpass and band rejection digital filter is created according to the selected parameters. This part of the code graphs the responses of both filters for greater clarity, then both filters are convolved with the "All movements" variable, and the result is saved in the "Convolution all" variable. The code also plots one of the acquisition channels with and without filter to see the result of this re-filtered stage.

```matlab
%Convolution of the filter with the signal  
[rows,columns]=size(All_movements);
for k=1:rows
    convoltion1 = conv(All_movements(k,:),hn); 
    convolution = [convolution;convoltion1];   
end
convolution = convolution(:,n/2+1:length(convolution)-n/2);
convolution_all=[];   
for k=1:rows
    convolution2 = conv(convolution(k,:),hn2); 
    convolution_all = [convolution_all;convolution2];  
end
convolution_all = convolution_all(:,n/2+1:length(convolution_all)-n/2); 
```

## Arrangement of samples in windows
After filtering the signal, a variable is created where the samples (windows) are accommodated according to the window size times and overlap time established in the "Parameter selection" section. A variable called "Samples" is created where each of the windows is arranged in a column, and a vector called "Windows_per_movement" is created where the number of samples (windows) for each movement to be classified is stored.

```matlab
for w=1:Movements     
    Begin = End + 1; 
    End = End + Data_per_movement(w);
    Actual_movement = convolution_all(:,Begin:End);
    Number_windows = floor((length(Actual_movement)-Window_length)/Overlap+1);  
    Windows_per_movement(w)= Number_windows;        %number of samples per move
    Begin2= 1;      
    End2=Window_length;   
    Window_begin = [];

    for p = 1:Number_windows 
        if End2<= length(Actual_movement)    
            Actual_samples = [Window_begin; Actual_movement(:,Begin2:End2)];
            Begin2 = Begin2 + Overlap;   
            End2 = End2 + Overlap; 
            Window_begin=Actual_samples;
        end      
    end 
    Samples = [Samples ; Actual_samples];          %matrix of total samples arranged in column form
    Actual_samples = []; 
end
```

## Extraction of features
Here the group of features selected from each of the samples is extracted from the "Samples" variable, and the result is stored in the "features" variable, where the rows of that variable are the channels of each of the samples, and the columns are the extracted features, for example, if group 1 was selected, the "features" variable will have six columns. 
The functions of the extracted features are included in this repository. However, the user can program different features in this part of the code and follow the same procedure for everything else.

```matlab
switch Feature_group
    case 1          
            features = zeros(rows,6);
            for k=1:rows
                N= Window_length; 
                features(k,1) = IEMG(N,Samples(k,:));
                features(k,2) = WL(Samples(k,:),N);
                features(k,3) = WAMP(N,Samples(k,:),threshold);
                features(k,4) = VAR(Samples(k,:),N);
                features(k,5) = ZC(Samples(k,:),N,threshold);
                features(k,6) = SSC(Samples(k,:),N,threshold);              
            end                         
         
     case 2 
            features = zeros(rows,10);
            for k=1:rows
                N= Window_length; 
                features(k,1) = MAV(N,Samples(k,:));
                features(k,2) = WAMP(N,Samples(k,:),threshold);
                features(k,3) = VAR(Samples(k,:),N);
                features(k,4) = ZC(Samples(k,:),N,threshold);
                features(k,5) = SSC(Samples(k,:),N,threshold);
                features(k,6) = WL(Samples(k,:),N); 
                features(k,7:10)= AR(Samples(k,:),4);             
            end 

     case 3    
           features = zeros(rows,2);
            for k=1:rows
                N= Window_length; %Numero de datos
                %umbral=0.1;
                m0 = moment0(N,Samples(k,:));
                m2 = moment2(N,Samples(k,:));
                m4 = moment4(N,Samples(k,:));
                NPs = m4/m2; 
                ZCs = m2/m0; 
                features(k,1) = NPs*m0;
                features(k,2) = ZCs*m0;
            end  
            
      case 4 
           features = zeros(rows,5);
            for k=1:rows
                N= Window_length;
                m0 = moment0(N,Samples(k,:));
                m2 = moment2(N,Samples(k,:));
                m4 = moment4(N,Samples(k,:));
                S = m0/(sqrt(m0-m2)*sqrt(m0-m4));
                IF = sqrt(m2^2/(m0*m4));
                wl = WL(Samples(k,:),N);
                features(k,1) = log(m0); 
                features(k,2) = log(m2/m0^2);
                features(k,3) = log(m4/m0^4);
                features(k,4) = log(abs(S));
                features(k,5) = log(IF/wl);  
            end   
      otherwise 
           disp('Select a correct value for the Features Group variable');     
end
```
## Algorithm to generate the sequence

Before generating the images, an algorithm was programmed to generate a sequence where each of the rows is adjacent to all the others at some point in that sequence and another sequence where each column is adjacent to the others at some point in the sequence. The first sequence is stored in the "SIS" variable and depends on the number of acquisition channels. The second sequence is in the "SIS2" variable and depends on the number of extracted features. These sequences are to be able to generate the types of images proposed.

```matlab
i = 1; 
j = i+1; 
count = 0; 
SIS = i; 
index = 2; 
while  i ~= j        
   a = find (SIS == i); 
   b = find (SIS == j);
   
   if isempty(b)
      d = [] ;
   elseif isempty(a); 
      d = [];     
   else    
       for k = 1: length(a)
           for q = 1: length(b)          
               c(k,q) = abs(a(k)-b(q));  
           end
       end 
      d = find(c==1);     
   end
   c = 0; 
   a = 0; 
   b = 0;    
   if  j > channels
       j = 1;
   elseif isempty(d)     
       SIS(index) = j; 
       i = j; 
       j = i+1; 
       index = index +1;
       count = 0;        
   else       
       j = j+1;    
   end
   d = []; 
end 

for  k = 1:channels    
   for   q = 1:channels
        a = find (SIS == k); 
        b = find (SIS == q);             
        if isempty(b)
            d = [] ;
        elseif isempty(a); 
            d = [];     
        else    
             for n = 1: length(a)
                for m = 1: length(b)          
                    c(n,m) = abs(a(n)-b(m));  
                end
             end              
            d = find(c==1);      
        end
        c = 0; 
        a = 0; 
        b = 0; 
        if isempty(d) & k~=q 
            SIS(index)= k; 
            SIS(index+1)=q;
            index = index+2;
        end
   end                     
end

[rows columns]=size(features);
i = 1; 
j = i+1; 
count = 0; 
SIS2 = i; 
%Nsis = 1; 
index = 2; 
while  i ~= j        
   a = find (SIS2 == i); 
   b = find (SIS2 == j);
   
   if isempty(b)
      d = [] ;
   elseif isempty(a); 
      d = [];     
   else    
        for k = 1: length(a)
           for p = 1: length(b)          
               c(k,p) = abs(a(k)-b(p));  
           end
        end 
      d = find(c==1); 
   end
   c = 0; 
   a = 0; 
   b = 0; 
   if  j > columns
       j = 1;
   elseif isempty(d)    
       SIS2(index) = j; 
       i = j; 
       j = i+1; 
       index = index +1;
       count = 0;        
   else       
       j = j+1;    
   end
  d = []; 
end 

for  k = 1:columns
    
   for   p = 1:columns
        a = find (SIS2 == k); 
        b = find (SIS2 == p);
                 
        if isempty(b)
            d = [] ;
        elseif isempty(a); 
            d = [];     
        else    
             for n = 1: length(a)
                for m = 1: length(b)          
                    c(n,m) = abs(a(n)-b(m));  
                end
             end              
            d = find(c==1);      
        end
        c = 0; 
        a = 0; 
        b = 0; 
        if isempty(d) & k~=p 
            SIS2(index)= k; 
            SIS2(index+1)=p;
            index = index+2;
        end
   end                      
end
```
## Generate the images
Finally, the set of images that can be used to train a convolutional neural network (CNN) is generated, the images are generated in individual folders for each movement, and the number of images depends on the number of samples that the database has for each movement, and on the type of image selected in the Parameter selection section.


```matlab
    file = ['Images_Features_Group_' num2str(Feature_group) '_Subject'  num2str(Subject_number)];  
    mkdir(file) 
    address = [pwd '\' file '\']; 
    Begin = 1; 
    End = channels; 
    features(find(isfinite(features)==0))=0;  
    features1 = normalizacion2(0,1,features);           %the feature matrix is normalized
    
    for k = 1:Movements
       file_mov = ['MOV_' num2str(k)];
       mkdir(file,file_mov)
       new_address = [address file_mov '\']
        for j = 1:Windows_per_movement(k)
            image = features1(Begin:End,:);
            image = normalizacion_imagen(0,255,image);  %the sample is normalized
            switch image_type
                case 1 
                   image = uint8(image(:,:))';
                case 2
                   image = uint8(image(SIS,:))'; 
                case 3
                   image = uint8(image(:,SIS2))';
                case 4
                   image = uint8(image(SIS,SIS2))'; 
                otherwise 
                   disp('Select a correct value for the image type variable');     
            end                                                        
            address_image = [new_address 'imagen' num2str(j) '.png'];
            imwrite(image,address_image)
            Begin = Begin + channels; 
            End = End + channels; 
        end 
    end 
```
The folders will be saved in the directory where you are running this program and can be used to train any CNN structure.

## Example 
The repository contains a sample signal inside the file called "Example_signal" The signal is stored in the EMG variable

The parameters of the signal acquisition protocol in the example are:
- subject_number = 1 
- channels = 12 
- Movements = 5 
- seconds_per_move = 5 
- repetitions = 6 
- seconds_rest = 3 
- sample_rate = 2000 

And the group of features and the type of images selected were: 

- feature_group = 4 
- image_type = 4

The selected window and overlap times were:

- Time_window_length = 200;         
- Time_overlap = 100;  

```matlab
CNN_preparation1(EMG,1,12,5,5,6,3,2000,4,4,200,100)
``` 
The main objective of the function is to generate a set of images in a central folder

![Main folder](https://github.com/JorgeSan88/CNN_Preparation/blob/main/Main%20folder.PNG)

Other folders will be created within that folder, one for each movement

![Movement folders](https://github.com/JorgeSan88/CNN_Preparation/blob/main/movement%20folders.PNG)

And within each folder, the set of images corresponding to each movement and according to the selected parameters will be generated in such a way that this set of images separated by movement can be used for training a CNN

![Set of images](https://github.com/JorgeSan88/CNN_Preparation/blob/main/Images.PNG)




