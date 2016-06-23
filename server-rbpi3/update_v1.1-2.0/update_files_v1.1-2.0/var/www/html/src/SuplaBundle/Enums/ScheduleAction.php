<?php

namespace SuplaBundle\Enums;

use Assert\Assert;
use Assert\Assertion;
use MyCLabs\Enum\Enum;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @method static ScheduleAction OPEN()
 * @method static ScheduleAction CLOSE()
 * @method static ScheduleAction SHUT()
 * @method static ScheduleAction REVEAL()
 * @method static ScheduleAction REVEAL_PARTIALLY()
 * @method static ScheduleAction TURN_ON()
 * @method static ScheduleAction TURN_OFF()
 * @method static ScheduleAction SET_RGBW_PARAMETERS()
 */
final class ScheduleAction extends Enum {
    const OPEN = 10;
    const CLOSE = 20;
    const SHUT = 30;
    const REVEAL = 40;
    const REVEAL_PARTIALLY = 50;
    const TURN_ON = 60;
    const TURN_OFF = 70;
    const SET_RGBW_PARAMETERS = 80;

    /**
     * @Groups({"basic", "flat"})
     */
    public function getValue() {
        return parent::getValue();
    }

    /**
     * @Groups({"basic", "flat"})
     */
    public function getCaption(): string {
        return self::captions()[$this->getValue()];
    }

    public static function captions(): array {
        return [
            self::OPEN => 'Open',
            self::CLOSE => 'Close',
            self::SHUT => 'Shut',
            self::REVEAL => 'Reveal',
            self::REVEAL_PARTIALLY => 'Reveal partially',
            self::TURN_ON => 'On',
            self::TURN_OFF => 'Off',
            self::SET_RGBW_PARAMETERS => 'Adjust parameters',
        ];
    }

    public function validateActionParam($actionParams) {
        switch ($this->getValue()) {
            case self::REVEAL_PARTIALLY:
                return $this->validateActionParamForRevealPartially($actionParams);
            case self::SET_RGBW_PARAMETERS:
                return $this->validateActionParamForRgbwParameters($actionParams);
            default:
                Assertion::null($actionParams, "Action {$this->getKey()} is not expected to have an action parameters.");
        }
    }

    private function validateActionParamForRevealPartially($actionParams) {
        Assert::that($actionParams)->count(1)->keyExists('percentage');
        Assert::that($actionParams['percentage'])->integer()->between(0, 100);
    }

    private function validateActionParamForRgbwParameters($actionParams) {
        Assertion::true(is_array($actionParams));
        Assertion::between(count($actionParams), 1, 3);
        Assertion::count(array_intersect_key($actionParams, array_flip(['hue', 'color_brightness', 'brightness'])), count($actionParams));
        if (isset($actionParams['hue'])) {
            Assertion::true(is_int($actionParams['hue']) || $actionParams['hue'] == 'random');
            if (is_int($actionParams['hue'])) {
                Assert::that($actionParams['hue'])->between(0, 359);
            }
            Assertion::keyExists($actionParams, 'color_brightness');
            Assert::that($actionParams['color_brightness'])->integer()->between(0, 100);
        }
        if (isset($actionParams['brightness'])) {
            Assert::that($actionParams['brightness'])->integer()->between(0, 100);
        }
    }
}
