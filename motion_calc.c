#include <stdio.h>
#include "mex.h"
#include <stdlib.h>


int max(int a,int b)
{
  if(a>b)
    return a;
  else
    return b;
}

int min(int a,int b)
{
  if(a<b)
    return a;
  else
    return b;
}
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int max();
    int min();
    
    struct
    {
	int frame_width;
	int frame_height;
	int search_range;
	int blocksize;
    } sim;
    	sim.frame_width = 1280;
	sim.frame_height = 720;
	sim.search_range = 64;
	sim.blocksize = 8;
    #define A_IN prhs[0] 
    #define B_IN prhs[1] 
    double *last_ups, *current;
    
    int num_in_row = sim.frame_width/sim.blocksize;
    int num_in_col = sim.frame_height/sim.blocksize;
    int num_block_all = num_in_row*num_in_col;
    
    int last_ups_dim[3];
    int M;
    int N;
    M = mxGetM(B_IN); 
    N = mxGetN(B_IN); 
    
    last_ups = mxGetPr(A_IN);
    current = mxGetPr(B_IN);
    
    
    #define M_OUT plhs[0]
    #define P_OUT plhs[1]
    double *motion, *prediction;
    
    int dim[2];
    dim[0]=num_block_all;
    dim[1]=5;
    M_OUT = mxCreateNumericArray(2,dim,mxDOUBLE_CLASS,mxREAL);
    motion = mxGetPr(M_OUT);
    
    P_OUT = mxCreateDoubleMatrix(sim.frame_height,sim.frame_width,mxREAL);
    prediction = mxGetPr(P_OUT);
    
   
    int i,j,k,s,t,delta_x,delta_y; 
    int flag;
    int pos_x,pos_y,pos_z;
    int det_x,det_y;
    double current_block[64],power_block,SE_min,SE ;
    int block_cell,block_floor,block_left,block_right;
    int search_left,search_right,search_cell,search_floor;
    for(i=0;i<num_block_all;i++)
    {

        block_cell = floor(i/num_in_row)*sim.blocksize;
        block_floor = block_cell+sim.blocksize-1;
        block_left = floor(i%num_in_row)*sim.blocksize;
        block_right = block_left+sim.blocksize-1;
        
        for(j=0;j<64;j++)
        {

            delta_x=j%8;
            delta_y=j/8;
            current_block[j] =current[(delta_x+block_left)*sim.frame_height+delta_y+block_cell];
        }

        
        search_left  = max(0, block_left-sim.search_range);
        search_right = min(sim.frame_width-9, block_left+sim.search_range);
        search_cell  = max(0, block_cell-sim.search_range);
        search_floor = min(sim.frame_height-9, block_cell+sim.search_range);
       

        power_block=0;
        
        for(j=0;j<64;j++)
        {
            power_block = power_block + current_block[j]*current_block[j];
        }
        
        SE_min = min(power_block/20,10000); 
        
        pos_x = block_left;
        pos_y = block_cell;
        pos_z = 1;
        det_x=0;
        det_y=0;
        
        for (j=search_cell;j<search_floor ; j++)
        {
            for (k=search_left; k<search_right; k++)
            {
                for (s=0; s<16; s++)
                {
                    SE=0;
                    for (t=0; t<64; t++)
                    {
                        delta_x=t%8;
                        delta_y=t/8;
                        SE += (current_block[t]-last_ups[j+delta_y+720*(k+delta_x+1280*s)])*(current_block[t]-last_ups[j+delta_y+720*(k+delta_x+1280*s)]);
                    }
                    if (SE < SE_min)
                    {
                        SE_min = SE;
                        flag = 1;
                        pos_x = k;
                        pos_y = j;
                        pos_z = s;
                    }
                }
            }
        }
        
        if (flag==1)
        {
            for(j=0;j<64;j++)
            {
                delta_x=j%8;
                delta_y=j/8;
                
                prediction[delta_y+block_cell+(delta_x+block_left)*sim.frame_height] =last_ups[pos_y+delta_y+720*(pos_x+delta_x+1280*pos_z)];
                det_x = pos_z%4;
                det_y = floor((pos_z+4)/4)-1;
            }
        }
        else
        {
            for(j=0;j<64;j++)
            {
                delta_x=j%8;
                delta_y=j/8;
                prediction[delta_y+block_cell+(delta_x+block_left)*sim.frame_height]=current_block[j];
            }
        }
        
        double SE_final=0;
        for (j=0;j<64;j++)
        {
            delta_x=j%8;
            delta_y=j/8;
            SE_final += (prediction[delta_y+block_cell+(delta_x+block_left)*sim.frame_height]-current_block[j])*(prediction[delta_y+block_cell+(delta_x+block_left)*sim.frame_height]-current_block[j]);
        }
        
        motion[i+14400*0] = i;
        motion[i+14400*1] = flag;
        motion[i+14400*2] =(pos_x-block_left)*4+det_x;
        motion[i+14400*3] =(pos_y-block_cell)*4;
        motion[i+14400*4] = SE_final;
        
        if (i%num_in_row==0)
            mexPrintf("the %d ", i/num_in_row);
        if (i%(num_in_row*10) == 0)
            mexPrintf('\n');
    }
    
    
   
}

