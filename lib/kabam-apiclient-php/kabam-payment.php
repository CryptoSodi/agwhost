<?php
define('KBM_PAYMENT_SERVICE_TIMEOUT', 10);

class KabamPayment {

    private $host;
    private $port;
    private $secret;

    public function __construct($host, $port, $secret) {
        $this->host = $host;
        $this->port = $port;
        $this->secret = $secret;
    }

    /**
     * @param $userId The user's NAID
     * @param $clientId The client (app) Id provided by kabam.com
     * @param $receipt The digital receipt from the payment provider (iTunes/GooglePlay etc.)
     * @param $mobileid 
     * @param $logData JSON string that contains necessary tracking data.
         {"serverid": '',               Integer Your server(world/realm) id that take this order, if you do not have different worlds (servers), simply put 1 
          "localcents":"",              Integer The price that user paid in localized price, multiple 100 so it will be cents (even for currencies that do not have cents, like JPY, please also multiply 100) 
          "localcurrency":"",           String The 3 letters Currency Symbol to represent the paid currency, like USD/EUR/GBP etc.
          "ipaddr":"", 	                IP address The ip address of the user
          "locale":"", 	                String The 2 letters locale code of the user, US/GB/FR/DE etc.
          "platform":"",                String The platform of your game itunes/googleapp
          "igc":"",                     Integer In game currency you give to user
          "igctype":"",                 String If you have more than 1 type of igc, you can specify the type of the igc here (OPTIONAL)
          "transactionid":"",           String The unique transaction/order id that from the payment provider
          "lang":"en",                  String The 2 letters code language of the user, en/de/fr/es etc.
          "ordertype":"payment",        String The type of order payment/offer (OPTIONAL)
          "offerprovider":"tapjoy"      String The offer provider like: tapjoy (OPTIONAL, if you set the ordertype as offer, it become a REQUIRED parameter)
         }
     */
    public function paymentLog($userId, $clientId, $receipt, $mobileid, $logData) {
        $service = "/api/paymentlog";
        $data = array('userid' => $userId, "gameid" => $clientId, "receipt" => $receipt, "mobileid" => $mobileid, "log" => $logData);
        return $this->post($service, $data);
    }

    private function post($service, $data) {
        try {
            return $this->makePostHttpRequest($service, $data);
        } catch (Exception $e) {
            $errMsg = $e->getMessage();
            $json = new stdClass();
            $json->success = false; 
            $json->errorcode = 4;
            $json->errormessage = $errMsg;
            return $json;
        }
    }

    private function generateSignature($querystring, $secretKey, $encodeUrl = false) {
        $string = "";
        if (!empty($querystring)) {
            $params = explode("&", $querystring);
            if (!empty($params)) {
                foreach ($params as $param) {
                    if (!empty($param)) {
                        $key = substr($param, 0, strpos($param, "="));
                        $value = substr($param, strrpos($param, "=") + 1);
                        $queryParams[$key] = $value;
                    }   
                }   
            }   
        }   
        if (!empty($queryParams)) {
            unset($queryParams['sig']);
            $queryParams['timestamp'] = time();
            ksort($queryParams);
            foreach ($queryParams as $key => $value) {
                $string .= urldecode($key);
                $string .= urldecode($value);
            }   
        }   
        $string .= $secretKey;
 
        $queryParams['sig'] = sha1($string);
 
        $newString = "";
        foreach ($queryParams as $key => $value) {
            $newParams[] = $key . "=" . ($encodeUrl ? urlencode($value) : $value);
        }   
 
        if (!empty($newParams)) {
            $newString .= implode("&", $newParams);
        }   
 
        return $newString;
    }

    private function makePostHttpRequest($service, $data) {
        $ch = curl_init();
        $headers = array();
        $headers[] = 'Content-type: application/x-www-form-urlencoded;'
                . 'charset=UTF-8';

        $data['timestamp'] = time();
        $fieldsString = http_build_query($data, '', '&');
        $signedString = $this->generateSignature($fieldsString, $this->secret);

        $headers[] = 'Content-Length: ' . strlen($signedString);

        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $signedString);
        curl_setopt($ch, CURLOPT_SSLVERSION, 3);
        curl_setopt($ch, CURLOPT_URL,  $this->host . ":" . $this->port . $service);
        
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_HEADER, 0);
       
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
        curl_setopt($ch, CURLOPT_TIMEOUT, KBM_API_SERVICE_TIMEOUT); 

        $output = curl_exec($ch);
        curl_close($ch);
        return $this->handleResponse($output, $this->host . ":" . $this->port . $service);
    }

    private function handleResponse($output, $url) {
        $json = json_decode($output);
        if ($json === null || $json === false) { 
            throw new Exception("Could not curl to $url");
        }

        return $json;
    }
}
