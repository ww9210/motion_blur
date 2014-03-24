
%function M =get_mv(filter)
%% read motion vector file
M = zeros(25,14400,9);
for frame=24:48
filename            =   strcat('./Result/intersection/',int2str(frame),'.txt');
outputname = strcat('./Result/intersection/',int2str(frame),'mv.txt');
fprintf('reading frame %d\n',frame);
tic
    mydataread(filename,outputname,14400) ;
toc
M(frame-23,:,:) = load(outputname);
end


%% get motion_current

blurinfo = reshape(M(1,:,:),14400,9);

%blurinfo = moiton_current(:,[1,2,8,9,6]);

table=[1 2 8 9 6]; 
[n,len]=size(table); 
motion_current=blurinfo(:,table); 

%% load disk
filename            =   './Result/39disk.txt';
outputname = './Result/39diskmv.txt';
%fprintf('reading frame %d\n',frame);
tic
    mydataread(filename,outputname,14400) ;
toc
M = load(outputname);