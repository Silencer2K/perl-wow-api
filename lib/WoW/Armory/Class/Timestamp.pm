package WoW::Armory::Class::Timestamp;

use strict;
use warnings;

########################################################################
package WoW::Armory::Class::Timestamp;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(hours milliseconds minutes seconds time)];

__PACKAGE__->mk_accessors;

1;
