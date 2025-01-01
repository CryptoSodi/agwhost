<?php

include_once('kabam-api-response.php');

class KabamApiPaymentResponse extends KabamApiResponse {

    public function __construct($success, $returnCode, $errorMessage) {
        parent::__construct($success, $returnCode, $errorMessage);

    }
}
