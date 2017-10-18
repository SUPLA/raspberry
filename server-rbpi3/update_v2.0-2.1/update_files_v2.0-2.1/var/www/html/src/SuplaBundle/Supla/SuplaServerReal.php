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

namespace SuplaBundle\Supla;

class SuplaServerReal extends SuplaServer {
    private $socket = null;

    public function __destruct() {
        $this->disconnect();
    }

    protected function connect() {
        if ($this->socket) {
            return $this->socket;
        }

        $old_er = error_reporting();
        error_reporting($old_er ^ E_WARNING);
        $this->socket = stream_socket_client('unix:///tmp/supla-server-ctrl.sock', $errno, $errstr);
        error_reporting($old_er);

        if (!$this->socket) {
            return false;
        }

        $hello = fread($this->socket, 4096);

        if (preg_match("/^SUPLA SERVER CTRL\n/", $hello) !== 1) {
            $this->disconnect();
        }
        return $this->socket;
    }

    protected function disconnect() {
        if ($this->socket) {
            fclose($this->socket);
            $this->socket = null;
        }
    }

    protected function command($command) {
        if ($this->socket) {
            fwrite($this->socket, $command . "\n");
            $result = fread($this->socket, 4096);
            return $result;
        }
        return false;
    }
}
