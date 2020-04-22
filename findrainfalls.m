clc
clear
%%%%%%%%%%%%%%%%%%  RAINFALL ANALYSIS FROM IMERG GPM %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% MODULE DESCRIPTION  %%%%%%%%%%%%%%%%%%%%%
% Purpose: Find high intensity rainfalls within a file with
% GPM rainfall file including a yearly timeseries 
% Contents:analysisrainfallGPM.m; rainfall30min.m (function); rainfall30minsingle.m (function)
% Authors: Clàudia Abancó
% Contact: c.abanco@exeter.ac.uk
% Organization: University of Exeter
% Programming Language: Matlab
% Required software packages: Matlab R2019a

%DEFINITION OF VARIABLES AND LOADING DATA

%Define rs, the index that will indicate where the rainfall event starts.
disp('Define the criteria to initiate/end the rainfall');
b=input('Intensity to initiate the rainfall has to be more or equal than... [mm/h] in 3 hours');


[fileName] = uigetfile('*', 'Select event file', '.');
U = load([fileName]);

%Identify variables from input matrix U.
%Rainfall every 30 minutes
    rain30min=U(:,4)/2;

m=size(U,1);   

phfloat30min=rain30min*2;
phfloat60min=zeros(m,1);
phfloat90min=zeros(m,1);
phfloat120min=zeros(m,1);
phfloat180min=zeros(m,1);
phfloat240min=zeros(m,1);
phfloat300min=zeros(m,1);



for i=2:m
phfloat60min (i,1)=(rain30min(i,1)+rain30min(i-1,1));
end
for i=2:m-1
    for j=i-1:i+1
    phfloat90min(i,1)=phfloat90min(i,1)+rain30min(j,1)/1.5;
    end
end
for i=3:m-1
    for j=i-2:i+1
    phfloat120min(i,1)=phfloat120min(i,1)+rain30min(j,1)/2;
    end
end
for i=3:m-3
    for j=i-2:i+3
    phfloat180min(i,1)=phfloat180min(i,1)+rain30min(j,1)/3;
    end
end    
for i=4:m-4
    for j=i-3:i+4
    phfloat240min(i,1)=phfloat240min(i,1)+rain30min(j,1)/4;
    end
end   
for i=5:m-5
    for j=i-4:i+5
    phfloat300min(i,1)=phfloat300min(i,1)+rain30min(j,1)/5;
    end
end


B=zeros(m,m);
j=1;
i=3;
while i<(m-4)
        if phfloat180min(i,1)>b  
          B(i,j)=1;
           for k=i+1:m-3
               if phfloat180min(k,1)>0
                    k=k+1;
                    i=k;
               elseif phfloat180min(k,1)==0
                   i=i+1;
                   break
               end
           end
          j=j+1;    
        end
    i=i+1;
end
B=B(1:m,1:j);

save('findrainfalls_new.txt','B','-ascii','-tabs')

disp('End of analysis');
