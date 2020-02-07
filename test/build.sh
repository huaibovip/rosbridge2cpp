cp -r ../build/install/include ./
cp -r ../build/install/lib ./


rm -rf build
mkdir build
cd build
cmake ..
make
make install
