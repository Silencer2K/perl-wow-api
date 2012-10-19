#!/usr/bin/perl

use strict;
use warnings;

use JSON::XS;
use List::Util qw(max);

my (@classes_list, %classes, %check_classes, %classes_map);

sub read_file {
    local $/;
    open FH, shift;
    my $ret = <FH>;
    close FH;
    return $ret;
}

sub make_class_hash {
    my ($data, $class) = @_;

    $class = $classes_map{$class} || $class;

    my (@fields, @blessed, @list);

    for my $key (sort keys %$data) {
        my $value = $data->{$key};
        my $ref = ref $value;
        if (!$ref) {
            push @fields, $key;
        }
        elsif ($ref eq 'HASH') {
            my $ret = make_class_hash($value, $class.'::'.ucfirst($key));
            push @blessed, [ $key, $ret ] if $ret;
        }
        elsif ($ref eq 'ARRAY') {
            if (@$value && ref $value->[0]) {
                my $ret = make_class_hash($value->[0], $class.'::'.ucfirst($key));
                push @list, [ $key, $ret ] if $ret;
            }
            else {
                push @fields, $key;
            }
        }
        elsif ($ref eq 'JSON::XS::Boolean') {
            push @fields, $key;
        }
        else {
            warn "I don't know what to do with $ref";
        }
    }

    if (!grep {$_ eq $class} @classes_list) {
        my $check_string = join(';',
            join(',', @fields),
            join(',', map {$_->[0]} @blessed),
            join(',', map {$_->[0]} @list)
        );

        my $check_class = $check_classes{$check_string};
        if ($check_class) {
            warn "Classes $class and $check_class are look alike";
        }
        else {
            $check_classes{$check_string} = $class;
        }

        push @classes_list, $class;
    }

    for my $field (@fields) {
        push @{$classes{$class}{fields}}, $field
            if !grep {$_ eq $field} @{$classes{$class}{fields}};
    }

    for my $field (@blessed) {
        push @{$classes{$class}{blessed}}, $field
            if !grep {$_->[0] eq $field->[0]} @{$classes{$class}{blessed}};
    }

    for my $field (@list) {
        push @{$classes{$class}{list}}, $field
            if !grep {$_->[0] eq $field->[0]} @{$classes{$class}{list}};
    }

    return $class;
}

my ($class, $map, @files) = @ARGV;

$classes_map{$_->[0]} = $_->[1]
    for map {[split /\s+/, $_, 2]} grep {$_ ne ''} split /\r?\n/, read_file($map);

for my $data (map {decode_json(read_file($_))} @files) {
    make_class_hash($data, $class);
}

print "package $class;\n\n";
print "use strict;\n";
print "use warnings;\n\n";

for my $class_2 (reverse sort @classes_list) {
    my @fields = @{$classes{$class_2}{fields}||[]};
    my @blessed = @{$classes{$class_2}{blessed}||[]};
    my @list = @{$classes{$class_2}{list}||[]};

    print "########################################################################\n";
    print "package $class_2;\n\n";
    print "use base 'WoW::Armory::Class';\n\n";

    if (@fields) {
        my $fields = join(' ', sort @fields);
        if (length $fields <= 40) {
            print "use constant FIELDS => [qw($fields)];\n\n";
        }
        else {
            $fields =~ s/([^\n]{70,}?) /$1\n/g;
            $fields =~ s/^/    /gsm;

            print "use constant FIELDS => [qw(\n$fields\n)];\n\n";
        }
    }

    if (@blessed) {
        my $length = max map {length $_->[0]} @blessed;
        $length += 4 - ($length + 1) % 4 if ($length + 1) % 4;
        print "use constant BLESSED_FIELDS =>\n";
        print "{\n";
        printf "    %-".$length."s => '%s',\n", $_->[0], $_->[1] for sort {$a->[0] cmp $b->[0]} @blessed;
        print "};\n\n";
    }

    if (@list) {
        my $length = max map {length $_->[0]} @list;
        $length += 4 - ($length + 1) % 4 if ($length + 1) % 4;
        print "use constant LIST_FIELDS =>\n";
        print "{\n";
        printf "    %-".$length."s => '%s',\n", $_->[0], $_->[1] for sort {$a->[0] cmp $b->[0]} @list;
        print "};\n\n";
    }

    print "__PACKAGE__->mk_accessors;\n\n";
}

print "1;\n";
