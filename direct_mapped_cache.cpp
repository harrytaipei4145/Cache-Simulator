#include <iostream>
#include <stdio.h>
#include <math.h>
#include <bitset>

using namespace std;

struct cache_content{
	bool v;
	unsigned int  tag;
//	unsigned int	data[16];    
	int time=999;
};

const int K=1024;

double log2( double n )  
{  
    // log(n)/log(2) is log2.  
    return log( n ) / log(double(2));  
}


void simulate(int cache_size, int block_size){
	unsigned int tag,index,x;

	int offset_bit = (int) log2(block_size);//5
	int index_bit = (int) log2(cache_size/block_size);//1
	int line= cache_size>>(offset_bit);//
	cout << offset_bit << " " << index_bit<<" "<<hex<<cache_size;
	cache_content *cache =new cache_content[line];
	cout<<"cache line:"<<line<<endl;

	for(int j=0;j<line;j++)
		cache[j].v=false;
	
	
  FILE * fp=fopen("ICACHE.txt","r");					//read file
  double sum = 0;
double n = 0;
	while(fscanf(fp,"%x",&x)!=EOF){

		//cout<<hex<<x<<" ";
		index=(x>>offset_bit)&(line-1);
		tag=x>>(index_bit+offset_bit);
		if(cache[index].v && cache[index].tag==tag){
			cache[index].v=true;
			sum++;//hit
		}
	else{						
			cache[index].v=true;			//miss
			cache[index].tag=tag;
			n++;
			sum++;
		}
	}
	fclose(fp);
	

	cout << "\n" << n / sum << endl;
	delete [] cache;
}
	
int main(){
	// Let us simulate 4KB cache with 16B blocks

	simulate(64, 32);
	

	system("pause");
}


