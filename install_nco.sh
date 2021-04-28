#!/bin/bash

INSTALL_PATH=`pwd`
rm -rf $INSTALL_PATH
mkdir -p $INSTALL_PATH/src

export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS='-O2 -fPIC'
export CXXFLAGS='-O2 -fPIC'
export CPPFLAGS='-O2 -fPIC'
export FFLAGS='-O2 -fPIC'
export FCFLAGS='-O2 -fPIC'

# ANTLR2
APP=antlr2
ANTLR_PATH=$INSTALL_PATH/$APP
rm -rf $ANTLR_PATH
cd $INSTALL_PATH/src
rm -rf antlr-2.7.7*
wget http://www.antlr2.org/download/antlr-2.7.7.tar.gz
tar xzf antlr-2.7.7.tar.gz ; cd antlr-2.7.7
cd lib/cpp/antlr
sed '10 a\
#include <stdio.h>\
#include <strings.h>' CharScanner.hpp > t.hpp
mv t.hpp CharScanner.hpp
cd -
./configure \
--prefix=$ANTLR_PATH \
--disable-csharp \
--disable-java \
--disable-python \
--disable-examples 2>&1 | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install


##GSL
APP=gsl
GSL_PATH=$INSTALL_PATH/$APP
rm -rf $GSL_PATH
cd $INSTALL_PATH/src
rm -rf gsl-2.4*
wget ftp://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz
#wget https://mirror.koddos.net/gnu/gsl/gsl-2.6.tar.gz
tar xzf gsl-2.4.tar.gz ; cd gsl-2.4
./configure \
--enable-shared=no \
--enable-static=yes \
--prefix=${GSL_PATH} 2>&1 | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install


# UDUNITS
APP=udunits2
UDUNITS_PATH=$INSTALL_PATH/$APP
rm -rf $UDUNITS_PATH
cd $INSTALL_PATH/src
rm -rf udunits-2.2.28*
wget ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.2.28.tar.gz
tar xzf udunits-2.2.28.tar.gz ; cd udunits-2.2.28
./configure \
--enable-shared=no \
--enable-static=yes \
--prefix=$UDUNITS_PATH 2>&1 | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install

# ZLIB
APP=zlib
ZLIB_PATH=$INSTALL_PATH/$APP
rm -rf $ZLIB_PATH
cd $INSTALL_PATH/src
rm -rf zlib-1.2.11*
wget http://www.zlib.net/zlib-1.2.11.tar.gz
tar zxf zlib-1.2.11.tar.gz ; cd zlib-1.2.11
./configure \
--prefix=$ZLIB_PATH | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install

# HDF5
APP=hdf5
HDF5_PATH=$INSTALL_PATH/$APP
rm -rf $HDF5_PATH
cd $INSTALL_PATH/src
rm -rf hdf5-1.8.16*
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.16/src/hdf5-1.8.16.tar.gz
tar xzf hdf5-1.8.16.tar.gz ; cd hdf5-1.8.16
./configure \
--prefix=$HDF5_PATH \
--enable-fortran \
--with-zlib=$ZLIB_PATH 2>&1 | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install

# NetCDF4
APP=netcdf4
NETCDF4_PATH=$INSTALL_PATH/$APP
rm -rf $NETCDF4_PATH
cd $INSTALL_PATH/src
rm -rf netcdf-4.1.3*
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz
tar xzf netcdf-4.1.3.tar.gz ; cd netcdf-4.1.3

export CPPFLAGS="-I$HDF5_PATH/include -I$ZLIB_PATH/include"
export LDFLAGS="-L$HDF5_PATH/lib -L$ZLIB_PATH/lib"

./configure \
--prefix=$NETCDF4_PATH \
--enable-fortran \
--enable-static \
--enable-shared\
--enable-f77 \
--disable-cxx \
--enable-netcdf4 \
--with-hdf5=$HDF5_PATH \
--with-zlib=$ZLIB_PATH \
--disable-dap 2>&1 | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install

# NCO
APP=nco
NCO_PATH=$INSTALL_PATH/$APP
rm -rf $NCO_PATH
cd $INSTALL_PATH/src
rm -rf nco-4.8.0*
wget https://sourceforge.net/projects/nco/files/nco-4.8.0.tar.gz
#wget https://github.com/nco/nco/archive/4.6.3.tar.gz
#cp 4.6.3.tar.gz nco-4.6.3.tar.gz
tar xzf nco-4.8.0.tar.gz ; cd nco-4.8.0
export LD_LIBRARY_PATH=$HDF5_PATH/lib:$LD_LIBRARY_PATH
export PATH=$HDF5_PATH/bin:$PATH
export LD_LIBRARY_PATH=$NETCDF4_PATH/lib:$LD_LIBRARY_PATH
export PATH=$NETCDF4_PATH/bin:$PATH
export LD_LIBRARY_PATH=$ANTLR_PATH/lib:$LD_LIBRARY_PATH
export PATH=$ANTLR_PATH/bin:$PATH
export LD_LIBRARY_PATH=$UDUNITS_PATH/lib:$LD_LIBRARY_PATH
export PATH=$UDUNITS_PATH/bin:$PATH
export LD_LIBRARY_PATH=$ZLIB_PATH/lib:$LD_LIBRARY_PATH
export PATH=$ZLIB_PATH/bin:$PATH
export LD_LIBRARY_PATH=$GSL_PATH/lib:$LD_LIBRARY_PATH
export PATH=$GSL_PATH/bin:$PATH

export NETCDF_INC=$NETCDF4_PATH/include
export NETCDF_LIB=$NETCDF4_PATH/lib
export NETCDF4_ROOT=$NETCDF4_PATH
export HDF5_LIB_DIR=$HDF5_PATH/lib
export GSL_ROOT=$GSL_PATH
export UDUNITS2_PATH=$UDUNITS_PATH
export UDUNITS_INC=${UDUNITS_PATH}/include
export UDUNITS_LIB=${UDUNITS_PATH}/lib

export LDFLAGS="-L$ANTLR_PATH/lib -lantlr -L$HDF5_PATH/lib -lhdf5_hl -lhdf5 -L$NETCDF4_PATH/lib -lnetcdff -lnetcdf -lcurl"
export CPPFLAGS="-I$HDF5_PATH/include -I$ANTLR_PATH/include"
./configure \
--prefix=$NCO_PATH \
--enable-gsl \
--enable-udunits \
--enable-udunits2 \
--disable-shared \
--enable-netcdf-4 2>&1 | tee $APP.config
make 2>&1 | tee $APP.make
make install 2>&1 | tee $APP.install


cd ../../ ; rm -rf src/
