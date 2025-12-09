<?php
// Database connection - session handled by calling script
$servername = "app_database";
$username = "root";
$password = "passwd";
$database = "grocerry";

$con = mysqli_connect($servername, $username, $password, $database);

if (!$con) {
    die("Connection failed: " . mysqli_connect_error());
}
?>
