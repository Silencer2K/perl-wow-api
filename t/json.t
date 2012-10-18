use Test::More qw(no_plan);

use JSON::XS;

sub read_file {
    local $/;
    open FH, shift;
    $ret = <FH>;
    close FH;
    return $ret;
}

sub test_array {
    my $array = shift;
    my $struct = shift;
    my ($p_class, $p_err);
    my $c = 0;
    for my $value (@$array) {
        $c++;
        my $class = ref $value;
        if (!$p_err) {
            if (defined $p_class) {
                if ($p_class ne $class) {
                    warn "Array contains different types: $struct";
                    $p_err = 1;
                }
            }
            $p_class = $class;
        }
        next if !$class;
        if ($class eq 'ARRAY') {
            my $ret = test_array($value, "$sturct\[$c]");
            return 0 if !$ret;
        }
        elsif ($class eq 'HASH') {
            warn "Hash is not blessed: $struct\[$c]";
        }
        elsif ($class =~ /::/ && !$class =~ /\bJSON::XS\b/) {
            my $ret = test_hash($value, "$struct\[$c]");
            return 0 if !$ret;
        }
    }
    return 1;
}

sub test_hash {
    my $obj = shift;
    my $struct = shift;
    for my $key (keys %$obj) {
        if (!$obj->can($key)) {
            warn "Method is not exists: ".ref($obj)."->$key()";
            return 0;
        }
        my $value = $obj->$key;
        my $class = ref $value;
        next if !$class;
        if ($class eq 'ARRAY') {
            my $ret = test_array($value, "$struct\{'$key'}");
            return 0 if !$ret;
        }
        elsif ($class eq 'HASH') {
            warn "Hash is not blessed: $struct\{'$key'}";
        }
        elsif ($class =~ /::/ && !$class =~ /\bJSON::XS\b/) {
            my $ret = test_hash($value, "$struct\{'$key'}");
            return 0 if !$ret;
        }
    }
    return 1;
}

sub test_json {
    my ($fname, $class) = @_;
    eval "use $class";
    if ($@) {
        warn "Can't use $class: $@";
        return 0;
    }
    my $obj = $class->new(decode_json(read_file($fname)));
    if (!$obj) {
        warn "Can't create new object: $class";
        return 0;
    }
    return test_hash($obj, ref($obj).'->');
}

ok(test_json('t/char.json', 'WoW::Armory::Class::Character'));
#ok(test_json('t/guild.json', 'WoW::Armory::Class::Guild'));

1;
