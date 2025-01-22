<?php
if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

$eventid = $_POST['eventid'];
$title = $_POST['title'];
$location = $_POST['location'];
$description = addslashes($_POST['description']);
$eventtype = $_POST['eventtype'];
$start = $_POST['start'];    
$end = $_POST['end'];
$image = $_POST['image'];

// $filename = $_POST['filename'];
$filename = "event-".randomfilename(10).".jpg";

if ($start == "NA"){
    $sqlupdateevent = "UPDATE `tbl_events` SET `event_title`='$title',`event_description`='$description',`event_enddate`='$end',`event_type`='$eventtype',`event_location`='$location'";   
}
if ($end =="NA"){
    $sqlupdateevent = "UPDATE `tbl_events` SET `event_title`='$title',`event_description`='$description',`event_startdate`='$start',`event_type`='$eventtype',`event_location`='$location'";       
}
if ($start =="NA" && $end =="NA"){
    $sqlupdateevent = "UPDATE `tbl_events` SET `event_title`='$title',`event_description`='$description',`event_type`='$eventtype',`event_location`='$location'";          
}
if ($start !="NA" && $end !="NA"){
    $sqlupdateevent = "UPDATE `tbl_events` SET `event_title`='$title',`event_description`='$description',`event_startdate`='$start',`event_enddate`='$end',`event_type`='$eventtype',`event_location`='$location'";
}
if ($image != "NA"){
   
    $sqlupdateevent = $sqlupdateevent . ",`event_filename`='$filename' WHERE `event_id`='$eventid'";
}else{
    $sqlupdateevent = $sqlupdateevent . " WHERE `event_id`='$eventid'";
}

include_once("dbconnect.php");

if ($conn->query($sqlupdateevent) === TRUE) {
    if ($image != "NA"){
        $decoded_image = base64_decode($image);
        $path = "../assets/events/". $filename;
        file_put_contents($path, $decoded_image);
    }
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}
	
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

function randomfilename($length) {
    $key = '';
    $keys = array_merge(range(0, 9), range('a', 'z'));

    for ($i = 0; $i < $length; $i++) {
        $key .= $keys[array_rand($keys)];
    }
    return $key;
}
?>