
# set up environment variables
PERL_VERSION=5.18.1
PERL_ZIP_FILE=perl-$PERL_VERSION.tar.gz
ROOT=/opt/dwimperl-$PERL_VERSION
PREFIX_PERL=/opt/dwimperl-$PERL_VERSION/perl
PREFIX_C=/opt/dwimperl-$PERL_VERSION/c

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
    ./Configure -des -Dprefix=$PREFIX_PERL
    make
    make test
    make install
fi

export PATH=$PREFIX_PERL/bin:$PATH
which perl
perl -v

# install cpan-minus
# gets stuck??
#cpanm --version >/dev/null 2>/dev/null
cpanm  >/dev/null 2>/dev/null
if [ $? != 1 ]; then
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
#perl Makefile.PL LIBS='-L/opt/libxml/lib/ -L/opt/zlib/lib' INC='-I/opt/libxml/include/libxml2 -I/opt/zlib/include'
#cpanm XML::LibXML
cpanm XML::LibXML --configure-args "LIBS='-L$PREFIX_C/lib/' INC='-I$PREFIX_C/include/ -I/$PREFIX_C/include/libxml2'"


