<?php
include('kabam-platform.php');
include('kabam-payment.php');
include('kabam-api-mobile-naid-response.php');
include('kabam-api-payment-response.php');

class KabamApi {

    private $env;
    private $KBMApiClientId;

    private $KBMApiSecret;
    private $KBMApiHost;
    private $KBMApiPort;
    private $KBMPaymentHost;
    private $KBMPaymentPort;

    private $platformClient;
    private $paymentClient;

    public function __construct($env, $clientId, $secret) {
        $this->KBMApiClientId = $clientId;
        $this->KBMApiSecret = $secret;
        if ($env == "PROD") {
            $this->KBMApiHost = "https://api.kabam.com";
            $this->KBMApiPort = 443;
            $this->KBMPaymentHost = "https://payv2.kabam.com";
            $this->KBMPaymentPort = 443;
        } else {
            $this->KBMApiHost = "http://api-sandbox.kabam.com";
            $this->KBMApiPort = 80;
            $this->KBMPaymentHost = "http://payv2beta.kabam.com";
            $this->KBMPaymentPort = 80;
        }
    }

    public function mobileGetNaid($userId, $platform, $biParams, $userCreationDate) {
        $client = $this->getPlatformClient();
        $result = $client->mobileGetNaid($userId, $this->KBMApiClientId, $platform, $biParams, $userCreationDate);

        // success
        if ($result->returnCode == 1) {
            $response = new KabamApiMobileNaidResponse(
                    true, 0, '', $result->access_token, $result->naid);
            return $response;
        }

        // error
        $response = new KabamApiMobileNaidResponse(
                false, $result->returnCode, $result->error, null, null);
        return $response;
    }

    public function paymentLog($naid, $receipt, $mobileid, $logData) {
        $client = $this->getPaymentClient();
        $result = $client->paymentLog($naid, $this->KBMApiClientId, $receipt, $mobileid, $logData);
        
        // success
        if ($result->success == true) { 
            $response = new KabamApiPaymentResponse(true, 0, '');
            return $response;
        }

        // error
        $response = new KabamApiPaymentResponse(false, $result->errorcode, $result->errormessage); 
        return $response;
    }

    protected function getPlatformClient() {
        if (!isset($this->platformClient)) {
            $this->platformClient = new KabamPlatform(
                    $this->KBMApiHost, $this->KBMApiPort, $this->KBMApiSecret);
        }

        return $this->platformClient;
    }

    protected function getPaymentClient() {
        if (!isset($this->paymentClient)) {
            $this->paymentClient = new KabamPayment(
                $this->KBMPaymentHost, $this->KBMPaymentPort, $this->KBMApiSecret);
        }

        return $this->paymentClient;
    }
}
