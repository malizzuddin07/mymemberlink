<?php
if ( !isset( $_POST ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );
$eventid = ( $_POST[ 'eventid' ] );

$sqldeleteevent = "DELETE FROM `tbl_events` WHERE `event_id` = '$eventid'";

if ( $conn->query( $sqldeleteevent ) === TRUE ) {
    $response = array( 'status' => 'success', 'data' => null );
    sendJsonResponse( $response );
} else {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
}

function sendJsonResponse( $sentArray )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
}

?>