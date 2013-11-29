This is the DWIM Perl for Linux distribution.

After unzipping the file to any directory you can already run
this version of Perl without any modification.


Let's say the installation directory is called /path/to/dir

You can run perl:

  /path/to/dir/perl/bin/perl -v


It is advisable to include the bin directory in your PATH
by addingthis line to your ~/.bashrc

  export PATH=/path/to/dir/perl/bin:$PATH


The distribution include a very limited test-suit located in the t/ directory.
You can run it by typing:

  /path/to/dir/perl/bin/perl /path/to/dir/perl/bin/prove /path/to/dir/perl/t

It will probably give you a warning:

Warning: program compiled against libxml 209 using older 207
Warning: XML::LibXML compiled against libxml2 20901, but runtime libxml2 is older 20706

to avoid this you can add the following line to ~/.bashrc

  export LD_LIBRARY_PATH=/path/to/dir/c/lib

This is not necessary if you unzipped this file in /opt


Known issues:
--------------

Besides the need of LD_LIBRARY_PATH work around (see above),
the sh-bang lines of all the scripts in the perl/bin directory
apoint to where the perl was originally compiled.
They should be relocated after unzipping this distribution.

The cpanm was installed but it is probably not working.

