<?php

class KabamApiResponse {
    private $errorMessage;
    private $returnCode;
    private $success;

    public function __construct($success, $returnCode, $errorMessage) {
        $this->errorMessage = $errorMessage;
        $this->returnCode = $returnCode;
        $this->success = $success;
    }

    public function getSuccess(){
        return $this->success;
    }

    public function setSuccess($success) {
        $this->success = $success;
    }

    public function getErrorMessage(){
        return $this->errorMessage;
    }

    public function getReturnCode() {
        return $this->returnCode;
    }

    public function setErrorMessage($errorMessage) {
        $this->errorMessage = $errorMessage;
    }

    public function setReturnCode($returnCode) {
        $this->returnCode = $returnCode;
    }
}
