# download gcem if necessary and then build
if [ ! -d gcem ]; then
    git clone https://github.com/kthohr/gcem.git
fi
cd ./gcem
mkdir -p build
cd build

# generate Makefiles and install
cmake .. -DCMAKE_INSTALL_PREFIX=gcem/
make install

cd ../..


mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=./
make install
cd ..
