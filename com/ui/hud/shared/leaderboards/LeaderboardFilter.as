package com.ui.hud.shared.leaderboards
{
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;

	public class LeaderboardFilter extends Sprite
	{
		private var _text:Label;

		public function LeaderboardFilter( fontSize:Number = 12, color:uint = 0, maxWidth:Number = 100, maxHeight:Number = 20, useLocalization:Boolean = true, fontNr:int = 0 )
		{
			_text = new Label(fontSize, color, maxWidth, maxHeight, useLocalization, fontNr);
			addChild(_text);
		}

		public function set align( type:String ):void
		{
			_text.align = type;
		}

		public function set autoSize( autoSize:String ):void
		{
			_text.autoSize = autoSize;
		}

		public function set multiline( multiline:Boolean ):void
		{
			_text.multiline = multiline;
		}

		public function set text( value:String ):void
		{
			_text.text = value;
		}

		public function set htmlText( value:String ):void
		{
			_text.htmlText = value;
		}

		public function setTextWithTokens( value:String, tokens:Object ):void
		{
			_text.setTextWithTokens(value, tokens);
		}

		public function setHtmlTextWithTokens( value:String, tokens:Object ):void
		{
			_text.setHtmlTextWithTokens(value, tokens);
		}

		public function set textColor( v:uint ):void
		{
			_text.textColor = v;
		}

		public function set constrictTextToSize( v:Boolean ):void
		{
			_text.constrictTextToSize = v;
		}

		public function destroy():void
		{
			_text.destroy();
			_text = null;
		}
	}
}
