package com.presenter.starbase
{
	import com.model.prototype.IPrototype;
	import com.model.starbase.TradeRouteVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.IImperiumPresenter;

	public interface ITradePresenter extends IImperiumPresenter
	{
		function getConstantPrototypeValueByName( name:String ):Number;
		function getProtoTypeUIName( prototype:IPrototype ):String;
		function getPrototypeUIDescription( prototype:IPrototype ):String;
		function loadIconFromPrototype( type:String, prototype:IPrototype, callback:Function ):void;
		function cancelContract( id:String ):void;
		function requestContract( centerSpaceBase:Boolean, contractPrototype:String, factionPrototype:String, callback:Function ):void;
		function getContractsFromFaction( contractGroup:String ):Vector.<IPrototype>;
		function getBalancedContractFromFaction( contractGroup:String ):IPrototype;
		function getAgentsFromFaction( contractGroup:String ):Vector.<IPrototype>;
		function getAgent( contractGroup:String, reputation:Number ):IPrototype;
		function getAgentDialogByGroup( name:String ):Vector.<IPrototype>;
		function hasAgentGreetingBeenViewed( agentID:int ):Boolean;
		function setAgentGreetingViewed( agentID:int ):void;
		function getTradeRouteTransaction( id:String ):TransactionVO;
		function addTransactionListener( callback:Function ):void;
		function removeTransactionListener( callback:Function ):void;

		function get tradeRouteCreditIncome():uint;
		function get tradeRouteResourceIncome():uint;
		function get maxContracts():int;
		function get maxUnlockedContracts():int;
		function get tradeRoutes():Vector.<TradeRouteVO>;
	}
}


