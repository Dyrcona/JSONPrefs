# JSONPrefs

A simple perl module to load and save preferences as JSON objects.

The JSONPrefs module can read JSON formatted files and turn them into
objects for use in storing and retrieving application preferences.
There are many ways of achieving this but I wanted something quick and
simple and this module was the result.  This module is not intended to
be a replacement for Config::JSON or other, more sophisticated,
modules.

This module is intended to be used on a file containing an anonymous
JSON object that gets converted to a HASHREF in Perl.  This object can
have fields that are any valid JSON data type.

## Examples

    use JSONPrefs;
    my $prefs = JSONPrefs->load('prefs.json');
    my $frobulate = $prefs->frobulate;
    ... Do something with $frobulate. ...
    $prefs->frobulate($frobulate);

Or to create a new, empty set of prefs for saving:

    my $prefs = JSONPrefs->new();
    my $frobulate = { frequency => 60, amplitude => 40};
    $prefs->set('frobulate', $frobulate);
    $prefs->save('frobulate.json');

Or, if you'd like the output to be human readable:

    my $prefs = JSONPrefs->new(1);
    my $frobulate = { frequency => 60, amplitude => 40};
    $prefs->set('frobulate', $frobulate);
    $prefs->save('frobulate.json');

## Installation

To install, simply run

    perl Makefile.PL
    make
    make install

There currently are no tests.

## Author

Jason Stephenson <jason@sigio.com>

## License

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

