function ImperiumXsollaDriverClass() {
	
	//--------------------------------------------------------------------------
	function getUrlVars() {
		var vars = {};
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
			vars[key] = value;
		});
		return vars;
	}
	function getUrlParam(parameter, defaultvalue){
		var urlparameter = defaultvalue;
		if(window.location.href.indexOf(parameter) > -1){
			urlparameter = getUrlVars()[parameter];
			}
		return urlparameter;
	}
	
	function setupLogin() {
		
	}
	var AuthToken = null;

	this.startup = function( onStartupComplete ) {

		AuthToken = getUrlParam("token","null");
		console.log("Xsolla driver initilized");
		onStartupComplete();
	};
	
	this.getPlayerXsollaGameAuthToken = function() {
		return AuthToken;
	};

	//--------------------------------------------------------------------------

	window._mq_ImperiumXsollaDriver = window._mq_ImperiumXsollaDriver || [];
	while ( window._mq_ImperiumXsollaDriver.length > 0 ) {
		var params = window._mq_ImperiumXsollaDriver.shift();
		var method = params.shift();
		this[ method ].apply( this, params );
	}

	window._mq_ImperiumXsollaDriver.push = function( params ) {
		var method = params.shift();
		this[ method ].apply( this, params );
	};
}

ImperiumXsollaDriver = new ImperiumXsollaDriverClass();
