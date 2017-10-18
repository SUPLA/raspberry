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

namespace SuplaBundle\EventListener;

use Doctrine\ORM\EntityManager;
use SuplaBundle\Entity\User;
use Symfony\Component\Security\Core\Encoder\EncoderFactoryInterface;
use Symfony\Component\Security\Http\Event\InteractiveLoginEvent;

class LegacyPasswordMigrationListener {
    private $encoderFactory;
    /** @var EntityManager */
    private $entityManager;

    public function __construct(EncoderFactoryInterface $encoderFactory, EntityManager $entityManager) {
        $this->encoderFactory = $encoderFactory;
        $this->entityManager = $entityManager;
    }

    public function onSecurityInteractiveLogin(InteractiveLoginEvent $event) {
        /** @var User $user */
        $user = $event->getAuthenticationToken()->getUser();
        $token = $event->getAuthenticationToken();

        if ($user->hasLegacyPassword()) {
            $plainPassword = $token->getCredentials();
            $user->clearLegacyPassword();
            $encoder = $this->encoderFactory->getEncoder($user);
            $user->setPassword($encoder->encodePassword($plainPassword, $user->getSalt()));
            $this->entityManager->persist($user);
            $this->entityManager->flush();
        }
        $token->eraseCredentials();
    }
}
