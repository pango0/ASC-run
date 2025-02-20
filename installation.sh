#!/bin/bash
set -e  

if [[ -z "$CONDA_PREFIX" ]]; then
    echo "Error: Please 'conda activate asc' first!"
    exit 1
fi

CONDA_BIN_DIR="$CONDA_PREFIX/bin"

echo "Installing HISAT-3N..."

git clone https://github.com/DaehwanKimLab/hisat2.git hisat-3n
cd hisat-3n
git checkout -b hisat-3n origin/hisat-3n

make -j$(nproc) \
    CFLAGS="-O3 -march=native -mtune=native -flto -fopenmp -mavx2 -I$CONDA_PREFIX/include" \
    CPPFLAGS="-I$CONDA_PREFIX/include" \
    LDFLAGS="-L$CONDA_PREFIX/lib"

mkdir -p $CONDA_PREFIX/bin
cp -r hisat-3n* $CONDA_PREFIX/bin/
cp -r hisat2* $CONDA_PREFIX/bin/

chmod +x $CONDA_PREFIX/bin/hisat-3n*
chmod +x $CONDA_PREFIX/bin/hisat2*

cd ..
rm -rf hisat-3n

echo "HISAT-3N installation completed successfully!"
