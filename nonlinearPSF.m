%%
%input:
%
%
%output:
%
%
%% change k to see different curves
motion_length=1.5;
%filter
I_max=255;
k=10;
mystep=0.001;
for k=1:20
    t = 0:mystep:motion_length;
    I_t = I_max*(1-exp(-k*t));
    plot(t,I_t);
    grid on;
    hold on;
    %figure;
end

%% discreate version I(n)
close all;
motion_length=1.5; %specify the motion length
k=1;% k is the non-linear parameter
t = 0:mystep:motion_length;
I_t = I_max*(1-exp(-k*t));
figure
plot(t,I_t);
grid on;
vectorlength = floor(motion_length/mystep);



seperation_number = 3;%divide on to 'seperation_number' parts
mask = floor(vectorlength/seperation_number):floor(vectorlength/seperation_number):vectorlength;
seperation_point_value = I_t(mask);
intergration_of_separations = seperation_point_value;
intergration_of_separations(1) = seperation_point_value(1);
for i=2:seperation_number
    intergration_of_separations(i)=seperation_point_value(i)-seperation_point_value(i-1);
end

intergration_of_separations = intergration_of_separations/norm(intergration_of_separations,1)


%% get different filters write the nonlinear filters to file
close all;
mystep=0.001;
I_max=255;
seperation_number = 3;%divide on to 'seperation_number' parts
str= strcat('./Result/nonlinearPSF/filterlength:',num2str(seperation_number),'_',datestr(now),'PSF.txt');
fid = fopen(str,'wt');
for motion_length = 1:0.1:3
    k=1.5;% k is the non-linear parameter
    t = 0:mystep:motion_length;
    I_t = I_max*(1-exp(-k*t));
    figure
    plot(t,I_t);
    grid on;
    vectorlength = floor(motion_length/mystep);
    
    mask = floor(vectorlength/seperation_number):floor(vectorlength/seperation_number):vectorlength;
    seperation_point_value = I_t(mask);
    intergration_of_separations = seperation_point_value;
    intergration_of_separations(1) = seperation_point_value(1);
    for i=2:seperation_number
        intergration_of_separations(i)=seperation_point_value(i)-seperation_point_value(i-1);
    end
    
    intergration_of_separations = intergration_of_separations/norm(intergration_of_separations,1)
    fprintf(fid,'%6.2f',intergration_of_separations);
    fprintf(fid,'\n');
    
end
fclose(fid);
close all;
%% write the nonlinear filters to file

str= strcat('./result/nonlinearPSF/filterlength:',num2str(seperation_number),'_',datestr(now),'PSF.txt');
fid = fopen(str,'wt');


