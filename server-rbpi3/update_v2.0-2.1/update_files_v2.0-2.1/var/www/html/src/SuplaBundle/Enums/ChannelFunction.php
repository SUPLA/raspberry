<?php
/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

namespace SuplaBundle\Enums;

use MyCLabs\Enum\Enum;

final class ChannelFunction extends Enum {
    const NONE = 0;
    const CONTROLLINGTHEGATEWAYLOCK = 10;
    const CONTROLLINGTHEGATE = 20;
    const CONTROLLINGTHEGARAGEDOOR = 30;
    const THERMOMETER = 40;
    const HUMIDITY = 42;
    const HUMIDITYANDTEMPERATURE = 45;
    const OPENINGSENSOR_GATEWAY = 50;
    const OPENINGSENSOR_GATE = 60;
    const OPENINGSENSOR_GARAGEDOOR = 70;
    const NOLIQUIDSENSOR = 80;
    const CONTROLLINGTHEDOORLOCK = 90;
    const OPENINGSENSOR_DOOR = 100;
    const CONTROLLINGTHEROLLERSHUTTER = 110;
    const OPENINGSENSOR_ROLLERSHUTTER = 120;
    const POWERSWITCH = 130;
    const LIGHTSWITCH = 140;
    const DIMMER = 180;
    const RGBLIGHTING = 190;
    const DIMMERANDRGBLIGHTING = 200;
    const DEPTHSENSOR = 210;
    const DISTANCESENSOR = 220;
}
