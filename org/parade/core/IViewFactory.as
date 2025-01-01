package org.parade.core
{
	public interface IViewFactory
	{
		function createView( targetClass:Class ):IView;

		function createAlert( alertTitle:String, alertBody:String, btnOneText:String, btnOneCallback:Function, btnOneArgs:Array, btnTwoText:String, btnTwoCallback:Function, btnTwoArgs:Array, onCloseUseBtnTwo:Boolean =
							  false, maxCharacters:int = 12, defaultInputText:String = '', clearInputOnFocus:Boolean = false, restrict:String = '', shouldNotify:Boolean = true, view:Class = null ):IView

		function notify( view:IView ):void;
		
		function openPayment():void;

		function destroyView( targetView:IView ):void;
	}
}
