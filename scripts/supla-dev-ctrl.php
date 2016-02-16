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
 
 @author Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
*/

class DeviceCtrl
{
   private $socket = FALSE;
   
   
   private function connect() {
   
   	if ( $this->socket !== FALSE )
   		return $this->socket;
   
   	$this->socket = stream_socket_client('unix:///tmp/supla-dev-ctrl.sock', $errno, $errstr);
   
   	if ( $this->socket === FALSE || $this->socket === null ) {
   		$this->socket == FALSE;
   		return FALSE;
   	}
   		
   	$hello = fread($this->socket, 4096);
   	
   	if ( preg_match("/^SUPLA DEVICE CTRL\n/", $hello) !== 1  ) {
   		$this->disconnect();
   	}
   	 
   	return $this->socket;
   
   }
   
   private function disconnect() {
   	
   	if ( $this->socket !== FALSE ) {
   		fclose($this->socket);
   		$this->socket = FALSE;
   	}
   	
   }
   
   private function command($cmd) {
   	
   	if ( $this->socket !== FALSE ) {
   		fwrite($this->socket,  $cmd."\n");
   		return fread($this->socket, 4096);
   	}
   	
   	return FALSE;
   	
   }
   
   
   private function channel_get_vt($channel_no, $hivalue) {
   	
   	$channel_no = intval($channel_no, 0);
        $c = $hivalue === true ? "HIVALUE" : "TYPE";
   	 
   	if ( $this->connect() !== FALSE ) {
   				
   		$result = $this->command("CHANNEL-GET-".$c.":".$channel_no);

   		if ( $result !== FALSE 
   			 && preg_match("/^".$c.":/", $result) === 1 ) {
   			 	list($val) = sscanf($result, $c.":%i\n");
   			 	
   			 	if ( is_numeric($val) ) {	
   			 		return $val;
   			 	};
   		}
   		
   	}
   	 
   	return FALSE;
   	
   }

   function channel_get_type($channel_no) {
        return $this->channel_get_vt($channel_no, false);
   }

   function channel_get_hivalue($channel_no) {
        return $this->channel_get_vt($channel_no, true);
   }

   function channel_set_hivalue($channel_no, $hivalue, $time_ms) {
   	
   	$channel_no = intval($channel_no, 0);
        $hivalue = intval($hivalue, 0);
        $time_ms = intval($time_ms, 0);

        if ( $hivalue != 1 ) {
           $hivalue = 0; 
           $time_ms = 0;
        };
          
   	 
   	if ( $this->connect() !== FALSE ) {
   				
   		$result = $this->command("CHANNEL-SET-HIVALUE:".$channel_no.",".$hivalue.",".$time_ms);

   		if ( $result !== FALSE 
   			 && preg_match("/^OK/", $result) === 1 ) {
   			 	return true;
   		}
   	}
   	 
   	return FALSE;
   	
   }
   
}

$channel_no = -1;
$cmd = 0;
$time_ms = 0;
$hi = 0;

foreach ($argv as $arg) {

    $e=explode("=",$arg);

    if(count($e)==2)
      if ( preg_match('/^CHANNEL-/', $e[0]) ) {

          $channel_no = intval($e[1], 0);

          if ( $e[0] == 'CHANNEL-GET-HIVALUE' ) {
             $cmd = 1;
          } else if ( $e[0] == 'CHANNEL-GET-TYPE' ) {
             $cmd = 2;
          } else if ( $e[0] == 'CHANNEL-SET-HIVALUE' ) {
             $cmd = 3;
          };
      } else if ( $e[0] == "HI" ) {
          $hi = intval($e[1], 0);
          if ( $hi != 1 ) $hi = 0;
      } else if ( $e[0] == "TIME" ) {
          $time_ms = intval($e[1], 0);
      };
}

if ( $cmd != 0 ) {

    $devctrl = new DeviceCtrl();
    $result = FALSE;

    switch($cmd) {
       case 1:

            $result = $devctrl->channel_get_hivalue($channel_no);
            if ( $result !== FALSE )
               print $result."\n";

            break;
       case 2:

            $result = $devctrl->channel_get_type($channel_no);
            if ( $result !== FALSE )
               print $result."\n";

            break;
       case 3:

            $result = $devctrl->channel_set_hivalue($channel_no, $hi, $time_ms);
            if ( $result !== FALSE )
               print "OK\n";

            break;
    };

    if ( $result === FALSE )
      print "FAIL\n";
};

?>
