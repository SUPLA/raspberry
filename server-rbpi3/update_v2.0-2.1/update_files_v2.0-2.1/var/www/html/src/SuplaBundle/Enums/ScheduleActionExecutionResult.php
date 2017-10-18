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
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @method static ScheduleActionExecutionResult UNKNOWN()
 * @method static ScheduleActionExecutionResult SUCCESS()
 * @method static ScheduleActionExecutionResult DEVICE_UNREACHABLE()
 * @method static ScheduleActionExecutionResult NO_SENSOR()
 * @method static ScheduleActionExecutionResult EXPIRED()
 * @method static ScheduleActionExecutionResult ZOMBIE()
 * @method static ScheduleActionExecutionResult SERVER_UNREACHABLE()
 * @method static ScheduleActionExecutionResult FAILURE()
 * @method static ScheduleActionExecutionResult CANCELLED()
 */
final class ScheduleActionExecutionResult extends Enum {
    const UNKNOWN = 0;
    const SUCCESS = 1;
    const DEVICE_UNREACHABLE = 2;
    const NO_SENSOR = 3;
    const EXPIRED = 4;
    const ZOMBIE = 5;
    const SERVER_UNREACHABLE = 6;
    const FAILURE = 7;
    const CANCELLED = 8;

    public function __construct($value) {
        parent::__construct($value ?: 0);
    }

    /**
     * @Groups({"basic", "flat"})
     */
    public function getCaption(): string {
        return self::captions()[$this->getValue()];
    }

    public static function captions(): array {
        return [
            self::UNKNOWN => 'Processing',
            self::SUCCESS => 'Successful',
            self::DEVICE_UNREACHABLE => 'Device unavailable',
            self::NO_SENSOR => 'Sensor disconnected',
            self::EXPIRED => 'Expired',
            self::ZOMBIE => 'Failed (zombie)',
            self::SERVER_UNREACHABLE => 'Server unreachable',
            self::FAILURE => 'Failed',
            self::CANCELLED => 'Cancelled',
        ];
    }

    public function isSuccessful(): bool {
        return $this->equals(self::SUCCESS());
    }
}
