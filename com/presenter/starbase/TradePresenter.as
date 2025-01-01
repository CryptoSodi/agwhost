package com.presenter.starbase
{
	import com.controller.SettingsController;
	import com.controller.transaction.TransactionController;
	import com.event.signal.TransactionSignal;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.StarbaseModel;
	import com.model.starbase.TradeRouteVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.ImperiumPresenter;
	import com.util.TradeRouteUtil;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class TradePresenter extends ImperiumPresenter implements ITradePresenter
	{
		protected const _logger:ILogger = getLogger('TradePresenter');

		private var _assetModel:AssetModel;
		private var _prototypeModel:PrototypeModel;
		private var _settingsController:SettingsController;
		private var _starbaseModel:StarbaseModel;
		private var _transactionController:TransactionController;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function getConstantPrototypeValueByName( name:String ):Number
		{
			var proto:IPrototype = _prototypeModel.getConstantPrototypeByName(name);
			return proto.getValue('value');
		}

		public function getProtoTypeUIName( prototype:IPrototype ):String
		{
			var currentAssetVO:AssetVO = _assetModel.getEntityData(prototype.getValue('uiAsset'));
			if (currentAssetVO != null)
				return currentAssetVO.visibleName;
			else
				return '';
		}

		public function getPrototypeUIDescription( prototype:IPrototype ):String
		{
			var currentAssetVO:AssetVO = _assetModel.getEntityData(prototype.getValue('uiAsset'));
			if (currentAssetVO != null)
				return currentAssetVO.descriptionText;
			else
				return '';
		}

		public function loadIconFromPrototype( type:String, prototype:IPrototype, callback:Function ):void
		{

			var currentAssetVO:AssetVO = _assetModel.getEntityData(prototype.getValue('uiAsset'));
			if (currentAssetVO != null)
				_assetModel.getFromCache('assets/' + currentAssetVO[type], callback);
		}

		public function getTradeRouteTransaction( id:String ):TransactionVO
		{
			return _transactionController.getTradeRouteTransaction(id);
		}

		public function getContractsFromFaction( contractGroup:String ):Vector.<IPrototype>
		{
			var contracts:Vector.<IPrototype>    = new Vector.<IPrototype>;
			var allContracts:Vector.<IPrototype> = _prototypeModel.getContractPrototypes();
			var len:uint                         = allContracts.length;
			var currentPrototype:IPrototype;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPrototype = allContracts[i];
				if (contractGroup == currentPrototype.getValue('contractGroup'))
					contracts.push(currentPrototype);
			}

			return contracts;
		}

		public function getBalancedContractFromFaction( contractGroup:String ):IPrototype
		{
			var balancedContract:IPrototype;
			var typeOfContract:String;
			var allContracts:Vector.<IPrototype> = _prototypeModel.getContractPrototypes();
			var len:uint                         = allContracts.length;
			var currentPrototype:IPrototype;

			switch (contractGroup)
			{
				case 'Starwind':
					typeOfContract = 'SyntheticsPreferred';
					break;
				case 'Solaris':
					typeOfContract = 'EnergyPreferred';
					break;
				case 'BlueComet':
					typeOfContract = 'CreditsPreferred';
					break;
				case 'WhiteDwarf':
					typeOfContract = 'AlloyPreferred';
					break;
				case 'AcmeUniversal':
					typeOfContract = 'Balanced';
					break;

			}


			for (var i:uint = 0; i < len; ++i)
			{
				currentPrototype = allContracts[i];
				if (contractGroup == currentPrototype.getValue('contractGroup') && String(currentPrototype.name).indexOf(typeOfContract) != -1)
					balancedContract = currentPrototype;
			}

			return balancedContract;
		}

		public function getAgentsFromFaction( contractGroup:String ):Vector.<IPrototype>
		{
			var agents:Vector.<IPrototype>    = new Vector.<IPrototype>;
			var allAgents:Vector.<IPrototype> = _prototypeModel.getAgentPrototypes();
			var len:uint                      = allAgents.length;
			var currentPrototype:IPrototype;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPrototype = allAgents[i];
				if (contractGroup == currentPrototype.getValue('faction'))
					agents.push(currentPrototype);
			}

			return agents;
		}

		public function getAgent( contractGroup:String, reputation:Number ):IPrototype
		{
			var agents:Vector.<IPrototype> = getAgentsFromFaction(contractGroup);
			var len:uint                   = agents.length;
			var currentAgent:IPrototype;
			for (var i:uint = 0; i < len; ++i)
			{
				currentAgent = agents[i];
				if (currentAgent.getValue('minRep') <= reputation && currentAgent.getValue('maxRep') >= reputation)
					break;
			}

			return currentAgent;
		}

		public function hasAgentGreetingBeenViewed( agentID:int ):Boolean
		{
			return _settingsController.hasAgentGreetingBeenViewed(agentID);
		}

		public function setAgentGreetingViewed( agentID:int ):void
		{
			_settingsController.setAgentGreetingViewed(agentID);
		}

		public function getAgentDialogByGroup( group:String ):Vector.<IPrototype>
		{
			var dialog:Vector.<IPrototype>    = new Vector.<IPrototype>;
			var allDialog:Vector.<IPrototype> = _prototypeModel.getDialogPrototypes();
			var len:uint                      = allDialog.length;
			var currentPrototype:IPrototype;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPrototype = allDialog[i];
				if (group == currentPrototype.getValue('dialogGroup'))
					dialog.push(currentPrototype);
			}

			return dialog;
		}

		public function requestContract( centerSpaceBase:Boolean, contractPrototype:String, factionPrototype:String, callback:Function ):void
		{
			var security:Number     = getConstantPrototypeValueByName('contractSecurityDefault');
			var duration:Number     = getConstantPrototypeValueByName('contractDurationDefault');
			var frequency:Number    = getConstantPrototypeValueByName('contractFrequencyDefault');
			var payout:Number       = getConstantPrototypeValueByName('contractPayoutDefault');
			var productivity:Number = getConstantPrototypeValueByName('contractProductivityDefault');

			_transactionController.requestContract(centerSpaceBase, contractPrototype, duration, factionPrototype, frequency, payout, productivity, security, callback, true);
		}

		public function cancelContract( id:String ):void
		{
			_transactionController.transactionCancel(id);
		}

		public function addTransactionListener( callback:Function ):void  { _transactionController.addListener(TransactionSignal.TRANSACTION, callback); }
		public function removeTransactionListener( callback:Function ):void  { _transactionController.removeListener(callback); }

		public function get tradeRouteCreditIncome():uint  { return _starbaseModel.tradeRouteCreditIncome; }
		public function get tradeRouteResourceIncome():uint  { return _starbaseModel.tradeRouteResourceIncome; }

		public function get maxContracts():int  { return TradeRouteUtil.maxContracts; }
		public function get maxUnlockedContracts():int  { return TradeRouteUtil.maxUnlockedContracts; }

		public function get tradeRoutes():Vector.<TradeRouteVO>  { return _starbaseModel.getTradeRoutesByBaseID(); }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set settingsController( v:SettingsController ):void  { _settingsController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		override public function destroy():void
		{
			super.destroy();
		}
	}
}


