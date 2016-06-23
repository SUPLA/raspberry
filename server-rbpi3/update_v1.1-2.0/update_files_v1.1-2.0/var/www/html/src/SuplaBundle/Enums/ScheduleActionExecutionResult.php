<?php

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
