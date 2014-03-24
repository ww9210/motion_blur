function result = korrelation(matr_A, matr_B,pos_x, pos_y, del_x, del_y, blocksize, del_x_orig, del_y_orig)

if nargin < 8
    del_x_orig = 0;
    del_y_orig = 0;
end

%% calculate the autocorrelation with deviation in position 
% input:        matr_A: original block
% pos_x:        block position from reference,x
% pos_y:        block position from reference,y
% del_x:        position deviation in x direction
% del_y:        position deviation in y direction
% blocksize:    blocksize 
% range:        decided by M and N. 

%% 
block_A = matr_A(pos_y+del_y_orig:pos_y+del_y_orig+blocksize-1, del_x_orig+pos_x:del_x_orig+pos_x+blocksize-1);
block_B = matr_B(pos_y+del_y:pos_y+del_y+blocksize-1, pos_x+del_x:pos_x+del_x+blocksize-1);
result = sum(sum(block_A.*block_B));
