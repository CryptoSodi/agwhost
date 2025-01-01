package com.presenter
{
	import org.robotlegs.extensions.presenter.api.IPresenter;

	public interface IImperiumPresenter extends IPresenter
	{
		function playSound( sound:String, volume:Number = 0.5 ):void;

		function addStateListener( callback:Function ):Boolean;
		function removeStateListener( callback:Function ):Boolean;

		function get hudEnabled():Boolean;
		function set hudEnabled( value:Boolean ):void;

		function get inFTE():Boolean;
	}
}
