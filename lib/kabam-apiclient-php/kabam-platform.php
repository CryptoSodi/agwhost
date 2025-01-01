<?php
require(dirname(__FILE__) . '/kabam-settings.php');
define('KBM_API_CLIENT_ReturnCodesServiceAccessFailure', 4096);
define('KBM_API_SERVICE_TIMEOUT', 5);

class KabamPlatform{

    private $host;
    private $port;
    private $secret;

    public function __construct($host, $port, $secret) {
        $this->host = $host;
        $this->port = $port;
        $this->secret = $secret;
    }

    /**
     * @param $userId The mobile unique identifier
     * @param $clientId The client (app) Id provided by kabam.com
     * @param $platform 'iphone', 'googleapp' or 'amazonapp'
     * @param $biParams json string with advertisement tracking information.
         { 'open_udid':'',        *See https://github.com/ylechelle/OpenUDID.
           'udid':'',             Pre IOS 6 udid.
           'mac':'',              mac address
           'mac_hash':'',         MD5 has of the mac address
           'device_id':'',        Android device id.
           'advertiser_id':''}    IOS6 advertiser id.
     * @param $userCreationDate When is this user created on the 3rd party game's side
          If not passed it will default to current unix time.
     */
    public function mobileGetNaid($userId, $clientId, $platform, $biParams, $userCreationDate) {
        $service = "/mobile/naid";
        $args = array('client_id' => $clientId);
        $data = array('user_id' => $userId, 'platform' => $platform,
            'bi_params' => $biParams);
        if ($userCreationDate) {
            $data['creation_date'] = $userCreationDate;
        }
        return $this->post($service, $args, $data);
    }

    public function post($service, $args, $data, $version=1) {
        try {
            return $this->makePostHttpRequest($service, $args, $data, $version);
        } catch (Exception $e) {
            $errMsg = $e->getMessage();
            $json = new stdClass();
            $json->returnCode = KBM_API_CLIENT_ReturnCodesServiceAccessFailure;
            $json->error = $errMsg;
            return $json;
        }
    }

    public function generateSignature($args, $data, $secret, $version=1) {
        if (strlen($secret) != 32) {
            throw new Exception("key must be of length 32.");
        }

        $this->removeNulls($args);
        $this->removeNulls($data);

        $sigData = array('nonce' => $this->makeNonce(),
                          'ts' => time(),
                          'version' => $version);

        if (is_array($args) && is_array($data)) {
            $baseString = $this->makeString(array_merge($args, $data, $sigData));
        } else if (is_array($args) && is_string($data)) {
            $baseString = $this->makeString(array_merge($args, $sigData));
            $baseString .= $data;
        } else if (is_array($data)) {
            $baseString = $this->makeString(array_merge($data, $sigData));
        } else if (is_array($args)) {
            $baseString = $this->makeString(array_merge($args, $sigData));
        } else {
            $baseString = $this->makeString($sigData);
        }

        $sigData['sig'] = hash_hmac('sha256', $baseString, $secret);
        return $sigData;
    }

    private function handleResponse($output, $url) {
        $json = json_decode($output);
        if ($json === null || $json === false) {
            throw new Exception("Could not curl to $url");
        }

        return $json;
    }

    protected function makePostHttpRequest($service, $args, $data, $version) {
        $ch = curl_init();
        $headers = array();
        $headers[] = 'Content-type: application/x-www-form-urlencoded;'
                . 'charset=UTF-8';

        // Set POST variables
        $fieldsString = http_build_query($data, '', '&');
        $sigData = $this->generateSignature($args, $data, $this->secret,
                $version);
        $headers[] = 'Content-Length: ' . strlen($fieldsString);
        $headers[] = 'User-Agent: KabamApiClient/' . KABAM_API_CLIENT_VERSION
                . ' php/' . KABAM_API_CLIENT_VERSION;
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fieldsString);
        $url = $this->makeUrl($service, $args, $sigData, $version);
        curl_setopt($ch, CURLOPT_SSLVERSION, 3);
        curl_setopt($ch, CURLOPT_URL, $url);

        // Return the transfer as a string
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_HEADER, 0);

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
        curl_setopt($ch, CURLOPT_TIMEOUT, KBM_API_SERVICE_TIMEOUT);

        // $output contains the output string
        $output = curl_exec($ch);
        curl_close($ch);
        return $this->handleResponse($output, $url);
    }

    protected function makeNonce() {
        // generate a nonce of length 10 matching [A-Za-z0-9]{10}
        return substr(base64_encode(rand(1000000000,9999999999)),0,10);
    }

    protected function makeString($args) {
        ksort($args);
        // str_replace for compatibility with Java URLEncoder.encode
        $baseString = str_replace('%2A', '*', http_build_query($args, '', '&'));
        return $baseString;
    }

    private function makeUrl($service, $args, $sigData, $version,
            $qparams = null) {

        $params = '';
        if ($args != null) {
            foreach ($args as $nm => $value) {
                $params .= '/' . $nm . "/" . $value;
            }
        }
        $nextQParamBeginChar = '?';
        if ($qparams != null) {
            $params .= '?';
            $nextQParamBeginChar = '&';
            $separator = '';
            foreach ($qparams as $nm => $value) {
                $params .= $separator . $nm . '=' . $value;
                $separator = '&';
            }
        }

        $host = $this->host;
        if ((strpos($this->host, 'http:') !== 0)
                && (strpos($this->host, 'https:') !== 0)) {
            // Use https by default
            $host = 'https://' . $this->host;
        }

        $servicePrefix = "";
        if (defined("KBM_API_SERVICE_PREFIX")) {
            $servicePrefix = KBM_API_SERVICE_PREFIX;
        }

        $port = "";
        if ($this->port) {
            $port = ':' . $this->port;
        }

        $url = $host . $port . $servicePrefix . $service . $params .
               $nextQParamBeginChar . 'sig=' . $sigData['sig'] .
               '&nonce=' . $sigData['nonce'] .
               '&ts=' . $sigData['ts'] .
               '&version=' . $version;
        return $url;
    }

    private function removeNulls(&$data) {
        if ($data === null) {
            $data = '';
            return;
        }

        if (is_array($data)) {
            foreach ($data as &$value) {
                $this->removeNulls($value);
            }
        }
    }
}
