#include <iostream>
using namespace std;


class MatMulUniversal {
    public:
    

  // Reads out a matrix of prespecified dimension from a byte stream.
  int[][] importMatrixBinary(DataInput sc, int height, int width) {
    int A[][] = new int[height][width];
    for (int i=0; i<height; ++i) {
      for (int j=0; j<width; ++j) {
        A[i][j] = sc.readByte();
        A[i][j] += sc.readByte() << 8;
        A[i][j] += sc.readByte() << 16;
        A[i][j] += sc.readByte() << 24;
      }
    }
    return A;
  }

  // A pseudo-hash for matrices.
  char jumpTrace(int[][] m) {
    int w = m[0].length;
    int h = m.length;
    int iterations = w*h;
    int x=0, y=0;
    int acc=1;
    for (int i=0; i<iterations; ++i) {
      acc = (acc*m[y][x] + 1) % (w*h);
      y = acc % h;
      x = (acc*m[y][x]) % w;
    }
    return (char) (((int) 'a') + acc%26);
  }
  
};

int main() {
  int l = 300;
  int n = 50;
  int m = 500;

    int A[l][n];
    int B[n][m];

    DataInput input = new DataInputStream(System.in);
    A = importMatrixBinary(input, l,n);
    B = importMatrixBinary(input, n,m);

    int C[][] = new int[l][m];
    for (int i=0; i<l; ++i) {
      for (int j=0; j<m; ++j) {
        int acc = 0;
        for (int k=0; k<n; ++k) {
          acc += A[i][k] * B[k][j];
        }
        C[i][j] = acc;
      }
    }
    cout <<(jumpTrace(C));

    return 0;
}