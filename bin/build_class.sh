#!/bin/sh

bin/class_from_json.pl WoW::Armory::Class::Character bin/char.map t/char.json bin/json/char*.json > Character.pm
bin/class_from_json.pl WoW::Armory::Class::Guild bin/guild.map t/guild.json bin/json/guild*.json > Guild.pm
