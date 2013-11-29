
# set up environment variables
PERL_VERSION=5.18.1
PERL_ZIP_FILE=perl-$PERL_VERSION.tar.gz
ROOT=/opt/dwimperl-$PERL_VERSION
PREFIX_PERL=/opt/dwimperl-$PERL_VERSION/perl
PREFIX_C=/opt/dwimperl-$PERL_VERSION/c
BUILD_HOME=`pwd`
ORIGINAL_PATH=$PATH
TEST_DIR=/opt/myperl


if [ -d $TEST_DIR ]; then
    echo $TEST_DIR already exists. Exiting!
    exit
fi

#echo $BUILD_HOME
#echo $PERL_ZIP_FILE

# install compiler
gcc --version 2>/dev/null >/dev/null
if [ ! $? ]; then
    yes | yum install gcc
fi

make --version 2>/dev/null >/dev/null
if [ ! $? ]; then
    yes | yum install make
fi


# See http://xmlsoft.org/
if [ ! -f $PREFIX_C/lib/libxml2.a ]; then
    LIBXML_VERSION=2.9.1
    wget ftp://xmlsoft.org/libxml2/libxml2-$LIBXML_VERSION.tar.gz
    tar xzf libxml2-$LIBXML_VERSION.tar.gz
    cd libxml2-$LIBXML_VERSION
    ./configure --prefix $PREFIX_C --without-python
    make
    make install
    cd $BUILD_HOME
fi

# See http://www.zlib.net/
if [ ! -f $PREFIX_C/lib/libz.a ]; then
    ZLIB_VERSION=1.2.8
    wget http://zlib.net/zlib-$ZLIB_VERSION.tar.gz
    tar xzf zlib-$ZLIB_VERSION.tar.gz 
    cd zlib-$ZLIB_VERSION
    ./configure --prefix $PREFIX_C
    make
    make install
    cd $BUILD_HOME
fi

# download and install perl
if [ ! -d $PREFIX_PERL ]; then
    if [ ! -f $PERL_ZIP_FILE ]; then
        wget http://www.cpan.org/src/5.0/$PERL_ZIP_FILE
    fi
    
    if [ !  -d perl-$PERL_VERSION ]; then
        tar xzf perl-$PERL_VERSION.tar.gz
    fi
    
    cd perl-$PERL_VERSION
    ./Configure -des -Duserelocatableinc -Dprefix=$PREFIX_PERL
    make
    make test
    make install
    cd $BUILD_HOME
fi

export PATH=$PREFIX_PERL/bin:$ORIGINAL_PATH
which perl
perl -v

# install cpan-minus
# these get stuck, so we check the existance of the file
#cpanm --version >/dev/null 2>/dev/null
#cpanm  >/dev/null 2>/dev/null
#if [ $? != 1 ]; then
if [ ! -f $PREFIX_PERL/bin/cpanm ]; then
    curl -L http://cpanmin.us | perl - App::cpanminus
fi

# install the easy modules
cpanm Test::Exception
cpanm Test::MockObject
cpanm Test::More
cpanm Test::Most
cpanm Test::NoWarnings
cpanm Test::Output
cpanm Test::Perl::Critic
cpanm Test::Pod
cpanm Test::Pod::Coverage
cpanm Test::Script
cpanm Test::WWW::Mechanize

cpanm Flickr::API
cpanm Path::Tiny
cpanm Config::Tiny
cpanm Digest::SHA
cpanm Digest::SHA1

cpanm XML::NamespaceSupport
cpanm XML::SAX

# LIBRARY_PATH
cpanm XML::LibXML --configure-args "LIBS='-L$PREFIX_C/lib/' INC='-I$PREFIX_C/include/ -I/$PREFIX_C/include/libxml2'"

if [ ! -d $ROOT/t ]; then
    cp -r $BUILD_HOME/t $ROOT
fi
prove $ROOT/t

cd '/opt';
tar czf dwimperl-$PERL_VERSION.tar.gz dwimperl-$PERL_VERSION

# testing it in another directory

mkdir $TEST_DIR
cd $TEST_DIR
tar xzf /opt/dwimperl-$PERL_VERSION.tar.gz
export PATH=$TEST_DIR/dwimperl-$PERL_VERSION/perl/bin:$ORIGINAL_PATH
prove $TEST_DIR/dwimperl-$PERL_VERSION/t
cd $BUILD_HOME
rm -rf $TEST_DIR


