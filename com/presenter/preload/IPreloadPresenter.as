
package com.presenter.preload
{
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;

	import org.osflash.signals.Signal;

	public interface IPreloadPresenter extends IImperiumPresenter
	{
		function trackPlayerProgress( id:int ):void;
		function beginLoad():void;

		function transitionToLoad():void;
		function sendCharacterToServer( factionPrototype:String, racePrototype:String ):void;
		function getRacePrototypesByFaction( faction:String, race:String ):Vector.<IPrototype>;
		function getRacePrototypeByName( race:String ):IPrototype;
		function getFirstNameOptions( race:String, gender:String ):Vector.<IPrototype>;
		function getLastNameOptions( race:String, gender:String ):Vector.<IPrototype>;
		function getAudioProtos():Vector.<IPrototype>;
		function getEntityData( type:String ):AssetVO;

		function loadPortraitIcon( portraitName:String, callback:Function ):void;
		function loadPortraitLarge( portraitName:String, callback:Function ):void;

		function addLoadCompleteListener( callback:Function ):void;
		function removeLoadCompleteListener( callback:Function ):void;

		function get beginSignal():Signal;
		function get completeSignal():Signal;
		function get progressSignal():Signal;
	}
}
