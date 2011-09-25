package MooseX::TrackDirty::Attributes;

# ABSTRACT: Track dirtied attributes

use warnings;
use strict;

use Moose 2.0 ();
use namespace::autoclean;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ 'MooseX::TrackDirty::Attributes::Trait::Attribute' => 'TrackDirty' ],
    ],
);

!!42;

__END__

=head1 SYNOPSIS

    package Foo;
    use Moose;
    use MooseX::TrackDirty::Attributes;

    # tracking accessor is not automagically applied
    has foo => (is => 'rw');

    # one_is_dirty() is generated by default
    has one => (traits => [ TrackDirty ], is => 'rw');

    # dirtyness "accessor" is generated as two_isnt_clean()
    has two      => (
        traits   => [ TrackDirty ],
        is       => 'rw',
        is_dirty => 'two_isnt_clean',
    );

    # three_is_dirty() and original_value_of_three() are generated
    has three => (
        traits         => [ TrackDirty ],
        is             => 'rw',
        original_value => 'original_value_of_three',
    );

    # ...meanwhile, at the bat-cave

    package main;
    my $foo = Foo->new();

    $foo->one_is_dirty; # false

=head1 DESCRIPTION

MooseX::TrackDirty::Attributes does the necessary metaclass fiddling to track
if attributes are dirty; that is, if they're set to some value and then set
again, to another value.  (The setting can be done by the constructor,
builder, default, accessor, etc.)

An attribute can be returned to a clean state by invoking its clearer.

=head1 WARNING!

Note that the API used here is incompatible with the previous version.
Sorry about that :\

=head1 CAVEAT

Note that with few exceptions we can only track
dirtiness at the very first level.  That is, if you have an attribute that is
a HashRef, we can tell that the _attribute_ is dirty iff the actual ref
changes, but not if the HashRef's keys/values change. e.g.
$self->hashref({ new => 'hash' }) would render the 'hashref' attribute dirty,
but $self->hashref->{foo} = 'bar' would not.

In plainer language: we can only tell if an attribute's value is dirty if our
accessors are used to modify its values.

=head1 ATTRIBUTE OPTIONS

To track a given attribute, the trait must be applied.  This package exports a
"TrackDirty" function that returns the full (ridiculously long) package nameof
the trait.

Once applied, we have two additional options that can be passed to the
attribute constructor (usually via 'has'):

=over 4

=item is_dirty => method_name

is_dirty controls what the name of the "is this attribute's value dirty?"
accessor is (returning true on dirty; false otherwise):

By default, the accessor is installed as "{attribute_name}_is_dirty";

If a legal method name is passed, the accessor is installed under that name;

Otherwise we blow up.

=item original_value => method_name

original_value controls what the name for the original value accessor is
installed (returns the original value if dirty, undef otherwise):

By default, we do not install an original_value accessor;

If a legal method name is passed, the accessor is installed under that name;

Otherwise we blow up.

=back

=cut
