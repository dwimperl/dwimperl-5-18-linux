#!/bin/sh -e

echo set up environment variables
PERL_VERSION=5.18.1
SUBVERSION=1
ARCHITECTURE=`uname -i`

PERL_SOURCE_VERSION=perl-$PERL_VERSION
PERL_SOURCE_ZIP_FILE=$PERL_SOURCE_VERSION.tar.gz

DWIMPERL_VERSION=dwimperl-$PERL_VERSION-$SUBVERSION-$ARCHITECTURE
ROOT=/opt/$DWIMPERL_VERSION
PREFIX_PERL=/opt/$DWIMPERL_VERSION/perl
PREFIX_C=/opt/$DWIMPERL_VERSION/c

BUILD_HOME=`pwd`
ORIGINAL_PATH=$PATH
TEST_DIR=/opt/myperl
BACKUP=/opt/dwimperl

echo "export PATH=$PREFIX_PERL/bin:\$PATH" > setpath

if [ -d $TEST_DIR ]; then
    echo $TEST_DIR already exists. Exiting!
    exit
fi

#echo $BUILD_HOME
#echo $PERL_SOURCE_ZIP_FILE

# install compiler
# gcc and make are needed for Perl
# cmake is needed for MySQL

for tool in gcc make cmake; do
    echo "Checking $tool"
    $tool --version || {
        echo "Installing $tool"
        yes | yum install $tool || { echo "Could not install $tool"; exit 1; }
    }
done

mkdir -p PREFIX_C

# download and install perl
if [ ! -d $PREFIX_PERL ]; then
    if [ ! -f $PERL_SOURCE_ZIP_FILE ]; then
        wget http://www.cpan.org/src/5.0/$PERL_SOURCE_ZIP_FILE
    fi
    
    if [ !  -d $PERL_SOURCE_VERSION ]; then
        tar xzf $PERL_SOURCE_ZIP_FILE
        #$PERL_SOURCE_VERSION.tar.gz
    fi
    
    cd $PERL_SOURCE_VERSION
    ./Configure -des -Duserelocatableinc -Dprefix=$PREFIX_PERL
    make
    make test
    make install
    cd $BUILD_HOME
fi

export PATH=$PREFIX_PERL/bin:$ORIGINAL_PATH
which perl
perl -v



# libxml2 and zlib are needed for XML::LibXML
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


# http://www.openssl.org/
# openssl is needed by Net::SSLEay which is needed by LWP::Protocol::https
if [ ! -f $PREFIX_C/lib/libssl.a ]; then
    wget http://www.openssl.org/source/openssl-1.0.1e.tar.gz
    tar xzf openssl-1.0.1e.tar.gz
    cd openssl-1.0.1e
    
    # instead of patching broken PODs that cause "make install" to fail
    #perl -i -p -e 's/^=item \d/=item */' doc/apps/cms.pod doc/apps/smime.pod
    #perl -i -p -e 'print "=back\n\n" if $.==281' doc/crypto/X509_STORE_CTX_get_error.pod
    # ... more patching is needed
    # we just remove them:
    rm -rf doc
    mkdir doc
    mkdir doc/apps
    mkdir doc/crypto
    mkdir doc/ssl
    cp $BUILD_HOME/empty.pod doc/apps/
    cp $BUILD_HOME/empty.pod doc/crypto/
    cp $BUILD_HOME/empty.pod doc/ssl/
    ./config --prefix=/opt/dwimperl-5.18.1-1-x86_64/c/ -fPIC
    make
    make test
    make install
fi



# MYSQL_VERSION=mysql-5.6.14
# wget http://dev.mysql.com/get/Downloads/MySQL-5.6/$MYSQL_VERSION.tar.gz
# tar xzf $MYSQL_VERSION.tar.gz
# cd $MYSQL_VERSION
# cmake .

# install cpan-minus
# these get stuck, so we check the existance of the file
#cpanm --version >/dev/null 2>/dev/null
#cpanm  >/dev/null 2>/dev/null
#if [ $? != 1 ]; then
if [ ! -f $PREFIX_PERL/bin/cpanm ]; then
    curl -L http://cpanmin.us | perl - App::cpanminus
fi

# install the easy modules
cpanm Test::Deep
cpanm Test::Exception
cpanm Test::Fatal
cpanm Test::Memory::Cycle
cpanm Test::MockObject
cpanm Test::More
cpanm Test::Most
cpanm Test::NoWarnings
cpanm Test::Output
cpanm Test::Perl::Critic
cpanm Test::Pod
cpanm Test::Pod::Coverage
cpanm Test::Requires
cpanm Test::Script
cpanm Test::WWW::Mechanize

cpanm App::Ack
#cpanm App::Nopaste  (dependency WWW::Pastebin::PastebinCom::Create is missing)
cpanm Flickr::API
cpanm Path::Tiny
#cpanm Cache   (DB_File is not installed)
cpanm Cache::Memcached::Fast
cpanm Catalyst
cpanm Carp::Always
cpanm Config::Tiny
cpanm Config::Any
cpanm Config::General
cpanm Config::Tiny
cpanm Date::Tiny
cpanm DateTime
cpanm DateTime::Tiny

cpanm Digest::SHA
cpanm Digest::SHA1
cpanm DBI
cpanm DBIx::Class
cpanm DBIx::Connector
cpanm DBD::SQLite
#cpanm DBD::mysql
cpanm Daemon::Control

cpanm Dancer2

cpanm Email::MIME::Kit
cpanm Email::Sender
cpanm Email::Simple

cpanm IO::Socket::INET6
cpanm Socket6
cpanm --notest Net::DNS  # prereq of Email::Valid and test fails
cpanm Email::Valid
cpanm Excel::Writer::XLSX

cpanm HTML::Entities
cpanm HTML::TableExtract
cpanm HTML::Template
cpanm HTTP::Lite
cpanm HTTP::Request
cpanm HTTP::Tiny


cpanm JSON

#OPENSSL_PREFIX=$PREFIX_C cpanm Net::SSLeay
#cpanm LWP::Protocol::https
cpanm LWP::UserAgent
cpanm LWP::UserAgent::Determined

cpanm Moo
cpanm MooX::Options
cpanm MooX::late
cpanm MooX::Singleton

cpanm Mojolicious
cpanm Moose
cpanm Net::Server
cpanm IO::Compress::Gzip
cpanm IO::Uncompress::Gunzip

# cpanm PAR::Packer failed
cpanm Plack
cpanm Plack::Middleware::Debug
cpanm Plack::Middleware::LogErrors
cpanm Plack::Middleware::LogWarn
cpanm POE

cpanm Starman
cpanm Storable
cpanm Spreadsheet::ParseExcel::Simple
cpanm Spreadsheet::WriteExcel
cpanm Spreadsheet::WriteExcel::Simple
cpanm Template
cpanm Term::ProgressBar::Simple
cpanm Text::CSV_XS
cpanm Time::HiRes
cpanm Time::ParseDate
cpanm Time::Tiny
cpanm Try::Tiny

cpanm Log::Contextual
cpanm Log::Dispatch
cpanm Log::Log4perl

cpanm XML::NamespaceSupport
cpanm XML::SAX

cpanm YAML

# LIBRARY_PATH
cpanm XML::LibXML --configure-args "LIBS='-L$PREFIX_C/lib/' INC='-I$PREFIX_C/include/ -I/$PREFIX_C/include/libxml2'"

cp $BUILD_HOME/README.txt $ROOT
if [ ! -d $ROOT/t ]; then
    cp -r $BUILD_HOME/t $ROOT
fi
prove $ROOT/t

cd '/opt';
tar czf $DWIMPERL_VERSION.tar.gz $DWIMPERL_VERSION

# testing it in another directory
mv $ROOT $BACKUP

mkdir $TEST_DIR
cd $TEST_DIR
tar xzf /opt/$DWIMPERL_VERSION.tar.gz
export PATH=$TEST_DIR/$DWIMPERL_VERSION/perl/bin:$ORIGINAL_PATH

# TODO: replace the sh-bang in all the files after relocation
# otherwise this will not work:
# prove $TEST_DIR/$DWIMPERL_VERSION/t

# Convince perl to look for the libxml2 files in the directory relative to its location
# Warning: program compiled against libxml 209 using older 207
# Warning: XML::LibXML compiled against libxml2 20901, but runtime libxml2 is older 20706

LD_LIBRARY_PATH=$TEST_DIR/$DWIMPERL_VERSION/c/lib perl $TEST_DIR/$DWIMPERL_VERSION/perl/bin/prove $TEST_DIR/$DWIMPERL_VERSION/t
cd $BUILD_HOME
rm -rf $TEST_DIR

mv $BACKUP $ROOT


# Read: http://www.davidpashley.com/articles/writing-robust-shell-scripts/

