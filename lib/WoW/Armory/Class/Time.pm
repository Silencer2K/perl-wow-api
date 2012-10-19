package WoW::Armory::Class::Time;

use strict;
use warnings;

########################################################################
package WoW::Armory::Class::Time;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(hours milliseconds minutes seconds time)];

__PACKAGE__->mk_accessors;

1;
