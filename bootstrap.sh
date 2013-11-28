
# set up environment variables
PERL_VERSION=5.18.1
PERL_ZIP_FILE=perl-$PERL_VERSION.tar.gz
PREFIX=/opt/dwimperl-$PERL_VERSION

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


# download and install perl
if [ ! -d $PREFIX ]; then
    if [ ! -f $PERL_ZIP_FILE ]; then
        wget http://www.cpan.org/src/5.0/$PERL_ZIP_FILE
    fi
    
    if [ !  -d perl-$PERL_VERSION ]; then
        tar xzf perl-$PERL_VERSION.tar.gz
    fi
    
    cd perl-$PERL_VERSION
    ./Configure -des -Dprefix=$PREFIX
    make
    make test
    make install
fi

export PATH=$PREFIX/bin:$PATH
which perl
perl -v

# install cpan-minus
# gets stuck??
#cpanm --version >/dev/null 2>/dev/null
#cpanm  >/dev/null 2>/dev/null
#if [ $? != 1 ]; then
#    curl -L http://cpanmin.us | perl - App::cpanminus
#fi

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

