function CNN_preparation(EMG,Subject_number,channels,Movements,Seconds_per_move,Repetitions,Seconds_rest,sample_rate,Feature_group,image_type,Time_window_length,Time_overlap)

threshold=0.000001;                 %Threshold for some features
Low_frequency=20;                   %High pass cutoff frequency
High_frequency=500;                 %Low pass cutoff frequency
Low_band = 49;                      %Band Reject Filter Low Cutoff Frequency
High_band = 51;   

%%  Concatenate the movements

Movement_Time = Seconds_per_move*sample_rate;
Rest_Time = Seconds_rest*sample_rate;

%Create a labeling vector according to acquisition times
Labeled = zeros(1,(Movement_Time+Rest_Time)*Movements*Repetitions);
Begin = 1;End = Rest_Time;End2 = End + Movement_Time;
for k = 1:Movements
        for r = 1:Repetitions
            Labeled(1,Begin:End) = 0;
            Labeled(1,End+1:End2) = k; 
            Begin = End2+1; 
            End = End2+Rest_Time;
            End2 = End+Movement_Time; 
        end
end 

%Adjust the size of the signal matrix and the labeling vector
if length(Labeled) > length(EMG)
    Labeled = Labeled(1:length(EMG));
else 
    EMG= EMG(:,1:length(Labeled));
end
All_movements=[];

%Concatenate the signal of the movements
for k = 0:Movements
   Positions = find(Labeled == k);
   Data_per_movement (k+1) = length(Positions); 
   Actual_movement = EMG(:,Positions); 
   All_movements = [All_movements Actual_movement];
   Actual_movement = [];     
end 

%% Digital filtering stage

Window_length = (sample_rate/1000)*Time_window_length;
Overlap =(sample_rate/1000)*Time_overlap;
n = 1000;                                          % filter order 
Wn1= (1/(sample_rate/2))*Low_frequency;  
Wn2= (1/(sample_rate/2))*High_frequency;  
Wn3= (1/(sample_rate/2))*Low_band; 
Wn4= (1/(sample_rate/2))*High_band; 
Wn_band_pass = [Wn1  Wn2];            
hn = fir1(n,Wn_band_pass);                         %define band pass filter          
[Hlp, qlp]=freqz(hn,1,n);   
maglp = abs(Hlp);
Wn_band_stop= [Wn3  Wn4];           
hn2 = fir1(n,Wn_band_stop,'stop');                 %define band stop filter
[Hlp2, qlp2]=freqz(hn2,1,n);   
maglp2 = abs(Hlp2);

%Plot filters respond
figure(1)
subplot(2,1,1); 
plot(qlp,maglp,'.'); 
title('Bandpass filter response'); 
xlabel('Frequency (w)');
ylabel('Amplitude Hlp(w)');
subplot(2,1,2); 
plot(qlp2,maglp2,'.'); 
title('Band stop filter response'); 
xlabel('Frequency (w)');
ylabel('Amplitude Hlp(w)');

%Convolution of the filter with the signal
convolution=[];   
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

%%Graph a channel with and without filter
figure(2)
plot(All_movements(1,:)); axis([0 length(All_movements) min(All_movements(1,:)) max(All_movements(1,:))]);
title('Graph a channel with and without filter');xlabel('Time [ms]'); ylabel('Amplitude [V]');
hold on 
plot(convolution_all(1,:));
hold off

%% Arrangement of samples in windows

End = 0;
Samples = [];
Actual_samples = [];
Windows_per_movement = [];
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
     
%% Extraction of features

[rows,columns]=size(Samples);      
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

%% Algorithm to generate the sequence of all the channels adjacent to the others, and the algorithm of all the features adjacent to the others

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

%% Generate the images
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
                   image = uint8(image(:,:));
                case 2
                   image = uint8(image(SIS,:)); 
                case 3
                   image = uint8(image(:,SIS2));
                case 4
                   image = uint8(image(SIS,SIS2)); 
                otherwise 
                   disp('Select a correct value for the image type variable');     
            end                                                        
            address_image = [new_address 'imagen' num2str(j) '.png'];
            imwrite(image,address_image)
            Begin = Begin + channels; 
            End = End + channels; 
        end 
    end 


end 