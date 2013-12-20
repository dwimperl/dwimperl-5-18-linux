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


cpanm="$PREFIX_PERL/bin/cpanm --mirror-only --mirror https://stratopan.com/szabgab/dwimperl/master"

function mycpan {
    echo '>>>>>>>' Installing from CPAN: $@
	$cpanm --notest $@
}


echo "export PATH=$PREFIX_PERL/bin:\$PATH" > setpath

if [ -d $TEST_DIR ]; then
    echo $TEST_DIR already exists. Exiting!
    exit
fi

echo $PREFIX_PERL
echo $cpanm

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

mkdir -p $PREFIX_C

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
if [ ! -f $PREFIX_PERL/bin/perl ]; then
    echo "Perl was not installed"
    exit 1
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
if [ ! -f $PREFIX_C/lib/libxml2.a ]; then
    echo "libxml2 not installed"
    exit 1
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
if [ ! -f $PREFIX_C/lib/libz.a ]; then
    echo "zlib not installed"
    exit 1
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
    ./config --prefix=$PREFIX_C -fPIC
    make
    make test
    make install
fi
if [ ! -f $PREFIX_C/lib/libssl.a ]; then
    echo "openssl not installed"
    exit 1
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

if [ "$1" != "" ]; then
    for name in $@; do
        mycpan $name
    done
    exit;
fi


# install the easy modules
mycpan Test::Deep
mycpan Test::Exception
mycpan Test::Fatal
mycpan Test::Memory::Cycle
mycpan Test::MockObject
mycpan Test::More
mycpan Test::Most
mycpan Test::NoWarnings
mycpan Test::Output
mycpan Test::Perl::Critic
mycpan Test::Pod
mycpan Test::Pod::Coverage
mycpan Test::Requires
mycpan Test::Script
mycpan Test::WWW::Mechanize

mycpan App::Ack
#mycpan App::Nopaste  (dependency WWW::Pastebin::PastebinCom::Create is missing)
mycpan Flickr::API
mycpan Path::Tiny
#mycpan Cache   (DB_File is not mycpaned)
mycpan Cache::Memcached::Fast
mycpan Catalyst
mycpan Carp::Always
mycpan Config::Any
mycpan Config::General
mycpan Config::Tiny
mycpan Date::Tiny
mycpan DateTime
mycpan DateTime::Tiny

mycpan Digest::SHA
mycpan Digest::SHA1
mycpan DBI
mycpan DBIx::Class
mycpan DBIx::Connector
mycpan DBD::SQLite
#mycpan DBD::mysql
mycpan Daemon::Control

mycpan Dancer2

mycpan Email::MIME::Kit
mycpan Email::Sender
mycpan Email::Simple

mycpan IO::Socket::INET6
mycpan Socket6
mycpan Net::DNS
mycpan Email::Valid
mycpan Excel::Writer::XLSX

mycpan HTML::Entities
mycpan HTML::TableExtract
mycpan HTML::Template
mycpan HTTP::Lite
mycpan HTTP::Request
mycpan HTTP::Tiny


mycpan JSON
 
OPENSSL_PREFIX=$PREFIX_C mycpan Net::SSLeay
mycpan Business::PayPal
mycpan LWP::Protocol::https
mycpan LWP::UserAgent
mycpan LWP::UserAgent::Determined
 
mycpan Moo
mycpan MooX::Options
mycpan MooX::late
mycpan MooX::Singleton


# POE-1.358  failed
# mycpan POE

mycpan Mojolicious
mycpan Moose
# list taken from Task::Moose
mycpan MooseX::StrictConstructor
mycpan MooseX::Params::Validate
mycpan MooseX::Role::TraitConstructor
mycpan MooseX::Traits
mycpan MooseX::Object::Pluggable
mycpan MooseX::Role::Parameterized
mycpan MooseX::GlobRef
mycpan MooseX::InsideOut
mycpan MooseX::Singleton
mycpan MooseX::NonMoose
mycpan MooseX::Declare
mycpan MooseX::Method::Signatures
mycpan TryCatch
mycpan MooseX::Types
mycpan MooseX::Types::Structured
mycpan MooseX::Types::Path::Class
mycpan MooseX::Types::Set::Object
mycpan MooseX::Types::DateTime
mycpan MooseX::Getopt
mycpan MooseX::ConfigFromFile
mycpan MooseX::SimpleConfig
mycpan MooseX::App::Cmd
mycpan MooseX::Role::Cmd
mycpan MooseX::LogDispatch
mycpan MooseX::LazyLogDispatch
mycpan MooseX::Log::Log4perl
# mycpan MooseX::POE
# mycpan MooseX::Workers depends on POE
mycpan MooseX::Daemonize
mycpan MooseX::Param
mycpan MooseX::Iterator
mycpan MooseX::Clone
mycpan MooseX::Storage
#???  mycpan Moose::Autobox
mycpan MooseX::ClassAttribute
mycpan MooseX::SemiAffordanceAccessor
mycpan namespace::autoclean
mycpan Pod::Coverage::Moose

# Net::Server 2.007 failed: https://rt.cpan.org/Public/Bug/Display.html?id=91523
mycpan --notest Net::Server
mycpan IO::Compress::Gzip
mycpan IO::Uncompress::Gunzip

# mycpan PAR::Packer failed
mycpan Plack
mycpan Plack::Middleware::Debug
mycpan Plack::Middleware::LogErrors
mycpan Plack::Middleware::LogWarn

# CGI::FormBuilder: lots of warnings like this:
# /bin/tar: Ignoring unknown extended header keyword `SCHILY.ino'
#### mycpan CGI::FormBuilder
mycpan CGI::FormBuilder::Source::Perl
# mycpan XML::RSS needs XML::Parser
# mycpan XML::Atom needs XML::Parser
mycpan MIME::Types
mycpan WWW::Mechanize
mycpan WWW::Mechanize::TreeBuilder
mycpan DBIx::Class::Schema::Loader
mycpan Dist::Zilla
mycpan Perl::Tidy
mycpan Perl::Critic
mycpan Modern::Perl
mycpan Perl::Version
mycpan Software::License
mycpan CHI

mycpan Text::Xslate

mycpan Starman
mycpan Storable
mycpan Spreadsheet::ParseExcel::Simple
mycpan Spreadsheet::WriteExcel
mycpan Spreadsheet::WriteExcel::Simple
mycpan Template
mycpan Term::ProgressBar::Simple
mycpan Text::CSV
mycpan Text::CSV_XS
mycpan Time::HiRes
mycpan Time::ParseDate
mycpan Time::Tiny
mycpan Try::Tiny

mycpan Log::Contextual
mycpan Log::Dispatch
mycpan Log::Log4perl

mycpan XML::NamespaceSupport
mycpan XML::SAX
 
mycpan YAML
 
# LIBRARY_PATH
echo ">>>>>> installing XML::LibXML"
$cpanm XML::LibXML --configure-args "LIBS='-L$PREFIX_C/lib/' INC='-I$PREFIX_C/include/ -I/$PREFIX_C/include/libxml2'"

# XML::Parser need expat http://sourceforge.net/projects/expat/

if [ ! -f $PREFIX_C/lib/libexpat.a ]; then
    EXPAT=expat-2.1.0
    wget http://downloads.sourceforge.net/project/expat/expat/2.1.0/$EXPAT.tar.gz
    tar xzf $EXPAT.tar.gz
    cd $EXPAT
    ./configure --prefix $PREFIX_C
    make
    make install
fi
# If you ever happen to want to link against installed libraries
# in a given directory, LIBDIR, you must either use libtool, and
# specify the full pathname of the library, or use the `-LLIBDIR'
# flag during linking and do at least one of the following:
#    - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
#      during execution
#    - add LIBDIR to the `LD_RUN_PATH' environment variable
#      during linking
#    - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
#    - have your system administrator add LIBDIR to `/etc/ld.so.conf'
# 
# See any operating system documentation about shared libraries for
# more information, such as the ld(1) and ld.so(8) manual pages.

#mycpan XML::Parser --configre-args = "EXPATLIBPATH=$PREFIX_C/lib EXPATINCPATH=$PREFIX_C/include"

#  mycpan XML::SAX::Writer
#  # mycpan XML::Simple needs XML::Parser
#  # mycpan XML::XPath  needs XML::Parser

mycpan Acme::MetaSyntactic
mycpan DBIx::RunSQL
mycpan Hash::Merge::Simple
#mycpan Geo::IP
#mycpan Dancer
#mycpan MIME::Lite

# Finished installing Perl modules, let's test now and create the tarball


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

