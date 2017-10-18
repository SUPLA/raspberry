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

namespace SuplaBundle\DependencyInjection;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\HttpKernel\DependencyInjection\ConfigurableExtension;

class SuplaExtension extends ConfigurableExtension {
    protected function loadInternal(array $mergedConfig, ContainerBuilder $container) {
        $container->setParameter('supla.version', $mergedConfig['version']);
        $container->setParameter('supla.webpack_hashes', $mergedConfig['webpack_hashes']);
        $container->setParameter(
            'supla.clients_registration.registration_active_time.initial',
            $mergedConfig['clients_registration']['registration_active_time']['initial']
        );
        $container->setParameter(
            'supla.clients_registration.registration_active_time.manual',
            $mergedConfig['clients_registration']['registration_active_time']['manual']
        );
        $container->setParameter(
            'supla.io_devices_registration.registration_active_time.initial',
            $mergedConfig['io_devices_registration']['registration_active_time']['initial']
        );
        $container->setParameter(
            'supla.io_devices_registration.registration_active_time.manual',
            $mergedConfig['io_devices_registration']['registration_active_time']['manual']
        );
    }
}
