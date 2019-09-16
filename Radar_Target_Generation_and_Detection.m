clear;
close all;
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Declare the variables
Range_max = 200; % in meters
Range_resolution = 1; % in meters
Velocity_max = 100; % in m/s
c = 3e8; %speed of light

%speed of light = 3e8
%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant
 
Target_range = 100; % in meters
Target_velocity = 50; % in m/s

%% FMCW Waveform Generation

% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

%To calculate Bandwidth

B = c / (2 * Range_resolution);

%To find the chirp time
%Sweep time has to ben knowsn and it should be around 5 -6 times the round trip time
Tsweep = 5.5;
Tchirp = Tsweep * (2 * Range_max / c) ;

%To find slope of FMCW
slope = B / Tchirp;

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq

                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples


%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(t)         
    
    
    % *%TODO* :
    %For each time stamp update the Range of the Target for constant velocity. 
    range_at_t = 2 * (Target_range + (Target_velocity * t(i)))/c;
    
    % *%TODO* :
    %For each time sample we need to update the transmitted and
    %received signal. 
    Tx(i) = cos(2 * pi * (fc * t(i) + slope * t(i)^2 / 2));
    Rx (i)  = cos(2 * pi * (fc * (t(i) - range_at_t) + slope * (t(i) - range_at_t)^2 / 2));
    
    % *%TODO* :
    %Now by mixing the Transmit and Receive signal, generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i).*Rx(i); % .* is used for elementwise multiplication
    
end

%% RANGE MEASUREMENT


 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
 
% Nr = 1024, Nd = 128
Mix = reshape(Mix, [1024, 128]); 

%or
%Mix = reshape (Mix, [Nr, Nd]);

 % *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
% *%TODO* :
% Take the absolute value of FFT output

FFT1 = abs(fft(Mix, Nr));

%To Normalize
FFT_Norm = FFT1./max(FFT1); % dividing every element by max value in the 1st FFT output. 

 % *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.

FFT_single_side = FFT_Norm(1:Nr/2-1);

%plotting the range
figure ('Name','Range from First FFT')

 % *%TODO* :
 % plot FFT output 
plot(FFT_single_side);
axis ([0 200 0 1]);
title('Range from First FFT');
ylabel('Normalized Amplitude');
xlabel('Range (m)');



%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM


% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure("Name", 'FFT2 surface plot') ,surf(doppler_axis,range_axis,RDM);
title('FFT2 surface plot');
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Amplitude');

%The below line is uncommented to view the output in different angles
%view(180,0); % chnage the valeus to 45, 90, 180, ..  360 degrees 

%% CFAR implementation

%Slide Window through the complete Range Doppler Map

% *%TODO* :
%Select the number of Training Cells in both the dimensions.

Tr = 10; % Range dimension
Td = 8; % Doppler dimension

% *%TODO* :
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation

Gr = 4; % Range dimension
Gd = 4; % Doppler dimension

% *%TODO* :
% offset the threshold by SNR value in dB

SNR_OFFSET = 14;

%To claculate the number of Gaurd and Training cells
% Remove CUT
Gaurd_N = (2 * Gr + 1) * (2 * Gd + 1) - 1;  
Train_N = (2 * Tr + 2 * Gr + 1) * (2 * Td + 2 * Gd + 1) - (Gaurd_N + 1);

% *%TODO* :
% This has been used in the loop
%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);


% *%TODO* :
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.


   % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
   % CFAR
   
for range = Tr + Gr + 1 : (Nr/2) -(Tr+Gr)
    for doppler = Td + Gd + 1 : Nd - (Td+Gd)
        %Create a vector to store noise_level for each iteration on training cells
        noise_level = zeros(1,1);
        
        for i = range - (Tr + Gr) : range + Tr + Gr 
            for j = doppler - (Td + Gd) : doppler + Td + Gd 
                if (abs(range-i) > Gr || abs(range-j) > Gd)
                    noise_level = noise_level + db2pow(RDM(i,j));
                end
            end
        end
        
        %Threshold using noise average value.
        %Convert back from pow to db using pow2db
        %Offset is added to the threshold
        threshold = SNR_OFFSET + pow2db(noise_level /(2 * (Td + Gd + 1) * 2 * (Tr + Gr + 1) - (Gr * Gd) - 1));
        
        %Compare with threshold
        if (RDM(range,doppler) < threshold)
            RDM(range,doppler) = 0;
        else
            RDM(range,doppler) = 1;
        end
    end
end

% *%TODO* :
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 
RDM(RDM~=0 & RDM~=1) = 0;

% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure('Name', '2D CFAR on the Output of RDM'),surf(doppler_axis,range_axis,RDM);
title('FFT2 surface plot');
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Amplitude');
colorbar;


 

