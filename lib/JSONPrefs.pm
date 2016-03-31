package JSONPrefs;

use strict;
use warnings;

=head1 NAME

JSONPrefs -  A simple perl module to load and save preferences as JSON objects.

=head1 SYNOPSIS

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

=head1 DESCRIPTION

The JSONPrefs module can read JSON formatted files and turn them into
objects for use in storing and retrieving application preferences.
There are many ways of achieving this but I wanted something quick and
simple and this module was the result.

=cut

BEGIN {
    use Carp;
    use JSON;
    use Scalar::Util qw/blessed/;
    use vars qw/$AUTOLOAD/;
    our $VERSION = '1.01';
}

=head2 METHODS

=over

=item C<new>

Create a new, empty JSONPrefs object.

=cut

sub new {
    my $class = shift;
    my $self = {};
    $self->{':pretty:'} = shift;
    $self->{':file:'} = undef;
    $self->{':prefs:'} = {};
    bless $self, $class;
    return $self;
}

=item C<load>

Load preferences from a JSON file.  Since we are a blessed hashref, we
expect the JSON file to contain a JSON object.  If called as a class
method, creates a new prefs object.  If called as an instance method,
replaces C<$self> with the loaded data.

=cut

sub load {
    my $class_or_self = shift;
    my $file = shift;
    croak("No filename supplied") unless (defined($file));

    my $self = undef;

    my $content;
    if (open(FILE, "<:utf8", "$file")) {
        while (my $line = <FILE>) {
            $content .= $line;
        }
        close(FILE);
    }

    if ($content) {
        if (blessed($class_or_self)) {
            $self = $class_or_self;
        } else {
            $self = $class_or_self->new();
        }
        $self->{':file:'} = $file;
        $self->{':prefs:'} = decode_json($content);
    }

    return $self;
}

=item C<pretty>

Get or set whether or not we pretty print when saving.

=cut

sub pretty {
    my $self = shift;
    if (@_) {
        $self->{':pretty:'} = shift;
    }
    return $self->{':pretty:'};
}

=item C<save>

Write the preference data to a named file.

=cut

sub save {
    my $self = shift;
    my $file = shift || $self->{':file:'};
    if ($file && open(FILE, ">:utf8", "$file")) {
        my $pretty = 0;
        # Check if $self->{':pretty:'} is defined && true selon perl.
        $pretty = 1 if (defined($self->{':pretty:'}) && $self->{':pretty:'});
        my $content = JSON->new()->allow_blessed(1)->convert_blessed(1)
            ->pretty($pretty)->encode($self->{':prefs:'});
        print(FILE "$content\n");
        close(FILE);
        $self->{':file:'} = $file;
        return 1;
    } else {
        carp("No file to save to!");
    }
    return 0;
}

=item C<fields>

Return an array of the fields in the preferences object.  This does
not iterate through subobjects at the moment, it only does the first
level of fields.

=cut

sub fields {
    my $self = shift;
    my @fields = ();
    foreach my $key (keys %{$self->{':prefs:'}}) {
        push(@fields, $key);
    }
    return @fields;
}

=item C<get>

Get the value of a field.  You can use this method to get the value of
a preference field whose name matches another JSONPrefs method.

=cut

sub get {
    my $self = shift;
    my $field = shift;
    if (ref($self->{':prefs:'}->{$field}) eq 'HASH'
            && !blessed($self->{':prefs:'}->{$field})) {
        my $temp->{':prefs:'} = $self->{':prefs:'}->{$field};
        bless($temp, blessed($self));
        $self->{':prefs:'}->{$field} = $temp;
    }
    return $self->{':prefs:'}->{$field};
}

=item C<set>

Set the value of a field.  You can use this method to set the value of
a preference field whose name matches another JSONPrefs method.

=cut

sub set {
    my $self = shift;
    my $field = shift;
    return $self->{':prefs:'}->{$field} = shift;
}

# Use field names like methods.  Also blesses any hashref members to
# return them as JSONPrefs objects.
sub AUTOLOAD {
    my $self = shift;
    my $type = ref ($self) || croak "$self is not an object";
    my $field = $AUTOLOAD;
    $field =~ s/.*://;
    if (@_) {
        return $self->set($field, @_);
    } else {
        return $self->get($field);
    }
}

=item C<TO_JSON>

Used by JSON to convert blessed JSONPrefs back into hashrefs.  You can
use it whenever you need to pass a JSON object to a perl subroutine
that expects a regular hashref.

=cut

sub TO_JSON {
    my $self = shift;
    return {%{$self->{':prefs:'}}};
}

=back

=head1 AUTHOR

Jason Stephenson E<lt>jason@sigio.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2012,2013 Merrimack Valley Library Consortium

Copyright 2012,2016 Jason Stephenson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

1;
