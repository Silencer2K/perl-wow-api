package WoW::Armory::Class::Guild;

use strict;
use warnings;

########################################################################
package WoW::Armory::Class::Guild::News;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(character itemId timestamp type)];

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Members::Character::Spec;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(
    backgroundImage description icon name order role
)];

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Members::Character;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(
    achievementPoints battlegroup class gender guild level name race realm
    thumbnail
)];

use constant BLESSED_FIELDS =>
{
    spec    => 'WoW::Armory::Class::Guild::Members::Character::Spec',
};

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Members;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(rank)];

use constant BLESSED_FIELDS =>
{
    character   => 'WoW::Armory::Class::Guild::Members::Character',
};

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Emblem;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(
    backgroundColor border borderColor icon iconColor
)];

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Challenge::Realm;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(battlegroup locale name slug timezone)];

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Challenge::Map::Criteria;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(hours milliseconds minutes seconds time)];

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Challenge::Map;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(id name slug)];

use constant BLESSED_FIELDS =>
{
    bronzeCriteria  => 'WoW::Armory::Class::Guild::Challenge::Map::Criteria',
    goldCriteria    => 'WoW::Armory::Class::Guild::Challenge::Map::Criteria',
    silverCriteria  => 'WoW::Armory::Class::Guild::Challenge::Map::Criteria',
};

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Challenge;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(groups)];

use constant BLESSED_FIELDS =>
{
    map     => 'WoW::Armory::Class::Guild::Challenge::Map',
    realm   => 'WoW::Armory::Class::Guild::Challenge::Realm',
};

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild::Achievements;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(
    achievementsCompleted achievementsCompletedTimestamp criteria criteriaCreated
    criteriaQuantity criteriaTimestamp
)];

__PACKAGE__->mk_accessors;

########################################################################
package WoW::Armory::Class::Guild;

use base 'WoW::Armory::Class';

use constant FIELDS => [qw(
    achievementPoints battlegroup lastModified level name realm side
)];

use constant BLESSED_FIELDS =>
{
    achievements    => 'WoW::Armory::Class::Guild::Achievements',
    emblem          => 'WoW::Armory::Class::Guild::Emblem',
};

use constant LIST_FIELDS =>
{
    challenge   => 'WoW::Armory::Class::Guild::Challenge',
    members     => 'WoW::Armory::Class::Guild::Members',
    news        => 'WoW::Armory::Class::Guild::News',
};

__PACKAGE__->mk_accessors;

1;
