clc
clear
%%%%%%%%%%%%%%%%%%  RAINFALL ANALYSIS FROM IMERG GPM %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% MODULE DESCRIPTION  %%%%%%%%%%%%%%%%%%%%%
% Purpose: Calculate parameters to characterize rainfalls that trigger landslides and obtain I-D curves for the rainfalls and eventually draw a threshold for the triggering rainfalls (if possible)
% Contents:analysisrainfallGPM.m; rainfall30min.m (function); rainfall30minsingle.m (function)
% Authors: Clàudia Abancó
% Contact: c.abanco@exeter.ac.uk
% Organization: University of Exeter
% Programming Language: Matlab
% Required software packages: Matlab R2019a


%%%%%%%%%%%%%%%%%% Input data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Criteria to start/end the rainfall event:
%       - Ph float (floating hourly intensity of rainfall; mm/h)
%       - 30min cummulated rainfall (mm/30 min)
% - Rainfall IMERG GPM data (see example file to see the format of the
% file)
% Col.1: Zeros (only a “1” at the location of a rainfall event) ===> see section “find rainfall events” for more info
% Col.2: Date and time yyyy-mm-dd hh:mm:ss (format is not critical)
% Col.3: Average intensity in 30 min (mm/h)

% BATCH version- File with X columns (equivalent to Col.1), each one
% corresponding to a rainfall event 


%Load the GPM file where the date and time of the landslide event is identified by a
%number 1 in the first column.
% Note that in the BATCH verison, this column will only be considered for the first iteration. 
[fileName] = uigetfile('*', 'Select GPM rainfall data file', '.');
U = load([fileName]);

%Define the criteria to initiate/end the rainfall.
disp('Define the criteria to initiate/end the rainfall');
a=input('Rainfall 30-min to initiate the rainfall has to be more or equal than... [mm/30min]');
b=input('Ph float to initiate the rainfall has to be more or equal than... [mm/h]');
c=input('Rainfall 30-min to finish the rainfall has to be less or equal than... [mm/30min]');
d=input('Ph float to finish the rainfall has to be less or equal than... [mm/h]');


e=input('Single [1] or Batch [2] analysis?');

if e==1

%SINGLE option
    [A,ev,delay,delayreal,cumrain]=rainfall30minsingle(U,a,b,c,d);
    headers={'Index trigger','Duration [min]','Total rainfall [mm]','Mean rainfall [mm/h]','Ph max float [mm/h]','1 day antecedent rainfall [mm]','3 days antecedent rainfall [mm]','10 days antecedent rainfall [mm]','Ph float 30 min [mm/h]','Pfloat 60 min [mm/h]','Phfloat 90 min [mm/h]','Phfloat 120 min [mm/h]','Phfloat 180 min [mm/h]','Phfloat 240 min [mm/h]','Phfloat 300 min [mm/h]'};
   
    [pathstr, name, ext] = fileparts(fileName);
    %name=num2str(r);
    xlswrite(name,headers,1,'A1')
	xlswrite(name,A,1,'A2') 
       
         
    h=figure('Name',fileName);

        timemax=max(ev(:,1));

        subplot(2,1,1)
        plot(ev(:,1),(ev(:,2))*2,'k',delayreal,ev((delay+1),2)*2,'or','MarkerSize',8,'Markerfacecolor','r'); 
        xlim([0 timemax])
        xlabel('Time (min)')
        ylabel('Rainfall intensity(mm/h)')

        subplot(2,1,2)
        plot(ev(:,1),cumrain,'k','LineWidth',2.5);
        xlim([0 timemax])
        xlabel('Time (min)')
        ylabel('Cummulated rainfall (mm)')

        suptitle(name);
        orient landscape
        saveas(h,name,'pdf')

elseif e==2
%BATCH option
    %If we want to do an analysis of multiple rainfalls, we will have an extra
    %.txt file where each column will have all "zeros" but a "one" in the
    %position of the trigger. 

    [fileName2] = uigetfile('*', 'Select triggers data file', '.');
    B = load([fileName2]);

    R=zeros(size(B,2),15);

    for z=1:size(B,2)-1
        [A,ev,delay,delayreal,cumrain]=rainfall30min(U,B,a,b,c,d,z);
        for y=1:15
            R(z,y)=A(1,y);
        end
    end

    
    headers={'Index trigger','Duration [min]','Total rainfall [mm]','Mean rainfall [mm/h]','Ph max float [mm/h]','1 day antecedent rainfall [mm]','3 days antecedent rainfall [mm]','10 days antecedent rainfall [mm]','Ph float 30 min [mm/h]','Pfloat 60 min [mm/h]','Phfloat 90 min [mm/h]','Phfloat 120 min [mm/h]','Phfloat 180 min [mm/h]','Phfloat 240 min [mm/h]','Phfloat 300 min [mm/h]'};
    [pathstr, name, ext] = fileparts(fileName);
    %name=num2str(r);
    xlswrite(name,headers,1,'A1')
	xlswrite(name,R,1,'A2') 

    t=input('Plot ID curves? Yes [1] or No [2]');

        if t==1
            durations=[0.5 1 1.5 2 3 4 5];
            numrainfalls=size(R,1);
            date=zeros(size(R,1),1);
            colors=distinguishable_colors(numrainfalls);
            for i=1:numrainfalls
                intensity=R(i,9:15);
                date(i,1)=R(i,1)/48;
                color=colors(i,:);
                plot(durations,intensity,'Color',color,'LineWidth',1.5);
                xlim([0 5.5])
                xlabel('Duration (h)')
                ylabel('Intensity (mm/h)')
                hold all
            end
            
            hleg = legend(num2str(floor(date (:,1))));
            htitle = get(hleg,'Title');
            set(htitle,'String','Day of year')
            
            caine1980=[19.42 14.82 12.652 11.31 9.655 8.630 7.911];
            nolascokumar2018=[7.84 6.46 5.76 5.32 4.75 4.38 4.11];
            arboleda1996=[2.374 2.44 2.45 2.54 2.68 2.76 2.83];
            plot(durations,caine1980, '--','LineWidth',2, 'DisplayName','Caine 1980')
            hold on
            plot(durations,nolascokumar2018,'--', 'LineWidth',2, 'DisplayName','Nolasco and Kumar 2018')
            hold on
            plot(durations,arboleda1996,'--', 'LineWidth',2, 'DisplayName','Arboleda 1996')
            hold on
        elseif t==2
            
        end
end

disp('End analysis');
