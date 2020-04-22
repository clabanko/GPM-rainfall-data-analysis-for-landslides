function [A,ev,delay,delayreal,cumrain]=rainfall30minsingle(U,a,b,c,d)

%Identify where the rainfall event starts

%Id event (the trigger of the geophones is identified by 1; other cases
% eventidcol=0)
    eventidcol=U(:,1); 

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

eventidcol=U(:,1);  

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

%Define r, the index that will indicate where the trigger is.
r=0;

for i=1:m
     if eventidcol(i)==1
         r=i;
     else
     r=r;
     end
 end
 rs=0;
 for j=r:-1:1
     if rain30min(j,1)>a && rain30min(j-1,1)==0 && rain30min(j-2,1)==0 
         rs=j;
         break
     end    
 end
 re=0;
 for k=r:m
    if rain30min(k,1)>c && rain30min(k+1,1)==0 && rain30min(k+2,1)==0
         re=k;
         break
     end
 end
duration=re-rs;
ev=zeros(duration+1,8);
time=[0:1:duration+1]';
timereal=time*30;
delay=r-rs;
delayreal=delay*30;

for i=1:duration+1
    ev(i,1)=timereal(i,1);
    ev(i,2)=rain30min(rs+(i-1),1);
    ev(i,3)=phfloat60min(rs+(i-1),1);
    %Data for the IDF curves
    ev(i,4)=phfloat90min(rs+(i-1),1);
    ev(i,5)=phfloat120min(rs+(i-1),1);
    ev(i,6)=phfloat180min(rs+(i-1),1);
    ev(i,7)=phfloat240min(rs+(i-1),1);
    ev(i,8)=phfloat300min(rs+(i-1),1);

end

% Calculate vector of cummulated rainfall
cumrain=zeros(duration+1,1);
cumrain(1,1)=rain30min(rs);
for i=2:duration+1
    cumrain(i,1)=cumrain(i-1,1)+rain30min(rs+(i-1),1);
end


%Calculate parameters
totalrain=sum(ev(:,2));
if totalrain<0
    totalrain=-1000;
end

ph30minmax=max(ev(:,2))*2;
meanrain=(totalrain/(duration*30))*60;
if meanrain<0
    meanrain=-1000;
end


ph60minmax=max(ev(:,3));
if ph60minmax<0
    ph60minmax=-1000;
end

ph90minmax=max(ev(:,4));
if ph90minmax<0
    ph90minmax=-1000;
end

ph120minmax=max(ev(:,5));
if ph120minmax<0
    ph120minmax=-1000;
end

ph180minmax=max(ev(:,6));
if ph180minmax<0
    ph180minmax=-1000;
end

ph240minmax=max(ev(:,7));
if ph240minmax<0
    ph240minmax=-1000;
end

ph300minmax=max(ev(:,8));
if ph300minmax<0
    ph300minmax=-1000;
end


%Antecedent rainfall
onedayrain=zeros(48,1);
threedaysrain=zeros(144,1);
tendaysrain=zeros(480,1);

for i=1:47
    onedayrain(i,1)=rain30min(rs-i,1);
end

for j=1:143
    threedaysrain(j,1)=rain30min(rs-j,1);
end

for k=1:479
    if rs-k>0
        tendaysrain(k,1)=rain30min(rs-k,1);
    else
        tendaysrain(k,1)=-9999;
    end
end
totaloneday=sum(onedayrain(:,1));
if totaloneday<0
    totaloneday=-1000;
end
totalthreedays=sum(threedaysrain(:,1));
if totalthreedays<0
    totalthreedays=-1000;
end
totaltendays=sum(tendaysrain(:,1));
if totaltendays<0
    totaltendays=-1000;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Output data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A=zeros(1,15);
A(1,1)=r;
A(1,2)=(duration+1)*30;
A(1,3)=totalrain;
A(1,4)=meanrain;
A(1,5)=ph60minmax;
A(1,6)=totaloneday;
A(1,7)=totalthreedays;
A(1,8)=totaltendays;
A(1,9)=ph30minmax;
A(1,10)=ph60minmax;
A(1,11)=ph90minmax;
A(1,12)=ph120minmax;
A(1,13)=ph180minmax;
A(1,14)=ph240minmax;
A(1,15)=ph300minmax;