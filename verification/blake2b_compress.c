#include "blake2b.h"
#include "stdio.h"

static inline uint64_t rotr64( const uint64_t w, const unsigned c )
{
  return ( w >> c ) | ( w << ( 64 - c ) );
}


#define G(r,i,a,b,c,d)                      \
  do {                                      \
    a = a + b + m[blake2b_sigma[r][2*i+0]]; \
    d = rotr64(d ^ a, 32);                  \
    c = c + d;                              \
    b = rotr64(b ^ c, 24);                  \
    a = a + b + m[blake2b_sigma[r][2*i+1]]; \
    d = rotr64(d ^ a, 16);                  \
    c = c + d;                              \
    b = rotr64(b ^ c, 63);                  \
  } while(0)


#define display()                   \
  do{                               \
    for (size_t i = 0; i < 16; i++) \
    {                               \
      printf("%lx\n",v[i]);         \
    }                               \
    printf("\n");                   \
  } while (0)                

#define ROUND(r)                    \
  do {                              \
    G(r,0,v[ 0],v[ 4],v[ 8],v[12]); \
    G(r,1,v[ 1],v[ 5],v[ 9],v[13]); \
    G(r,2,v[ 2],v[ 6],v[10],v[14]); \
    G(r,3,v[ 3],v[ 7],v[11],v[15]); \
    G(r,4,v[ 0],v[ 5],v[10],v[15]); \
    G(r,5,v[ 1],v[ 6],v[11],v[12]); \
    G(r,6,v[ 2],v[ 7],v[ 8],v[13]); \
    G(r,7,v[ 3],v[ 4],v[ 9],v[14]); \
  } while(0)

static void blake2b_compress( blake2b_state *S )
{
  uint64_t m[16];
  uint64_t v[16];
  size_t i;

  for( i = 0; i < 8; ++i ) {
    v[i] = S->h[i];
  }
  for ( i = 0; i < 16; i++)
  {
      m[i] = i*100000;
  }
  

  v[ 8] = blake2b_IV[0];
  v[ 9] = blake2b_IV[1];
  v[10] = blake2b_IV[2];
  v[11] = blake2b_IV[3];
  v[12] = blake2b_IV[4] ^ S->t[0];
  v[13] = blake2b_IV[5] ^ S->t[1];
  v[14] = blake2b_IV[6] ^ S->f[0];
  v[15] = blake2b_IV[7] ^ S->f[1];



  ROUND( 0 );
  ROUND( 1 );
  ROUND( 2 );
  ROUND( 3 );
  ROUND( 4 );
  ROUND( 5 );
  ROUND( 6 );
  ROUND( 7 );
  ROUND( 8 );
  ROUND( 9 );
  ROUND( 10 );
  ROUND( 11 );

  for( i = 0; i < 8; ++i ) {
    S->h[i] = S->h[i] ^ v[i] ^ v[i + 8];
  }
}

int main(int argc, char const *argv[])
{
    blake2b_state state;
    state.f[0] = 100000;
    state.f[1] = 200000;
    state.t[0] = 300000;
    state.t[1] = 500000;

    for (size_t i = 0; i < 8; i++)
    {
        state.h[i] = i*100000;
    }
    
    blake2b_compress(&state);

    for (size_t j = 0; j < 8; j++)
    {
        printf("%lx\n",state.h[j]);
    }
    return 0;
}
