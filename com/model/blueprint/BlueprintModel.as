package com.model.blueprint
{
	import com.enum.ToastEnum;
	import com.event.ToastEvent;
	import com.model.Model;
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;
	import com.service.server.incoming.data.BlueprintData;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class BlueprintModel extends Model
	{
		private var _ownedBlueprints:Dictionary   = new Dictionary();

		private var _blueprintCompleteText:String = 'CodeString.Toast.BlueprintComplete'; //Blueprint Complete!
		private var _blueprintPartText:String     = 'CodeString.Toast.BlueprintPartGained'; //Parts Collected:  [[Number.partsCollected]]/[[Number.partsTotal]]

		public function importPlayerBlueprints( blueprintData:BlueprintData, displayIfNotInList:Boolean = false ):void
		{
			var blueprintVO:BlueprintVO = ObjectPool.get(BlueprintVO);
			blueprintVO.init(blueprintData.id);
			blueprintVO.importData(blueprintData);

			if (blueprintVO.name in _ownedBlueprints)
			{
				var currentBlueprint:BlueprintVO = _ownedBlueprints[blueprintVO.name];
				if (currentBlueprint.partsRemaining != blueprintVO.partsRemaining)
					popToast(blueprintVO);
			} else if (blueprintVO.partsCollected >= blueprintVO.totalParts && displayIfNotInList)
				popToast(blueprintVO);

			_ownedBlueprints[blueprintVO.name] = blueprintVO;
		}

		public function getBlueprintByName( name:String ):BlueprintVO
		{
			if (name in _ownedBlueprints)
				return _ownedBlueprints[name]

			return null;
		}
		
		public function getBlueprintByUIName( name:String ):BlueprintVO
		{
			for each (var vo:BlueprintVO in _ownedBlueprints)
			{
				var bpPrototype:IPrototype = vo.prototype;
				if(bpPrototype.getValue('uiAsset') == name)
				{
					return vo;
				}
			}				
			
			return null;
		}

		public function getBlueprintByID( id:String ):BlueprintVO
		{
			for each (var vo:BlueprintVO in _ownedBlueprints)
			{
				if (vo.id == id)
					return vo;
			}

			return null;
		}

		public function removeBlueprintByName( name:String ):void
		{
			if (name in _ownedBlueprints)
				delete _ownedBlueprints[name];
		}

		public function get ownedBlueprints():Dictionary  { return _ownedBlueprints; }

		private function popToast( blueprint:BlueprintVO ):void
		{
			var text:String;
			if (blueprint.complete)
				text = Localization.instance.getString(_blueprintCompleteText);
			else
				text = Localization.instance.getStringWithTokens(_blueprintPartText, {'[[Number.partsCollected]]':blueprint.partsCollected, '[[Number.partsTotal]]':blueprint.totalParts});

			var toastEvent:ToastEvent = new ToastEvent();
			toastEvent.toastType = ToastEnum.BLUEPRINT;
			toastEvent.prototype = blueprint;
			if (text != '')
				toastEvent.addStringsFromArray([text]);
			dispatch(toastEvent);
		}
	}
}
