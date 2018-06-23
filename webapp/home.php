<?php
  include '/etc/database.php';
  
  $mysqli = new mysqli( $db_endpoint, 
                        $db_username, 
                        $db_password,  
                        $db_name
                      );

  // read all record from table 
  $result = $mysqli->query("SELECT * FROM users");

  var_dump($results);

   
?>
