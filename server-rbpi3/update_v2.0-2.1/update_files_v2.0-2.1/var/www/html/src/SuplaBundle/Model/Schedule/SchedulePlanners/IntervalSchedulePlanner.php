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

namespace SuplaBundle\Model\Schedule\SchedulePlanners;

use SuplaBundle\Entity\Schedule;

class IntervalSchedulePlanner implements SchedulePlanner {

    const CRON_EXPRESSION_INTERVAL_REGEX = '#^\*/(\d{1,3})( \*)*$#';

    public function calculateNextRunDate(Schedule $schedule, \DateTime $currentDate) {
        preg_match(self::CRON_EXPRESSION_INTERVAL_REGEX, $schedule->getTimeExpression(), $matches);
        $intervalInMinutes = intval($matches[1]);
        $period = "PT{$intervalInMinutes}M";
        $nextRunDate = clone $currentDate;
        $nextRunDate->add(new \DateInterval($period));
        return CompositeSchedulePlanner::roundToClosest5Minutes($nextRunDate, $schedule->getUserTimezone());
    }

    public function canCalculateFor(Schedule $schedule) {
        return !!preg_match(self::CRON_EXPRESSION_INTERVAL_REGEX, $schedule->getTimeExpression());
    }
}
