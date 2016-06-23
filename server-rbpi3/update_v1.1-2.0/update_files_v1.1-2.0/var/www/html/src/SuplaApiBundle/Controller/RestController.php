<?php
/*
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

namespace SuplaApiBundle\Controller;

use FOS\RestBundle\Controller\FOSRestController;

/**
 * Each entity controller must extends this class.
 *
 * @abstract
 */
abstract class RestController extends FOSRestController {

    private $api_man;
    private $user;
    private $parent;

    public function getApiUser() {

        if ($this->user === null) {
            $this->user = $this->container->get('security.token_storage')->getToken()->getUser();
        }
        return $this->user;
    }

    public function getParentUser() {

        if ($this->parent === null
            && $this->getUser() !== null
        ) {
            $this->parent = $this->getUser()->getParentUser();
        }
        return $this->parent;
    }

    public function getApiManager() {

        if ($this->api_man === null) {
            $this->api_man = $this->container->get('api_manager');
        }

        return $this->api_man;
    }
}
