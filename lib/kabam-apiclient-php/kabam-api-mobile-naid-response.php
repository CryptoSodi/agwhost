<?php
include_once('kabam-api-response.php');

class KabamApiMobileNaidResponse extends KabamApiResponse {

    private $accessToken;
    private $naid;

    public function __construct($success, $returnCode, $errorMessage, $accessToken, $naid) {
        parent::__construct($success, $returnCode, $errorMessage);

        $this->accessToken = $accessToken;
        $this->naid = $naid;
    }

    public function getAccessToken() {
        return $this->accessToken;
    }

    public function getNaid() {
        return $this->naid;
    }

    public function setNaid($naid) {
        $this->naid = $naid;
    }

    public function setAccessToken($accessToken) {
        $this->accessToken = $accessToken;
    }
}
