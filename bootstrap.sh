PERL_VERSION=5.18.1
PERL_ZIP_FILE=perl-$PERL_VERSION.tar.gz
PREFIX=/opt/dwimperl-$PERL_VERSION

echo $PERL_ZIP_FILE

yes | yum install gcc
yes | yum install make

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
    make install
fi
export PATH=$PREFIX/bin:$PATH
which perl
perl -v


