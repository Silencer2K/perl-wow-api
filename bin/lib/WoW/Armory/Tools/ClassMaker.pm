package WoW::Armory::Tools::ClassMaker;

use strict;
use warnings;

use JSON::XS;
use Hash::Merge qw(merge);
use List::Util qw(max);

sub read_file {
    local $/;
    open FH, shift;
    my $ret = <FH>;
    close FH;
    return $ret;
}

sub parse_hash {
    my ($self, $json, $class) = @_;

    $self->{list}{$class} = 1;

    for my $key (keys %$json) {
        my $value = $json->{$key};
        my $ref = ref $value;

        my $subclass = $class.'::'.ucfirst($key);

        $subclass = $self->{classmap}{$subclass} || $subclass;

        if (!$ref || $ref eq 'JSON::XS::Boolean') {
            $self->{defines}{$class}{fields}{$key} = 1;
        }
        elsif ($ref eq 'HASH') {
            $self->{defines}{$class}{blessed}{$key} = $subclass;
            $self->parse_hash($value, $subclass);
        }
        elsif ($ref eq 'ARRAY') {
            $self->{defines}{$class}{fields}{$key} = 1
                if !$self->{defines}{$class}{list}{$key};

            for my $value_2 (@$value) {
                if (ref $value_2 eq 'HASH') {
                    $self->{defines}{$class}{list}{$key} = $subclass;
                    $self->parse_hash($value_2, $subclass);

                    delete $self->{defines}{$class}{fields}{$key};
                }
            }
        }
    }
}

sub find_duplicate {
    my ($self, $class) = @_;

    my $check = join(';',
        join(',', sort keys %{$self->{defines}{$class}{fields}}),
        join(',', sort keys %{$self->{defines}{$class}{blessed}}),
        join(',', sort keys %{$self->{defines}{$class}{list}}),
    );

    if ($self->{check}{$check}) {
        print STDERR "$class looks like $self->{check}{$check}\n";
    }
    else {
        $self->{check}{$check} = $class;
    }
}

sub output_class {
    my ($self, $class) = @_;

    open FH, ">$self->{output}/$class.pm";

    print FH "package $self->{namespace}::$class;\n\n";
    print FH "use strict;\n";
    print FH "use warnings;\n\n";

    my @subclasses = grep {/^${class}::/} sort keys %{$self->{list}};
    my @pkgs;

    for my $subclass (@subclasses) {
        push @pkgs, values %{$self->{defines}{$subclass}{blessed}||{}};
        push @pkgs, values %{$self->{defines}{$subclass}{list}||{}};
    }

    @pkgs = grep { $_ ne $class } map { s/::.+$//; $_ } @pkgs;

    if (@pkgs) {
        @pkgs = sort keys %{{map {$_ => 1} @pkgs}};

        if (@pkgs) {
            print FH "use $self->{namespace}::$_;\n" for @pkgs;
            print FH "\n";
        }
    }

    for my $subclass (reverse sort @subclasses, $class) {
        print FH "#"x(72)."\n";
        print FH "package $self->{namespace}::$subclass;\n\n";
        print FH "use base 'WoW::Armory::Class';\n\n";

        my %fields = %{$self->{defines}{$subclass}{fields}||{}};
        my %blessed = %{$self->{defines}{$subclass}{blessed}||{}};
        my %list = %{$self->{defines}{$subclass}{list}||{}};

        if (%fields) {
            my $fields = join(', ', map {"'$_'"} sort keys %fields);

            $fields =~ s/([^\n]{70,}?) /$1\n/g;
            $fields =~ s/^/    /gsm;

            print FH "use constant FIELDS => [\n$fields\n];\n\n";
        }

        if (%blessed) {
            my $length = max(map {length $_} keys %blessed) + 2;
            $length += 4 - ($length + 1) % 4 if ($length + 1) % 4;

            print FH "use constant BLESSED_FIELDS =>\n";
            print FH "{\n";

            printf FH "    %-".$length."s => '%s',\n", "'$_'", "$self->{namespace}::$blessed{$_}"
                for sort keys %blessed;

            print FH "};\n\n";
        }

        if (%list) {
            my $length = max(map {length $_} keys %list) + 2;
            $length += 4 - ($length + 1) % 4 if ($length + 1) % 4;

            print FH "use constant LIST_FIELDS =>\n";
            print FH "{\n";

            printf FH "    %-".$length."s => '%s',\n", "'$_'", "$self->{namespace}::$list{$_}"
                for sort keys %list;

            print FH "};\n\n";
        }

        print FH "__PACKAGE__->mk_accessors;\n\n";
    }

    print FH "1;\n";
    close FH;
}

sub build {
    my ($proto, %opts) = @_;

    my $class = ref $proto || $proto;
    my $self = bless {}, $class;

    $self->{namespace} = $opts{NameSpace} || 'WoW::Armory::Class';
    $self->{output} = $opts{Output} || '.';

    $self->{classes} = $opts{Classes} || [];
    $self->{classmap} = $opts{ClassMap} || {};

    $self->{list} = {};
    $self->{defines} = {};
    $self->{check} = {};

    for (@{$self->{classes}}) {
        my @files = map { glob $_ } @{$_->{Source}};

        my $json = {};
        $json = merge($json, decode_json(read_file($_))) for @files;

        $self->parse_hash($json, $_->{Class});
    }

    $self->find_duplicate($_) for sort keys %{$self->{list}};
    $self->output_class($_) for grep {!/::/} keys %{$self->{list}};
}

1;
