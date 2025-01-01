package com.controller.transaction.requirements
{
	public interface IRequirement
	{
		function get showIfMet():Boolean;
		function get isMet():Boolean;
		function toHtml():String;
		function get hasLink():Boolean;
		function destroy():void;
	}
}
