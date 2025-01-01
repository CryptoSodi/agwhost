package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;
	
	import com.model.battle.BattleModel;
	
	import org.ash.core.Entity;

	public interface IGamePresenter extends IImperiumPresenter
	{
		function confirmReady():void;

		function cleanup():void;

		function loadBackground(battleModel:BattleModel, useModelData:Boolean = false):void;

		function addCleanupListener( callback:Function ):void;
		function removeCleanupListener( callback:Function ):void;

		function getEntity( id:String ):Entity;
		function getAssetVO( prototype:IPrototype ):AssetVO;
		function getAssetVOByName( name:String ):AssetVO;
	}
}
