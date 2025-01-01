package com.model.prototype
{
	public interface IPrototype
	{
		function getValue( key:String ):*;
		function getUnsafeValue( key:String ):*;

		function get asset():String;
		function get uiAsset():String;

		function get name():String;
		function get itemClass():String;
		function get buildTimeSeconds():uint;

		function get alloyCost():int;
		function get creditsCost():int;
		function get energyCost():int;
		function get syntheticCost():int;
	}
}
