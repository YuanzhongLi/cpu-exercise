#include <stdio.h>

short array[ 4096 ];

void sort( int size )
{
	int i, j;
	for( i = 0; i < size; i++ ){
		for( j = size-1; j >= 1; j-- ) {
			if ( array[j] < array[j-1] ) {
				int tmp = array[j];
				array[j] = array[j-1];
				array[j-1] = tmp;
			}
		}
	}
}

int main( int argc, char* argv[] )
{
	int i;
	int size = 8;

	array[ 0 ] = 5;
	array[ 1 ] = 9;
	array[ 2 ] = 1;
	array[ 3 ] = 4;
	array[ 4 ] = 3;
	array[ 5 ] = 2;
	array[ 6 ] = 0;
	array[ 7 ] = 8;

	sort( size );

	for( i = 0; i < size; i++ ){
		printf( "%d\n", array[ i ] );
	}

	return 0;
}


