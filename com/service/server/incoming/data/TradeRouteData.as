package com.service.server.incoming.data
{
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	public class TradeRouteData implements IServerData
	{
		public var began:uint;
		public var baseID:String;
		public var bribe:Number;
		public var contractPrototype:IPrototype;
		public var duration:Number;
		public var end:uint;
		public var frequency:Number;
		public var id:String;
		public var name:String;
		public var offerExpires:uint;
		public var offerRejected:Boolean;
		public var payout:Number;
		public var productivity:Number;
		public var reputation:Number;
		public var reputationWhenBegun:Number;
		public var security:Number;

		private var _factionPrototype:IPrototype;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			var protoModel:PrototypeModel = PrototypeModel.instance;
			var assetModel:AssetModel     = AssetModel.instance;

			factionPrototype = protoModel.getFactionPrototypeByName(input.readUTF());
			baseID = input.readUTF();
			reputation = input.readInt64();

			offerExpires = input.readInt64();
			contractPrototype = protoModel.getContractPrototypeByName(input.readUTF());
			productivity = input.readDouble();
			payout = input.readDouble();
			duration = input.readDouble();
			frequency = input.readDouble();
			security = input.readDouble();
			reputationWhenBegun = input.readInt64();
			began = input.readInt64();
			end = input.readInt64();
			/* buildState */
			input.readInt();

			bribe = input.readDouble();
			// extension
			input.readDouble();
			// efficiency
			input.readDouble();

			offerRejected = input.readBoolean();

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in TradeRouteData is not supported");
		}

		public function get corporation():String  { return _factionPrototype.name; }

		public function get factionPrototype():IPrototype  { return _factionPrototype; }
		public function set factionPrototype( v:IPrototype ):void
		{
			_factionPrototype = v;
			var currentAssetVO:AssetVO = AssetModel.instance.getEntityData(factionPrototype.getValue('uiAsset'));
			name = currentAssetVO.visibleName;
		}

		public function destroy():void
		{
			contractPrototype = null;
			factionPrototype = null;
		}
	}
}
